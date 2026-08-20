# Session 12 Summary — bar chart reference-locked

**Branch:** `session-12-bar-chart-lock`  
**Date:** 2026-08-20  
**Prompt:** `prompts/12-task-bar-chart-lock.md`

## Criterion map

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | `bar()` uses one accent + grey tone ramp — no `theme.colors[s % n]` rainbow | SHIPPED | `barColorFor()` in `bar.ts` returns `acc` for the globally highest bar and `toneOrder[]` for all others. `grep "theme.colors\["` on `bar.ts` returns zero matches. |
| 2 | Dashed panel frame + eyebrow row + `+` y-guide top + `+` x-axis ticks | SHIPPED | `buildLines()` calls `frameTop(..., true)` (dashed), `frameRule`, `frameRow(eyebrow)`. `yGuide()` returns `"+"` at row 0 and `"│"` elsewhere. `buildXTicks()` places `"+"` at the centre of each bar group. Confirmed visually and by smoke tests in verify script. |
| 3 | Per-series summary row (MIN/MAX/AVG/LAST) present under chart | SHIPPED | `buildSummary()` calls `seriesStats()` which returns `{min, max, avg, last}`; formats as `· min N · max N · avg N · last N`. Peak-series `max N` rendered in accent. |
| 4 | `circular*.ts`, `area.ts`, `line.ts` byte-identical to `main` | SHIPPED | `git diff main -- packages/core/src/charts/pie.ts donut.ts area.ts line.ts line-model.ts` returns empty diff. Verify script checks confirmed this via `wc -l` of diff output. |
| 5 | `### LOCKED: bar chart — session 12 design` in `README.md`; `.ai/KNOWLEDGE.md` synced | SHIPPED | `README.md` has the full LOCKED section at `## License` boundary. `KNOWLEDGE.md` has "Bar chart locked (S12)" in the LOCKED design bullet list. |
| 6 | `pnpm --filter @chitra/core run test` and `pnpm typecheck` exit 0 | SHIPPED | 163/163 tests pass (up from 148 pre-S12; 159 after the first pass, +4 more added when the cold review's findings were fixed — a real cross-theme rainbow check, a real accent/tone color check replacing a color-blind one, and two sparkline-presence regression tests). Typecheck exits 0. |
| 7 | `scripts/verify-session-12.sh` exits 0; `scripts/demo-session-12.sh` exits 0 | SHIPPED | Verify: **28/28 ALL GREEN** (added `bar-summary-spark-not-dead`, an execute-based regression check for the dead-sparkline finding below). Demo: exit 0. |
| 8 | `sessions/session-12-summary.md` (per-criterion); `sessions/session-12-review.md` (cold fidelity pass) | SHIPPED | This file (corrected, staged). `sessions/session-12-review.md` holds two passes: pass 1 REJECT (found the dead sparkline and this file's own then-false review-existence claim), pass 2 ACCEPT (independently re-derived the sparkline fix's correctness by hand). Pass 2 ALSO caught this file misattributing which test fixed the color-check gap and citing a stale test count — both corrected in this same pass, disclosed in the Correction section below, not quietly fixed. |

## What was not built

- **SVG/web bar renderer** (`BarChartModel` / `barModelToSvg`): `bar()` has no shared model like `LineChartModel`. The bar chart is terminal-only. Stated plainly in the demo summary table.
- **`sparkline.ts` / `histogram.ts` lock**: the session prompt scoped these out explicitly as separate future work.

## Correction (post cold-review-1, REJECT)

This session's first pass shipped with two real defects, both caught by an independent cold
review, both now fixed and independently re-verified before landing:

1. **The sparkline was dead code.** `sparkStr()` existed and was called, but the panel's own
   auto-width formula sized itself to exactly fit the summary text, leaving zero (in fact
   negative) room for the spark — it silently rendered as `""` in every demo/test call shipped as
   proof. Fixed: `bar.ts` now reserves real width (`SPARK_MIN`/`SPARK_RESERVE`) for the spark
   when the summary row is the panel's binding size constraint. Verified with a new regression
   test (`bar.test.ts`) and a new execute-based verify check (`bar-summary-spark-not-dead`) that
   both run the exact demo example and assert a real spark glyph appears.
2. **This file falsely claimed `sessions/session-12-review.md` already existed** as evidence for
   criterion 8's SHIPPED verdict, before that file had ever been produced. That was a fabricated
   evidence citation, not a stale reference — disclosed here plainly rather than quietly edited
   away. The real review now exists and reached REJECT on the first pass, correctly.

**Correction to an earlier version of this note:** the fix did NOT replace `bar.test.ts`'s
original "applies accent to the peak bar and tone ramp to all others (no rainbow)" test — that
test is still present, unchanged, and still runs in `noColor: true` mode, asserting only
`toContain("█")` and `toContain("max 99")`. It cannot detect a rainbow-color regression and
never could; a second cold review caught this earlier summary crediting the wrong test as "the
fix." The real fix is a NEW, separate test added alongside it:
`"colors the peak bar with theme.accent and every other bar with a theme.tones entry (real color
check)"`, which renders WITH color (`showAxes: false` to isolate the plot from chrome), extracts
every ANSI code immediately preceding a `█` glyph, and asserts each is either `theme.accent` or a
member of `theme.tones` — genuinely capable of failing on a rainbow regression. A second new test,
`"never uses a raw theme.colors[] rainbow entry..."`, repeats the same check across all seven
built-in themes.

## Fakest green

**The still-present `"applies accent to the peak bar..."` test in `bar.test.ts` is a real, live
fakest green — not fixed, left in place.** It runs in `noColor: true` mode and asserts only that
`"█"` and `"max 99"` appear; this passes identically whether the color logic is correct, a
hardcoded rainbow, or deleted entirely. It is harmless only because a second, genuinely
behavioral test (named above) now covers the same claim with real color assertions. The
`bar-no-rainbow-colors` verify-script check (a `grep -q '! theme.colors['` source match) has the
same property — real, but backstopped by the behavioral tests, never sufficient alone.

## Command to render a bar chart

```bash
cd packages/core && node_modules/.bin/tsx -e "
import { bar } from './src/charts/bar.js';
bar({
  data: [42, 67, 38, 55, 72],
  labels: ['Jan','Feb','Mar','Apr','May'],
  title: 'Monthly Deploys',
}).render();
"
```

## Next session candidates

1. **Lock `sparkline.ts`** to the shared design language (tone ramp, panel chrome, summary).
2. **`lineModelToSvg` alignment**: bring the SVG web renderer fully in line with the terminal output (colour-matched series, `+` x-ticks, per-series stat boxes).
3. **Release `v0.1.0`**: tag and publish `@chitra/core` to npm (`NODE_AUTH_TOKEN` must be set).
