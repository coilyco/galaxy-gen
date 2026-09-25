# Stars, associations, and the population

How stars are stored, born, grouped, and retired.

- **Storage** (`src/rust/stars.rs`). Struct-of-arrays with continuous f32
  positions, stable u32 ids, binary ids, lifecycle stages, and halo-dwell
  counters. Stars are collisionless and sample a coarse 64x64 field rebuilt
  every 4 ticks, so integration stays O(N).
- **IMF.** Salpeter-flavored `m^-2.35` over masses 3-120. Luminosity is roughly
  `m^2` and lifetime `900 x (30/m)^2`. `class_index` is sim state only, since the
  renderer keys color on `age`.
- **Associations.** A birth within 3.2 cells of a young member joins its
  `cluster_id`, else it allocates a new one. The batch gets one shared orbit:
  12% of radial gas motion survives, prograde motion stays, and an azimuthal
  field average plus a halo and black-hole floor supplies support.
- **Binding.** A softened pull toward each association center, with the mean
  acceleration subtracted so binding cannot move the center of mass. Groups
  under three members dissolve, binding ends at age 620, and after a 56-tick
  grace a tidal radius releases exterior members. Release clears
  `cluster_id` only, so released stars stream on their exact orbits.
- **Rendering.** Newborns start embedded and smoothstep into view between age
  12 and 72. Bound groups of four or more get one low-alpha glow.
- **Resolved-luminosity floor.** An unbound main-sequence star below
  `RESOLVED_LUMINOSITY_FLOOR` retires into the diffuse halo. It is the
  population's only real sink: 23-30k with it, 123-131k without
  (galaxy-gen#72). Association members are exempt.
- **Dragon: the elliptical's spheroid IS the faint population.** The disk floor
  deletes it, and no metric catches that. The elliptical uses zero until its
  retired light is rendered (galaxy-gen#72, blind spot galaxy-gen#7051).

Related: [morphology.md](morphology.md) for elliptical relaxation,
[stellar-evolution.md](stellar-evolution.md) for the death channels.

Detail, verbatim:

- [stellar-model](../.agents/skills/coding-galaxy-gen-internals/references/stellar-model.md)
- [stellar-population](../.agents/skills/coding-galaxy-gen-internals/references/stellar-population.md)
- [stellar-associations](../.agents/skills/coding-galaxy-gen-internals/references/stellar-associations.md)
