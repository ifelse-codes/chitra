# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S00 onboarding, 2026-07-02.)

## Active Branch
`main` — git repo initialized 2026-07-02 (baseline import commit). S01 work branches from here.

## What Currently Works (observed, not claimed)
- `pnpm install` — clean (~25s). One benign peer-dep warning (esbuild-plugin-pino vs
  esbuild 0.27.3 in `artifacts/api-server`).
- `pnpm --filter @chitra/core run test` — **116/116 pass**, 7 files, ~0.7s.
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `pnpm run typecheck` (full workspace: libs build + api-server + chitra-docs +
  mockup-sandbox + scripts) — **exit 0**.
- `@chitra/core` library: 20 charts, 3 renderers, 7 themes, `ChartResult` output surface —
  present and typechecked.

## What Is Broken / Incomplete
- **No publishable build**: core `build` script is `tsc --noEmit`; the `dist/` bundle its
  `package.json` `exports` points at is not produced. Not npm-shippable as-is.
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.
- No `scripts/verify-session-00.sh` / `demo-session-00.sh` (onboarding is docs-only, exempt).

## What Is In Progress
- **S00 (this session):** brownfield onboarding — seeding `.ai/` files from verified reality.
  Complete pending founder sign-off.
- **S01 (next):** Docs & examples milestone (founder-chosen). See [[roadmap]] and
  `prompts/01-task-kickoff.md`.

## Cost Tracking
- Cumulative: $0.00
