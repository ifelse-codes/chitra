// Single source of truth for the docs-site chart gallery.
//
// Each spec renders through the real @chitra/core library, so the previews
// shipped in src/data/{charts.ts,ansi-charts.json} are GENERATED, never
// hand-pasted. Edit a chart here; run `pnpm gen:charts` to refresh both files.
//
// Imported from core *source* (relative path) so this works without a built
// dist/ — it is dev tooling, run via tsx, never bundled into the app.
import {
  line,
  bar,
  area,
  sparkline,
  histogram,
  scatter,
  pie,
  donut,
  heatmap,
  progress,
  gauge,
  horizontalBar,
  timeline,
  radar,
  boxplot,
  waterfall,
  funnel,
  candlestick,
  treemap,
  sankey,
} from "../../../packages/core/src/index.js";
import type { ChartResult } from "../../../packages/core/src/types.js";

export interface ChartSpec {
  id: string;
  name: string;
  description: string;
  /** Human-facing snippet shown in the docs. Should mirror `ansi`/`plain`. */
  code: string;
  /** Colored output → src/data/ansi-charts.json (rendered to HTML by ansi.ts). */
  ansi: () => string;
  /** Plain, no-ANSI fallback → CHARTS[].preview in src/data/charts.ts. */
  plain: () => string;
  /** Optional browser-native SVG output from the same core chart result. */
  svg?: () => string;
}

/** Single-chart spec helper: both outputs from one ChartResult factory. */
function single(make: () => ChartResult): Pick<ChartSpec, "ansi" | "plain" | "svg"> {
  return {
    ansi: () => make().toString(),
    plain: () => make().toPlain(),
    svg: () => make().toSVG?.() ?? "",
  };
}

/** Composite spec helper: join several charts (e.g. stacked sparklines). */
function multi(...makes: Array<() => ChartResult>): Pick<ChartSpec, "ansi" | "plain"> {
  return {
    ansi: () => makes.map((m) => m().toString()).join("\n"),
    plain: () => makes.map((m) => m().toPlain()).join("\n"),
  };
}

