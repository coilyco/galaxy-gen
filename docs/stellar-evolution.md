# Stellar evolution and chemical enrichment

Two deterministic post-main-sequence channels, plus a heavy-element ledger that
rides along with every baryonic carrier.

- **Massive channel.** Core collapse leaves neutron stars. Compact binary
  partners merge and emit a short gamma-ray burst.
- **Quiet channel.** A lower-mass star becomes a red giant, emits a
  `PlanetaryNebula` returning most of its envelope to nearby gas, and leaves a
  white dwarf that eventually phase-mixes into the diffuse halo.
- **Delayed thermonuclear channel.** Intermediate-mass draws split into close
  binaries. Once both white dwarfs pass a seed-derived delay, a
  `TypeIaSupernova` disrupts them, returns their mass, emits a linked shock,
  and converts up to 35% of the binary mass into heavy elements.
- **Metal carriers.** Every gas cell, resolved star, hot halo, diffuse halo,
  black hole, radiated sink, and pending `StarBirth` carries heavy-element mass.
  Every transfer keeps the source metallicity.
- **Production.** Core collapse synthesizes 2% of progenitor mass, Type Ia up
  to 35%, recorded in `metal_produced_total`. Tests enforce tracked metals =
  seeded + produced, and 0 <= carrier metals <= carrier mass.
- **Presentation.** Red giants render large and warm, white dwarfs compact and
  blue-white, planetary nebulae as slow cyan and pink shells, Type Ia as a
  bright blue-white front. Dust lanes need enough metals, and [OIII] emission
  scales with local abundance.
- **State.** Every stage, binary id, delay, counter, and composition array
  survives the worker round-trip.

Detail, verbatim:

- [stellar-evolution](../.agents/skills/coding-galaxy-gen-internals/references/stellar-evolution.md)
- [chemical-enrichment](../.agents/skills/coding-galaxy-gen-internals/references/chemical-enrichment.md)
