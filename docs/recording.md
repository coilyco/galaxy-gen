# Recording and visual capture

Capture a run as an animated GIF or an MP4 from the browser, with no checkout,
ffmpeg, or dev server. The whole path runs client-side on the public site.

- **Using it.** Generate a galaxy, pick **gif** or **mp4**, press **record**,
  play or step the run, then press **stop** to encode and download. The file is
  named for the permalink that reproduces it, so
  `galaxy-<seed>-<scenario>-<size>.mp4` leads back to the exact galaxy.
  Recording captures the canvas only.
- **Format.** MP4 has true color, hardware encoding, and files about an order of
  magnitude smaller. GIF stays the default because it pastes anywhere and has
  no capability floor. The **mp4** pill renders disabled, with the reason, where
  WebCodecs or H.264 is missing.
- **Funnel.** `src/js/lib/recorder.ts` subscribes to `dataviz.setFrameListener`,
  which fires at the end of every render path, so each captured frame is a
  completed draw paired with its tick.
- **Budget and backpressure.** GIF takes one reduced `getImageData` inline and
  encodes on idle callbacks. Past 8 pending frames it encodes inline rather
  than drop a frame. MP4 reads the scratch canvas directly, and awaiting
  `CanvasSource.add` is its backpressure.
- **Constraints.** H.264 rejects odd dimensions, so both axes round down to
  even. A mid-capture resize keeps the first size.
- **Defaults.** 10 ticks per frame (reproducible by tick, not wall clock), 240
  frames max, width 640, 12 fps, GIF per-frame palettes.
- **Tests.** `e2e/record.spec.ts` parses the downloaded bytes: GIF signature,
  dimensions, frame count, and trailer, and MP4 `ftyp` plus `moov`.
- **Visual capture harness.** `e2e/visual-capture.spec.ts` shoots the same
  galaxy at the same tick for before-and-after comparison, and skips unless
  `GALAXY_CAPTURE` is set. It advances on the main thread and paints the
  advanced state explicitly, since waiting photographs a tick-0 galaxy.

Related: [performance.md](performance.md) for where the frame budget went.

Detail, verbatim, with the ImageMagick comparison commands:

- [recording](../.agents/skills/coding-galaxy-gen-internals/references/recording.md)
- [recording-internals](../.agents/skills/coding-galaxy-gen-internals/references/recording-internals.md)
- [visual-capture](../.agents/skills/coding-galaxy-gen-internals/references/visual-capture.md)
