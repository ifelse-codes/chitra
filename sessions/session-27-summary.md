# Session 27 — candlestick + boxplot LOCKED to the mudra panel language

- **Type:** CODE. Branch `session-27-candlestick-boxplot` from `origin/main` (PR #28 merged).
- **Contract:** `prompts/27-task-candlestick-boxplot.md`. Two stories by explicit founder
  direction ("candlestick boxplot migrate first") — 1-story rule waived, disclosed in the
  prompt. Neither chart had an audit mockup (queue empty after S26); S18–S26 family language
  applied by analogy, waterfall down-outline precedent for bearish candles.
- **Open question resolved (approved):** adaptive price precision — integers when the range
  spans 100+, else ≤1dp (range ≥ 10) or ≤2dp trimmed, never float sprawl, never silent
  integer rounding. Shared by both charts (`axisPriceFmt`); feet use the same rule.

## What shipped (Req 1–13)

- **Candlestick (Req 1–6):** ups solid `▓` on mid-grey, downs dashed outline
  (`┌╌╌┐`/`│  │`/`└╌╌┘`, waterfall language), peak close (ties → first) solid `█`
  accent spent exactly once; wicks stay in kind tone (accent touches only `█` bodies +
  non-block text). Dashed frame, `OHLC` eyebrow, `│`/`+` guide, `└╌` baseline, truncated
  period labels, 2 rules. Foot `N · HI · LO · LAST` (LAST accented). Empty → framed
  `N 0 · (no data)` + null facts; flat range pads ±1; non-finite excluded; narrow-safe.
  `toJSON` += `count`/`high`/`low`/`last`. Retired: `theme.colors[2]/[5]` flood, decimal
  sprawl, bare title, solid baseline, `Math.max(...[])` crash, `toRow` NaN.
- **Boxplot (Req 7–11):** peak median group (ties → first) box+whiskers+caps+median in
  accent once; others grey ramp + `░▒▓` fill by share of peak median. Median is a
  horizontal `───`/`═══` run vs vertical `│` edges. `SPREAD` eyebrow, same panel chrome.
  Foot `GROUPS · MED · PEAK <label> <v>` (PEAK accented). Empty → `GROUPS 0 · (no data)` +
  null `stats`/`peakGroup`; single-value safe; non-finite excluded pre-`quartiles()`;
  groups with no finite samples dropped with labels. `toJSON` keeps
  `data`/`labels`/`stats` += `peakGroup {label,index,median}`. Retired: per-group rainbow,
  `┼─┼`/`repeat` RangeError, `rawData[0]` crash.
- **Gates (Req 12–13):** `verify-session-27.sh` 20/20 (tonal censuses, outline/median proofs,
  chrome, precision, feet, degen, toJSON, source-lock, core tests + typecheck, README blocks,
  drift gate, dist-renders-locked, zero-deps, branch). `demo-session-27.sh` exit 0, 8/8 PASS.
  Docs previews regenerated (drift green; candlestick spec description de-rainbowed), `dist/`
  rebuilt (untracked, playground use). Full suite **428/428** (+37 new), typecheck clean.

## Commits (all ≤3 files)

1. `6c6f25e` candle render + tests · 2. `53869fd` box render + tests · 3. `e8d903c` README
   2 LOCK blocks · 4. `d0248f6` docs spec + previews · 5. `4c802c8` verify + demo scripts.

## Assumptions (max 2, both approved)

1. Boxplot shares the candle precision rule. 2. No `positiveColor`-style overrides (neither
   chart had them; waterfall precedent not needed).

## Fidelity map

Req 1–6 candle SHIPPED · Req 7–11 box SHIPPED · Req 12–13 gates SHIPPED (13/13 claimed;
independent cold review in `sessions/session-27-review.md` disposes).
