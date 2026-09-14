# Session Boot

## Current Session
- **Number:** 27 — COMPLETE (closeout gate + PR)
- **Type:** CODE — candlestick + boxplot locked to the mudra panel language
- **Branch:** `session-27-candlestick-boxplot` (close on branch; main untouched until PR merges)
- **Date last updated:** 2026-09-13

## Repo State Snapshot
- `.ai/SESSION` = 27.
- Remote: `github.com/ifelse-codes/chitra`. `main` has S00–S26 (PR #28 merged the
  S26 waterfall/funnel/sankey/radar lock).
- **S27 shipped**: `candlestick()` + `boxplot()` re-rendered in the reference/panel
  language, per the founder direction ("candlestick boxplot migrate first"; neither
  chart had an audit mockup — the audit queue is empty after S26 — so the S18–S26
  family language applies by analogy, waterfall down-outline precedent for bearish
  candles). Two stories by explicit founder direction (1-story rule waived,
  disclosed). Retired: `theme.colors[2]/[5]` green/red candle flood, per-group
  `theme.colors[si % n]` box rainbow, decimal y-label sprawl, bare titles, solid
  baselines, the `Math.max(...[])` empty crash, `toRow` NaN rows, boxplot's
  `┼─┼`/`repeat` RangeError and `rawData[0]` crash. One accent spent exactly once
  per chart (peak close candle, peak median group); grey tone ramp + `░▒▓` shade
  texture elsewhere (founder's 2026-09-11 ruling). Adaptive price precision
  (integers when range spans 100+, else ≤1dp/≤2dp trimmed — approved at PLAN, never
  float sprawl, never silent integer rounding). Dashed frames, metric eyebrows
  (`OHLC`/`SPREAD`), two rule separators, fact feet with accented key fact
  (`N · HI · LO · LAST` / `GROUPS · MED · PEAK`). Degenerate-safe throughout
  (framed no-data panels, null JSON facts, flat-range ±1 guard, non-finite
  excluded, narrow-safe). README carries two `### LOCKED — session 27 design`
  blocks; candlestick docs description de-rainbowed.
- Verify: `scripts/verify-session-27.sh` — 20/20 ALL GREEN (core 428/428, +37
  candle/box tests). Demo: `scripts/demo-session-27.sh` — exit 0, 8/8 PASS.
  `dist/` rebuilt (playground runs `dist`; note: dist escapes `·` as `\xB7`, so
  the dist gate renders through the bundle instead of grepping it).
- Summary: `sessions/session-27-summary.md`. Review: `sessions/session-27-review.md`
  — **independent cold pass ACCEPT, attested** (13 of 13 SHIPPED;
  `Review-Inputs-SHA 313a52c5…2822531a` binds the verdict to the committed diff +
  prompt). Fakest green (disclosed, test-strength only, code correct): the candle
  ties-first test asserts accent presence, not second-candle exclusivity — candidate
  S28 hardening. Fidelity + attestation gates pass WITHOUT any waiver.
- The locked family now spans circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), timeline (S21),
  gauge (S22), progress (S23), histogram (S25), waterfall + funnel + sankey +
  radar (S26), **candlestick + boxplot (S27)** — 18 locked.

## Next Session
- **Number:** 28 — candidates: the founder-deferred footer pass (A trim / B
  plain words / B-diet, one dedicated session); `lineModelToSvg` parity; real
  `v0.1.0` release (`NODE_AUTH_TOKEN`); Playwright QA into CI; candle ties-first
  exclusivity test hardening (S27 review note).
- Open in a **new chat** (one session per chat).
