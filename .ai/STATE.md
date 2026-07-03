# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S02 closed, 2026-07-03.)

## Active Branch
`main` — S02 merged via PR #3 (squash `c382802`). Remote:
`github.com/ifelse-codes/chitra`. Next session branches from here.

## What Currently Works (observed, not claimed)
- `pnpm install` — clean (~25s). One benign peer-dep warning (esbuild-plugin-pino vs
  esbuild 0.27.3 in `artifacts/api-server`).
- `pnpm --filter @chitra/core run test` — **116/116 pass**, 7 files, ~0.7s.
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `pnpm run typecheck` (full workspace: libs build + api-server + chitra-docs +
  mockup-sandbox + scripts) — **exit 0**.
- `@chitra/core` library: 20 charts, 3 renderers, 7 themes, `ChartResult` output surface —
  present and typechecked.
- **S01 docs generator** (`artifacts/chitra-docs/scripts/`): `chart-specs.ts` (single source)
  + `generate-charts.ts` render all 20 charts through `@chitra/core` → regenerate
  `src/data/charts.ts` + `ansi-charts.json`. `pnpm gen:charts` writes; `gen:charts:check`
  fails on drift. `scripts/verify-session-01.sh` — ALL GREEN (4/4); `demo-session-01.sh`
  exits 0.
- **S02 expanded examples** (`examples/basic.ts`): multi-series bar chart, theme tour
  across all 7 themes, and MCP-tool-shaped AI agent output. `scripts/verify-session-02.sh`
  — **ALL GREEN (6/6)**; `demo-session-02.sh` exits 0.

## What Is Broken / Incomplete
- **No publishable build**: core `build` script is `tsc --noEmit`; the `dist/` bundle its
  `package.json` `exports` points at is not produced. Not npm-shippable as-is.
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.

## Fixed this session
- Examples now demonstrate multi-series charts, every theme, and AI-agent output.
- Added automated verify + demo scripts for S02.

## What Is In Progress
- Nothing active. **S03 (polish docs site)** is next — see [[roadmap]].
  `prompts/03-task-polish-docs.md` does not exist yet; create it at kickoff.

## Cost Tracking
- Cumulative: $0.00
