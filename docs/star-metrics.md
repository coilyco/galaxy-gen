# Star-population metrics, and which ones to trust

The numbers `debug-sim` prints about the star layer. Two look interchangeable
and are not, and one has cost a retraction.

- **`vsig`, rotational support.** Mean streaming speed over dispersion,
  averaged across radial bins. This separates a disk (above ~1.5) from a mush
  (below ~0.7). Binned, because pooling radii charges the rotation gradient to
  dispersion.
- **`vsy` / `vsm` / `vso`, the age split.** Each cohort cold with only the
  mixture hot means dispersion was written in at birth. Old cohorts hotter than
  young means something heats stars after birth. The pooled number cannot tell
  these apart.
- **`scirc`, DO NOT TUNE AGAINST THIS.** It cannot tell a circular orbit from an
  eccentric one caught at pericenter (galaxy-gen#66).
- **`bcirc`, the ratio at birth.** Splits born wrong from drifted wrong.
  Dragon: this probe mirrors the birth site's clamps by hand, so probe and call
  site move together.
- **`arm`, arm tracing.** Gas density at star positions over disk mean, per
  radial bin. Deliberately blind to kinematics.
- **`sctr` / `sctry`, central concentration.** Young stars track where stars
  form, so agreement with all ages means nothing is migrating.
- **`cden`, the amount where the rest are shape.** Core star density. Every
  other bar divides by a total and cannot see the population emptying. On
  galaxy-gen#7051 a floor retired 81% of stars and `econ` did not move. It
  guards the elliptical alone.
- **Calibration.** Every metric, and the ablation field filters, has a unit
  test against a population whose answer is known by construction. A metric
  nobody checked that way is how #66 went wrong. Two cold cohorts a factor of
  two apart still pool to about 4.2, so generational offset alone cannot drive
  `vsig` under 1.0.

Related: [stellar-heating.md](stellar-heating.md), [ablation.md](ablation.md).

Detail, verbatim:

- [star-metrics](../.agents/skills/coding-galaxy-gen-internals/references/star-metrics.md)
- [metric-calibration](../.agents/skills/coding-galaxy-gen-internals/references/metric-calibration.md)
