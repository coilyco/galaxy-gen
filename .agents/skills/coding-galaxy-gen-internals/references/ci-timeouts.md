# CI job timeouts

Verbatim header formerly at the top of the Forgejo `build-publish.yml` and `ci.yml`
(now `.github/workflows/ci.yml`), moved here when the code-comments hook capped
file headers at two lines. The hosted job timeout is 20m, since it also installs
wasm-pack (the pinned release, `scripts/ci/install-wasm-pack.sh`).

```text
# `just ci-setup` runs `wasm-pack build`, and wasm-pack downloads the
# wasm-bindgen CLI at that step because dev-base does not ship one. When that
# fetch stalls the job has no timeout of its own, so it sits until the runner's
# 30m budget is gone and reports `cancelled` rather than a failure. Six runs
# died at the identical `Installing wasm-bindgen...` line: 157, 158, 159, 160,
# 163, 164. A healthy run finishes in under 5m (1m51s and 4m03s observed), so
# 10m fails a stall fast and legibly while leaving real headroom.
#
# This bounds the symptom. The download itself is galaxy-gen#89.
```

## Node is pinned to 24, and the e2e job has a 20m timeout (COI-3445)

`node-version: lts/*` floated. On 2026-11-01 it resolved to Node 24.22.1 and the
e2e job's `npx playwright install --with-deps chromium` took seconds. By
2026-11-04 it resolved to Node 26.13.0, and the same step, with the same
Playwright 1.59.1, Chrome 147.0.7727.15 build 1217 and runner image
(ubuntu-24.04 20261025.353.1), logged the Chrome download at 100% and then
never returned. Runs 41898681002, 41926646635 and 41943787025 sat there until
cancelled. A healthy e2e job finishes in about 8m, so 20m fails a stall fast.

Pinning bounds the symptom on the version that worked. Moving to Node 26 is a
deliberate change that has to show the Playwright install completing first.
