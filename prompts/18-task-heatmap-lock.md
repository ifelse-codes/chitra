# Session 18 — Lock the `heatmap` chart to the reference/panel design language

**Type:** CODE · **Branch:** `session-18-heatmap-lock` (off `main`)

## Goal
Carry the reference/panel design language — the family the scatter chart joined at
session 17 — onto the `heatmap` chart. Replace the 10-colour blue→orange→red rainbow
(`HEAT_COLORS_DARK`) with the documented grey tone ramp as the intensity encoding and
spend the single accent hue exactly once, on the peak cell.

## Design contract (family language, adapted onto a grid/matrix)
- **ONE accent hue, spent EXACTLY once**, on the maximum-value cell (ties → first in
  row-major order, deterministic). Everything else uses the grey tone ramp
  `#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`. The heatmap's intensity encoding IS that grey
  ramp (light→dark by magnitude); the accent marks only the peak. Never a
  `theme.colors[i % n]` rainbow.
- **Same panel language as every locked chart:** dashed frame (`┌╌…╌┐`), an uppercase
  letter-spaced eyebrow row, the `│` / `+` guide language, and the `│ ╌…╌ │` rule
  separators (one below the eyebrow, one above the summary).
- **Summary footer** of facts true for arbitrary matrix data: `rows×cols · min..max ·
  peak (r,c)`, with the peak coords in the accent hue.
- **Empty / degenerate data renders safely:** an empty grid gives a framed panel with an
  `n 0`-style footer and no `Infinity`/`NaN`; an all-equal grid renders honestly with a
  collapsed range.

## Deliverables
1. `packages/core/src/charts/heatmap.ts` — grey ramp + single accent on the max cell;
   dashed panel frame, eyebrow, guides, rule separators, summary footer; empty/degenerate safe.
2. `artifacts/chitra-docs/scripts/chart-specs.ts` — heatmap spec reflects the locked look.
3. Regenerate previews with `pnpm gen:charts` (rewrites the generated `charts.ts` /
   `ansi-charts.json`). Never hand-edit a generated preview.
4. `packages/core/README.md` — a `### LOCKED: heatmap chart — session 18 design` block
   mirroring the scatter block.
5. `packages/core/tests/heatmap.test.ts` — falsifiability tests: the accent hue appears
   EXACTLY once (raw-ANSI census), the ramp is the documented grey ramp, empty/degenerate safe.

## Acceptance criteria
- [ ] Rainbow `HEAT_COLORS_DARK` gone; cells coloured on the documented grey ramp.
- [ ] Accent hue spent exactly once, on the max cell (ties → first row-major).
- [ ] Panel chrome present: dashed frame, uppercase eyebrow, `│`/`+` guide, two rule separators.
- [ ] Footer reports `rows×cols · min..max · peak (r,c)` with peak coords in the accent.
- [ ] Empty grid → framed `n 0`, no Infinity/NaN; all-equal grid → collapsed range.
- [ ] README carries the LOCKED heatmap block.
- [ ] Heatmap falsifiability tests green; full `@chitra/core` suite green; typecheck clean.

## Guardrails
- Max 3 files per commit. Footprint = the heatmap renderer, its spec, the regenerated
  previews, the README contract block, and the heatmap tests. Do not touch other charts.

## Execution
- step 1 — lock `heatmap.ts` (grey ramp + one accent + panel chrome + footer) & tests — done: e538751
- step 2 — heatmap spec + regenerate derived previews (`gen:charts`) — done: 1ad9c6c
- step 3 — README `### LOCKED: heatmap chart — session 18 design` block — done: 22b34f9
- step 4 — harden falsifiability tests per the cold fidelity review — done: e2b6bb9
