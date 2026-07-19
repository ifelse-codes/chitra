# Session 07 Summary — CI workflows

**Milestone:** Backlog → shipped · **Branch:** `session-07-ci-workflows` · **Date:** 2026-07-18

## What shipped
- **`.github/workflows/ci.yml`** — GitHub Actions CI on push to `main` + every pull request, with a
  frozen-lockfile pnpm install and pinned toolchain (Node 26, pnpm 9.12.3, lockfile v9.0). Three jobs:
  - **core** — `@chitra/core` test (116) · typecheck · dist build (ESM + CJS + `.d.ts`)
  - **docs** — `@workspace/chitra-docs` typecheck · build (`typecheck:libs` first, so a fresh clone
    resolves the `lib/*` tsconfig project references whose `dist` is not in git)
  - **chart-drift** — `gen:charts:check` (fails if the generated chart previews drift from the spec source)
- **`scripts/verify-session-07.sh`** — 13 checks: workflow exists, valid YAML, triggers, pins Node + pnpm,
  frozen install, all 6 gates wired, and `@chitra/core` stays green (116 tests). **ALL GREEN (13/13).**
- **`scripts/demo-session-07.sh`** — shows the CI gates, pins, a live drift check, and a green verify run.

## Verification
- `scripts/verify-session-07.sh` → **ALL GREEN (13/13)** (re-run independently, not self-reported).
- `@chitra/core` test → **116/116**; typecheck → exit 0; build → ESM + CJS + `.d.ts` emitted.

## How it was built
Built through a **Vajra dogfood ride-along** (Vajra Session 76) — the task ran on the governed
`vajra claude` instance under chitra's own `.ai/` constitution + hooks. The delivered CI was then
independently re-verified (13/13) before landing. Closes the long-standing backlog item "CI workflows
(README references `.github/workflows/*` that don't exist)".

## Not in scope (carried)
- `release.yml` / publish workflow (backlog).
- The S05 ground-truth remediation debt (stale `.ai/` bookkeeping backfill for S04) — this closeout
  refreshes `STATE.md`/`SESSION-BOOT.md`/`SESSION` to current, but the S04 verify/demo/summary backfill
  and the closeout-integrity gate remain open.
