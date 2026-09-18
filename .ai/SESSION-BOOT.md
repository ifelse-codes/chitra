# Session Boot

## Current Session
- **Number:** 28 — IN PROGRESS (code complete + committed; cold review + PR + closeout to go)
- **Type:** CODE — chart composability (`frame`/`compact`/`maxWidth`/`toContent`/exact-`height` on all 20 charts) + 20-chart SRE dashboard (CLI + 2-col web grid)
- **Branch:** `session-28-sparkline` (close on branch; main untouched until PR merges)
- **Date last updated:** 2026-09-18

## Repo State Snapshot
- `.ai/SESSION` = 28.
- Remote: `github.com/ifelse-codes/chitra`. `main` has S00–S27 (PR #29 merged the
  S27 candlestick/boxplot lock). S28 sparkline lock delivered earlier on this
  branch (5 atomic commits + verify + demo + cold ACCEPT 9/9).
- **This chat (S28 extension, 12 atomic commits, all ≤3 files, hooks green):**
  `BaseChartOptions` gains `frame?` (default true), `compact?` (default false),
  `maxWidth?` (ANSI-safe per-line clip via `truncateAnsi`); `ChartResult` gains
  `toContent()` (body-only re-render, `toPlain()` semantics unchanged);
  explicit `height` is now body-exact on the 10 charts that ignored it
  (horizontalBar, gauge, timeline, pie, donut, heatmap, funnel, sankey,
  sparkline, progress) via `fitBodyLines`/`normalizeHeight`; the 10 plot charts
  already respected it. `SparklineOptions`/`ProgressOptions` gain
  frame/compact/height/maxWidth parity. `index.ts` exports `frameTop`,
  `frameBottom`, `frameRow`, `frameRule`, `truncateAnsi`.
- Tests: `packages/core/tests/composability.test.ts` (+7: compact strips box
  corners, body-exact heights, toContent clean, maxWidth caps, JSON unaffected,
  defaults unchanged). Suite: **442/442 green** (was 435), `typecheck` clean.
  (`pnpm run lint` unrunnable — eslint binary not installed; pre-existing.)
- Dashboard: `playground/sre-dashboard/` committed (sim, CLI `--once`/live,
  `sre-server.ts` :4173). Web is a 2-col × 10-row no-scroll grid, every tile
  exactly 3 rows, client-measured widths (`/cells?single=&wide=`), 2s refresh.
  CLI `--once` = 158 lines, ≤78 wide.
- Verify: `pnpm test` + `tsc --noEmit` green on the committed tree (no
  session verify script was created this chat — owed if the belt requires it).

## Next Session
- **Number:** 29 — cold review of the 12 S28-extension commits → PR
  `session-28-sparkline` → `main` → closeout. Then prior candidates:
  founder-deferred footer pass; `lineModelToSvg` parity; `v0.1.0` release;
  Playwright QA into CI; candle ties-first test hardening.
- Open in a **new chat** (one session per chat).
