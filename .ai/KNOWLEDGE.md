# chitra — Knowledge Base

**Permanent facts only. Reloaded every session.** (Seeded S00 brownfield onboarding, 2026-07-02.)

## What chitra is
- **`@chitra/core`** (`packages/core/`, v0.1.0, MIT) — the product: a zero-runtime-dependency
  TypeScript terminal charting library. "Beautiful visualizations for terminals, agents, and
  modern developer workflows." 20 chart types, 3 renderers (braille/blocks/ascii), 7 themes.
- Around the lib sits a **Replit-scaffolded full-stack** (all in-scope per founder):
  - `artifacts/chitra-docs/` — React 19 + Vite + Tailwind v4 + shadcn/ui docs/marketing site
    (renders chitra output; `src/data/charts.ts`, `src/data/ansi-charts.json`).
  - `artifacts/api-server/` — Node API server (esbuild bundle, pino logger; only `/healthz`
    route so far).
  - `artifacts/mockup-sandbox/` — Vite sandbox.
  - `lib/api-spec/openapi.yaml` — OpenAPI 3.1 source of truth (title `Api` — do NOT rename).
  - `lib/api-zod/` — zod schemas generated from the OpenAPI spec.
  - `lib/api-client-react/` — orval-generated TanStack Query client.
  - `lib/db/` — drizzle-orm schema.

## Stack & tooling
- pnpm workspaces (pnpm 9.12). Node 26 local (README claims Node 24; CI targets 20/22/24).
  TypeScript 5.9. ESM throughout.
- **pnpm only** — root `preinstall` hard-fails any other package manager and deletes
  `package-lock.json`/`yarn.lock`.
- Workspace globs (`pnpm-workspace.yaml`): `artifacts/*`, `lib/*`, `lib/integrations/*`,
  `packages/*`, `scripts`. Internal packages are named `@workspace/*`; the shippable one is
  `@chitra/core`.
- Testing: **Vitest** (`packages/core/tests/`, 7 files).

## Commands (verified working)
| Command | Effect |
|---|---|
| `pnpm install` | Install workspace (~25s; esbuild peer-dep warning on api-server is benign) |
| `pnpm --filter @chitra/core run test` | 121 tests |
| `pnpm --filter @chitra/core run test:coverage` | tests + coverage |
| `pnpm --filter @chitra/core run typecheck` | `tsc --noEmit` on the lib |
| `pnpm run typecheck` | full-workspace typecheck (libs build + artifacts + scripts) |
| `pnpm run build` | typecheck + `pnpm -r run build` |

## Conventions & invariants (must never break)
- **Zero runtime dependencies** in `@chitra/core` — ANSI, braille math, rendering are all
  self-contained. Never add a runtime dep.
- **AI-agent output is core**: every chart returns a `ChartResult`
  (`{ render, toString, toPlain, toMarkdown, toJSON }`). `toPlain()` / `toJSON()` +
  `noColor: true` are the LLM/MCP integration surface.
- **Public API stability**: exported fns (`line`/`bar`/`area`/`sparkline`/… + `plot()` fluent
  builder) shouldn't break for consumers. `BaseChartOptions` carries shared fields; specific
  charts only declare unique options. `PlotBuilder` wraps the same chart fns (no duplication).
- **121 core tests stay green.** Never leave the suite red.
- North-star (founder): *"the best chart lib ever created."*

## Environment quirks / gotchas
- ESM **NodeNext**: imports use `.js` extensions on `.ts` files → run via `tsx`, not `node`
  directly. `tsx` is at `packages/core/node_modules/.bin/tsx`.
- Core `tsconfig.json` uses `noEmit: true`, no `rootDir`, so tests live in sibling `tests/`.
  The published build path (`dist/index.js` per package.json `exports`) is **not produced by
  the current `build` script** (`tsc --noEmit`) — real dist bundling is unbuilt.
- `lib/api-spec/openapi.yaml` `info.title` must stay `Api` (comment: changing it breaks
  generated import paths).
- Repo **is** a git repo at `github.com/ifelse-codes/chitra`; `main` hosts S00–S08.
  Vajra branch/commit/PR rules run via `.githooks/` (`core.hooksPath .githooks`) and
  `.ai/hooks/*`. Commits are founder-approved (`VAJRA_ALLOW_COMMIT=<NN>`); pushes/PRs
  need `VAJRA_ALLOW_PUBLISH=1`.

## Where things live
- `packages/core/src/`: `index.ts` (exports), `types.ts`, `ansi.ts`, `utils.ts`, `plot.ts`,
  `themes/`, `renderers/` (braille/blocks/ascii, `panel.ts`), `charts/` (20 chart files).
- `design-reference/` — target design language to build toward (founder-sourced):
  `tui-chart.html`, `mudra-chart.html`, `mudra-dashboard.html`. The terminal panel was
  "modeled on the tui-chart.html reference design language"; next session should learn
  these fully and rebuild the chart look to match.
- `examples/basic.ts` — worked examples for all chart types.
- `CONTRIBUTING.md`, `replit.md` (Replit agent notes), `darshan/SKILL.md` (output skill).
