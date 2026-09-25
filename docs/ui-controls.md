# UI controls and URL state

The React shell in `src/js/lib/application.tsx`. Plain `useState`, no store.

- **Layout.** On desktop the panel floats over a full-bleed canvas. On mobile
  the canvas sits above a horizontal control bar, so chrome never covers the
  sim.
- **Controls.** Galaxy size (default 500), scenario, generate, play-pause,
  reset, and record. Seed mass and dt are fixed constants. Star color is not a
  control, since the resolved layer is always keyed by age.
- **Reset vs generate.** Reset rebuilds the current seed at tick zero and drops
  the spent `t`. Generate rolls a fresh universe unless `lock=1` pins the seed.
- **Default view vs debug.** The default view shows only the sim tick as a
  caption, the one number `?t=` makes actionable. The counter table, tick-ms,
  FPS, single-step, and camera sit behind `?debug=1`.
- **Chrome toggle.** Hides the panel and mirrors to `?ui=0`, so a clean frame is
  shareable. It rests near-invisible and wakes on pointer movement, so the
  hidden state is never a trap. There is no keyboard surface.
- **URL round-trip.** `?seed=&size=&scenario=&lock=&t=&ui=&debug=` through
  `history.replaceState`. A URL seed is honored for the first generate.
- **Addressable moments.** Pausing or stepping stamps `t` into the URL, and a
  seed+t link auto-generates and fast-forwards to that tick. Determinism
  guarantees the identical frame.
- **Seeds are u64.** `crypto.getRandomValues` for a fresh one, `BigInt` to paste
  and validate.
- **Test contract.** A `data-wasm-ready` gate marks readiness, and every
  E2E-touched element carries a load-bearing `data-testid`.

Related: [rendering.md](rendering.md), [recording.md](recording.md).

Verbatim original:
[ui-controls](../.agents/skills/coding-galaxy-gen-internals/references/ui-controls.md).
