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
| `pnpm --filter @chitra/core run test` | 142 tests |
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
- **LOCKED design (S09) — all future charts follow this look and feel** (see the
  "LOCKED: circular charts" contract in `packages/core/README.md`):
  - **Braille sub-pixel drawing** (2×4 dots/cell, supersampled 2×2 per dot) for smooth
    round geometry — no blocky steps.
  - **One accent hue on the primary/largest slice**, grey tone ramp (`#ECECEF→#6A6A75`)
    on the rest — never per-slice fill patterns/stripes/in-wedge labels.
  - **Dashed panel frame** (`┌╌…╌┐`, `│ ╌…╌ │`), eyebrow row, right-aligned legend
    beside the ring, optional status row, donut center shows total.
  - **Braille needs a glyph-complete mono font** (Cascadia Mono/Fira Code/Menlo) — docs
    site font stack must keep one or braille columns misalign in the browser.
  - **Area chart locked too** (S09): line = fill's interpolated top edge (no separate
    stroke); y-range auto-scales to the data so the area fills the panel; empty cells are
    spaces (never blank-braille `⠀` which renders as faint dots); one accent only on the
    peak cap + footer `max` value. See "LOCKED: area chart" in `packages/core/README.md`.
  - **Line chart locked to the founder's `tui-chart (1).html` reference** (S10): every
    series is a continuous thin braille line in its own colour (primary on the tone
    ramp), every series drops its glyph marker (`* ○ + × □`, every 2nd index, matching
    the SVG), dotted `·` gridlines on the y-step rows in the grid colour (series/markers
    outrank them), and per-series `min/max/avg/last` summary rows with the primary's
    `max` in accent. The primary keeps the 3-dot accent peak cap, and the cap outranks
    markers. Block/ascii renderers share the look. See "LOCKED: line chart" in
    `packages/core/README.md`.
  - **Bar chart locked (S12)**: `bar()` carries the shared locked design language. One
    accent on the globally highest bar (spent once); all other bars use the grey tone
    ramp — no per-series rainbow. Panel: dashed frame, eyebrow row, `+` y-guide top,
    `+` x-tick row, rule separators, per-series MIN/MAX/AVG/LAST summary rows (peak-series
    `max` in accent). Auto-scale y-range; empty cells are spaces; panel width auto-expands
    to fit summary rows. See "LOCKED: bar chart — session 12 design" in
    `packages/core/README.md`.
  - Live design preview: `/tmp/ring-lab/index.html`; handoff for LLM polish:
    `scripts/ring-polish-handoff.mjs`.
- **163 core tests stay green.** Never leave the suite red.
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
