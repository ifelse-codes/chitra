import type { BarChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, stripAnsi, truncateAnsi, visibleLength } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";
import { buildBlockBar } from "../renderers/blocks.js";
import { buildAsciiBar } from "../renderers/ascii.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

const SPARK_CHARS = "▁▂▃▄▅▆▇█";

function seriesStats(values: number[]): { min: number; max: number; avg: number; last: number } {
  const min = Math.min(...values);
  const max = Math.max(...values);
  const avg = values.reduce((a, b) => a + b, 0) / (values.length || 1);
  const last = values[values.length - 1] ?? 0;
  return { min, max, avg, last };
}

function sparkStr(values: number[], color: string, width: number, noColor: boolean): string {
  if (values.length === 0 || width <= 0) return "";
  const lo = Math.min(...values);
  const hi = Math.max(...values);
  const range = hi - lo || 1;
  let out = "";
  for (let i = 0; i < width; i++) {
    const idx = Math.min(values.length - 1, Math.floor(((i + 0.5) / width) * values.length));
    const t = ((values[idx] ?? lo) - lo) / range;
    out += SPARK_CHARS[Math.min(7, Math.round(t * 7))]!;
  }
  return colorize(out, color, noColor);
}

/** Renders a chitra-standard TUI panel carrying the LOCKED S12 design language:
 *  dashed frame, eyebrow row, `│`/`+` y-guide, one accent + grey tone ramp
 *  (accent spent once on the peak bar), `+` x-tick row, and per-series
 *  AVG/PEAK summary with compact sparkline. */
