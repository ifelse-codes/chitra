---
role: implementation-advisor
session: 19
agent: claude-code-subagent (verified: toolu_01HpdAisWcxa4Y6HSRDAPbog)
source-sha: 9d08c5b59792707230a2f081fbe01e215600bdac51b0ee7c35cf5f73be09dd90
captured: 2026-09-04T04:43:55Z
cost_usd: null
---

# Implementation-advisor handoff — session 19

# Implementation Advisor — Session 19 (horizontalBar → locked design language)

Read ONLY bar.ts, horizontalBar.ts, blocks.ts, panel.ts, and the README locked-bar block. The rewrite is a straight rotation of the S12 language. Scope = three files (horizontalBar.ts, README, S19 scripts/tests); no types.ts edit, no blocks.ts default change, zero deps; toJSON.type stays "horizontalBar".

rec 1 — Compute the accent index with an explicit strict-`>` loop over `data` (first global max wins the tie), not `indexOf(Math.max(...))`, so empty data and the data-order tie-break (criterion 6) are handled without `-Infinity`.
rec 2 — Replace `theme.colors[i % theme.colors.length]` with the S12 scheme: `theme.accent` for the peak row only, `theme.tones[2]` (grey ramp) for every other row; apply the same color to that row's value label so the peak value renders in accent (criterion 4).
rec 3 — Pass `" "` as the explicit `emptyChar` to both `buildHorizontalBlockBar(...,"█"," ")` and `buildAsciiHBar(...,"█"," ")`; do NOT change the default in blocks.ts (shared by the vertical bar path).
rec 4 — Reuse `frameTop/frameRule/frameRow/frameBottom` in the exact bar.ts order (top, rule, eyebrow, rows, tick-guide, rule, summary, bottom) with dashed=true, eyebrow `(opts.xLabel ?? "VALUES").toUpperCase()`.
rec 5 — Render a single rotated value-axis guide row under the bars: a `labelWidth+1` gutter then `"+" + "╌".repeat(barWidth-2) + "+"` in `theme.axis`, carrying the `+`-tick vocabulary horizontally (criterion 2).
rec 6 — Invert width from fixed-60 to auto-expand: `effectiveWidth = opts.width ?? Math.max(labelWidth+BAR_MIN+valueWidth+6, eyebrow+4, summary+4, 36)`, then derive `barWidth` (floored at 1) so labels/values/eyebrow are never clipped (criterion 5).
rec 7 — Add the empty-data guard: skip the bar-row loop and render frame + eyebrow + rule + `n 0` summary + bottom (scatter empty-data contract); keep the `max===min` all-equal path (already safe in renderer) and single-item path unmodified.
rec 8 — Read utils.ts (`minMax`, `formatNumber`) before finalizing the empty-data guard — confirm `minMax([])`'s return so the guard condition is exact.
rec 9 — Add the `### LOCKED: horizontalBar chart — session 19 design` README block styled after S12/S17/S18: accent-once, grey ramp hex string, rotated panel language, space empty-cells, auto-scale/auto-width, degenerate safety (criterion 7).
rec 10 — Split into three commits (chart rewrite / README / S19 scripts+tests), each ≤3 files.
rec 11 — Ensure verify-session-19.sh asserts raw-RGB accent-hue count == 1 and greps for zero `░`; the accent==1 check is the test that fails without the first-global-max accent rule, the no-`░` grep guards criterion 3.

## Handoff Delta
- `+` new: first implementation-advisor handoff for this session (2753 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
