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
- **S03 — Polish docs site** ✅ DONE
  Copy, IA, and navigation on `artifacts/chitra-docs` now point users to install,
  quickstart, chart gallery, and AI-agent output. Fixed stale theme names and added
  verify/demo scripts. verify-session-03 ALL GREEN.
- **S04 — README / getting-started** ← next
  Sharpen `packages/core/README.md` + top-level adopter
  path; examples provably match lib output.

## Backlog (not yet scheduled)
- ✅ **S06** — Real publishable `dist/` build for `@chitra/core` (ESM + CJS + `.d.ts`, zero deps).
- ✅ **S07** — CI workflows (`.github/workflows/ci.yml`: core · docs · chart-drift gates, pinned toolchain).
- `release.yml` / publish workflow (npm publish on tag).
- Flesh out `artifacts/api-server` beyond `/healthz` if the hosted API is pursued.
- S05 ground-truth remediation still open: S04 verify/demo/summary backfill + a closeout-integrity gate.

## Guardrails carried forward (see [[knowledge]])
- Zero runtime deps · keep `toPlain()`/`toJSON()` agent output · 116 tests green ·
  public API stability.
