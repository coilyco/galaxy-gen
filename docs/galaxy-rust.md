# Galaxy simulation internals and the tick worker

Cell grid with Newtonian gravity and an in-place tick, run off the main thread
by a Web Worker that owns its own WASM `Galaxy`.

- **Layout.** Struct-of-arrays (parallel `Vec<f32>` and `Vec<u16>`) so the inner
  loop auto-vectorizes. Acceleration accumulates in cartesian, since the old
  polar form spent four trig calls per pair.
- **Hot path.** `gravitate_all()` is a symmetric O(N squared / 2) pair sweep
  that skips empty cells. `apply_acceleration()` integrates, reassigns cells,
  and coalesces mass through a `Vec<u32>` rather than a `HashMap`. `tick`
  returns a new `Galaxy` but reuses scratch buffers internally.
- **Buffers.** Persistent `vel_x` and `vel_y`, or motion restarts from rest each
  tick. `frac_x` and `frac_y` keep sub-grid offsets so clouds move smoothly.
  Integer `xs_i` and `ys_i` index a precomputed `inv_r3` table by r squared, so
  the hot loop has no `sqrt`.
- **Worker in.** `init` hydrates from transferred state, `start` loops at up to
  20 ticks/s, `setTimeModifier` updates dt live, `stop` halts and replies.
- **Worker out.** `snapshot` carries gas mass, offsets, metallicity, star render
  packing, transients, the radiation field, and counters, with typed arrays
  transferred. `stopped` returns the opaque buffers for a byte-exact
  round-trip, guarded by a unit test.
- **Flat layouts are a serialization contract.** Stars are 15 f32 per star,
  star render packing is 7 f32, and events are a u32 header plus 12 u32 per
  pending event. Changing field order breaks the round-trip test. Integer ids
  survive f32 because live ids stay far below 2^24.

Related: [sim-constants.md](sim-constants.md),
[processes-events.md](processes-events.md), [integrator.md](integrator.md).

Detail, verbatim, with every field order:

- [galaxy-rust](../.agents/skills/coding-galaxy-gen-internals/references/galaxy-rust.md)
- [tick-worker](../.agents/skills/coding-galaxy-gen-internals/references/tick-worker.md)
