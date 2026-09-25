# Why the stellar disk stops rotating, and what fixed it

The stellar disk used to end a pressure-supported mush by t=2500, burying good
gas structure under 40k non-rotating points. Evidence: galaxy-gen#70,
compiling #65 and #66.

- **Two independently sufficient causes**, which is why one-at-a-time ablation
  found nothing. The absolute `ASSOCIATION_ORBIT_SPEED_CAP` handed newborns
  2-3x their own circular speed, past the ~1.41 escape ratio. And the coarse
  field stars read was lumpy enough to scatter even a correct orbit.
- **What ships.** `birth_orbit_ratio_cap` (1.06) clamps a newborn to a multiple
  of its own circular speed. `STAR_FIELD_AXISYMMETRIC` replaces the stellar
  field with its azimuthal average. `birth_velocity_dispersion` gives the
  elliptical its dispersion on purpose (1.5, disks 0.3).
  `COLLAPSE_RADIATION_RESIST` rises 20 to 80 for disks.
- **Measured** at size 500, t=2500, two seeds (`vsig`, above ~1.5 is a disk):
  irregular to spiral 0.48/0.31 before, 2.50/3.30 after. Bang to spiral
  2.49/2.75. The elliptical target stays near 0.5. The disk holds to t=5000.
- **The arms survive.** Stars trace arms because they are born where gas
  collapses, not because the field has arms. A coherent analytic wave does not
  heat stars, so `STAR_WAVE_COUPLING` stays 0.0.
- **Dragon: the elliptical's spheroid came from the birth bug.** Fixing the cap
  alone makes it rotate. It needs `birth_velocity_dispersion` in the same
  change.
- **Dragon: the elliptical keeps the old radiation gate.** At 80 its extra
  supernovae sweep gas into an annulus and fail its ring check.
- **Dragon: past ~1.41 a birth never comes back.** Angular momentum is conserved
  in a torque-free potential.
- **Still open.** Central over-concentration below size 250 (#70 item 4), and
  the elliptical's unbounded population (galaxy-gen#72).

Related: [ablation.md](ablation.md) for the harness,
[stellar-population.md](stellar-population.md) for how a birth gets its orbit.

Detail, verbatim, including the before-and-after numbers:
[stellar-heating](../.agents/skills/coding-galaxy-gen-internals/references/stellar-heating.md).
