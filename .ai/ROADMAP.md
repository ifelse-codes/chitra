# chitra — Working Roadmap

**Updated at every closeout.** North-star: *the best terminal chart lib ever created* —
zero-dep, AI-first, delightful. (Seeded S00; sequenced S01, 2026-07-02.)

## Milestone: Docs & examples
- **S01** ✅ — Docs-from-lib generator (PR #1, squash `d4242d8`).
- **S02** ✅ — Expand examples (PR #3).
- **S03** ✅ — Polish docs site.
- **S04** ✅ — README / getting-started.

## Backlog (not yet scheduled)
- ✅ **S06** — Real publishable `dist/` build for `@chitra/core` (ESM + CJS + `.d.ts`, zero deps).
- ✅ **S07** — CI workflows (`.github/workflows/ci.yml`: core · docs · chart-drift gates, pinned toolchain).
- ✅ **Session 08 (S08)** — release.yml publish workflow (this session). v* tag push → re-runs S07
  gates → `pnpm publish --access public` with `NODE_AUTH_TOKEN`. Plus line-chart
  SV-grade upgrade, shared `LineChartModel` + `toSVG()` web renderer, docs SVG
  output, and the terminal dashboard panel (`timestamp`/`status`/`summary`).
- Flesh out `artifacts/api-server` beyond `/healthz` if the hosted API is pursued.
- Exercise a real release: tag `v0.1.0` (needs `NODE_AUTH_TOKEN` secret in repo settings).
- S05 ground-truth remediation still open: S04 verify/demo/summary backfill + a closeout-integrity gate.

## Guardrails carried forward (see [[knowledge]])
- Zero runtime deps · keep `toPlain()`/`toJSON()` agent output · 121 tests green ·
  public API stability.
