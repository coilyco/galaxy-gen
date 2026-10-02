#!/usr/bin/env bash
# Runner egress goes through FORGEJO_EGRESS_PROXY; the nested DinD path has no
# direct route out. Forgejo itself must stay off the proxy or the checkout
# deadlocks against its own ingress.
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "usage: ci-command.sh <command> [args...]" >&2
  exit 2
fi

HTTP_PROXY="${FORGEJO_EGRESS_PROXY:-}"
HTTPS_PROXY="$HTTP_PROXY"
NO_PROXY="forgejo.coilysiren.me,forgejo.forgejo.svc.cluster.local"
no_proxy="$NO_PROXY"
export HTTP_PROXY HTTPS_PROXY NO_PROXY no_proxy

exec "$@"
