# Seeded backdrop

The deep-space sky the galaxy hangs in, generated from the same `?seed=` as
the physics and built from the renderer's own sprites, so a permalink
reproduces the sky and it reads as the same universe. Lives in
`src/js/lib/starfield.ts`. The renderer passes the sprite assets in, so the
generator holds no visual vocabulary of its own.

- **Distant stars.** Seeded positions and brightness, colors from the
  renderer's `starColors` pushed toward the cool faint end. Brightness follows
  a square law, since uniformly lit points read as noise. The brightest few get
  a soft halo and a faint cross.
- **Faint nebulosity** from additive gas sprites, and a little multiplied dust
  that only bites where a cloud has already brightened the pixels.
- **A seeded band** of stars and haze along a great circle, the distant
  galactic-plane cue.
- **It is scenery.** One `FADE` constant is the master dimmer if the sky ever
  pulls attention off the galaxy.
- **No teal.** The [OIII] tier is a shock diagnostic, and as ambient haze it
  reads as green fog.
- **The middle is reserved.** Haze fades inside `CENTER_KEEPOUT`, computed in
  pixel space so it stays circular on a wide viewport.
- **Sprites are authored faint** because the galaxy stacks dozens per pixel, so
  the backdrop's alpha multiplier runs much higher.
- **Cost.** Built once per (seed, viewport) into an offscreen canvas and
  blitted as the opaque base, replacing the old `fillRect`. The opaque base is
  load-bearing, because multiply dust needs opaque pixels. It sits under the
  camera and frame rotation, so the sky stays screen-fixed.
- **Tests.** `e2e/starfield.spec.ts` counts lit pixels in the four corners and
  checks it is drawn, dark, reproducible, seed-sensitive, tick-stable, and
  cached.

Verbatim original:
[starfield](../.agents/skills/coding-galaxy-gen-internals/references/starfield.md).
