# Canvas renderer

`src/js/lib/dataviz.tsx`. One `<canvas>` per frame, DPR-aware and clamped at
2x. Render-only exaggeration is fine, since nothing flows back into the sim.

- **Composition.** A seeded opaque backdrop ([starfield.md](starfield.md)), then
  the world in a co-rotating stellar frame. Pan and zoom sit behind `?debug=1`.
- **Gas sprites.** Soft pre-rendered sprites in four tiers (cold blue-violet,
  warm magenta, H-alpha pink, shock-swept [OIII] teal). Ramps stay flat and
  mid-dark because brightness comes from accumulation.
- **Screen-space blocks.** Cells aggregate into blocks sized to the minimum
  sprite footprint, so the gas looks the same at any grid size. Grid resolution
  used to act as an exposure control. Steady-state frames allocate nothing.
- **Two gas passes** split by a stable block hash, so clusters sit inside their
  clouds. Dust multiplies from a dark core to white, and only coherent dense
  cold neighbourhoods stamp it. The opaque base stops multiply from painting
  grey squares.
- **Stars.** Main-sequence color keys on `age`, newborn cyan to deep amber, with
  no white stop. Mass is currently unrendered. The ramp test asserts
  `starAgeBucket` over the population, because a pixel check passed a ramp
  broken to 100x its span.
- **Batching.** Color and alpha are quantized, and discs batch into buckets,
  turning ~10k draws into a few hundred. Alpha steps on a sqrt curve so faint
  glows keep distinct rungs. Only rare giants earn per-star spikes.
- **Transients.** Supernova fronts grow as `E^0.2 t^0.4`, shimmer is a GPU
  self-blit, gamma-ray jets use a stable hash axis, and quasars share the
  physics pulse and axis.
- **Fades.** Stars fade 0.88 to 1.32 of the disk radius, gas to zero at 0.94,
  hiding the confinement ridge (see [integrator.md](integrator.md)). A gentle
  screen vignette runs after the lens.
- **Lens.** `r_src = r - thetaE^2 / r`, drawn as concentric clipped self-blits
  on the GPU. The region is cleared first and the snapshot re-laid, or it reads
  as a dark box or a double-blended square.

Detail, verbatim:

- [rendering](../.agents/skills/coding-galaxy-gen-internals/references/rendering.md)
- [rendering-fades](../.agents/skills/coding-galaxy-gen-internals/references/rendering-fades.md)
- [rendering-gas](../.agents/skills/coding-galaxy-gen-internals/references/rendering-gas.md)
- [rendering-stars](../.agents/skills/coding-galaxy-gen-internals/references/rendering-stars.md)
