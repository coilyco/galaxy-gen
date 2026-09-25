# Black hole and quasar feedback

The central hole is live in both particle systems: it pulls, it feeds, it can
ignite as a quasar, and it can evaporate.

- **Pull.** The shared gas integrator adds its softened point-mass
  acceleration, so CPU, Barnes-Hut, and WebGPU force paths all include the same
  nuclear potential.
- **Feed.** `bh_accretion` (cadence 8) applies weak tangential viscosity inside
  7 cells and removes gas only inside the 2-cell sink, weighted toward low
  angular momentum so a nuclear ring leaks inward visibly. `BlackHoleCapture`
  needs a star inside radius 0.5 and slow (< 0.8), so fast stars slingshot.
- **Ignite.** After tick 1000, with the hole grown at least 1.20x and smoothed
  accretion at least 0.00025 of seeded mass, a 360-tick quasar episode starts
  and emits `QuasarIgnition`. A seed-derived bipolar axis holds for the whole
  episode, a 56-tick pulse envelope drives it, and a 500-tick cooldown bounds
  repeats. Duty-cycle state travels in the worker snapshot.
- **Feedback.** `quasar_feedback` runs after gas forces and before integration.
  Pulse crests accelerate gas in two opposed cones and deposit radiation in a
  slightly broader pair. Gas and metals stay on their cells, so the baryon and
  metal ledgers still close while the host is reshaped.
- **Evaporate.** `bh_evaporation` applies `dM/dt = -HAWKING_COEFF/M^2`,
  negligible while fat and runaway once small, at a deliberately exaggerated
  rate. Radiated mass exits through `radiated_total`.
- **Render.** Lens depth scales with `sqrt(bh_mass / seeded mass)`. The canvas
  draws the same axis as ionization cones, and physics stays authoritative in
  Rust.
- **Reference.** Seed `409007255426557616`, size 250, `irregular-elliptical`
  ignites near tick 2330. Native and WASM can cross thresholds on different
  ticks, so browser checkpoints are calibrated in the browser.

Detail, verbatim:

- [black-hole](../.agents/skills/coding-galaxy-gen-internals/references/black-hole.md)
- [quasar-feedback](../.agents/skills/coding-galaxy-gen-internals/references/quasar-feedback.md) - ignition, feedback, reference acceptance
