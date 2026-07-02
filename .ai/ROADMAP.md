# chitra — Working Roadmap

**Updated at every closeout.** North-star: *the best terminal chart lib ever created* —
zero-dep, AI-first, delightful. (Seeded S00; sequenced S01, 2026-07-02.)

## Milestone: Docs & examples
Founder wants "all of the above." Vajra caps one story/session, so the four asks are
**sequenced** — generator first because the other three should render *generated-correct*
output, not hand-pasted strings.

- **S01 — Docs-from-lib generator** ✅ DONE (PR #1, squash `d4242d8`)
  Single spec source (`chart-specs.ts`) renders every chart via `@chitra/core` →
  regenerates `charts.ts` + `ansi-charts.json`; `gen:charts:check` fails on drift. Fixed
  a title drift + phantom `"neon"` theme. verify-session-01 ALL GREEN.
- **S02 — Expand examples** ← next
  Deepen `examples/basic.ts`: multi-series, all 7 themes, agent `toJSON()`/`noColor` usage.
  Reuse the S01 spec source where possible.
- **S03 — Polish docs site** — copy, IA, navigation on `artifacts/chitra-docs` (App.tsx),
  now backed by generated previews.
- **S04 — README / getting-started** — sharpen `packages/core/README.md` + top-level adopter
  path; examples provably match lib output.

## Backlog (not yet scheduled)
- Real publishable `dist/` build for `@chitra/core` (current `build` is `tsc --noEmit`).
- CI workflows (README references `.github/workflows/*` that don't exist).
- Flesh out `artifacts/api-server` beyond `/healthz` if the hosted API is pursued.

## Guardrails carried forward (see [[knowledge]])
- Zero runtime deps · keep `toPlain()`/`toJSON()` agent output · 116 tests green ·
  public API stability.
