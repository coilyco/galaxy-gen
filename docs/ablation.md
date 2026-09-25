# Ablation harness

Ask which force is responsible for something by switching one candidate off
and re-running, instead of tuning a constant and hoping the result is
attributable.

```bash
just ablation-sweep                       # 2500 ticks, size 500, 2 seeds
just ablation-sweep 5000 500 3 12345 2    # ticks size seeds start-seed scenario
GALAXY_ABL_AXISYMMETRIC_FIELD=1 just debug-sim 2500 500 2 12345 2
```

- **Switches live in the kernel.** Editing a constant per run let a probe drift
  from the call site on galaxy-gen#66. A switch the kernel reads cannot. The
  wasm build reads no environment and always runs shipped physics, and
  `debug-sim` prints the resolved configuration as its first line.
- **Thirteen `GALAXY_ABL_*` switches** cover field cadence, smoothing,
  axisymmetry, star self-gravity, association binding, birth dispersion, the
  birth orbit ratio cap, star wave coupling, collapse radiation resistance,
  length reference size, and the resolved luminosity floor.
- **Reading results.** `vsig` is `v_rot / sigma` over the resolved disk, above
  ~1.5 a rotating disk and below ~0.7 a mush. Prefer the cohort numbers
  (`vsy`, `vsm`, `vso`) when asking whether something heats stars.
- **What it found.** No single factor holds the disk. A birth orbit ratio cap
  plus an axisymmetric field together hold `vsig` at 2.2-2.4 at t=2500, against
  0.3-0.5 baseline, because there are two independent heat sources. Stars are
  heated by structure that changes under them, not by structure that rotates
  with them. The fix is in [stellar-heating.md](stellar-heating.md).
- **A result at one domain size is a hypothesis at another.** Several length
  scales are absolute cell counts, so compare same size and tick count.

Detail, verbatim:

- [ablation](../.agents/skills/coding-galaxy-gen-internals/references/ablation.md)
- [ablation-switches](../.agents/skills/coding-galaxy-gen-internals/references/ablation-switches.md) - the full switch table
- [ablation-rationale](../.agents/skills/coding-galaxy-gen-internals/references/ablation-rationale.md) - why each switch exists
