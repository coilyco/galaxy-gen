# Processes, events, and the causal loop

The process registry defines causality, struct-of-arrays store state,
processes perform bulk transformations, events represent discrete changes, and
rendering derives appearance from the resulting world.

- **Registry** (`src/rust/process.rs`). Static descriptors with reads, writes,
  `requires_fresh`, cadence, and phase offset. Registry order IS the causal
  chain, so changing it is a physics change. Unit tests check fresh reads have
  an earlier writer and pin the order to a golden list.
- **Order.** gravity, spiral and ring density waves, gas_pressure,
  quasar_feedback, gravity_field, integrate_gas, integrate_stars,
  radiation_field, collapse_watch, stellar_halo, stellar_aging, bh_accretion,
  bh_evaporation, gas_dissipation, gas_fountain. Motion every tick, fields
  every 4, lifecycle every 8-16.
- **Events** (`src/rust/events.rs`). An event emitted on tick N runs on N+1, in
  stable (tick, seq) order, with a causal parent id. Renderer transients read
  executed events and are never authoritative state.
- **RNG.** One u64 master seed. Streams derive per (process id, tick) through
  splitmix64, so adding a process never shifts another's draws.
- **Determinism.** Same seed, tick count, and dt sequence give identical state.
  Golden-hash tests pin every scenario's mass field after 100 ticks.
- **The loop.** Gas clumps, density waves gather it, dense cool cells collapse
  into stellar associations, radiation resists the next collapse and lifts hot
  gas to the halo, the fountain cools it back, stars age, and supernovae return
  gas and shock nearby cells. The black-hole branch is in
  [black-hole.md](black-hole.md).
- **Lifecycle chains.** Associations bind and release by persisted
  `cluster_id`. Compact binaries merge into a `GammaRayBurst`. Intermediate
  pairs end as a Type Ia. Stars that stay beyond 1.18 disk radii phase-mix into
  `stellar_halo_mass`.
- **Ledgers.** Baryon mass across every carrier stays constant to sub-1.0, and
  a second ledger tracks heavy elements plus explicit yields.

Detail, verbatim:

- [processes-events](../.agents/skills/coding-galaxy-gen-internals/references/processes-events.md)
- [causal-loop](../.agents/skills/coding-galaxy-gen-internals/references/causal-loop.md)
- [lifecycle-chains](../.agents/skills/coding-galaxy-gen-internals/references/lifecycle-chains.md)
