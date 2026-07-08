# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S03 closed, 2026-07-03.)

## Active Branch
`session-03-polish-docs` — S03 implementation complete and ready for PR. Remote:
`github.com/ifelse-codes/chitra`. Next session branches from `main` after S03 merges.

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **116/116 pass**, 7 files.
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `pnpm --filter @workspace/chitra-docs run gen:charts:check` — **exit 0**.
- `pnpm --filter @workspace/chitra-docs run typecheck` — **exit 0**.
- `PORT=5000 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run build` — **exit 0**.
- `scripts/verify-session-03.sh` — **ALL GREEN (8/8)**.
- `scripts/demo-session-03.sh` — **exit 0**.
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
- **S03 docs polish** (`artifacts/chitra-docs/src/App.tsx` + `index.css`): improved
  start-here navigation, homepage route cards, corrected theme copy, and clearer AI-agent
  output path.

## What Is Broken / Incomplete
- **No publishable build**: core `build` script is `tsc --noEmit`; the `dist/` bundle its
  `package.json` `exports` points at is not produced. Not npm-shippable as-is.
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.

## Fixed this session
- Docs site now routes users through Install → Quickstart → Chart gallery → Agent output.
- Removed stale `neon` theme references from docs-site copy.
- Added S03 automated verify + demo scripts.

## What Is In Progress
- S03 closeout / PR publication.
- **S04 (README / getting-started)** is next — see [[roadmap]].
  `prompts/04-task-readme-getting-started.md` does not exist yet; create it at kickoff.

## Cost Tracking
- Cumulative: $0.00
