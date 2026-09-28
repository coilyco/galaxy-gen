// Sentry for crashes only (teable:coilyco/deploy#8347): uncaught errors and
// render crashes, fully annotated, with user-data keys scrubbed.
import * as Sentry from "@sentry/react";
import type { Breadcrumb, ErrorEvent } from "@sentry/react";

const EVENTS_PER_MINUTE = 20;
const SCRUBBED = "[Filtered]";

// Names that hold what a visitor typed or chose, rather than what the app did.
export const USER_DATA_KEYS = new Set([
  "value",
  "input",
  "text",
  "query",
  "search",
  "email",
  "password",
  "token",
  "authorization",
  "cookie",
]);

const sent: number[] = [];

export function withinBudget(now: number): boolean {
  while (sent.length > 0 && sent[0] < now - 60_000) sent.shift();
  if (sent.length >= EVENTS_PER_MINUTE) return false;
  sent.push(now);
  return true;
}

export function scrub(value: unknown, depth = 0): unknown {
  if (depth > 8 || value === null || typeof value !== "object") return value;
  if (Array.isArray(value)) return value.map((item) => scrub(item, depth + 1));
  const out: Record<string, unknown> = {};
  for (const [key, item] of Object.entries(value as Record<string, unknown>)) {
    out[key] = USER_DATA_KEYS.has(key.toLowerCase()) ? SCRUBBED : scrub(item, depth + 1);
  }
  return out;
}

// Only the parts that can carry user data are scrubbed, so the exception stays readable.
export function beforeSend(event: ErrorEvent): ErrorEvent | null {
  if (!withinBudget(Date.now())) return null;
  if (event.request) event.request = scrub(event.request) as ErrorEvent["request"];
  if (event.extra) event.extra = scrub(event.extra) as ErrorEvent["extra"];
  if (event.contexts) event.contexts = scrub(event.contexts) as ErrorEvent["contexts"];
  if (event.breadcrumbs) event.breadcrumbs = event.breadcrumbs.map(beforeBreadcrumb);
  return event;
}

export function beforeBreadcrumb(crumb: Breadcrumb): Breadcrumb {
  return crumb.data ? { ...crumb, data: scrub(crumb.data) as Breadcrumb["data"] } : crumb;
}

export function initCrashReporting(dsn: string): boolean {
  if (!dsn) return false;
  try {
    // Default integrations stay on for annotation. None of them turns a handled
    // error or a console line into an event, and no tracing or replay is added.
    Sentry.init({
      dsn,
      sendDefaultPii: false,
      tracesSampleRate: 0,
      beforeSend,
      beforeBreadcrumb,
    });
    return true;
  } catch (error) {
    // The name only: a DSN parse error can carry the DSN.
    console.warn(`Sentry initialization failed (${(error as Error).name}); continuing`);
    return false;
  }
}

// React 19 root hook for render crashes. Errors a boundary catches are handled.
export const onUncaughtError = Sentry.reactErrorHandler();
