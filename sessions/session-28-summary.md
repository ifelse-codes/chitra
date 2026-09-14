# Session 28 — sparkline LOCKED to the mudra panel language

- **Type:** CODE. Branch `session-28-sparkline` from `origin/main` (PR #29 merged).
- **Contract:** founder direction in-chat ("ok close it here and lock") on the v8
  shape+shade prototype (throwaway `…/opencode/spark-heat-compare.html`, lib
  untouched): the heatmap strip grammar with a pulse — height reads the trend,
  shade reads the intensity. One story. No audit mockup exists for sparkline;
  S18–S27 family language applied by analogy (heatmap cells + histogram
  mode-peak + progress superseded-style precedent for `renderer`).
- **Open questions resolved (approved):** all-purple theme; v8 over the
  heatmap-flat-strip, mini-area, and sensor-table variants (all prototyped,
  all rejected with reasons on record); facts describe plotted points.

## What shipped (Req 1–8)

- **Sparkline (Req 1–6):** every reading is one 2-wide column, ≤4 rows tall by
  share of range; grey ramp + matching `░▒▓` glyph by share (2026-09-11
  shade-texture ruling; 2-wide so dithers render solid in browsers); peak
  (ties → first) solid `█` accent exactly once. Dashed frame, label on top,
  `SPARKLINE` eyebrow, 2 rules. Foot `n · min · max · last · peak` (peak
  accented; `showValue: false` drops `last`). `width` = plotted columns,
  deterministic even-index downsample; panel auto-expands (floor, never cap).
  Empty/all-non-finite → framed `n 0 · (no data)` + null facts (old code
  returned bare `""`); flat range full columns; non-finite excluded from
  plot, facts, and count; narrow-safe. `toJSON` keeps `type`/`data`/`label`/
  `plain` += `count`/`min`/`max`/`last`/`peak {index,value}`. Retired:
  `theme.colors[0]` teal flood, `▁▂▃` strip, braille/ascii paths (option
  accepted, design superseded — progress precedent), backtick `toMarkdown`.
- **Gates (Req 7–8):** `verify-session-28.sh` 17/17 (vocab, tonal census,
  ties-first exclusivity, chrome, feet, renderer+width, degen, toJSON,
  source-lock, core tests + typecheck, README block, drift gate,
  dist-renders-locked, zero-deps, branch). `demo-session-28.sh` exit 0, 4/4
  PASS (accent ×4 on peak · grey ×67 · 0 leaks). Docs previews regenerated
  (sparkline-only diff, drift green), `dist/` rebuilt (untracked, playground
  use). Full suite **435/435** (baseline 430: S27's 428 + 2 polish tests;
  −10 old sparkline + 15 new), typecheck clean.

## Commits (all ≤3 files)

- Pending founder commit approval (asked post-verify, per constitution).

## Assumptions (max 2, both approved)

1. v8 (2-wide shade+shape, 4 rows, `n·min·max·last·peak`) is the fidelity
   target. 2. Downsampling = even-index sampling; facts describe plotted
   points (`data` keeps input).

## Fidelity map

Req 1–6 sparkline SHIPPED · Req 7–8 gates SHIPPED (8/8 claimed; independent
cold review in `sessions/session-28-review.md` disposes).
