# Changelog — @chitra/core

All notable changes to this package follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

> Pre-release. No public version has been published to npm yet.

## [0.1.0] — current working version (unpublished)

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
