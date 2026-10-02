# @ifelse.codes/chitra

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
npm install @ifelse.codes/chitra
# or
pnpm add @ifelse.codes/chitra
# or
yarn add @ifelse.codes/chitra
```

## Quickstart

```typescript
import { bar, line, sparkline, plot } from "@ifelse.codes/chitra";

// 1. Simple Bar Chart
bar({
  data: [42, 67, 38, 55, 72],
  labels: ["Jan", "Feb", "Mar", "Apr", "May"],
  title: "Monthly Deployments",
  theme: "tokyo-night"
}).render(); // prints to stdout

// 2. Line Chart (braille renderer by default — smooth continuous curves)
line({
  data: [10, 20, 15, 35, 28, 45, 38, 52],
  title: "Revenue"
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
import { bar } from "@ifelse.codes/chitra";

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

> **Full reference:** every chart's `toJSON()` shape, the `toContent()` vs
> `toPlain()` choice, empty/clamp behaviour, and the MCP untrusted-input
> guardrail live at [chitra.iifelse.com/ai-data](https://chitra.iifelse.com/ai-data).

## Renderers

`renderer` is one of exactly three values — `"braille"`, `"blocks"`, `"ascii"`
(`RendererType` in `src/types.ts`). The default is per chart, not global:

| Renderer | Best for | Default for |
|---|---|---|
| **`braille`** | area, scatter, and high-resolution single-series line plots — 4× resolution over standard characters (⠀–⣿) | `line`, `scatter` |
| **`blocks`** | bar, progress, histograms — Unicode Block elements (▁▂▃▄▅▆▇█) | `bar`, `horizontalBar` |
| **`ascii`** | restrictive environments, legacy SSH sessions, plain log files | — (opt in) |

Notes on the line renderer: markers are drawn as a glyph-only chain (`* o + x`) at every
2nd data point, with no `●` filler, so crossing curves stay traceable by shape. `ascii` is
the one exception — it interpolates a connecting slope line under its markers. `blocks`
does not.

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

## License

MIT
