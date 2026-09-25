# Morphology: spirals, rings, and ellipticals

Each scenario's shape is simulation state, not a render mask. Forces act on
gas only. Stars stay collisionless and form where the gas collapses.

- **Spiral density waves.** A two-arm logarithmic potential with phase
  `2 theta - pitch ln(r) - pattern_phase` advances rigidly every tick, so gas
  passes through compression lanes instead of carrying a painted arm. Smooth
  radial tapers avoid a force discontinuity at the nucleus and the edge.
- **Ring density waves.** `bang => ring` adds a radial force proportional to
  `-tanh((r - r0) / width)` toward 0.58 disk radii, with no azimuthal term, so
  it cannot paint arms or a bar. Only cells inside the annulus accumulate
  collapse heat.
- **Elliptical relaxation.** `IrregularElliptical` uses no wave force. An
  irregular exponential cloud with high dispersion assembles under gravity,
  pressure (`0.35`) keeps it resolved, and collapse tuning (`0.4` density,
  `0.2` probability) spreads births through the reservoir.
- **Resolved gas pressure.** Without it, admitted collisions merge parcels
  permanently. A density-gradient force plus conservative post-advection flux
  keep lanes several cells wide. Transfers carry metals and momentum exactly.
- **No special spawn path.** `collapse_watch` turns sustained dense, cool,
  weakly irradiated cells into `CloudCollapse` then `StarBirth`.
- **Spiral checks.** `spi` (pitch-aware amplitude) and `cov` (radial-band
  coverage) with a cell floor, for `bang => spiral` at ticks 1000-1100 and
  `irregular => spiral` at 1993-2093.
- **Ring checks.** `ring`, `hollow`, `rcov`, and `rw` with a cell floor, for
  seed 42 size 50 through ticks 1400-1500.
- **Elliptical checks.** Concentration, smoothness, axis ratio, extent, and
  rotational support (`econ`, `esm`, `axis`, `ext`, `erot`), every tick 900-1000
  at size 50 seed 42. Core star density is the one amount-reading bar
  (galaxy-gen#7051).

Detail, verbatim, with every threshold:

- [spiral-density-waves](../.agents/skills/coding-galaxy-gen-internals/references/spiral-density-waves.md)
- [ring-density-waves](../.agents/skills/coding-galaxy-gen-internals/references/ring-density-waves.md)
- [elliptical-relaxation](../.agents/skills/coding-galaxy-gen-internals/references/elliptical-relaxation.md)
