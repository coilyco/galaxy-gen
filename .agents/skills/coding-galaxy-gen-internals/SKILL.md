---
name: coding-galaxy-gen-internals
description: Verbatim long-form engineering reference behind galaxy-gen's short docs/ pages - integrator, forces, events, stellar lifecycle and heating, star metrics, density waves, black hole, rendering, recording, seeding, constants, worker layouts, ablation, CI timeouts, and the perf journal. Triggers - galaxy-gen internals, why this constant, field order, ablation switch, quasar feedback, rendering gas, perf rewrite, star metrics, stellar heating.
---

# galaxy-gen internals reference

The `docs/` pages in galaxy-gen are short overviews held to the small
documentation band. The long-form engineering record behind each one lives here
verbatim, so detail is kept without growing `docs/`. Read the overview page
first, then the reference file it links to when you need thresholds, field
orders, measurements, or the story behind a decision.

**Why:** Kai ratified the small band for galaxy-gen on 2026-09-24
(teable:coilyco/galaxy-gen#8239). Skill references are exempt from the size cap,
so detail moved here rather than into more docs.

**How to apply:** when a code comment names a `docs/` page, the page links the
matching file below. Edit the reference when the detail changes, and keep the
overview page in step.

## References, by overview page

- `docs/ablation.md` - [ablation](references/ablation.md), [ablation-switches](references/ablation-switches.md), [ablation-rationale](references/ablation-rationale.md)
- `docs/black-hole.md` - [black-hole](references/black-hole.md), [quasar-feedback](references/quasar-feedback.md)
- `docs/development.md` - [development](references/development.md), [ci-timeouts](references/ci-timeouts.md)
- `docs/FEATURES.md` - [FEATURES](references/FEATURES.md), the pre-trim inventory
- `docs/galaxy-rust.md` - [galaxy-rust](references/galaxy-rust.md), [tick-worker](references/tick-worker.md)
- `docs/integrator.md` - [integrator](references/integrator.md), [gas-forces](references/gas-forces.md), [boundary-ridge](references/boundary-ridge.md), [co-rotating-frame](references/co-rotating-frame.md)
- `docs/morphology.md` - [spiral-density-waves](references/spiral-density-waves.md), [ring-density-waves](references/ring-density-waves.md), [elliptical-relaxation](references/elliptical-relaxation.md)
- `docs/performance.md` - [perf-rewrite](references/perf-rewrite.md), the four-part journal
- `docs/processes-events.md` - [processes-events](references/processes-events.md), [causal-loop](references/causal-loop.md), [lifecycle-chains](references/lifecycle-chains.md)
- `docs/recording.md` - [recording](references/recording.md), [recording-internals](references/recording-internals.md), [visual-capture](references/visual-capture.md)
- `docs/rendering.md` - [rendering](references/rendering.md), [rendering-fades](references/rendering-fades.md), [rendering-gas](references/rendering-gas.md), [rendering-stars](references/rendering-stars.md)
- `docs/scenarios.md` - [scenarios](references/scenarios.md), [seeding](references/seeding.md)
- `docs/sim-constants.md` - [sim-constants](references/sim-constants.md)
- `docs/star-metrics.md` - [star-metrics](references/star-metrics.md), [metric-calibration](references/metric-calibration.md)
- `docs/starfield.md` - [starfield](references/starfield.md)
- `docs/stellar-evolution.md` - [stellar-evolution](references/stellar-evolution.md), [chemical-enrichment](references/chemical-enrichment.md)
- `docs/stellar-heating.md` - [stellar-heating](references/stellar-heating.md)
- `docs/stellar-population.md` - [stellar-model](references/stellar-model.md), [stellar-population](references/stellar-population.md), [stellar-associations](references/stellar-associations.md)
- `docs/ui-controls.md` - [ui-controls](references/ui-controls.md)

Sibling skills: [`coding-galaxy-gen-astrophysics`](../coding-galaxy-gen-astrophysics/SKILL.md)
for the physics the sim approximates, and
[`coding-galaxy-gen-references`](../coding-galaxy-gen-references/SKILL.md) for
external catalogs and libraries.
