# Session Boot

## Current Session
- **Number:** 28 — IN PROGRESS (delivery + verify green; review + PR + closeout to go)
- **Type:** CODE — sparkline locked to the mudra panel language (v8 shape+shade)
- **Branch:** `session-28-sparkline` (close on branch; main untouched until PR merges)
- **Date last updated:** 2026-09-14

## Repo State Snapshot
- `.ai/SESSION` = 28.
- Remote: `github.com/ifelse-codes/chitra`. `main` has S00–S27 (PR #29 merged the
  S27 candlestick/boxplot lock).
- **S28 delivery**: `sparkline()` re-rendered in the reference/panel language,
  per the founder direction ("ok close it here and lock") on the throwaway v8
  prototype (shape+shade strip: height reads trend, shade reads intensity).
  Retired: the single-teal `theme.colors[0]` strip, `▁▂▃` sub-blocks, braille/
  ascii paths (option accepted, design superseded — progress precedent),
  backtick `toMarkdown`, bare `""` on empty. One accent spent exactly once on
  the peak reading (ties → first); grey tone ramp + `░▒▓` shade texture
  elsewhere (founder's 2026-09-11 ruling). Dashed frame, label on top,
  `SPARKLINE` eyebrow, two rule separators, fact foot with accented peak
  (`n · min · max · last · peak`; `showValue: false` drops `last`). `width`
  keeps column meaning with deterministic even-index downsample; facts
  describe plotted points. Degenerate-safe throughout (framed no-data panel,
  null JSON facts, flat-range full columns, non-finite excluded from plot +
  facts + count, narrow-safe). README carries `### LOCKED — session 28
  design`; docs previews regenerated (sparkline-only diff, drift gate green);
  `dist/` rebuilt (gitignored, playground use).
- Verify: `scripts/verify-session-28.sh` — 17/17 ALL GREEN (core 435/435:
  baseline 430 = S27's 428 + 2 polish tests; −10 old sparkline + 15 new).
  Demo: `scripts/demo-session-28.sh` — exit 0, 4/4 PASS (accent ×4 on peak ·
  grey ×67 · 0 leaks). Summary: `sessions/session-28-summary.md`. Contract:
  `prompts/28-task-sparkline.md` (9 numbered requirements).
- The locked family now spans circular (S09), area (S09), line (S10), bar
  (S12), scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20),
  timeline (S21), gauge (S22), progress (S23), histogram (S25), waterfall +
  funnel + sankey + radar (S26), candlestick + boxplot (S27), **sparkline
  (S28)** — 19 locked.

## Next Session
- **Number:** 29 — candidates: the founder-deferred footer pass (A trim / B
  plain words / B-diet, one dedicated session); `lineModelToSvg` parity; real
  `v0.1.0` release (`NODE_AUTH_TOKEN`); Playwright QA into CI; candle ties-first
  exclusivity test hardening (S27 review note).
- Open in a **new chat** (one session per chat).
