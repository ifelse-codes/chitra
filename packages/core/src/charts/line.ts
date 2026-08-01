import type { LineChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, stripAnsi, visibleLength } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { createLineChartModel, lineModelToPlain, lineModelToSvg, type LineChartModel, type LineSeriesModel } from "./line-model.js";
import { BrailleCanvas, plotLineOnBrailleCanvas } from "../renderers/braille.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

function terminalWidth(explicit?: number): number {
  if (explicit) return explicit;
  const cols = typeof process !== "undefined" ? process.stdout?.columns : undefined;
  return Math.max(60, Math.min(cols || 76, 100));
}

/** Renders a chitra-standard TUI panel: frame, header, legend, plot, summary, status. */
export function line(opts: LineChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = terminalWidth(opts.width);
  const height = opts.height ?? 14;
  const renderer = opts.renderer ?? "braille";
  const showAxes = opts.showAxes !== false;

  const model = createLineChartModel(opts);
  const innerWidth = width - 4; // minus "│ " ... " │"

  const yAxisWidth = Math.max(
    formatNumber(model.yMax).length,
    formatNumber(model.yMin).length,
    ...model.yTicks.map((t) => formatNumber(t).length)
  ) + 1;
  const plotCols = Math.max(8, innerWidth - (showAxes ? yAxisWidth + 1 : 0));
  const plotRows = height;

  function plotRowLabel(row: number): { label: string; isTick: boolean } {
    if (!showAxes) return { label: "", isTick: false };
    const closest = model.yTicks.find((t) => {
      const rowNorm = 1 - row / Math.max(1, plotRows - 1);
      const tNorm = (t - model.yMin) / Math.max(1e-9, model.yMax - model.yMin);
      return Math.abs(rowNorm - tNorm) < 0.5 / Math.max(1, plotRows - 1);
    });
    if (closest === undefined) return { label: " ".repeat(yAxisWidth), isTick: false };
    return { label: padStart(formatNumber(closest), yAxisWidth), isTick: true };
  }

  function renderBraillePlot(): string[] {
    const canvases = model.series.map(() => new BrailleCanvas(plotCols, plotRows));
    model.series.forEach((series, index) => {
      plotLineOnBrailleCanvas(canvases[index], series.values, model.yMin, model.yMax);
    });

    const rows: string[] = [];
    for (let row = 0; row < plotRows; row++) {
      const { label, isTick } = plotRowLabel(row);
      const axisChar = showAxes ? colorize(isTick ? "├" : "│", theme.axis, noColor) : "";
      const emptyChar = isTick ? colorize("·", theme.axis, noColor) : "\u2800";
      const rowChars = canvases.map((c) => c.toLines(emptyChar)[row] ?? "");
      const merged = mergeCanvasRows(rowChars, model.series, noColor, emptyChar);
      const prefix = showAxes ? colorize(label, theme.label, noColor) + axisChar : "";
      rows.push(prefix + merged);
    }
    return rows;
  }

  function renderBlockPlot(): string[] {
    const grid = Array.from({ length: plotRows }, () => Array<string>(plotCols).fill(""));
    model.series.forEach((series, si) => {
      const values = series.values;
      const colorAnsi = series.color;
      for (let col = 0; col < plotCols; col++) {
        const exactX = (col / Math.max(1, plotCols - 1)) * (values.length - 1);
        const idxL = Math.floor(exactX);
        const idxR = Math.min(values.length - 1, Math.ceil(exactX));
        const frac = exactX - idxL;
        const val = values[idxL] + frac * (values[idxR] - values[idxL]);
        const yNorm = model.yMax === model.yMin ? 0.5 : (val - model.yMin) / (model.yMax - model.yMin);
        const yRow = Math.round((1 - yNorm) * (plotRows - 1));

        let ch = renderer === "ascii" ? series.marker : "●";
        if (renderer === "ascii" && col > 0) {
          const isExactPoint = frac < 0.1 || frac > 0.9;
          if (!isExactPoint) {
            const prevX = ((col - 1) / Math.max(1, plotCols - 1)) * (values.length - 1);
            const prevVal = values[Math.floor(prevX)];
            ch = val > prevVal + 1e-9 ? "/" : val < prevVal - 1e-9 ? "\\" : "-";
          }
        }
        if (yRow >= 0 && yRow < plotRows && !grid[yRow][col]) {
          grid[yRow][col] = colorize(ch, colorAnsi, noColor);
        }
      }
    });

    const rows: string[] = [];
    for (let row = 0; row < plotRows; row++) {
      const { label, isTick } = plotRowLabel(row);
      const axisChar = showAxes ? colorize(isTick ? "├" : "│", theme.axis, noColor) : "";
      const prefix = showAxes ? colorize(label, theme.label, noColor) + axisChar : "";
      let rowStr = prefix;
      for (let col = 0; col < plotCols; col++) {
        rowStr += grid[row][col] || (isTick && showAxes ? colorize("┈", theme.axis, noColor) : " ");
      }
      rows.push(rowStr);
    }
    return rows;
  }

  function renderXAxis(): string[] {
    if (!showAxes) return [];
    const axisPrefix = " ".repeat(yAxisWidth);
    const rows = [colorize(axisPrefix + "└" + "─".repeat(plotCols), theme.axis, noColor)];
    if (model.labels.length > 0) {
      const n = model.labels.length;
      const positions = model.labels.map((_, i) => Math.round((i / Math.max(1, n - 1)) * (plotCols - 1)));
      const tickChars = Array<string>(plotCols).fill("─");
      positions.forEach((p) => { if (p >= 0 && p < plotCols) tickChars[p] = "┼"; });
      rows[0] = colorize(axisPrefix + "└" + tickChars.join(""), theme.axis, noColor);
      const labelChars = Array<string>(plotCols).fill(" ");
      model.labels.forEach((label, i) => {
        const pos = positions[i];
        const truncated = label.slice(0, Math.max(1, Math.floor(plotCols / n) - 1));
        for (let j = 0; j < truncated.length; j++) {
          const col = pos - Math.floor(truncated.length / 2) + j;
          if (col >= 0 && col < plotCols) labelChars[col] = truncated[j];
        }
      });
      rows.push(" ".repeat(yAxisWidth + 1) + colorize(labelChars.join(""), theme.label, noColor));
    }
    return rows;
  }

  function renderLegend(): string[] {
    if (!model.showLegend || model.series.length === 0) return [];
    const items = model.series.map((s) => colorize(`──${s.marker}── ${s.name}`, s.color, noColor));
    return wrapItems(items, innerWidth);
  }

  function renderSummary(): string[] {
    if (!model.showSummary) return [];
    const rows: string[] = [colorize("╌".repeat(innerWidth), theme.axis, noColor)];
    const colWidth = Math.max(16, Math.floor(innerWidth / Math.max(1, model.series.length)));
    let line1 = "", line2 = "", line3 = "", line4 = "", header = "";
    model.series.forEach((s) => {
      header += padVisible(colorize(s.name, s.color, noColor), colWidth);
      line1 += padVisible(colorize(` min ${formatNumber(s.stats.min)}`, theme.label, noColor), colWidth);
      line2 += padVisible(colorize(` max ${formatNumber(s.stats.max)}`, theme.label, noColor), colWidth);
      line3 += padVisible(colorize(` avg ${formatNumber(s.stats.avg)}`, theme.label, noColor), colWidth);
      line4 += padVisible(colorize(`last ${formatNumber(s.stats.last)}`, theme.label, noColor), colWidth);
    });
    rows.push(header, line1, line2, line3, line4);
    return rows;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    lines.push(frameTop(width, model.title, opts.timestamp, theme.axis, theme.title, noColor));
    if (opts.timestamp || model.showLegend) {
      lines.push(frameRule(width, theme.axis, noColor));
    }
    for (const item of renderLegend()) lines.push(frameRow(width, item, theme.axis, noColor));
    if (model.showLegend) lines.push(frameRow(width, "", theme.axis, noColor));

    const plotRowsOut = renderer === "braille" ? renderBraillePlot() : renderBlockPlot();
    for (const row of plotRowsOut) lines.push(frameRow(width, row, theme.axis, noColor));
    for (const row of renderXAxis()) lines.push(frameRow(width, row, theme.axis, noColor));

    for (const row of renderSummary()) lines.push(frameRow(width, row, theme.axis, noColor));

    if (opts.status) {
      lines.push(frameRule(width, theme.axis, noColor));
      lines.push(frameRow(width, colorize(`Status: ${opts.status}`, theme.title, noColor), theme.axis, noColor));
    }
    lines.push(frameBottom(width, theme.axis, noColor));
    return lines;
  }

  const output = buildLines().join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "line",
        data: opts.data,
        labels: opts.labels,
        title: opts.title,
        plain: stripAnsi(output),
        model: lineModelToPlain(model),
      };
    },
    toSVG() { return lineModelToSvg(model); },
  };
}