export function bar(opts: BarChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const height = opts.height ?? 10;
  const renderer = opts.renderer ?? "blocks";
  const showAxes = opts.showAxes !== false;
  const barWidth = 1;
  const barGap = 1;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti ? (rawData as number[][]) : [rawData as number[]];
  const multiSeries = series.length > 1;

  const allValues = series.flat();
  const { min: dataMin, max: dataMax } = minMax(allValues);
  const yMin = opts.yMin ?? Math.min(0, dataMin);
  const yMax = opts.yMax ?? dataMax;

  const numBars = series[0]!.length;
  const numSeries = series.length;
  const labels = opts.labels ?? series[0]!.map((_, i) => String(i + 1));
  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);

  // One accent + grey tone ramp — same locked language as area/line/circular.
  // The single bar with the globally highest value gets the accent (spent once,
  // like the area's 3-dot peak cap and the circular's "largest slice = accent").
  // All other bars use the grey tone ramp; series identity comes from position
  // and the summary legend, not from separate bright hues.
  const acc = theme.accent!;
  const tones = theme.tones!;
  const toneOrder = [tones[2]!, tones[0]!, tones[3] ?? tones[1]!, tones[1]!].filter(Boolean) as string[];

  let maxSi = 0;
  let maxBi = 0;
  let maxVal = -Infinity;
  series.forEach((sv, si) => {
    sv.forEach((v, bi) => {
      if (v > maxVal) { maxVal = v; maxSi = si; maxBi = bi; }
    });
  });

  function barColorFor(si: number, bi: number): string {
    if (si === maxSi && bi === maxBi) return acc;
    if (!multiSeries) return toneOrder[0]!;
    return toneOrder[si % toneOrder.length]!;
  }

  const yAxisW = Math.max(
    formatNumber(yMax).length,
    formatNumber(yMin).length
  ) + 1; // +1 for the y-guide char (│ or +)

  const barSlotW = numSeries * barWidth + barGap;
  const plotCols = Math.max(numBars * barSlotW - barGap, 1);

  // Pre-compute the minimum inner width to fit the widest summary row so the
  // panel never clips its own footer (accent/stats are only meaningful uncut).
  const nameW = Math.max(...seriesLabels.map((l) => l.length)) + 2;
  const minSummaryInner = Math.max(...series.map((sv, si) => {
    const s = seriesStats(sv);
    return nameW + ` · avg ${formatNumber(s.avg)} · peak ${formatNumber(s.max)}`.length;
  }));

  // Reserve real room for the spark so it isn't silently starved to width 0 whenever the
  // summary row is the panel's binding width constraint. SPARK_RESERVE = SPARK_MIN glyphs +
  // 2 separator spaces (one matches buildSummary()'s existing pad convention, one is the
  // leading space placed directly before the spark itself).
  const SPARK_MIN = 5;
  const SPARK_RESERVE = SPARK_MIN + 2;
  const effectiveWidth = opts.width ?? Math.max(plotCols + yAxisW + 4, minSummaryInner + 4 + SPARK_RESERVE, 36);
  const innerWidth = effectiveWidth - 4;

  function yRowLabel(row: number): string {
    if (!showAxes) return "";
    const yLabelStep = Math.max(1, Math.floor(height / 4));
    const yVal = yMax - (row / Math.max(1, height - 1)) * (yMax - yMin);
    const label = (row % yLabelStep === 0 || row === height - 1)
      ? padStart(formatNumber(Math.round(yVal)), yAxisW - 1)
      : " ".repeat(yAxisW - 1);
    return colorize(label, theme.label, noColor);
  }

  function yGuide(row: number): string {
    if (!showAxes) return "";
    // `+` at the top row mirrors the reference's y-axis tick mark (LOCKED line chart).
    return colorize(row === 0 ? "+" : "│", theme.axis, noColor);
  }

  function buildPlotRows(): string[] {
    const rows: string[] = [];
    for (let row = 0; row < height; row++) {
      let line = yRowLabel(row) + yGuide(row);
      for (let b = 0; b < numBars; b++) {
        for (let s = 0; s < numSeries; s++) {
          const value = series[s]![b]!;
          const color = barColorFor(s, b);
          const cells = renderer === "ascii"
            ? buildAsciiBar(value, yMin, yMax, height, "#", " ")
            : buildBlockBar(value, yMin, yMax, height, "█", " ");
          const cell = cells[row]!;
          line += cell === " " ? " " : colorize(cell, color, noColor);
        }
        if (b < numBars - 1) line += " "; // gap between bar groups
      }
      rows.push(line);
    }
    return rows;
  }

  function buildXTicks(): string {
    if (!showAxes || labels.length === 0) return "";
    const cells: string[] = Array(plotCols).fill(" ");
    for (let b = 0; b < numBars; b++) {
      const groupStart = b * barSlotW;
      const mid = groupStart + Math.floor((numSeries - 1) / 2);
      if (mid < plotCols) cells[mid] = "+";
    }
    return " ".repeat(yAxisW) + colorize(cells.join(""), theme.axis, noColor);
  }

  function buildXLabels(): string {
    if (!showAxes || labels.length === 0) return "";
    const chars: string[] = Array(plotCols).fill(" ");
    for (let b = 0; b < numBars; b++) {
      const label = labels[b] ?? "";
      const slot = label.slice(0, barSlotW);
      const col = b * barSlotW;
      for (let j = 0; j < slot.length && col + j < plotCols; j++) {
        chars[col + j] = slot[j]!;
      }
    }
    return " ".repeat(yAxisW) + colorize(chars.join(""), theme.label, noColor);
  }

  function buildLegend(): string[] {
    if (!multiSeries || opts.legend === false) return [];
    const items = seriesLabels.map((sl, si) => {
      const color = toneOrder[si % toneOrder.length]!;
      return colorize("■ " + sl, color, noColor);
    });
    const rows: string[] = [];
    let cur = "";
    for (const item of items) {
      const candidate = cur ? cur + "  " + item : item;
      if (visibleLength(candidate) > innerWidth && cur) { rows.push(cur); cur = item; }
      else cur = candidate;
    }
    if (cur) rows.push(cur);
    return rows;
  }

  function buildSummary(): string[] {
    return series.map((sv, si) => {
      const stats = seriesStats(sv);
      const color = toneOrder[si % toneOrder.length]!;
      // Accent on the peak fact for the series that holds the global peak bar.
      const peakPart = si === maxSi
        ? colorize(`peak ${formatNumber(stats.max)}`, acc, noColor)
        : `peak ${formatNumber(stats.max)}`;
      const name = colorize(("■ " + seriesLabels[si]!).padEnd(nameW), color, noColor);
      const left = `${name} · avg ${formatNumber(stats.avg)} · ${peakPart}`;
      const room = innerWidth - visibleLength(left) - 2;
      const sparkW = room < SPARK_MIN ? 0 : Math.min(14, room);
      const rawSpark = sparkStr(sv, color, sparkW, noColor);
      const spark = rawSpark ? " " + rawSpark : "";
      const pad = Math.max(0, innerWidth - visibleLength(left) - visibleLength(spark) - 1);
      return left + " ".repeat(pad) + spark;
    });
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    // xLabel reused as the eyebrow caption; defaults to "VALUES" when absent.
    const eyebrow = (opts.xLabel ?? "VALUES").toUpperCase();
    if (useFrame && !useCompact) {
      lines.push(frameTop(effectiveWidth, opts.title ?? "BAR", undefined, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
      for (const item of buildLegend()) lines.push(useFrame ? frameRow(effectiveWidth, item, theme.axis, noColor) : item);
    }

    for (const row of buildPlotRows()) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row);

    const xTicks = buildXTicks();
    if (xTicks) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, xTicks, theme.axis, noColor) : xTicks);
    const xLabels = buildXLabels();
    if (xLabels) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, xLabels, theme.axis, noColor) : xLabels);

    if (!useCompact) {
      for (const row of buildSummary()) lines.push(useFrame ? frameRow(effectiveWidth, row, theme.axis, noColor) : row);
    }

    if (useFrame && !useCompact) lines.push(frameBottom(effectiveWidth, theme.axis, noColor, true));
    return lines;
  }

  const rawLines = buildLines();
  const clippedLines = opts.maxWidth === undefined ? rawLines : rawLines.map((l) => truncateAnsi(l, opts.maxWidth!));
  const output = clippedLines.join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toContent() { return bar({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "bar",
        data: opts.data,
        labels: opts.labels,
        title: opts.title,
        plain: stripAnsi(output),
      };
    },
  };
}
