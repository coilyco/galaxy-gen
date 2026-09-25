# Gas integrator, forces, and the domain edge

Semi-implicit Euler with a transfer scheme: cells carry sub-grid offsets and
hop to a neighbour when an offset crosses a half cell. Each load-bearing choice
was reached by breaking the sim first.

- **Flow relaxation, not drag.** Velocity decays toward the local circular flow,
  not toward rest. Plain drag froze every galaxy into a blob by t=1000. The halo
  pull and boundary spring apply in the integration step, so CPU, Barnes-Hut,
  and WebGPU paths all inherit them.
- **Step cap clamps the vector norm**, not each axis. A per-axis clamp funnels
  fast transits into four diagonal sectors and shreds rings into a pinwheel.
- **Two passes.** Pass 1 records where each cell wants to go. Pass 2 admits
  movers iteratively like a traffic wave. One sweep froze dense clouds, and
  trusting intent alone collapsed clouds into a mega-blob.
- **Pressure overflow.** Cells above `CELL_MASS_CAP` shed excess and momentum to
  neighbours, or a capped region gridlocks within ~500 ticks.
- **Conservative transport.** A post-advection flux spreads excess density, and
  cooling gas drifts down the arm or ring potential. Every transfer carries
  metals and momentum exactly.
- **Gas forces.** Radiation-dissipated gas moves to the hot `halo_gas_mass`
  reservoir, and `gas_fountain` cools it back on a 480-tick cycle. The ring and
  spiral density waves act on gas only. See [morphology.md](morphology.md).
- **Boundary ridge.** The confinement spring makes the disk radius an
  equilibrium, so the densest gas ring sits on the domain edge. Spreading it
  broke spiral coherence, ring births, and the goldens, so it stays and the
  renderer fades gas to zero at 0.94 of the disk radius instead
  (galaxy-gen#65). Stars get a repulsive halo band out to a 3x hard clip.
- **Co-rotating frame.** The renderer rotates world layers at a calibrated,
  tick-derived stellar rate, so gas visibly sweeps through and leaves newborn
  stars behind. Presentation only, and Rust stays inertial.

Detail, verbatim:

- [integrator](../.agents/skills/coding-galaxy-gen-internals/references/integrator.md)
- [gas-forces](../.agents/skills/coding-galaxy-gen-internals/references/gas-forces.md)
- [boundary-ridge](../.agents/skills/coding-galaxy-gen-internals/references/boundary-ridge.md)
- [co-rotating-frame](../.agents/skills/coding-galaxy-gen-internals/references/co-rotating-frame.md)
