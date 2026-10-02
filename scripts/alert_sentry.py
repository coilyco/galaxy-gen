#!/usr/bin/env python3
"""Report a CI or CD failure to Sentry as one error event. Stdlib only.

One HTTPS POST to the ingest host the DSN names, for any runner. The caller passes
SENTRY_DSN, and a missing or malformed one fails the step loudly. Other fields fall
back to the runner's GITHUB_* variables. A host watcher sets ALERT_SOURCE and
ALERT_MESSAGE for a generic event. Every event carries alert=true. Contract and
rollout: docs/watchers-and-health.md in coilyco/infrastructure.
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from typing import Any

# GITHUB_SERVER_URL is the cluster-local name the runner registered against, so
# a link built from it is unreachable from a phone. This is the forge ROOT_URL.
DEFAULT_FORGE_URL = "https://forgejo.coilysiren.me"

# Sentry caps a tag value at 200 characters and drops the event on a longer one.
TAG_LIMIT = 200
LEVELS = ("fatal", "error", "warning", "info", "debug")


def now() -> str:
    """RFC 3339 UTC. Built from time, not datetime.UTC, which needs Python 3.11."""
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


def field(name: str, *runner_vars: str) -> str:
    """An explicit override, else the runner's own value, else a visible gap.

    A missing field must never cost the alert. "workflow: ?" still says
    something broke.
    """
    for var in (name, *runner_vars):
        value = os.environ.get(var, "").strip()
        if value:
            return value
    return "?"


def run_url() -> str:
    explicit = os.environ.get("RUN_URL", "").strip()
    if explicit:
        return explicit
    base = os.environ.get("FORGE_URL", "").strip() or DEFAULT_FORGE_URL
    repo = os.environ.get("REPO", "") or os.environ.get("GITHUB_REPOSITORY", "")
    run_id = os.environ.get("GITHUB_RUN_ID", "")
    if not (repo and run_id):
        return "?"
    return f"{base.rstrip('/')}/{repo}/actions/runs/{run_id}"


def parse_dsn(dsn: str) -> str:
    """The envelope endpoint a DSN names.

    Raises ValueError without echoing the DSN, which carries the project key.
    """
    parts = urllib.parse.urlsplit(dsn)
    host = parts.hostname or ""
    path = parts.path.rstrip("/")
    prefix, _, project = path.rpartition("/")
    valid = parts.scheme in ("http", "https") and parts.username and host
    if not (valid and project):
        raise ValueError("malformed DSN")
    netloc = host + (f":{parts.port}" if parts.port else "")
    return f"{parts.scheme}://{netloc}{prefix}/api/{project}/envelope/"


def csv(name: str) -> list[str]:
    parts = os.environ.get(name, "").split(",")
    return [part.strip() for part in parts if part.strip()]


def clipped(tags: dict[str, str]) -> dict[str, str]:
    return {key: value[:TAG_LIMIT] for key, value in tags.items()}


def base_event(
    message: str,
    fingerprint: list[str],
    tags: dict[str, str],
) -> dict[str, Any]:
    level = os.environ.get("ALERT_LEVEL", "").strip()
    return {
        "event_id": uuid.uuid4().hex,
        "timestamp": now(),
        "platform": "other",
        "level": level if level in LEVELS else "error",
        "logger": "ci-alert",
        "logentry": {"formatted": message},
        "fingerprint": fingerprint,
        "tags": clipped({"alert": "true", **tags}),
    }


def build_ci_event() -> dict[str, Any]:
    repo = field("REPO", "GITHUB_REPOSITORY")
    workflow = field("WORKFLOW", "GITHUB_WORKFLOW")
    kind = os.environ.get("ALERT_KIND", "").strip() or "CI"
    url = run_url()
    event = base_event(
        f"{repo} {kind} failing\nworkflow: {workflow}\nrun: {url}",
        # One issue per repo, workflow and kind, so a repeat failure joins the
        # open issue instead of opening a new one each run.
        [repo, workflow, kind],
        {
            "source": "ci",
            "ci": "true",
            "repo": repo,
            "workflow": workflow,
            "kind": kind,
        },
    )
    event["environment"] = "ci"
    event["extra"] = {
        "run_url": url,
        "job": field("JOB", "GITHUB_JOB"),
        "ref": field("REF", "GITHUB_REF"),
        "sha": field("SHA", "GITHUB_SHA"),
    }
    return event


def build_generic_event(source: str) -> dict[str, Any]:
    message = os.environ.get("ALERT_MESSAGE", "").strip() or f"{source} alert"
    # A malformed pair is dropped rather than raising: a partial alert beats none.
    pairs = (item.partition("=") for item in csv("ALERT_TAGS"))
    tags = {}
    for key, sep, value in pairs:
        if sep and key.strip():
            tags[key.strip()] = value.strip()
    event = base_event(
        message,
        csv("ALERT_FINGERPRINT") or [source, message.splitlines()[0]],
        {**tags, "source": source},
    )
    event["environment"] = os.environ.get("ALERT_ENVIRONMENT", "").strip() or "host"
    return event


def build_event() -> dict[str, Any]:
    """The CI event by default, or the generic one when ALERT_SOURCE names a source."""
    source = os.environ.get("ALERT_SOURCE", "").strip()
    return build_generic_event(source) if source else build_ci_event()


def build_envelope(event: dict[str, Any], dsn: str) -> bytes:
    """One event as a Sentry envelope, authenticated by the `dsn` header."""
    payload = json.dumps(event).encode("utf-8")
    header = {
        "event_id": event["event_id"],
        "dsn": dsn,
        "sent_at": now(),
    }
    item = {"type": "event", "length": len(payload)}
    return (
        b"\n".join(
            [
                json.dumps(header).encode("utf-8"),
                json.dumps(item).encode("utf-8"),
                payload,
            ]
        )
        + b"\n"
    )


def main() -> int:
    dsn = os.environ.get("SENTRY_DSN", "").strip()
    if not dsn:
        print("alert failed: SENTRY_DSN is not set", file=sys.stderr)
        return 1
    try:
        endpoint = parse_dsn(dsn)
    except ValueError:
        print("alert failed: SENTRY_DSN is not a valid DSN", file=sys.stderr)
        return 1
    event = build_event()
    request = urllib.request.Request(
        endpoint,
        data=build_envelope(event, dsn),
        headers={"Content-Type": "application/x-sentry-envelope"},
        method="POST",
    )
    # The ingest host is external, so the ambient egress proxy is the right path.
    # Nothing below prints the request: its URL and body both carry the project key.
    try:
        with urllib.request.build_opener().open(request, timeout=15) as response:
            print(f"alert posted: {response.status} event {event['event_id']}")
    except urllib.error.HTTPError as exc:
        retry = exc.headers.get("Retry-After")
        suffix = f" retry-after {retry}" if retry else ""
        print(f"alert rejected: HTTP {exc.code}{suffix}", file=sys.stderr)
        return 1
    except OSError as exc:
        print(f"alert failed ({type(exc).__name__})", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
