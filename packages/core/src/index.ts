export { plot, PlotBuilder } from "./plot.js";

export {
  bar,
  line,
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
} from "./charts/index.js";

export { themes, resolveTheme } from "./themes/index.js";
export { BrailleCanvas, plotLineOnBrailleCanvas, plotAreaOnBrailleCanvas } from "./renderers/braille.js";
export { createLineChartModel, lineModelToSvg } from "./charts/line-model.js";
export type { LineChartModel, LineSeriesModel } from "./charts/line-model.js";
export { sparklineBlocks, buildHorizontalBlockBar, blockHeight } from "./renderers/blocks.js";
export { sparklineAscii, buildAsciiHBar } from "./renderers/ascii.js";
export { frameTop, frameBottom, frameRow, frameRule } from "./renderers/panel.js";
export { ansi, colorize, stripAnsi, truncateAnsi, hexToAnsi } from "./ansi.js";
export {
  minMax,
  normalize,
  clamp,
  formatNumber,
  quartiles,
  createGrid,
  gridToString,
} from "./utils.js";

export type {
  Theme,
  ThemeName,
  RendererType,
  OutputFormat,
  BaseChartOptions,
  LineChartOptions,
  BarChartOptions,
  HorizontalBarChartOptions,
  SparklineOptions,
  AreaChartOptions,
  HistogramOptions,
  ScatterPlotOptions,
  PieChartOptions,
  DonutChartOptions,
  HeatmapOptions,
  ProgressOptions,
  GaugeOptions,
  TimelineOptions,
  RadarChartOptions,
  BoxPlotOptions,
  WaterfallOptions,
  FunnelOptions,
  CandlestickOptions,
  TreemapOptions,
  SankeyOptions,
  ChartResult,
} from "./types.js";

// Injected at build time from package.json — see build.mjs (esbuild `define`)
// and vitest.config.ts (the same define, so the suite sees the real value).
// Never restate the version here: a literal in this file shipped as "0.1.0"
// inside dist/ while the manifest said 0.3.0 (S41 requirement 2). If the define
// is ever missing this throws a ReferenceError rather than silently lying.
declare const __CHITRA_VERSION__: string;
export const VERSION = __CHITRA_VERSION__;
