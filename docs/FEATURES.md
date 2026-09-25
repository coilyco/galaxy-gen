# galaxy-gen feature inventory

What ships. Pairs with [README.md](../README.md) (pitch),
[AGENTS.md](../AGENTS.md) (agent rules), and [development.md](development.md). The full pre-trim inventory is
[FEATURES](../.agents/skills/coding-galaxy-gen-internals/references/FEATURES.md).

## Simulation core (`src/rust/galaxy.rs`)

- Cell-grid N-body sim on a flat struct-of-arrays grid, O(N squared / 2) pair
  sweep, no `sqrt` in the hot path. See [galaxy-rust.md](galaxy-rust.md).
- Reproducible seeding, so the same `(additional, seed)` gives byte-identical
  galaxies. See [scenarios.md](scenarios.md).
- Four scenarios: `bang => ring`, `bang => spiral`, `irregular => spiral`,
  `irregular => elliptical`. See [morphology.md](morphology.md).

## Living-galaxy loop (`process.rs`, `events.rs`, `stars.rs`)

- Process registry, deterministic event queue, and per-(process, tick) RNG
  streams. See [processes-events.md](processes-events.md).
- Galactic fountain, conserved baryon and metal ledgers, and stellar lifecycles
  through supernovae and mergers. See [stellar-evolution.md](stellar-evolution.md).
- Temporary bound associations and a bounded resolved population. See
  [stellar-population.md](stellar-population.md).
- Central black hole with bipolar quasar episodes. See [black-hole.md](black-hole.md).

## Frontend

- `Frontend` wraps the WASM `Galaxy` with a `"cpu" | "webgpu"` backend, physics
  in a worker, and a WGSL direct-sum kernel with CPU fallback.
- Controls, URL round-trip, and the chrome toggle. See [ui-controls.md](ui-controls.md).
- Layered canvas renderer with age-keyed stars and a lens post-process. See
  [rendering.md](rendering.md) and [starfield.md](starfield.md).
- Client-side GIF and MP4 capture. See [recording.md](recording.md).

## Build, test, deploy

- `wasm-pack`, webpack 5, Babel, Tailwind v4, ESLint, Prettier, clippy, and
  `cargo fmt`. Perf history in [performance.md](performance.md).
- `debug-sim` probe and `ablation-sweep`. See [ablation.md](ablation.md).
- Served on k3s at `galaxy-gen.coilysiren.me` by unprivileged nginx, from a sha-tagged image.
