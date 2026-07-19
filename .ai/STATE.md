# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S07 closed, 2026-07-18.)

## Active Branch
None — between sessions (S07 complete). Remote: `github.com/ifelse-codes/chitra`. Next session branches
from `main`.

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **116/116 pass**.
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `pnpm --filter @chitra/core run build` — **real publishable dist** (ESM `index.js` + CJS `index.cjs` +
  `index.d.ts`); zero runtime deps; ESM+CJS each expose 44 exports (S06).
- `pnpm --filter @workspace/chitra-docs run gen:charts:check` / `typecheck` / `build` — **exit 0**.
- **`.github/workflows/ci.yml` (S07)** — CI on push to `main` + every PR: 3 jobs (core test·typecheck·build
  · docs typecheck·build · `gen:charts:check` drift), pinned Node 26 / pnpm 9.12.3, frozen install.
- `scripts/verify-session-07.sh` — **ALL GREEN (13/13)**; `demo-session-07.sh` — exit 0.
- `@chitra/core` library: 20 charts, 3 renderers, 7 themes, `ChartResult` output surface.

## What Is Broken / Incomplete
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.
- **S05 ground-truth remediation debt (partially open):** this closeout refreshes STATE/SESSION-BOOT/
  SESSION to current, but the S04 verify/demo/summary backfill and a closeout-integrity gate remain open;
  `.ai/KNOWLEDGE.md` should be re-checked for the stale "NOT a git repo" falsehood.

## Milestones done
- **S01** docs-from-lib chart generator · **S02** expanded examples · **S03** docs-site polish ·
  **S04** README / getting-started · **S05** NO-CODE ground-truth · **S06** real publishable dist build ·
  **S07** CI workflows (this session).

## What Is In Progress
- None — S07 landed on `main`. **Next: S08** — candidates: `release.yml`/publish workflow · flesh out
  `artifacts/api-server` · the remaining S05 GT remediation. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist build + S07 CI built via Vajra dogfood runs, billed to Vajra).
