# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S01 in progress, 2026-07-02.)

## Active Branch
`session-01-docs-examples` (off `main`). git initialized 2026-07-02.

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
  fails on drift. `scripts/verify-session-01.sh` — **ALL GREEN (4/4)**; `demo-session-01.sh`
  exits 0.

## What Is Broken / Incomplete
- **No publishable build**: core `build` script is `tsc --noEmit`; the `dist/` bundle its
  `package.json` `exports` points at is not produced. Not npm-shippable as-is.
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.

## Fixed this session
- Docs previews were hand-pasted and had drifted (line title `Revenue Growth` in
  ansi-charts.json vs `Revenue Trend` in charts.ts) — now generated, so they can't diverge.
- Candlestick doc referenced phantom theme `"neon"` → corrected to `"dracula"`.

## What Is In Progress
- **S01:** Docs-from-lib generator — code complete, verify green; pending commit + PR +
  closeout. See [[roadmap]]. Next in milestone: S02 expand examples.

## Cost Tracking
- Cumulative: $0.00
