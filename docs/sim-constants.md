# Simulation constants

Every tuned constant in the gas and star kernels, and what each one holds up.
Values live in `src/rust/galaxy.rs`, and scenario-owned parameters live on
`Scenario::params`.

- **`GRAVATIONAL_CONSTANT` 5.0e-4.** Tuned so circular orbits fit under the step
  cap. The old 5.0e-2 made every initial condition free-fall.
- **`SOFTENING_SQ` 1.0.** Avoids division by ~0 inside a shared cell.
- **`MAX_SUBGRID_STEP` 1.0.** One cell per tick, clamping the displacement
  vector norm rather than each axis.
- **Flow relaxation.** `v = u + (v - u) * exp(-flow_drag * dt)` toward the local
  circular flow `u = flow_support * v_c(r)`, with
  `v_c(r) = v_flat * r / sqrt(r^2 + rc^2)`. The halo also pulls `v_c^2 / r`
  inward, so a rotating disk is the attractor. Without it the disk freezes or
  falls in. `flow_support` below 1.0 is the elliptical's concentration knob.
- **`REPULSE_R2` 2.0.** Gravity turns repulsive at small integer r squared, a
  contact-pressure proxy mirrored in the WGSL kernel.
- **`CELL_MASS_CAP` 128.** A full destination parks the mover at its cell edge
  with velocity intact (`BLOCKED_FRICTION` 1.0), because reflecting or damping
  thermalizes disk rotation. Overflow sheds to neighbours.
- **`CONFINE_STIFFNESS` 0.02.** Gas boundary spring past the disk radius. It is
  load-bearing, since banding it broke four tests (see
  [integrator.md](integrator.md)).
- **`STAR_FIELD_SCALE` 0.25.** Stars read a quarter-strength field with half the
  gas halo curve, so they orbit at half the gas pace. That is the intended
  look, not an accident.
- **Star halo.** Between the soft clip and `HARD_CLIP_FACTOR` 3.0x, a repulsive
  gradient `HALO_STIFFNESS x (r - soft)/(hard - r)` diverges at the clip, so
  nothing reaches it. `STAR_HALO_DRAG` bleeds speed inside the band only.

Verbatim original, with the full rationale for each:
[sim-constants](../.agents/skills/coding-galaxy-gen-internals/references/sim-constants.md).
