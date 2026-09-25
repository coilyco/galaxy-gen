# Scenarios and seeding

A scenario is a hardcoded `start => end-shape` pair plus the physics constants
that steer the run toward it. Noise only textures a scenario, and the shape
drivers are deterministic, so the end shape is sturdy across seeds.

- **`BangRing`.** A central explosion with symmetric ejection settles into an
  annular potential near 0.58 disk_r, with annulus-scoped collapse.
- **`BangSpiral`.** An m=2 lobed ejection tilted 0.6 rad prograde
  (`eject_swirl`). A rotating logarithmic wave gathers it into arms between
  about ticks 500 and 1000.
- **`IrregularSpiral`.** Domain-warped smoke noise with a seeded two-arm
  overdensity, settling into long-lived arms later than the bang start.
- **`IrregularElliptical`.** Smoke noise under an exponential envelope, weak
  rotation, high dispersion, and a whisper of `star_drag` so the young swarm
  settles instead of evaporating.
- **Smoke seeder.** Three fBm stacks (density plus two warps) of four octaves.
  The field is stretched about a slightly dark center and then shaped by a
  power law, and the order matters.
- **Fixed gas budget.** The fBm mean varies +-35% by seed and thin draws lose
  structure before t=1000, so the total budget is normalized.
- **Bang seeder.** Ejection speed keys to the core's own escape velocity plus
  the halo climb `v_flat^2 * ln((rt^2 + rc^2) / rc^2)`. Without the halo term
  ejecta stall short of the ring. Speed jitter breaks the diagonal grid
  artifact. `core_fill_scale` keeps the core below collapse density.
- **Orbital support, every scenario.**
  `v = boost * sqrt(G*M_enc/r + v_c(r)^2)` tangentially, the combined
  self-gravity and halo equilibrium. A hand-tuned ramp free-falls within a few
  hundred ticks.
- **Determinism.** `seed_with_mode_seeded` gives byte-identical output for the
  same `(additional, scenario, seed)`, which is what `?seed=` rests on.

Related: [morphology.md](morphology.md), [sim-constants.md](sim-constants.md).

Detail, verbatim:

- [scenarios](../.agents/skills/coding-galaxy-gen-internals/references/scenarios.md)
- [seeding](../.agents/skills/coding-galaxy-gen-internals/references/seeding.md)
