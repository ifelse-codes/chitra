# Session 20 — lock the `treemap` chart to the reference/panel design language

> **Type: CODE.** Branch `session-20-treemap-lock`. One story: rotate the S18 heatmap locked
> language onto the hierarchical area chart. Keep it tight.

## Goal

`treemap` is NOT locked to chitra's reference design language (the mudra review flagged it:
rainbow `theme.colors[i % n]`, no frame, no eyebrow, no summary footer). Its sibling `heatmap`
was locked in S18 and is the exact reference for a 2-D magnitude chart. Apply that locked
language to the treemap.

## Named references (read ONLY these — do not scan the repo)

- `packages/core/src/charts/heatmap.ts` — the S18 locked reference implementation (accent-once
  on the peak cell, grey tone ramp, panel chrome, summary footer).
- `packages/core/README.md` → `### LOCKED: heatmap chart — session 18 design` — the written contract.
- `packages/core/src/charts/treemap.ts` — the target to rewrite (currently rainbow).
- `packages/core/src/renderers/panel.ts` — `frameTop` / `frameRow` / `frameRule` / `frameBottom`.
- `packages/core/tests/heatmap.test.ts` — the raw-ANSI accent-census test pattern to mirror.

## Acceptance (testable, EARS-style)

1. WHEN `treemap` renders, THEN the single maximum-value node is drawn in the theme's accent hue,
   and EVERY other node uses the grey tone ramp (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, light →
   dark by magnitude). No `theme.colors[i % n]` rainbow, ever. Verified at raw-RGB level (accent
   spent on the peak node only, zero non-ramp/non-accent cell segments).
2. WHEN `treemap` renders, THEN it carries the same panel language as the locked families: dashed
   frame (`┌╌…╌┐` / `└╌…╌┘`), an uppercase eyebrow row (`AREA`), a `+`/`│` left guide on the plot,
   and two `│ ╌…╌ │` rule separators.
3. WHEN a node has children, THEN the layout flattens honestly — the leaves are laid out (no parent
   block is drawn) and the peak is the max leaf, first in flatten order on ties.
4. WHEN values are shown, THEN the summary footer reports `n <count> · <min>..<max> · peak <label>`
   with the peak label in the accent hue.
5. WHEN degenerate input is given (empty data, all-equal values, single node), THEN it renders
   safely (no crash, no NaN/Infinity, deterministic accent tie-break = first max in data order).
6. WHEN a cell is empty, THEN it is a SPACE — the plot never writes a phantom filler outside the
   shade ramp.
7. `packages/core/README.md` carries a `### LOCKED: treemap chart — session 20 design` block.
8. `scripts/verify-session-20.sh` exits 0 (with a raw-RGB accent census + a no-rainbow assertion),
   `scripts/demo-session-20.sh` shows the before/after, and `pnpm --filter @chitra/core run test`
   is green.

## Guardrails

- **Dispatch the tech-lead FIRST** (mandatory) and let its `required` verdict bind the crew; every
  role it marks `required` must produce a real governed handoff (`vajra next --role <name> --from
  <file>`) or the close cannot go green (the S139 gate).
- **Budget every subagent dispatch TIGHT: named files only, never "read the repo"** (Vajra S134).
- Max 3 files per atomic commit (hook-enforced); commit only with the founder marker in the launch env.
- Do NOT touch `timeline`/`gauge`/`progress` or any other chart — those are S21+ stories.
- Public API stays stable (`toPlain()`/`toJSON()` output preserved); zero runtime deps.

## Delta (vs ROADMAP)

- `+` `treemap` joins the locked family (circular S09 · area S09 · line S10 · bar S12 · scatter S17
  · heatmap S18 · horizontalBar S19) — the first hierarchical chart in the locked language.
