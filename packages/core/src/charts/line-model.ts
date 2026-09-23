import type { LineChartOptions } from "../types.js";
import { minMax, niceTicks, formatNumber } from "../utils.js";
import { resolveTheme, GREY_TONES } from "../themes/index.js";
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

/** Resolved theme colours (raw ANSI codes) the SVG renderer paints with — the
 *  same values the terminal renderer uses, so the two surfaces stay in step. */
export interface LineChartStyle {
  background: string;
  axis: string;
  label: string;
  title: string;
  grid: string;
  accent: string;
}

export interface LineChartModel {
  title: string;
  timestamp?: string;
  status?: string;
  showSummary: boolean;
  showLegend: boolean;
  xLabel: string;
  yLabel: string;
  eyebrow: string;
  labels: string[];
  yMin: number;
  yMax: number;
  yTicks: number[];
  series: LineSeriesModel[];
  /** Canonical terminal colours per series (ANSI truecolor). Both the terminal
   *  renderer and the SVG renderer read THIS array — the single source of truth
   *  that stops the two surfaces from drifting. */
  seriesColors: string[];
  /** Terminal's monochrome texture steps (1 solid, 2 dashed, 3 dotted). In
   *  colour mode every series is step 1, exactly like the terminal. */
  strokeSteps: number[];
  noColor: boolean;
  grid: boolean;
  style: LineChartStyle;
}

function seriesStats(values: number[]): LineSeriesStats {
  const total = values.reduce((sum, value) => sum + value, 0);
  return { min: Math.min(...values), max: Math.max(...values), avg: total / values.length, last: values[values.length - 1] };
}

const markers = ["*", "○", "+", "×", "◆", "□"];

/** The terminal's legend dash language: primary solid, extras dashed/dotted —
 *  a MONOCHROME fallback only; colour mode is solid for every series. */
export const DASH_CHARS = ["──", "╌╌", "··", "─╌"];
export const DASH_ARRAYS = ["none", "12 10", "3 9", "10 4"];

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
  const noColor = options.noColor ?? false;
  const longest = Math.max(...data.map((values) => values.length));
  const labels = options.labels?.length
    ? options.labels
    : Array.from({ length: Math.min(7, longest) }, (_, index) => `${index + 1}`);

  // Canonical colour logic, moved here from the terminal renderer so the model
  // owns it: a lone line keeps the grey tone ramp (accent spent once on its
  // peak); with several series the primary becomes the accent hero and the
  // extras recede onto the shared grey ramp.
  const accent = theme.accent ?? theme.colors[0]!;
  const tones = (theme.tones ?? GREY_TONES).filter(Boolean) as string[];
  const toneOrder = [tones[2], tones[0], tones[3] ?? tones[1], tones[1]].filter(Boolean) as string[];
  const multiSeries = data.length > 1;
  const seriesColors = data.map((_, index) =>
    index === 0 && multiSeries ? accent : toneOrder[index % toneOrder.length]!
  );
  const strokeSteps = data.map((_, index) => (noColor ? (index === 0 ? 1 : index === 1 ? 2 : 3) : 1));

  return {
    title: options.title ?? "Line chart",
    timestamp: options.timestamp,
    status: options.status,
    showSummary: options.summary ?? (options.legend !== false && data.length > 0),
    showLegend: options.legend !== false,
    xLabel: options.xLabel ?? "Time",
    yLabel: options.yLabel ?? "Value",
    eyebrow: (options.eyebrow ?? "TREND").toUpperCase(),
    labels,
    yMin,
    yMax,
    yTicks: ticks.ticks.filter((t) => t >= yMin - 1e-9 && t <= yMax + 1e-9),
    series: data.map((values, index) => ({
      name: options.seriesLabels?.[index] ?? `Series ${index + 1}`,
      color: seriesColors[index]!,
      marker: markers[index % markers.length],
      values,
      stats: seriesStats(values),
    })),
    seriesColors,
    strokeSteps,
    noColor,
    grid: options.grid ?? false,
    style: {
      background: "#07090a",
      axis: theme.axis,
      label: theme.label,
      title: theme.title,
      grid: theme.grid ?? theme.axis,
      accent,
    },
  };
}

/* ── SVG rendition ─────────────────────────────────────────────
 * Mirrors the terminal surface 1:1: the same theme tones, the same glyph
 * markers at every 2nd data point, the same monochrome dash textures, the
 * same optional dotted gridlines, the same legend/eyebrow/footer captions,
 * and the same "accent spent once on the peak" rule. The only intentional
 * difference is the medium: SVG draws contours as strokes, not braille cells.
 * Both renderers read `seriesColors`/`style` from the one model above. */

