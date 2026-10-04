# Changelog — @ifelse.codes/chitra

All notable changes to this package follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

> Nothing yet.

## [0.4.0]

### Changed
- **Published from the public repository, so this release carries npm provenance —
  `0.3.0` and every earlier version do not.** npm generates provenance only for a public
  GitHub repository, so the asymmetry is the evidence of the flip, not a workflow change:
  `release.yml` is untouched and still publishes with `npm publish` and no `--provenance`
  flag.
- **No source change.** `packages/core/src` is byte-identical to `0.3.0`; the tests are
  still 453 in 23 files. This version exists because the release event (the repository
  becoming public) happened after `0.3.0`.

## [0.3.0]

### Changed
- **The package is now `@ifelse.codes/chitra`.** It was `@ifelse.codes/core` through
  `0.2.0` (and `@chitra/core` before that). The scope was never the constraint — the part
  after the slash is what buried the product name in every install command. The code is
  unchanged from `0.2.0`.
- **Dropped `mcp` from `keywords`.** Nothing ships an MCP server; it is founder-deferred
  until a release exists *and* someone demands it. A keyword is a promise in a search index.
- `description` now leads with the name, so the npm page is identifiable at a glance.

## [0.2.0]

### Changed
- Published by CI via npm **Trusted Publishing (OIDC)** — no npm token in CI. The publish
  step uses `npm publish`, not `pnpm publish`: pnpm 9.x predates Trusted Publishing and is
  token-only, so it cannot exchange an OIDC token.

## [0.1.0] — first published version

### Added

**Charts (20 types)**
- `bar`, `horizontalBar` — vertical and horizontal bar charts
- `line` — line chart with configurable renderers
- `area` — area / filled-line chart
- `sparkline` — compact inline sparklines
- `histogram` — frequency distribution chart
- `scatter` — scatter / dot plot
- `pie`, `donut` — circular proportion charts
- `heatmap` — grid-based heat map
- `progress`, `gauge` — progress bar and radial gauge
- `timeline` — horizontal timeline / Gantt-style chart
- `radar` — radar / spider chart
- `boxplot` — box-and-whisker plot
- `waterfall` — cumulative waterfall chart
- `funnel` — funnel / conversion chart
- `candlestick` — OHLC candlestick chart
- `treemap` — nested rectangle tree map
- `sankey` — flow / Sankey diagram

**Renderers (3)**
- `BrailleCanvas`, `plotLineOnBrailleCanvas`, `plotAreaOnBrailleCanvas` — high-density Braille dot renderer
- `sparklineBlocks`, `buildHorizontalBlockBar`, `blockHeight` — Unicode block renderer
- `sparklineAscii`, `buildAsciiHBar` — ASCII fallback renderer

**Themes (7)**
- `themes`, `resolveTheme` — built-in theme registry with named theme resolution

**Composition API**
- `plot` / `PlotBuilder` — fluent builder for composing multi-series charts

**ANSI utilities**
- `ansi`, `colorize`, `stripAnsi`, `hexToAnsi` — terminal colour helpers

**Math / layout utilities**
- `minMax`, `normalize`, `clamp`, `formatNumber`, `quartiles` — data helpers
- `createGrid`, `gridToString` — text-grid layout primitives

**Types**
- `ChartResult`, `Theme`, `ThemeName`, `RendererType`, `OutputFormat`
- Per-chart option types for all 20 chart types

**Distribution**
- Dual ESM + CJS build (`dist/index.js` + `dist/index.cjs`) with bundled type declarations
- Zero runtime dependencies
