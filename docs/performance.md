# Performance

The inner loop went from under 1 FPS to about 18 FPS at 250x250, roughly 55x,
then the default rose to 500x500. The full journal is load-bearing for the
inner loop, so read it before changing the tick or the render path.

- **Part one, the ~55x rewrite.** Eight levers, each with observation, insight,
  diff, and measurement:
  - strip the unused `specs` ECS
  - struct-of-arrays instead of `Vec<Cell>`
  - an integer r squared lookup table that kills `sqrt`
  - the pair-symmetry trap, reverted
  - velocity integration with sub-grid fractions
  - SVG to canvas, the hidden bottleneck
  - a Barnes-Hut quadtree for large N
  - reusable scratch buffers, a zero-ish-copy WASM boundary, and benches
- **Part two, raising the default to 500x500.** Gas as screen-space blocks, the
  lens off a framebuffer readback, star discs batched by quantized color and
  alpha, allocation churn removed. The coda explains why the tick cap sets the
  render rate, and why 250 janks when 500 does not.
- **Part three, the traversal node.** The profiler could not see the regime
  that ships until it was fixed. A 24-byte traversal node replaced the old
  leaf-flag pass.
- **Part four, two frame rates with one name.** The opening is worker-bound, and
  the cap is a paint-rate cap that headroom does not help. Believe `paintHz`.
- **Benches.** `benches/tick_bench.rs`, `benches/perf_profile.rs`,
  `e2e/perf.spec.ts`, `e2e/render-perf.spec.ts`, and `e2e/runtime-perf.spec.ts`,
  driven by `just perf-profile` and `just test-perf`.

Full journal, verbatim, with every table and diff:
[perf-rewrite](../.agents/skills/coding-galaxy-gen-internals/references/perf-rewrite.md).
