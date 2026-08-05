# @chitra/core

A production-grade TypeScript terminal charting library. Beautiful visualizations for terminals, agents, and modern developer workflows.

## Features

- **20 Chart Types:** Line, bar, area, sparkline, histogram, scatter, pie, donut, heatmap, progress, gauge, timeline, radar, boxplot, waterfall, funnel, candlestick, treemap, sankey, horizontal bar.
- **AI-Agent Native:** Exposes `toPlain()` and `toJSON()` so LLMs and MCP tools get clean data without ANSI escape code noise.
- **Zero Dependencies:** All ANSI colors, braille math, and layout logic are self-contained.
- **TypeScript First:** Complete type definitions.
- **Three Renderers:** Braille (for high-resolution curves), Blocks (for robust terminal support), and ASCII (for SSH/fallback environments).
- **Fluent API:** Shared configuration using a chainable `plot(data)` builder.

## Installation

```bash
npm install @chitra/core
# or
pnpm add @chitra/core
# or
yarn add @chitra/core
```

## Quickstart

```typescript
import { bar, line, sparkline, plot } from "@chitra/core";

// 1. Simple Bar Chart
bar({
  data: [42, 67, 38, 55, 72],
  labels: ["Jan", "Feb", "Mar", "Apr", "May"],
  title: "Monthly Deployments",
  theme: "tokyo-night"
}).render(); // prints to stdout

// 2. High-Resolution Line Chart (Braille renderer)
line({
  data: [10, 20, 15, 35, 28, 45, 38, 52],
  title: "Revenue",
  renderer: "braille"
}).render();

// 3. Fluent API Builder
plot([42, 67, 38, 55, 72])
  .labels(["Jan", "Feb", "Mar", "Apr", "May"])
  .title("Deploys")
  .theme("dracula")
  .bar()
  .render();
```

## AI Agent Integration

When writing MCP (Model Context Protocol) tools or building AI agents, you don't want to feed the LLM a string full of `\x1b[31m` ANSI escape codes.

Every chart returns a `ChartResult` object with safe export methods:

```typescript
import { bar } from "@chitra/core";

const chart = bar({
  data: [42, 67, 38],
  labels: ["Q1", "Q2", "Q3"],
  title: "Quarterly Revenue",
  noColor: true // strips formatting
});

// For LLM context (clean text):
const plainText = chart.toPlain();

// For structured data extraction:
const json = chart.toJSON(); 
// { type: "bar", title: "Quarterly Revenue", data: [42, 67, 38], plain: "..." }
```

## Renderers

Chitra supports three rendering modes:
- **`braille` (default for continuous data):** Uses Unicode Braille patterns (⠀–⣿) to achieve 4× resolution over standard characters. Best for line, area, and scatter plots.
- **`blocks` (default for discrete data):** Uses Unicode Block elements (▁▂▃▄▅▆▇█). Best for bar, progress, and histograms.
- **`ascii`:** Pure ASCII characters. Best for restrictive environments, legacy SSH sessions, or basic log files.

## Themes

Chitra includes 7 built-in themes that automatically map series data to colors:
`"default"`, `"nord"`, `"dracula"`, `"github-dark"`, `"tokyo-night"`, `"solarized"`, and `"monochrome"`.

## Design Style

Chitra's look is built on the `design-reference/` language — tui-chart (terminal-native),
mudra-chart (one-hue refinement), and mudra-dashboard (terminal translation). The target
look for terminal output:

- **Dashed panel frame**, mono-first typography, sharp corners. Floating `panel-tag`
  labels (`- SUMMARY -`) sit on the frame line.
- **Series identity = tone + dash + glyph**, never rainbow color alone. Each series is
  separated by a tone from the theme's ramp, a dash pattern (solid / dashed / dotted /
  dash-dot), and a glyph marker (`* o + x`).
- **One accent hue per theme**, reserved for the primary or active series; other series
  stay muted so the accent lands where the eye is pointing.
- **Thin dashed gridlines** with a solid baseline axis, and `+` tick marks on both axes.
- **Eyebrow captions** — uppercase, letter-spaced, mono — label the x/y axes.
- **Metric summary cells** — LAST value prominent, MIN / MAX / AVG beneath, per series.
- **SVG output mirrors the terminal model**: the web renderer draws the same tones,
  dashes, glyphs, grid, and captions as the terminal renderer, from the same model.

