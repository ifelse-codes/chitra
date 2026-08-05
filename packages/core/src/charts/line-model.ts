import type { LineChartOptions } from "../types.js";
import { minMax, niceTicks } from "../utils.js";
import { resolveTheme } from "../themes/index.js";
import { stripAnsi } from "../ansi.js";

export interface LineSeriesStats {
  min: number;
  max: number;
  avg: number;
  last: number;
}

export interface LineSeriesModel {
  name: string;
  color: string;
  marker: string;
  values: number[];
  stats: LineSeriesStats;
}

export interface LineChartModel {
  title: string;
  timestamp?: string;
  status?: string;
  showSummary: boolean;
  showLegend: boolean;
  xLabel: string;
  yLabel: string;
  labels: string[];
  yMin: number;
  yMax: number;
  yTicks: number[];
  series: LineSeriesModel[];
}

function seriesStats(values: number[]): LineSeriesStats {
  const total = values.reduce((sum, value) => sum + value, 0);
  return { min: Math.min(...values), max: Math.max(...values), avg: total / values.length, last: values[values.length - 1] };
}

const markers = ["*", "○", "+", "×", "◆", "□"];

/** Shared, renderer-neutral line-chart description for web and terminal output. */
export function createLineChartModel(options: LineChartOptions): LineChartModel {
  const raw = options.data;
  const data = Array.isArray(raw[0]) ? raw as number[][] : [raw as number[]];
  const { min, max } = minMax(data.flat());
  // Auto-scale the y-range to the data (like the LOCKED area chart) so the
  // line fills the panel height — no dead space hugging the bottom.
  const yMin = options.yMin ?? min;
  const yMax = options.yMax ?? max;
  const ticks = niceTicks(yMin, yMax, 6);
  const theme = resolveTheme(options.theme);
  const longest = Math.max(...data.map((values) => values.length));
  const labels = options.labels?.length
    ? options.labels
    : Array.from({ length: Math.min(7, longest) }, (_, index) => `${index + 1}`);

  return {
    title: options.title ?? "Line chart",
    timestamp: options.timestamp,
    status: options.status,
    showSummary: options.summary ?? (options.legend !== false && data.length > 0),
    showLegend: options.legend !== false,
    xLabel: options.xLabel ?? "Time",
    yLabel: options.yLabel ?? "Value",
    labels,
    yMin,
    yMax,
    yTicks: ticks.ticks.filter((t) => t >= yMin - 1e-9 && t <= yMax + 1e-9),
    series: data.map((values, index) => ({
      name: options.seriesLabels?.[index] ?? `Series ${index + 1}`,
      color: theme.colors[index % theme.colors.length],
      marker: markers[index % markers.length],
      values,
      stats: seriesStats(values),
    })),
  };
}

/** Exportable SVG rendition of the exact same model used by the terminal renderer. */
export function lineModelToSvg(model: LineChartModel, width = 1200, height = 430): string {
  const left = 72, right = 24, top = 32, bottom = 70;
  const plotWidth = width - left - right;
  const plotHeight = height - top - bottom;
  const esc = (text: string) => text.replace(/[&<>"']/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[char]!);
  const color = (ansi: string) => {
    const match = ansi.match(/\x1b\[38;2;(\d+);(\d+);(\d+)m/);
    return match ? `rgb(${match[1]},${match[2]},${match[3]})` : "#8ae234";
  };
  const point = (value: number, index: number, length: number) => {
    const x = left + (index / Math.max(1, length - 1)) * plotWidth;
    const y = top + plotHeight - ((value - model.yMin) / Math.max(1, model.yMax - model.yMin)) * plotHeight;
    return [x, y] as const;
  };
  const grids = model.yTicks.map((value) => {
    const y = point(value, 0, 2)[1];
    return `<line x1="${left}" x2="${width - right}" y1="${y}" y2="${y}" stroke="#474d47" stroke-dasharray="8 8"/><text x="${left - 14}" y="${y}" fill="#70e35d" font-size="16" text-anchor="end" dominant-baseline="middle">${esc(String(value))}</text>`;
  }).join("");
  const lines = model.series.map((series) => {
    const points = series.values.map((value, index) => point(value, index, series.values.length));
    const hex = color(series.color);
    const path = points.map(([x, y]) => `${x.toFixed(1)},${y.toFixed(1)}`).join(" ");
    const dots = points.filter((_, index) => index % 2 === 0).map(([x, y]) => `<text x="${x}" y="${y}" fill="${hex}" font-size="17" text-anchor="middle" dominant-baseline="middle">${series.marker}</text>`).join("");
    return `<polyline points="${path}" fill="none" stroke="${hex}" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round"/>${dots}`;
  }).join("");
  const xTicks = model.labels.map((label, index) => {
    const x = left + (index / Math.max(1, model.labels.length - 1)) * plotWidth;
    return `<line x1="${x}" x2="${x}" y1="${height - bottom}" y2="${height - bottom + 7}" stroke="#ccd6cc"/><text x="${x}" y="${height - bottom + 29}" fill="#70e35d" font-size="16" text-anchor="middle">${esc(label)}</text>`;
  }).join("");
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" font-family="JetBrains Mono, monospace"><rect width="100%" height="100%" fill="#07090a"/><text x="18" y="23" fill="#d7e0d7" font-size="16">${esc(model.yLabel)}</text>${grids}<line x1="${left}" x2="${left}" y1="${top}" y2="${height - bottom}" stroke="#ccd6cc"/><line x1="${left}" x2="${width - right}" y1="${height - bottom}" y2="${height - bottom}" stroke="#ccd6cc"/>${xTicks}<text x="${width / 2}" y="${height - 13}" fill="#70e35d" font-size="16" text-anchor="middle">${esc(model.xLabel)} →</text>${lines}</svg>`;
}

export function lineModelToPlain(model: LineChartModel): object {
  return { ...model, series: model.series.map((series) => ({ ...series, color: stripAnsi(series.color) })) };
}
