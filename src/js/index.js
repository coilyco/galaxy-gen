import React from "react";
import * as ReactDOM from "react-dom/client";
import * as application from "./lib/application";
import { initCrashReporting, onUncaughtError } from "./lib/crash";

// Baked in at build time from SENTRY_DSN; empty leaves Sentry off.
initCrashReporting(process.env.SENTRY_DSN);

ReactDOM.createRoot(document.getElementById("root"), { onUncaughtError }).render(
  <application.Interface />
);
