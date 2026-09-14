# Session 27 — Independent Fidelity Review (post-polish re-review from scratch)

## Method controls

- Cold inputs only: read `prompts/27-task-candlestick-boxplot.md` (including binding Founder amendment) and the delivery diff via `git diff --no-color --no-ext-diff $(git merge-base main HEAD) HEAD -- ':(exclude)sessions' ':(exclude)prompts' ':(exclude).ai/*'`.
- Did NOT read forbidden inputs: `sessions/session-27-summary.md`, `sessions/session-27-review.md` (stale ACCEPT), `.ai/STATE.md`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md`, `.ai/ROADMAP.md`, `.ai/KNOWLEDGE.md`.
- Read-only verification only: `scripts/verify-session-27.sh` (20/20 PASS), `scripts/demo-session-27.sh` (8/8 PASS), full core suite (430 PASS), plus live `node dist` renders for 10-date fit and eyebrow de-dupe.
- Prior ACCEPT treated as stale; all 15 items (Req 1–13 + 2 amendment clauses) ruled from scratch on diff identifiers.

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| Req 1 — candlestick tonal, never rainbow (ups solid, downs `┌╌╌┐`/`│  │`/`└╌╌┘`, peak highest-close first-wins solid `█` accent exactly once, wicks in own tone) | SHIPPED | `candlestick.ts: tUp/tones[2], tDown/tones[0], peakIdx strict >`, `isPeak→colorize("█".repeat(candleW),acc)`, `wickCell(kindTone)`, `outlineCell(...┌╌/└╌...)`; census `candle-tonal-census` PASS, `candle-outline-downs` PASS, no `theme.colors[` in source |
| Req 2 — candlestick locked panel (dashed `┌╌/└╌`, uppercase eyebrow, `│`/`+` guide + precision rule, dashed `└╌` baseline, period labels, two `│ ╌ │` rules, width-is-floor + min width) | SHIPPED | `candlestick.ts: frameTop/frameRule/frameRow/frameBottom, yGuide(+ /│), buildBaseline(└╌), effectiveWidth=max(opts.width,gutter+plotCols+4,...,40), CANDLE_MIN=4`; `panel-chrome-both` PASS, uniform-width test PASS, `label-precision-rule` PASS |
| Req 3 — candlestick foot `N <n> · HI <v> · LO <v> · LAST <v>`, LAST accented, true facts | SHIPPED | `candlestick.ts: footPlain + buildSummary() head + colorize(LAST,acc)`; `feet-formats` PASS (`N 3 · HI 115 · LO 95 · LAST 107`, accent present); demo `candle-chrome` PASS |
| Req 4 — candlestick degenerate-safe (empty framed `N 0 · (no data)` null facts, flat visible, non-finite excluded, narrow no RangeError, no NaN/Infinity) | SHIPPED | `candlestick.ts: valid=filter(Number.isFinite×4), empty→yMin/yMax=0, flat yMax===yMin→±1, rowOf clamped, pad/Math.max(0,...)`; `candle-degenerate` PASS; live `dist` empty/flat/mixed/narrow all safe |
| Req 5 — candlestick `toJSON()` additive (`type/data/plain` + `count/high/low/last`, null when empty, options unchanged) | SHIPPED | `candlestick.ts: toJSON(){type,data,plain,count:n,high,low,last}` with `high/low/last=null` when empty; `tojson-additive` PASS (`count 3/high 115/low 95/last 107`) |
| Req 6 — README `### LOCKED: candlestick chart — session 27 design` block | SHIPPED | `packages/core/README.md:+### LOCKED: candlestick chart — session 27 design` with tonal/accent/precision/panel/degenerate/agent-surface bullets; `readme-lock-blocks` PASS |
| Req 7 — boxplot tonal, never rainbow (peak highest-median first-wins box+whiskers+median accent once, others grey ramp + shade by share peak, median distinct) | SHIPPED | `boxplot.ts: peakIdx strict >, isPeak?acc:tones[toneIdx(median)], shadeOf→SPREAD_SHADES[░▒▓], median ───/═══ vs │ edges`; `boxplot-tonal-census` + `boxplot-median-marker` PASS, no `theme.colors[` |
| Req 8 — boxplot locked panel (dashed frame, `SPREAD`/title-upper eyebrow, `│`/`+` guide, dashed baseline, truncated labels, two rules, width floor) | SHIPPED | `boxplot.ts: frameTop(title??BOXPLOT), eyebrow=(title??SPREAD).toUpperCase(), yGuide, buildBaseline(└╌), buildGroupLabels slice(0,sw), GROUP_MIN=7, effectiveWidth=max(...)`; `panel-chrome-both` PASS |
| Req 9 — boxplot foot `GROUPS <n> · MED <v> · PEAK <label> <v>`, PEAK accented, true | SHIPPED | `boxplot.ts: footPlain + buildSummary() colorize(PEAK,acc), med=percentile(50)`; `feet-formats` PASS (`GROUPS 2 · MED … PEAK B 20` accented), demo `GROUPS 3 · MED 6 · PEAK C 16` verified true by sort |
| Req 10 — boxplot degenerate-safe + additive surface (empty `GROUPS 0 · (no data)` null `stats/peakGroup`, single-value safe, non-finite excluded pre-`quartiles()`, `toJSON` keeps `data/labels/stats` + `peakGroup`, options unchanged) | SHIPPED | `boxplot.ts: kept=filter finite, drop-empty-groups, flat ±1, GROUP_MIN pad, toJSON{data,labels:kept.map,stats:empty?null:stats,peakGroup:empty?null:{label,index,median}}`; `boxplot-degenerate` + `tojson-additive` PASS |
| Req 11 — README `### LOCKED: boxplot chart — session 27 design` block | SHIPPED | `packages/core/README.md:+### LOCKED: boxplot chart — session 27 design` with tonal/median/labels/foot/degenerate bullets; `readme-lock-blocks` PASS |
| Req 12 — `scripts/verify-session-27.sh` exits 0 and `scripts/demo-session-27.sh` exits 0 | SHIPPED | verify 20/20 PASS (outline, both censuses, median-marker, chrome, precision, feet, both degen, tojson, source-locked, core-tests, typecheck, candle/box tests, readme, drift, dist, deps, branch); demo 8/8 PASS observed |
| Req 13 — docs previews in sync (`gen:charts:check` green), full suite green, rebuilt `dist/` carries both locks, zero runtime deps | SHIPPED | `chart-drift-gate` PASS, `core-tests-green` 430 PASS, `dist-carries-locks` PASS (dist empty `N 0/GROUPS 0` + `LAST 2`), `zero-runtime-deps` PASS; `artifacts/.../charts.ts` + `ansi-charts.json` regenerated with locked previews |
| Amend-1 — candles auto-fit longest period label in full (4-wide floor kept), no `Jan`/`Jan1` mush on ten dates | SHIPPED | `candlestick.ts: candleW=max(CANDLE_MIN=4,...label.length), labels padEnd(candleW+1) full`; live `dist` 10-date render contains all of `Jan 8/Jan 9/Jan10/Jan11/Jan12/Jan15/Jan16/Jan17/Jan18/Jan19`, preview in `charts.ts` shows full row; unit `fits longest period label` PASS |
| Amend-2 — eyebrow always `OHLC`, frame top alone carries `opts.title` (no two-row echo) | SHIPPED | `candlestick.ts: eyebrow="OHLC" const, frameTop(opts.title??CANDLESTICK)`; live `dist` title `CHRX — 10-Day Price Action` appears once (frame top), eyebrow row `OHLC`; unit `keeps eyebrow OHLC even when title set` PASS; preview shows `CHRX` top + `OHLC` eyebrow |

15 of 15 SHIPPED.

Fakest green: `candlestick-tests fits-longest-label` uses only 3 dates (all length 5) where the old truncation would not mush, so it stays green without proving the 10-date auto-fit — only the regenerated 10-date preview plus manual dist render proves Amend-1.

**Verdict:** ACCEPT

Scope judgment: Full 15-item scope delivered with no re-scoping or regression; polish fixes both amendment defects.

**Review-Inputs-SHA:** de131db07fee6150a8815d463e376f58cdc62d9d41308aa359ab9d8a624c0403
