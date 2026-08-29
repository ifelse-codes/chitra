export type RendererType = "braille" | "blocks" | "ascii";

export type ThemeName =
  | "default"
  | "nord"
  | "dracula"
  | "github-dark"
  | "tokyo-night"
  | "solarized"
  | "monochrome";

export type OutputFormat = "ansi" | "plain" | "markdown" | "json";

export interface Theme {
  name: string;
  colors: string[];
  axis: string;
  label: string;
  title: string;
  grid?: string;
  /** One-hue accent (mudra design language). Falls back to colors[0]. */
  accent?: string;
  /** Greyscale tone ramp for non-accent series. Falls back to a grey ramp. */
  tones?: string[];
}

export interface Padding {
  top: number;
  right: number;
  bottom: number;
  left: number;
}

export interface BaseChartOptions {
  width?: number;
  height?: number;
  title?: string;
  theme?: ThemeName | Theme;
  renderer?: RendererType;
  colors?: string[];
  padding?: Partial<Padding>;
  legend?: boolean;
  xLabel?: string;
  yLabel?: string;
  labels?: string[];
  showAxes?: boolean;
  output?: OutputFormat;
  noColor?: boolean;
}

export interface LineChartOptions extends BaseChartOptions {
  data: number[] | number[][];
  seriesLabels?: string[];
  smooth?: boolean;
  fill?: boolean;
  showPoints?: boolean;
  yMin?: number;
  yMax?: number;
  /** Shown top-right of the panel frame, e.g. "2026-07-29 10:42:17 IST". */
  timestamp?: string;
  /** Shown in the panel footer, e.g. "All systems operational ✓". */
  status?: string;
  /** Show min/max/avg/last summary block below the chart. Default true when legend is shown. */
  summary?: boolean;
  /** Eyebrow caption under the header (uppercase, spaced). */
  eyebrow?: string;
  /** Dotted `·` backdrop on the y-step rows. Default false — the y labels and
   *  `│` guide already carry the scale, so the plot reads cleaner without it. */
  grid?: boolean;
}

export interface BarChartOptions extends BaseChartOptions {
  data: number[] | number[][];
  seriesLabels?: string[];
  stacked?: boolean;
  yMin?: number;
  yMax?: number;
}

export interface HorizontalBarChartOptions extends BaseChartOptions {
  data: number[];
  yMin?: number;
  yMax?: number;
}

export interface SparklineOptions {
  data: number[];
  width?: number;
  renderer?: RendererType;
  theme?: ThemeName | Theme;
  noColor?: boolean;
  label?: string;
  showValue?: boolean;
}

export interface HistogramOptions extends BaseChartOptions {
  data: number[];
  bins?: number;
  yMin?: number;
  yMax?: number;
}

export interface ScatterPlotOptions extends BaseChartOptions {
  data: Array<{ x: number; y: number; label?: string }> | Array<Array<{ x: number; y: number }>>;
  seriesLabels?: string[];
  xMin?: number;
  xMax?: number;
  yMin?: number;
  yMax?: number;
  /** Eyebrow caption under the header (uppercase, letter-spaced). */
  eyebrow?: string;
  /** Optional override: index into the primary series that spends the one
   *  accent hue. Defaults to the primary series' max-y point (LOCKED S17). */
  highlight?: number;
}

export interface PieChartOptions extends BaseChartOptions {
  data: number[];
  radius?: number;
  /** Shown top-right of the dashed panel frame. */
  timestamp?: string;
  /** Shown in the panel footer, e.g. "All systems operational ✓". */
  status?: string;
  /** Eyebrow caption under the header (uppercase, spaced). */
  eyebrow?: string;
}

export interface DonutChartOptions extends PieChartOptions {
  innerRadius?: number;
  /** Show value + pct metric cells below the legend. Default true. */
  summary?: boolean;
}

export interface HeatmapOptions extends BaseChartOptions {
  data: number[][];
  xLabels?: string[];
  yLabels?: string[];
  colorScale?: "sequential" | "diverging";
  cellWidth?: number;
}

export interface ProgressOptions {
  value: number;
  max?: number;
  width?: number;
  label?: string;
  showPercent?: boolean;
  theme?: ThemeName | Theme;
  noColor?: boolean;
  style?: "bar" | "blocks" | "braille" | "ascii";
}

export interface GaugeOptions extends BaseChartOptions {
  value: number;
  min?: number;
  max?: number;
  thresholds?: Array<{ value: number; color: string }>;
  label?: string;
}

export interface TimelineOptions extends BaseChartOptions {
  events: Array<{
    label: string;
    start: number;
    end?: number;
    color?: string;
  }>;
  min?: number;
  max?: number;
}

export interface RadarChartOptions extends BaseChartOptions {
  data: number[] | number[][];
  labels: string[];
  seriesLabels?: string[];
  yMax?: number;
}

export interface BoxPlotOptions extends BaseChartOptions {
  data: number[] | number[][];
  yMin?: number;
  yMax?: number;
}

export interface WaterfallOptions extends BaseChartOptions {
  data: number[];
  positiveColor?: string;
  negativeColor?: string;
  totalColor?: string;
  showTotal?: boolean;
}

export interface FunnelOptions extends BaseChartOptions {
  data: number[];
  showPercent?: boolean;
}

export interface CandlestickOptions extends BaseChartOptions {
  data: Array<{ open: number; high: number; low: number; close: number; label?: string }>;
  yMin?: number;
  yMax?: number;
}

export interface TreemapOptions extends BaseChartOptions {
  data: Array<{ label: string; value: number; children?: Array<{ label: string; value: number }> }>;
}

export interface SankeyOptions extends BaseChartOptions {
  nodes: string[];
  links: Array<{ source: string; target: string; value: number }>;
}

export interface AreaChartOptions extends LineChartOptions {
  fillChar?: string;
}

export interface ChartResult {
  render(): void;
  toString(): string;
  toMarkdown(): string;
  toJSON(): object;
  toPlain(): string;
  /** Available for chart types with a browser-native renderer. */
  toSVG?(): string;
}
