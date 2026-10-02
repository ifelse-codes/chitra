# Chitra

A production-grade TypeScript terminal charting library — "Beautiful visualizations for terminals, agents, and modern developer workflows."

## Run & Operate

- `pnpm --filter @ifelse.codes/chitra run test` — run all tests (453 tests)
- `pnpm --filter @ifelse.codes/chitra run test:coverage` — run tests with coverage report
- `pnpm --filter @ifelse.codes/chitra run typecheck` — typecheck the library
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm example` — render every chart type to your terminal

## Stack

- pnpm workspaces, Node.js 26, TypeScript 5.9
- Zero runtime dependencies
- Testing: Vitest
- Rendering: Unicode Braille (⠀–⣿), Unicode Blocks (▁▂▃▄▅▆▇█), ASCII fallback

## Where things live

- `packages/core/` — `@ifelse.codes/chitra` main library package
  - `src/types.ts` — all TypeScript interfaces and types
  - `src/ansi.ts` — ANSI color primitives (zero-dep)
  - `src/utils.ts` — math, formatting, grid utilities
  - `src/plot.ts` — fluent `PlotBuilder` API
  - `src/version.ts` — generated from `package.json`; regenerate with `node scripts/sync-version.mjs`
  - `src/themes/` — 7 built-in themes
  - `src/renderers/` — braille, blocks, ASCII engines
  - `src/charts/` — 20 chart implementations
  - `tests/` — Vitest test suite, one file per chart
- `examples/basic.ts` — full working examples for all 20 chart types
- `.github/workflows/ci.yml` — CI on Node 26
- `.github/workflows/release.yml` — NPM publish on git tag
- `CONTRIBUTING.md` — contributor guide

## Architecture decisions

- Zero runtime dependencies — ANSI colors, braille math, and all rendering is self-contained
- TypeScript ESM with `.js` extensions in imports (NodeNext module resolution)
- `ChartResult` interface: every chart returns `{ render, toString, toPlain, toContent, toMarkdown, toJSON }` (plus `toSVG()` where a browser-native renderer exists) for AI agent compatibility
- `BaseChartOptions` carries shared fields (`labels`, `theme`, `renderer`, `noColor`, etc.) so specific chart types only declare their unique options
- `PlotBuilder` fluent API wraps the same underlying chart functions — no code duplication
- The version lives in `package.json` and nowhere else; `src/version.ts` is generated from it and CI fails if the two disagree

## Product

**@ifelse.codes/chitra** — A terminal charting library with 20 chart types (line, bar, area, sparkline, histogram, scatter, pie, donut, heatmap, progress, gauge, timeline, radar, boxplot, waterfall, funnel, candlestick, treemap, sankey, horizontal bar), 3 renderers (braille/blocks/ASCII), 7 themes, and first-class AI agent support via `toPlain()` / `toJSON()`.

## User preferences

_Populate as you build — explicit user instructions worth remembering across sessions._

## Gotchas

- TypeScript files use `.js` extensions in imports (ESM NodeNext convention) — run via `tsx` (`pnpm example`) not `node` directly
- `pnpm-workspace.yaml` globs `packages/*` and `lib/*`; `lib/` is Replit-era scaffolding for an API server that is not part of the product
- `tsconfig.json` for the core package uses `noEmit: true` — no `rootDir` set so tests can be in a sibling `tests/` directory
- `PORT` / `BASE_PATH` are optional now — the vite configs default them (`5000`, `/`) and CI still exports both. They used to be hard throws, which broke every build that was not CI's.
- `packages/core/dist/` is gitignored, so anything that typechecks the docs app must build core first — that is why CI builds core before the docs typecheck

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
