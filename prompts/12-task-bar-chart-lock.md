# Session 12 — Reference-lock the bar chart

**Branch:** `session-12-bar-chart-lock` (from `main`)
**Type:** CODE
**Session:** 12

## Goal

Bring `bar()` up to the same locked design language as the three already-locked chart families
(circular S09, area S09, line S10), then LOCK it.

## Design

The shared locked language (from `packages/core/README.md` `## Design Style` and all three
`### LOCKED:` sections):

- **One accent hue + grey tone ramp** — never per-series rainbow. Accent is spent once on
  the highest-value bar; every other bar uses the grey tone ramp
  (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`).
- **Dashed panel frame** (`┌╌…╌┐`), **eyebrow row** (uppercase, letter-spaced), **`+`
  y-guide top**, **`+` x-axis ticks** between plot and x-labels.
- **Per-series summary rows** (MIN / MAX / AVG / LAST) with compact sparkline, same shape
  as the line/area summary.
- **Auto-scale y-range** (`yMin` defaults to `min(0, data.min)`); empty cells are spaces.

## Acceptance criteria

1. `bar()` uses one accent + grey tone ramp — no raw `theme.colors[s % n]` rainbow.
   covers: 1
2. Dashed panel frame + eyebrow row + `+` y-guide top + `+` x-axis ticks present.
   covers: 2
3. Per-series summary row (MIN/MAX/AVG/LAST + spark) present under chart.
   covers: 3
4. `area.ts`, `line.ts`, `circular*.ts` output unchanged from `main` (byte-identical diff).
   covers: 4
5. `### LOCKED: bar chart — session 12 design` section in `packages/core/README.md`.
   covers: 5
6. `pnpm --filter @chitra/core run test` and typecheck exit 0.
   covers: 6
7. `scripts/verify-session-12.sh` exits 0; `scripts/demo-session-12.sh` exits 0.
   covers: 7
8. `sessions/session-12-summary.md` with SHIPPED/PARTIAL/NOT-BUILT per criterion;
   `sessions/session-12-review.md` from independent cold fidelity pass.
   covers: 8

## Plan

1. `git checkout -b session-12-bar-chart-lock` from `main`. covers: —
2. Write this prompt file (`prompts/12-task-bar-chart-lock.md`). covers: —
3. Rewrite `packages/core/src/charts/bar.ts`:
   - Import `frameTop/Bottom/Row/Rule` from `panel.ts` for dashed frame.
   - Color logic: find overall max bar → accent; single-series non-max → `tones[2]`;
     multi-series extra series → `toneOrder[si % len]`.
   - `buildPlotRows()`: y-label + `+`/`│` y-guide + bar columns per row.
   - `buildXTicks()`: `+` row aligned to each bar group centre.
   - `buildXLabels()`: bar group labels.
   - `buildSummary()`: per-series MIN/MAX/AVG/LAST + sparkline string.
   - `buildLines()`: assemble panel — frameTop → frameRule → eyebrow → [legend] →
     plotRows → xTicks → xLabels → frameRule → summary → frameBottom. covers: 1, 2, 3
4. Update `packages/core/tests/bar.test.ts` for new visual contract. covers: 6
5. Add `### LOCKED: bar chart — session 12 design` to `packages/core/README.md`. covers: 5
6. Sync lock into `.ai/KNOWLEDGE.md`. covers: 5
7. Write `scripts/verify-session-12.sh` and `scripts/demo-session-12.sh`. covers: 7
8. Run verify; fix any failures. covers: 6, 7
9. Fidelity cold review → `sessions/session-12-review.md`. covers: 8
10. Write `sessions/session-12-summary.md`. covers: 8
11. Update `.ai/SESSION`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md`, `.ai/STATE.md`. covers: —
