# Session 19 — lock the `horizontalBar` chart to the reference design language

**Type:** CODE · **Branch:** `session-19-horizontalbar-lock` · **Date:** 2026-09-04
**Verify:** `scripts/verify-session-19.sh` — ALL GREEN (11 pass, 0 fail) · core **217/217** · demo exit 0

## What shipped

`horizontalBar` was the last chart family not locked to chitra's reference/panel design
language (rainbow `theme.colors[i % n]`, `░` phantom filler, no panel chrome). This session
rotated the S12 `bar` locked language to the horizontal orientation, closing the
reference-language migration for the core chart set (circular S09 · area S09 · line S10 ·
bar S12 · scatter S17 · heatmap S18 · **horizontalBar S19**).

## Governance ritual (Vajra S144 full-loop dogfood)

- **Tech-lead dispatched FIRST** (mandatory). Crew verdict binds: **4 required**
  (implementation-advisor, qa-specialist, demo-producer, fidelity-reviewer), **5
  deferred-budget** with money arithmetic ($20/mo, ~6M tokens/dispatch).
- Every `required` role produced a real governed handoff (`.ai/handoffs/session-19-*.md`,
  provenance-verified). `vajra next --check-crew 19` → **READY**.
- The S139 required-crew gate is live in `scripts/verify-closeout.sh` for this run.

## Acceptance criteria → evidence

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | Exactly ONE accent bar (global max), all others grey ramp, no rainbow; raw-RGB accent count == 1 | SHIPPED | `horizontalBar.ts:33-40` first-max via strict `>`; `buildBarRows` colors `isPeak ? acc : grey (tones[2])`; no `theme.colors[`. Test `raw-rgb-accent-count-1` renders + counts ANSI codes before `█` == 1, rejects rainbow across all 7 themes. |
| 2 | Panel language rotated horizontal: dashed frame, uppercase eyebrow, `+` value-axis guide, rule separators | SHIPPED | `buildLines` reuses `frameTop/frameRule/frameRow/frameBottom`; eyebrow `(xLabel ?? "VALUES").toUpperCase()`; `buildAxisGuide` emits `+╌…╌+`; two rules. |
| 3 | Empty cell = SPACE, never `░` | SHIPPED | Both renderers called with explicit `" "` empty-char (overriding the `░` default). `no-phantom-fill-glyph` asserts zero `░` in blocks + ascii. |
| 4 | Each value label rendered; peak value in accent | SHIPPED | `buildBarRows` renders `formatNumber(v)` per item, `colorize(..., isPeak ? acc : label)`; summary `max` accented + `peak <label>`. Test asserts `accent+"47"`. |
| 5 | Auto-scale (`min(0,dataMin)` baseline) + auto-width never clips | SHIPPED | `yMin = min(0,dataMin)`; `effectiveWidth = max(label+bar+value, eyebrow, summary, 36)`; `barWidth` floored at 1. Tests assert long label survives + `│ 0 … 30 │` baseline. |
| 6 | Degenerate (empty/all-equal/single) safe, first-max tie-break | SHIPPED | `hasData` guards; `minMax` skipped when empty. `degenerate-safe` renders `[]`,`[42]`,`[5,5,5]` — no NaN/Infinity, framed `n 0`. Tie test asserts `peak b` + accent==1 on `[5,9,9,2]`. |
| 7 | README `### LOCKED: horizontalBar chart — session 19 design` block | SHIPPED | `packages/core/README.md` block added; `readme-lock-block` greps the exact heading. |
| 8 | verify exit 0 (raw-RGB accent + no-`░`), demo before/after, core tests green | SHIPPED | `verify-session-19.sh` 11/11 GREEN; `demo-session-19.sh` before/after with falsifiable live checks, exit 0; `pnpm --filter @chitra/core run test` 217/217. |

## Commits (atomic, ≤3 files each)

- `f9253e4` horizontalBar.ts rewrite + 25 tests
- `0ae6589` README lock block + regenerated previews
- `689cf44` verify + demo scripts
- `0dcd830` docs preview auto-size fix (cold-review rec 1)
- `24be492` / `9c6dbd6` governance handoffs (tech-lead, impl, demo, qa, review)

## Follow-ups (non-blocking, from the cold review)

- Add an auto-width test asserting the **summary** row edge fits (currently only the label
  edge is asserted). — cold-review rec 1 (the preview clip is now fixed).
- Reconcile "letter-spaced eyebrow" prose vs code (only uppercases, inherited from the S12
  reference) — amend prose or add real letter-spacing to both `bar` and `horizontalBar`. — rec 2.

## Next session — 3 options

1. Bring `lineModelToSvg` to terminal parity (SVG mirrors the locked terminal 1:1).
2. Exercise a real `v0.1.0` release (`release.yml`, `NODE_AUTH_TOKEN`).
3. Wire the local Playwright QA into CI.