### LOCKED: circular charts (pie / donut) — session 09 design

The pie and donut look is **the locked reference for every future circular chart**. Rules
that must not change:

- **The circle is drawn as braille sub-pixels** (2 dots wide × 4 dots tall per cell) at
  dot-space resolution, so the curve reads as a genuinely round circle — matching the
  reference HTML's stroked SVG circles. **No** fill patterns (`█▓▒░▚▞`), **no** density
  stripes, **no** radial seams, **no** in-wedge labels. Clean solid disc, round rim.
- **Slice separation is tone ramp + one accent**, never per-slice fill patterns: the
  largest slice gets the theme's single accent hue, the rest get the grey tone ramp
  (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`). In color output the slices read apart;
  in plain mode the legend is the separator.
- **Edge quality**: each braille dot is supersampled at 2×2 sub-points and lit only when
  the majority fall inside the ring — keeps the rim smooth and vertically symmetric.
- **Right-aligned legend** beside the ring: solid swatch + label, value and percent
  right-aligned. Ring on the left, legend vertically centred.
- **Panel**: dashed frame (`┌╌…╌┐`), eyebrow row (uppercase, letter-spaced) under the
  top rule, optional status row before the bottom rule. Donut centre shows the total.
- **Braille rendering requires a glyph-complete mono font** (Cascadia Mono, Fira Code,
  Menlo). Web/editor output must load one or the circle columns misalign.

### LOCKED: area chart — session 09 design

The area chart follows the same locked language. Rules that must not change:

- **The line IS the fill's top edge.** No separate stroke pass: every column of the plot
  is filled down to the baseline with interpolated sub-pixel braille, and the top dot of
  each column is the line. This gives one clean continuous curve with no gap or jitter
  between the stroke and the fill.
- **Auto-scale the y-range to the data** (`yMin`/`yMax` default to the data min/max, not
  0) so the area fills the panel height — no dead space hugging the bottom.
- **Empty cells are spaces, never blank-braille (`⠀` U+2800).** Blank braille renders as
  faint dots in browsers; plain spaces keep the panel clean.
- **One accent, used only for what's relevant.** The peak (series max) gets a small 3-dot
  accent cap on the line; the rest of the line is the tone ramp (`#A4A4AE`), the fill is
  a lighter tone (`#C6C6CE`), and the footer's `max N` value is accent too. The whole
  curve must never be painted accent.
- **Same panel language**: dashed frame, eyebrow row, y-axis labels with `│` guide on the
  left, footer `series · max · min · last`.

### LOCKED: line chart — session 10 design

The line chart carries the same locked language as the area chart. Rules that must not change:

- **Every series is a continuous thin line** (braille sub-pixels, interpolated between points) —
  each series in its own colour (`*` primary on the tone ramp, the rest from the theme palette),
  so curves read like a classic terminal chart rather than a fill diagram.
- **Every series drops its glyph marker at data points** (`* ○ + × □`, every 2nd index) so
  crossing curves stay traceable by shape even in monochrome — matching the SVG web renderer.
  The legend shows each series' identity (`──*── Up  ╌╌○╌╌ Down  ··+·· Base`).
- **Dashed gridlines** on the y-step rows (dotted `·` guides in the grid colour) — series cells
  and markers always outrank them, and the top/base rows stay clean.
- **Auto-scale the y-range to the data** (`yMin`/`yMax` default to the data min/max) so the
  line fills the panel height — no dead space hugging the bottom. The shared `LineChartModel`
  feeds the same range to the SVG web renderer.
- **Empty cells are spaces, never blank-braille (`⠀` U+2800).**
- **One accent, spent once**: the primary's peak (series max) gets a 3-dot accent cap; the rest
  of the curve stays on its tone ramp, and the primary's `max N` in the summary is accent too.
- **Per-series summary rows** under the chart: `* Up · min N · max N · avg N · last N` for every
  series (MIN / MAX / AVG / LAST), replacing the single footer line.
- **Same panel language**: dashed frame (`┌╌…╌┐`), eyebrow row, `│` y-guide on the left,
  series legend (`──*── name`), clean X-axis labels.

## License

MIT
