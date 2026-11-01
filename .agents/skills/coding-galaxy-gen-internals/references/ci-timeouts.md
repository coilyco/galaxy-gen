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
