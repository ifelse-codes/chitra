# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S08 closed, 2026-08-01.)

## Active Branch
None — between sessions (S08 complete). Remote: `github.com/ifelse-codes/chitra`.
Next session branches from `main`.

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **121/121 pass**.
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `pnpm --filter @chitra/core run build` — **real publishable dist** (ESM `index.js` +
  CJS `index.cjs` + `index.d.ts`); zero runtime deps; ESM+CJS each expose 44+ exports.
- `pnpm run typecheck` (full workspace) — **exit 0**.
- **`.github/workflows/ci.yml` (S07)** — CI on push to `main` + every PR (core · docs ·
  chart-drift), pinned Node 26 / pnpm 9.12.3, frozen install.
- **`.github/workflows/release.yml` (S08)** — v* tag push only; 3 CI gates as `needs:`
  of a `publish` job (`--access public`, `NODE_AUTH_TOKEN`), pinned toolchain.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. Line chart: SV-grade ascii renderer, shared `LineChartModel` +
  `toSVG()`, terminal dashboard panel (`timestamp` / `status` / `summary` options).
- **Docs** (`artifacts/chitra-docs`): chart pages render real core SVG output;
  `gen:charts:check` drift gate green.
- `scripts/verify-session-08.sh` — **ALL GREEN (15/15)**; `demo-session-08.sh` — exit 0.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` tracked and wired
  (`core.hooksPath .githooks`), `.ai/hooks/*` committed.

## What Is Broken / Incomplete
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.
- **S05 ground-truth remediation debt (still open):** S04 verify/demo/summary backfill
  and a closeout-integrity gate remain; `.ai/KNOWLEDGE.md` "NOT a git repo" falsehood
  was corrected at S08 closeout.
- First real release (tag `v0.1.0`) not yet exercised — needs `NODE_AUTH_TOKEN`
  secret in repo settings.

## Milestones done
- **S01** docs-from-lib chart generator · **S02** expanded examples · **S03** docs-site
  polish · **S04** README / getting-started · **S05** NO-CODE ground-truth · **S06** real
  publishable dist build · **S07** CI workflows · **S08** release.yml + line/SVG/dashboard
  upgrades (this session).

## What Is In Progress
- None — S08 landed on `main`. **Next: S09** — candidates: flesh out
  `artifacts/api-server` beyond `/healthz` · the remaining S05 GT remediation ·
  exercise a real `v0.1.0` release. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood
  runs, billed to Vajra).
