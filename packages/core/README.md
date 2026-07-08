# @chitra/core

**Beautiful visualizations for terminals, agents, and modern developer workflows.**

```
   5 ┤⠀⠀⠀⠀⣀⡤⠔⠒⠉⠉⠒⠢⢄⡀⠀⠀
   4 ┤⢀⡠⠔⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⢄
   3 ┤⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
   2 ┤
   1 ┤
     └────────────────────
```

Chitra is the standard visualization library for:

- **CLI applications** and terminal dashboards
- **AI agents**, MCP servers, and LLM applications
- **DevOps tooling**, observability systems, and build pipelines
- **Developer tooling** of every kind

Think Chart.js for terminals. Recharts for AI agents. Matplotlib for the command line.

**New here?** Follow the path: [Install](#install) → [Render your first chart](#your-first-chart) → [Run the examples](#run-the-examples) → [AI agent output](#ai-agent-output).

---

## Install

```bash
npm install @chitra/core
# or
pnpm add @chitra/core
```

Every chart function returns a `ChartResult` — call `.render()` to print it, or `.toString()` / `.toPlain()` / `.toMarkdown()` / `.toJSON()` to capture it.

---

## Your first chart

### Simple API

```ts
import { line, bar, sparkline } from "@chitra/core";

// Line chart
console.log(line({ data: [10, 20, 15, 30, 25], title: "Revenue" }).toString());

// Bar chart
console.log(bar({ data: [42, 67, 38, 55], labels: ["Q1", "Q2", "Q3", "Q4"] }).toString());

// Inline sparkline
console.log(sparkline({ data: [1, 3, 2, 5, 4], label: "CPU" }).toString());
```

### Fluent API

```ts
import { plot } from "@chitra/core";

plot([10, 20, 15, 30, 25])
  .title("Revenue")
  .theme("tokyo-night")
  .width(60)
  .height(15)
  .line()
  .render();
```

---

## Run the examples

A single runnable file exercises every chart type, the theme tour, the fluent API, and
AI-agent output — see [`examples/basic.ts`](../../examples/basic.ts) in the repo.

```bash
git clone https://github.com/ifelse-codes/chitra.git
cd chitra
pnpm install
npx tsx examples/basic.ts
```

The AI-agent section at the end of that file (`bar(...).toPlain()` + `.toJSON()`) shows the
exact shape you would return from an MCP tool.

---

## Chart Types

| Chart | Function | Description |
|-------|----------|-------------|
| Line | `line()` | Time series, trends |
| Area | `area()` | Filled line charts |
| Bar | `bar()` | Vertical bar charts |
| Horizontal Bar | `horizontalBar()` | Horizontal bars with labels |
| Sparkline | `sparkline()` | Inline mini charts |
| Histogram | `histogram()` | Distribution visualization |
| Scatter | `scatter()` | XY point plots |
| Pie | `pie()` | Proportional slice charts |
| Donut | `donut()` | Pie with center value |
| Heatmap | `heatmap()` | 2D intensity grids |
| Progress | `progress()` | Progress bars |
| Gauge | `gauge()` | Single-value gauges |
| Timeline | `timeline()` | Gantt-style event timelines |
| Radar | `radar()` | Spider/radar charts |
| Box Plot | `boxplot()` | Statistical distributions |
| Waterfall | `waterfall()` | Cumulative delta charts |
| Funnel | `funnel()` | Conversion funnels |
| Candlestick | `candlestick()` | OHLC financial charts |
| Treemap | `treemap()` | Hierarchical area charts |
| Sankey | `sankey()` | Flow diagrams |

---

## Rendering Engines

```ts
// Braille (highest density, default for line/area/scatter)
line({ data, renderer: "braille" })

// Unicode blocks ▁▂▃▄▅▆▇█ (default for bar/sparkline)
bar({ data, renderer: "blocks" })

// ASCII (legacy terminals)
line({ data, renderer: "ascii" })
```

---

## Themes

```ts
const themes = [
  "default",       // cyan/magenta on dark
  "nord",          // Arctic palette
  "dracula",       // Purple/pink on dark
  "github-dark",   // GitHub dark mode
  "tokyo-night",   // Popular terminal theme
  "solarized",     // Solarized classic
  "monochrome",    // Black and white
];

line({ data, theme: "tokyo-night" })

// Custom theme
line({
  data,
  theme: {
    name: "custom",
    colors: ["\x1b[36m", "\x1b[35m"],
    axis: "\x1b[90m",
    label: "\x1b[37m",
    title: "\x1b[1m\x1b[97m",
  }
})
```

---

## Output Formats

Every chart returns a `ChartResult` with five ways to consume it:

```ts
const chart = line({ data: [1, 2, 3] });

chart.render();          // prints the ANSI chart to stdout
chart.toString();        // ANSI-colored string (terminals)
chart.toPlain();         // plain text, ANSI stripped (LLM input)
chart.toMarkdown();      // plain text fenced in a ``` code block (chat/docs)
chart.toJSON();          // structured object { type, data, labels, title, plain }
```

---

## AI agent output

For agents, MCP servers, and LLM tools, pass `noColor: true` and pick the helper that fits
the channel: **plain** for raw text, **markdown** for chat surfaces, **json** for structured
tool results.

```ts
// Plain text — drop straight into an MCP tool result
const chartText = line({
  data: metrics,
  title: "Response Times",
  noColor: true,          // no ANSI escapes for LLM consumption
}).toPlain();

return { content: [{ type: "text", text: chartText }] };
```

```ts
// JSON — structured response the agent can reason over
const result = bar({
  data: counts,
  labels: categories,
  noColor: true,
}).toJSON();

// result.type   — chart type, e.g. "bar"
// result.data   — the original data
// result.labels — category labels
// result.title  — chart title
// result.plain  — plain-text rendering
```

---

## Multi-Series Charts

```ts
// Multi-series line chart
line({
  data: [
    [10, 20, 15, 30],   // Series 1
    [5, 15, 25, 20],    // Series 2
  ],
  seriesLabels: ["Revenue", "Costs"],
  theme: "nord",
})

// Grouped bar chart
bar({
  data: [
    [40, 55, 70],
    [30, 45, 60],
  ],
  labels: ["Q1", "Q2", "Q3"],
  seriesLabels: ["2024", "2025"],
})
```

---

## API Reference

### Common Options

All chart functions accept these base options:

```ts
interface BaseChartOptions {
  width?: number;          // Chart width in terminal columns (default: 60)
  height?: number;         // Chart height in terminal rows (default: 10-15)
  title?: string;          // Chart title
  theme?: ThemeName | Theme;
  renderer?: "braille" | "blocks" | "ascii";
  labels?: string[];       // X-axis / category labels
  showAxes?: boolean;      // Show axis lines (default: true)
  noColor?: boolean;       // Disable ANSI colors
  legend?: boolean;        // Show legend (default: true when multi-series)
  xLabel?: string;         // X-axis label
  yLabel?: string;         // Y-axis label
  yMin?: number;           // Y-axis minimum override
  yMax?: number;           // Y-axis maximum override
}
```

### PlotBuilder (Fluent API)

```ts
plot(data)
  .title(string)
  .theme(ThemeName | Theme)
  .renderer(RendererType)
  .width(number)
  .height(number)
  .size(width, height)
  .labels(string[])
  .seriesLabels(string[])
  .noColor(boolean)
  .axes(boolean)
  .yRange(min, max)
  .line()        // → ChartResult
  .area()        // → ChartResult
  .bar()         // → ChartResult
  .horizontalBar()
  .sparkline()
  .histogram(bins?)
  .pie()
  .donut()
```

---

## Low-Level API

```ts
import {
  BrailleCanvas,
  plotLineOnBrailleCanvas,
  sparklineBlocks,
  stripAnsi,
  hexToAnsi,
  ansi,
} from "@chitra/core";

// Direct braille canvas access
const canvas = new BrailleCanvas(40, 10);
plotLineOnBrailleCanvas(canvas, myData, 0, 100);
console.log(canvas.toString());

// ANSI utilities
console.log(ansi.rgb(255, 100, 50) + "colored text" + ansi.reset);
console.log(hexToAnsi("#7aa2f7") + "Tokyo Night blue" + ansi.reset);
```

---

## Architecture

```
@chitra/core
├── src/
│   ├── index.ts          — Main exports
│   ├── types.ts          — All TypeScript types
│   ├── ansi.ts           — ANSI color utilities
│   ├── utils.ts          — Math, formatting, grid utilities
│   ├── plot.ts           — Fluent PlotBuilder API
│   ├── themes/           — 7 built-in themes
│   ├── renderers/        — Braille, blocks, ASCII engines
│   └── charts/           — 20 chart implementations
└── tests/                — Vitest test suite (>90% coverage)
```

**Design principles:**
- Zero runtime dependencies
- Tree-shakable — import only what you use
- Renderer-agnostic — swap braille/blocks/ascii per chart
- Theme-agnostic — custom themes via simple objects
- AI-first — `toJSON()` and `toPlain()` for agent consumption
- TypeScript-first — full type inference on all options

---

## License

MIT © Chitra contributors