const SGR_HEX: Record<number, string> = {
  30: "#1c1c1c", 31: "#cd3131", 32: "#0dbc79", 33: "#e5e510",
  34: "#2472c8", 35: "#bc3fbc", 36: "#11a8cd", 37: "#e5e5e5",
  90: "#666666", 91: "#f14c4c", 92: "#23d18b", 93: "#f5f543",
  94: "#3b8eea", 95: "#d670d6", 96: "#29b8db", 97: "#f2f2f2",
};

/** ANSI (truecolor or xterm named) → CSS colour. */
export function ansiToCss(code: string): string {
  const tc = code.match(/38;2;(\d+);(\d+);(\d+)/);
  if (tc) return `rgb(${tc[1]},${tc[2]},${tc[3]})`;
  let hex = "#c6c6ce";
  for (const m of code.matchAll(/\x1b\[([0-9;]+)m/g)) {
    for (const part of m[1]!.split(";")) {
      const named = SGR_HEX[Number(part)];
      if (named) hex = named;
    }
  }
  return hex;
}

/** Index of the drawn glyph nearest the primary peak (accent lands once). */
function peakMarkerIndex(values: number[]): number {
  if (values.length === 0) return -1;
  let maxIdx = 0;
  let maxVal = values[0] ?? Number.NEGATIVE_INFINITY;
  values.forEach((v, i) => {
    if (v > maxVal) {
      maxVal = v;
      maxIdx = i;
    }
  });
  const even = maxIdx % 2 === 0 ? maxIdx : maxIdx - 1;
  return even < 0 ? 0 : even;
}

/** Exportable SVG rendition of the exact same model used by the terminal renderer. */
export function lineModelToSvg(model: LineChartModel, width = 1200, height = 430): string {
  const left = 104, right = 40, top = 108, bottom = height - 132;
  const plotWidth = width - left - right;
  const plotHeight = bottom - top;
  const style = model.style;
  const esc = (text: string) => text.replace(/[&<>"']/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[char]!);
  const point = (value: number, index: number, length: number) => {
    const x = left + (index / Math.max(1, length - 1)) * plotWidth;
    const y = top + plotHeight - ((value - model.yMin) / Math.max(1, model.yMax - model.yMin)) * plotHeight;
    return [x, y] as const;
  };
  const fmt = (n: number) => formatNumber(n);

  const parts: string[] = [];
  parts.push(`<rect width="100%" height="100%" fill="${style.background}"/>`);
  parts.push(`<text x="24" y="38" fill="${ansiToCss(style.title)}" font-size="22" font-weight="700">${esc(model.title)}</text>`);
  if (model.timestamp) {
    parts.push(`<text x="${width - 24}" y="38" fill="${ansiToCss(style.axis)}" font-size="14" text-anchor="end">${esc(model.timestamp)}</text>`);
  }
  parts.push(`<text x="24" y="68" fill="${ansiToCss(style.label)}" font-size="13" letter-spacing="3">${esc(model.eyebrow)}</text>`);

  // Legend — the terminal's `──glyph── name` dash pairs, one per series.
  if (model.showLegend && model.series.length > 0) {
    let lx = 24;
    model.series.forEach((series, i) => {
      const dash = model.noColor ? DASH_CHARS[(i % (DASH_CHARS.length - 1)) + 1] ?? DASH_CHARS[0]! : DASH_CHARS[0]!;
      const text = `${dash}${series.marker}${dash} ${series.name}`;
      parts.push(`<text x="${lx}" y="94" fill="${ansiToCss(model.seriesColors[i]!)}" font-size="14">${esc(text)}</text>`);
      lx += text.replace(/[^\x00-\x7f]/g, "").length * 8 + dash.length * 8 + 40;
    });
  }

  // Optional dotted gridlines — the terminal only draws these when `grid` is on.
  if (model.grid) {
    for (const value of model.yTicks) {
      const y = point(value, 0, 2)[1];
      if (y <= top + 1 || y >= bottom - 1) continue;
      parts.push(`<line x1="${left}" x2="${width - right}" y1="${y}" y2="${y}" stroke="${ansiToCss(style.grid)}" stroke-dasharray="2 8" stroke-opacity="0.85"/>`);
    }
  }

  // Axes + y tick labels (terminal prints integers at the y-step rows).
  parts.push(`<line x1="${left}" x2="${left}" y1="${top}" y2="${bottom}" stroke="${ansiToCss(style.axis)}" stroke-width="1.5"/>`);
  parts.push(`<line x1="${left}" x2="${width - right}" y1="${bottom}" y2="${bottom}" stroke="${ansiToCss(style.axis)}" stroke-width="1.5"/>`);
  for (const value of model.yTicks) {
    const y = point(value, 0, 2)[1];
    parts.push(`<text x="${left - 14}" y="${y}" fill="${ansiToCss(style.label)}" font-size="15" text-anchor="end" dominant-baseline="middle">${esc(fmt(Math.round(value)))}</text>`);
  }

  // Series: continuous contour (texture-coded in monochrome) + glyph markers
  // at every 2nd point, with the accent spent once on the primary peak.
  const peakIdx = peakMarkerIndex(model.series[0]?.values ?? []);
  model.series.forEach((series, si) => {
    if (series.values.length < 2) return;
    const hex = ansiToCss(model.seriesColors[si]!);
    const points = series.values.map((value, index) => point(value, index, series.values.length));
    const path = points.map(([x, y]) => `${x.toFixed(1)},${y.toFixed(1)}`).join(" ");
    parts.push(`<polyline points="${path}" fill="none" stroke="${hex}" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round" stroke-dasharray="${DASH_ARRAYS[model.strokeSteps[si]! - 1] ?? "none"}"/>`);
    points.forEach(([x, y], index) => {
      if (index % 2 !== 0) return; // markers at every 2nd point, like the terminal
      const isPeak = si === 0 && index === peakIdx;
      parts.push(`<text x="${x}" y="${y}" fill="${isPeak ? ansiToCss(style.accent) : hex}" font-size="18" text-anchor="middle" dominant-baseline="middle">${esc(series.marker)}</text>`);
    });
  });

  // X tick marks (`+`, terminal's dedicated tick row) + period labels.
  const n = model.labels.length;
  model.labels.forEach((label, i) => {
    const x = left + ((i + 0.5) / Math.max(1, n)) * plotWidth;
    parts.push(`<text x="${x}" y="${bottom + 24}" fill="${ansiToCss(style.axis)}" font-size="15" text-anchor="middle">+</text>`);
    parts.push(`<text x="${x}" y="${bottom + 48}" fill="${ansiToCss(style.label)}" font-size="15" text-anchor="middle">${esc(label)}</text>`);
  });
  parts.push(`<text x="${width / 2}" y="${height - 34}" fill="${ansiToCss(style.label)}" font-size="14" text-anchor="middle">${esc(model.xLabel)} →</text>`);

  // Summary footer — one row per series, echoing the terminal stats line and
  // its compact sparkline. The primary's `highest` is the accent's text use.
  if (model.showSummary && model.series.length > 0) {
    const sparkW = 160, sparkH = 26;
    const sparkX = width - right - sparkW;
    let rowY = height - 12 - model.series.length * 22;
    for (let si = 0; si < model.series.length; si++) {
      const series = model.series[si]!;
      const hex = ansiToCss(model.seriesColors[si]!);
      const stats = series.stats;
      const highest = `highest ${fmt(stats.max)}`;
      const base = `${series.marker} ${series.name} · lowest ${fmt(stats.min)} · `;
      parts.push(`<text x="24" y="${rowY}" fill="${hex}" font-size="15">${esc(base)}</text>`);
      const baseW = esc(base).length * 8.2;
      const highestColor = si === 0 ? ansiToCss(style.accent) : hex;
      parts.push(`<text x="${24 + baseW}" y="${rowY}" fill="${highestColor}" font-size="15">${esc(highest)}</text>`);
      parts.push(`<text x="${24 + baseW + highest.length * 8.2}" y="${rowY}" fill="${hex}" font-size="15">${esc(` · avg ${fmt(stats.avg)} · last ${fmt(stats.last)}`)}</text>`);

      // Compact sparkline (the terminal's `▁▂▃▄▅▆▇█` echo).
      const vals = series.values;
      if (vals.length >= 2) {
        const lo = Math.min(...vals), hi = Math.max(...vals);
        const span = hi - lo || 1;
        const pts = vals.map((v, i) => {
          const x = sparkX + (i / (vals.length - 1)) * sparkW;
          const y = rowY - 5 - ((v - lo) / span) * sparkH;
          return `${x.toFixed(1)},${y.toFixed(1)}`;
        }).join(" ");
        parts.push(`<polyline points="${pts}" fill="none" stroke="${hex}" stroke-width="1.6" stroke-opacity="0.9"/>`);
      }
      rowY += 22;
    }
  }

  parts.push(`<text x="24" y="${top - 12}" fill="${ansiToCss(style.label)}" font-size="12">${esc(model.yLabel)}</text>`);

  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" font-family="JetBrains Mono, ui-monospace, monospace">${parts.join("")}</svg>`;
}

export function lineModelToPlain(model: LineChartModel): object {
  return { ...model, series: model.series.map((series) => ({ ...series, color: stripAnsi(series.color) })) };
}
