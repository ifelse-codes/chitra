# Session 07 — CI workflows (backlog, CI-first)

## Goal (one story)
Gate every push to `main` and every PR with CI: core tests/typecheck/build, docs
typecheck/build, and a chart-drift check — on a pinned, frozen toolchain.

## Context (from S04/S06)
- S04 sharpened README / getting-started; S06 shipped a real publishable `dist/`.
- 116 core tests, `pnpm run typecheck` full workspace, docs `gen:charts:check` all green.

## Deliverables
- `.github/workflows/ci.yml` — on push to `main` + every PR: 3 jobs
  (core test·typecheck·build · docs typecheck·build · `gen:charts:check` drift),
  pinned Node 26 / pnpm 9.12.3, frozen install.
- S07 verify and demo scripts.

## Exit Criteria
- `scripts/verify-session-07.sh` exits 0 (13 checks).
- Core tests green (116), docs typecheck/build + chart-drift green.

## Guardrails
- Branch `session-07-ci-workflows` from `main`.
- Commits need approval token.
- Invariants: zero runtime deps, public API stability, generated previews stay source-of-truth.
- Max 2 assumptions; <=3 files per atomic commit.