export const SPECS: ChartSpec[] = [
  {
    id: "line",
    name: "Line Chart",
    description:
      "Continuous data over time, rendered with explicit ASCII line characters matching classical terminal monitoring.",
    code: `import { line } from "@chitra/core";

line({
  data: [
    24000, 24080, 24150, 24260, 24400, 24460, 24380, 24400, 24340, 24310,
    24480, 24390, 24270, 24140, 24060, 24060, 23990, 23880, 23940, 23900,
    24060, 24000, 24060, 24120, 24180, 24260, 24280, 24240, 24350, 24340,
    24460, 24470, 24490, 24510, 24550, 24600, 24660, 24800, 24860, 24860,
    24720, 24660, 24630, 24590, 24540, 24510, 24470, 24520, 24560, 24600
  ],
  labels: ["7D Ago", "6D Ago", "5D Ago", "4D Ago", "3D Ago", "2D Ago", "1D Ago", "Now"],
  title: "NIFTY 50 INDEX",
  width: 72,
  height: 18,
  theme: "default",
  renderer: "ascii", // Forces explicit line drawing (- / \\ o)
}).render();`,
    ...single(() =>
      line({
        data: [
          24000, 24080, 24150, 24260, 24400, 24460, 24380, 24400, 24340, 24310,
          24480, 24390, 24270, 24140, 24060, 24060, 23990, 23880, 23940, 23900,
          24060, 24000, 24060, 24120, 24180, 24260, 24280, 24240, 24350, 24340,
          24460, 24470, 24490, 24510, 24550, 24600, 24660, 24800, 24860, 24860,
          24720, 24660, 24630, 24590, 24540, 24510, 24470, 24520, 24560, 24600
        ],
        labels: ["7D Ago", "6D Ago", "5D Ago", "4D Ago", "3D Ago", "2D Ago", "1D Ago", "Now"],
        title: "NIFTY 50 INDEX",
        width: 72,
        height: 18,
        theme: {
            name: "nifty",
            colors: ["\x1b[38;2;52;211;153m"], // Bright explicit green
            axis: "\x1b[38;2;71;85;105m", // Dim explicit slate
            label: "\x1b[38;2;148;163;184m",
            title: "\x1b[38;2;52;211;153m",
            grid: "\x1b[38;2;51;65;85m"
        },
        renderer: "ascii",
      }),
    ),
  },
  {
    id: "bar",
    name: "Bar Chart",
    description:
      "Vertical bars for comparing categorical values, with optional grouping and stacking.",
    code: `import { bar } from "@chitra/core";

bar({
  data: [42, 67, 38, 55, 72, 61],
  labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
  title: "Monthly Sales",
  height: 10,
}).render();`,
    ...single(() =>
      bar({
        data: [42, 67, 38, 55, 72, 61],
        labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
        title: "Monthly Sales",
        height: 10,
      }),
    ),
  },
  {
    id: "area",
    name: "Area Chart",
    description:
      "Like a line chart but with the area below filled in — great for volume/accumulation.",
    code: `import { area } from "@chitra/core";

area({
  data: [10, 20, 15, 35, 28, 45, 38, 52],
  title: "Area Chart",
  width: 52,
  height: 10,
}).render();`,
    ...single(() =>
      area({
        data: [10, 20, 15, 35, 28, 45, 38, 52],
        title: "Area Chart",
        width: 52,
        height: 10,
      }),
    ),
  },
  {
    id: "sparkline",
    name: "Sparkline",
    description:
      "Compact inline charts — perfect for dashboards, logs, and status readouts.",
    code: `import { sparkline } from "@chitra/core";

// Unicode blocks (default)
sparkline({ data: [45, 52, 61, 58, 70, 65, 78, 72, 80, 82],
  label: "CPU", showValue: true }).render();

// Braille renderer
sparkline({ data: [60, 62, 65, 63, 68, 70, 72, 69, 74, 78],
  label: "MEM", renderer: "braille" }).render();

// ASCII fallback
sparkline({ data: [12, 8, 15, 6, 20, 18, 25, 22, 30, 28],
  label: "NET", renderer: "ascii" }).render();`,
    ...multi(
      () =>
        sparkline({
          data: [45, 52, 61, 58, 70, 65, 78, 72, 80, 82],
          label: "CPU",
          showValue: true,
        }),
      () =>
        sparkline({
          data: [60, 62, 65, 63, 68, 70, 72, 69, 74, 78],
          label: "MEM",
          renderer: "braille",
        }),
      () =>
        sparkline({
          data: [12, 8, 15, 6, 20, 18, 25, 22, 30, 28],
          label: "NET",
          renderer: "ascii",
        }),
    ),
  },
  {
    id: "histogram",
    name: "Histogram",
    description: "Distribution of continuous data across configurable bins.",
    code: `import { histogram } from "@chitra/core";

histogram({
  data: [1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,7,7,8],
  bins: 8,
  title: "Distribution",
  height: 10,
  width: 40,
}).render();`,
    ...single(() =>
      histogram({
        data: [1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 7, 7, 8],
        bins: 8,
        title: "Distribution",
        height: 10,
        width: 40,
      }),
    ),
  },
  {
    id: "scatter",
    name: "Scatter Plot",
    description:
      "Two-dimensional point data for spotting correlations and clusters.",
    code: `import { scatter } from "@chitra/core";

scatter({
  data: [
    {x:1,y:2}, {x:2,y:4}, {x:3,y:3}, {x:4,y:7},
    {x:5,y:5}, {x:6,y:9}, {x:7,y:6}, {x:10,y:12},
  ],
  title: "Scatter Plot",
  width: 50,
  height: 12,
}).render();`,
    ...single(() =>
      scatter({
        data: [
          { x: 1, y: 2 },
          { x: 2, y: 4 },
          { x: 3, y: 3 },
          { x: 4, y: 7 },
          { x: 5, y: 5 },
          { x: 6, y: 9 },
          { x: 7, y: 6 },
          { x: 10, y: 12 },
        ],
        title: "Scatter Plot",
        width: 50,
        height: 12,
      }),
    ),
  },
  {
    id: "pie",
    name: "Pie Chart",
    description:
      "Circular proportional chart for showing part-to-whole relationships.",
    code: `import { pie } from "@chitra/core";

pie({
  data: [35, 25, 20, 12, 8],
  labels: ["Organic", "Direct", "Social", "Email", "Paid"],
}).render();`,
    ...single(() =>
      pie({
        data: [35, 25, 20, 12, 8],
        labels: ["Organic", "Direct", "Social", "Email", "Paid"],
      }),
    ),
  },
  {
    id: "donut",
    name: "Donut Chart",
    description:
      "Pie chart with a hollow centre — great for showing a primary metric.",
    code: `import { donut } from "@chitra/core";

donut({
  data: [30, 25, 22, 15, 8],
  labels: ["TypeScript", "Python", "Rust", "Go", "Other"],
}).render();`,
    ...single(() =>
      donut({
        data: [30, 25, 22, 15, 8],
        labels: ["TypeScript", "Python", "Rust", "Go", "Other"],
      }),
    ),
  },
  {
    id: "heatmap",
    name: "Heatmap",
    description:
      "2D grid whose intensity is a grey tone ramp, with the single peak cell marked in the accent hue.",
    code: `import { heatmap } from "@chitra/core";

heatmap({
  data: [
    [1, 3, 5, 7, 9],
    [2, 4, 6, 8, 10],
    [3, 5, 7, 9, 11],
    [4, 6, 8, 10, 12],
  ],
  title: "Activity Heatmap",
  width: 40,
  height: 8,
}).render();`,
    ...single(() =>
      heatmap({
        data: [
          [1, 3, 5, 7, 9],
          [2, 4, 6, 8, 10],
          [3, 5, 7, 9, 11],
          [4, 6, 8, 10, 12],
        ],
        title: "Activity Heatmap",
        width: 40,
        height: 8,
      }),
    ),
  },
  {
    id: "progress",
    name: "Progress Bar",
    description:
      "Single-value progress panel in the locked design language — grey-tone fill with an accented leading edge. Great for build steps, quotas, and budgets.",
    code: `import { progress } from "@chitra/core";

progress({ value: 87, label: "Build" }).render();
progress({ value: 62, label: "Tests" }).render();
progress({ value: 34, label: "Coverage" }).render();`,
    ...multi(
      () => progress({ value: 87, label: "Build" }),
      () => progress({ value: 62, label: "Tests" }),
      () => progress({ value: 34, label: "Coverage" }),
    ),
  },
  {
    id: "gauge",
    name: "Gauge",
    description:
      "Single-value meter in the locked panel language — grey-tone fill with an accented reading edge. Great for KPIs, CPU usage, battery level.",
    code: `import { gauge } from "@chitra/core";

gauge({
  value: 73,
  min: 0,
  max: 100,
  label: "CPU Load",
  width: 40,
}).render();`,
    ...single(() =>
      gauge({ value: 73, min: 0, max: 100, label: "CPU Load", width: 40 }),
    ),
  },
  {
    id: "horizontalBar",
    name: "Horizontal Bar",
    description:
      "Bars running left-to-right — ideal for ranked lists and comparisons.",
    code: `import { horizontalBar } from "@chitra/core";

horizontalBar({
  data: [892, 645, 534, 421, 289],
  labels: ["TypeScript", "Python", "Rust", "Go", "Ruby"],
}).render();`,
    ...single(() =>
      horizontalBar({
        data: [892, 645, 534, 421, 289],
        labels: ["TypeScript", "Python", "Rust", "Go", "Ruby"],
      }),
    ),
  },
  {
    id: "timeline",
    name: "Timeline / Gantt",
    description:
      "Gantt-style spans on a shared time scale — grey tone ramp by span length, with the single longest span marked in the accent hue.",
    code: `import { timeline } from "@chitra/core";

timeline({
  events: [
    { label: "Design", start: 0, end: 2 },
    { label: "Build",  start: 2, end: 6 },
    { label: "Test",   start: 5, end: 7 },
    { label: "Deploy", start: 7, end: 8 },
  ],
  title: "Sprint Timeline",
  width: 52,
}).render();`,
    ...single(() =>
      timeline({
        events: [
          { label: "Design", start: 0, end: 2 },
          { label: "Build", start: 2, end: 6 },
          { label: "Test", start: 5, end: 7 },
          { label: "Deploy", start: 7, end: 8 },
        ],
        title: "Sprint Timeline",
        width: 52,
      }),
    ),
  },
  {
    id: "radar",
    name: "Radar Chart",
    description:
      "Spider/radar chart for multi-axis comparison of a single entity.",
    code: `import { radar } from "@chitra/core";

radar({
  data: [8, 6, 9, 7, 5, 8],
  labels: ["Speed", "Safety", "UX", "Perf", "Cost", "Scale"],
  title: "System Radar",
  width: 40,
}).render();`,
    ...single(() =>
      radar({
        data: [8, 6, 9, 7, 5, 8],
        labels: ["Speed", "Safety", "UX", "Perf", "Cost", "Scale"],
        title: "System Radar",
        width: 40,
      }),
    ),
  },
  {
    id: "boxplot",
    name: "Box Plot",
    description:
      "Statistical summary showing median, quartiles, and whiskers.",
    code: `import { boxplot } from "@chitra/core";

boxplot({
  data: [
    [12, 18, 22, 28, 35],
    [15, 20, 25, 30, 40],
    [8,  14, 19, 25, 33],
  ],
  labels: ["Q1", "Q2", "Q3"],
  width: 50,
  height: 12,
}).render();`,
    ...single(() =>
      boxplot({
        data: [
          [12, 18, 22, 28, 35],
          [15, 20, 25, 30, 40],
          [8, 14, 19, 25, 33],
        ],
        labels: ["Q1", "Q2", "Q3"],
        width: 50,
        height: 12,
      }),
    ),
  },
  {
    id: "waterfall",
    name: "Waterfall",
    description:
      "Running total chart — shows cumulative effect of positive/negative values.",
    code: `import { waterfall } from "@chitra/core";

waterfall({
  data: [500, -120, 80, -60, 150],
  labels: ["Start", "COGS", "Rev", "OpEx", "Sales"],
  height: 10,
  width: 50,
  showTotal: true,
}).render();`,
    ...single(() =>
      waterfall({
        data: [500, -120, 80, -60, 150],
        labels: ["Start", "COGS", "Rev", "OpEx", "Sales"],
        height: 10,
        width: 50,
        showTotal: true,
      }),
    ),
  },
  {
    id: "funnel",
    name: "Funnel Chart",
    description:
      "Conversion funnel — visualise drop-off across stages of a pipeline.",
    code: `import { funnel } from "@chitra/core";

funnel({
  data: [10000, 6800, 3400, 1200, 340],
  labels: ["Visitors", "Sign-ups", "Trials", "Paid", "Enterprise"],
  width: 55,
}).render();`,
    ...single(() =>
      funnel({
        data: [10000, 6800, 3400, 1200, 340],
        labels: ["Visitors", "Sign-ups", "Trials", "Paid", "Enterprise"],
        width: 55,
      }),
    ),
  },
  {
    id: "candlestick",
    name: "Candlestick",
    description:
      "OHLC financial chart — open, high, low, close per period. Green = bullish (close > open), red = bearish.",
    // NOTE: prior docs referenced theme "neon", which does not exist in
    // @chitra/core (valid: default, nord, dracula, github-dark, tokyo-night,
    // solarized, monochrome). Corrected to "dracula".
    code: `import { candlestick } from "@chitra/core";

candlestick({
  title: "CHRX — 10-Day Price Action",
  data: [
    { open: 142, high: 158, low: 138, close: 155, label: "Jan 8" },
    { open: 155, high: 168, low: 148, close: 151, label: "Jan 9" },
    { open: 151, high: 163, low: 143, close: 161, label: "Jan10" },
    { open: 161, high: 182, low: 158, close: 178, label: "Jan11" },
    { open: 178, high: 185, low: 162, close: 165, label: "Jan12" },
    { open: 165, high: 174, low: 155, close: 170, label: "Jan15" },
    { open: 170, high: 192, low: 167, close: 188, label: "Jan16" },
    { open: 188, high: 196, low: 176, close: 179, label: "Jan17" },
    { open: 179, high: 198, low: 178, close: 195, label: "Jan18" },
    { open: 195, high: 215, low: 190, close: 210, label: "Jan19" },
  ],
  height: 16,
  width: 72,
  theme: "dracula",
}).render();`,
    ...single(() =>
      candlestick({
        title: "CHRX — 10-Day Price Action",
        data: [
          { open: 142, high: 158, low: 138, close: 155, label: "Jan 8" },
          { open: 155, high: 168, low: 148, close: 151, label: "Jan 9" },
          { open: 151, high: 163, low: 143, close: 161, label: "Jan10" },
          { open: 161, high: 182, low: 158, close: 178, label: "Jan11" },
          { open: 178, high: 185, low: 162, close: 165, label: "Jan12" },
          { open: 165, high: 174, low: 155, close: 170, label: "Jan15" },
          { open: 170, high: 192, low: 167, close: 188, label: "Jan16" },
          { open: 188, high: 196, low: 176, close: 179, label: "Jan17" },
          { open: 179, high: 198, low: 178, close: 195, label: "Jan18" },
          { open: 195, high: 215, low: 190, close: 210, label: "Jan19" },
        ],
        height: 16,
        width: 72,
        theme: "dracula",
      }),
    ),
  },
  {
    id: "treemap",
    name: "Treemap",
    description:
      "Hierarchical area chart whose intensity is a grey tone ramp, with the single peak node marked in the accent hue.",
    code: `import { treemap } from "@chitra/core";

treemap({
  data: [
    { label: "TS",     value: 45 },
    { label: "Python", value: 30 },
    { label: "Rust",   value: 15 },
    { label: "Go",     value: 7  },
    { label: "Ruby",   value: 3  },
  ],
  title: "Codebase",
  width: 50,
  height: 10,
}).render();`,
    ...single(() =>
      treemap({
        data: [
          { label: "TS", value: 45 },
          { label: "Python", value: 30 },
          { label: "Rust", value: 15 },
          { label: "Go", value: 7 },
          { label: "Ruby", value: 3 },
        ],
        title: "Codebase",
        width: 50,
        height: 10,
      }),
    ),
  },
  {
    id: "sankey",
    name: "Sankey Diagram",
    description: "Flow diagram showing how quantities move between nodes.",
    code: `import { sankey } from "@chitra/core";

sankey({
  nodes: ["Users", "Free", "Pro", "Enterprise", "Churned"],
  links: [
    { source: 0, target: 1, value: 60 },
    { source: 0, target: 2, value: 30 },
    { source: 0, target: 3, value: 10 },
    { source: 1, target: 4, value: 20 },
  ],
  width: 52,
}).render();`,
    ...single(() =>
      sankey({
        nodes: ["Users", "Free", "Pro", "Enterprise", "Churned"],
        links: [
          { source: 0, target: 1, value: 60 },
          { source: 0, target: 2, value: 30 },
          { source: 0, target: 3, value: 10 },
          { source: 1, target: 4, value: 20 },
        ],
        width: 52,
      }),
    ),
  },
];
