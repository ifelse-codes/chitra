# Session 01 Summary — Docs-from-lib chart generator

**Milestone:** Docs & examples (story 1 of 4) · **Branch:** `session-01-docs-examples` ·
**Merged:** PR #1 (squash `d4242d8`) → `main` · **Date:** 2026-07-02

## What shipped
- **Single source of truth** — `artifacts/chitra-docs/scripts/chart-specs.ts` renders all 20
  gallery charts through the real `@chitra/core` (imported from source via `tsx`; no `dist/`
  needed).
- **Generator** — `generate-charts.ts` emits `src/data/charts.ts` (`.toPlain()` previews) +
  `src/data/ansi-charts.json` (colored `.toString()`), with a `--check` drift mode.
- **Scripts** — `gen:charts` / `gen:charts:check` in `chitra-docs`; `tsx` devDep added.
- **Regenerated** the shipped gallery data from the library.

## Bugs fixed (surfaced by generating)
- Line preview title drift: `Revenue Growth` (ansi-charts.json) vs `Revenue Trend`
  (charts.ts) → unified.
- Candlestick referenced a **phantom theme `"neon"`** (not in `@chitra/core`) → `"dracula"`.

## Verification
- `scripts/verify-session-01.sh` → **ALL GREEN (4/4)**: core-tests (116), core-typecheck,
  docs-charts-insync, docs-typecheck.
- `scripts/demo-session-01.sh` → exit 0.

## Notes / decisions
- Founder asked for "all of the above"; capped to one story/session by Vajra, so the four
  docs asks were **sequenced** (generator first, as the foundation).
- Repo was not under git at session start — S00/S01 also did `git init`, first push to
  `github.com/ifelse-codes/chitra`, and PR #1.
- Known gap unchanged: `@chitra/core` has no publishable `dist/` build (backlog).

## 3 next options
1. **S02 — Expand examples** (next in milestone): multi-series, all 7 themes, agent
   `toJSON()`/`noColor`. Prompt: `prompts/02-task-expand-examples.md`.
2. **S03 — Polish docs site** (copy/IA/nav), now backed by generated previews.
3. **Backlog — real `dist/` build** for `@chitra/core` so it's npm-shippable + CI workflows.
