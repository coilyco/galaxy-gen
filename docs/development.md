# Development

- **Rust** (`src/rust/`). `lib.rs` re-exports `galaxy`. `galaxy.rs` holds the
  struct-of-arrays gas grid, physics, lifecycle, seeding, and tick, exposed to
  JS through `wasm-bindgen`. Methods like `seed()` and `tick()` return new
  Galaxy instances.
- **WASM bridge.** `wasm-pack` builds into `pkg/` (gitignored), which
  package.json references as `"galaxy_gen_backend": "file:pkg"`.
- **JS** (`src/js/`). `index.html` shell, `index.js` React entry,
  `lib/galaxy.ts` wraps the WASM Galaxy and its worker snapshots,
  `lib/application.tsx` is the UI, `lib/dataviz.tsx` the layered canvas, and
  `lib/styles.css` the Tailwind theme.
- **Build.** `cargo build` and `cargo test`, `wasm-pack build`, webpack 5 with
  babel and `webpack-dev-server`. The justfile carries the multi-step flows.
- **CI.** Forgejo runs the Rust and JS gates inside the dev-base image through
  `just` verbs (`ci.yml` on PRs, `build-publish.yml` on `main`). Those jobs
  carry a 10m timeout because wasm-pack's wasm-bindgen download can stall until
  the 30m runner budget and report `cancelled`. Healthy runs take under 5m, and
  the download is galaxy-gen#89. GitHub Actions keeps browser e2e (galaxy-gen#74).

```bash
just install
just dev
just test
just build-js-prod
```

- **README animation.** Start the dev server, run `just capture-readme` (set
  `GALAXY_CAPTURE_URL` off port 8081), inspect the candidate, then
  `just promote-readme`. Capture never overwrites an earlier candidate or the
  tracked GIF.
- **Conventions.** `wasm_bindgen` only at the public boundary. State is parallel
  flat arrays indexed `row * size + col`. Physics accumulates cartesian
  acceleration and keeps fractional gas positions. Tests live in `mod tests_*`
  at the bottom of `galaxy.rs`. Frontend state is React `useState` only.
- **Dependencies.** Rust: `wasm-bindgen`, `rand`, `console_error_panic_hook`.
  JS: React, TypeScript, webpack, Tailwind, Playwright.

Verbatim originals: [development](../.agents/skills/coding-galaxy-gen-internals/references/development.md),
[ci-timeouts](../.agents/skills/coding-galaxy-gen-internals/references/ci-timeouts.md).