function padVisible(str: string, width: number): string {
  const len = visibleLength(str);
  return len >= width ? str : str + " ".repeat(width - len);
}

function wrapItems(items: string[], maxWidth: number): string[] {
  const rows: string[] = [];
  let current = "";
  for (const item of items) {
    const candidate = current ? current + "  " + item : item;
    if (visibleLength(candidate) > maxWidth && current) {
      rows.push(current);
      current = item;
    } else {
      current = candidate;
    }
  }
  if (current) rows.push(current);
  return rows;
}

function mergeCanvasRows(
  rows: string[],
  series: LineSeriesModel[],
  noColor: boolean,
  emptyChar: string = "\u2800"
): string {
  if (rows.length === 0) return "";
  const visualRows = rows.map(extractVisualChars);
  const len = visualRows[0]?.length ?? 0;
  const emptyVisible = stripAnsi(emptyChar);
  let result = "";

  for (let i = 0; i < len; i++) {
    let found = false;
    for (let si = 0; si < visualRows.length; si++) {
      const ch = visualRows[si][i];
      if (ch && ch !== emptyVisible && ch !== "\u2800" && ch !== " ") {
        result += colorize(ch, series[si].color, noColor);
        found = true;
        break;
      }
    }
    if (!found) result += emptyChar;
  }
  return result;
}

function extractVisualChars(row: string): string[] {
  const chars: string[] = [];
  let inEscape = false;
  for (let i = 0; i < row.length; i++) {
    const ch = row[i];
    if (ch === "\x1b") { inEscape = true; continue; }
    if (inEscape) { if (ch === "m") inEscape = false; continue; }
    chars.push(ch);
  }
  return chars;
}
