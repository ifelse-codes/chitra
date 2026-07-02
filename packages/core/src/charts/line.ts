import type { LineChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, stripAnsi } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";
import { BrailleCanvas, plotLineOnBrailleCanvas } from "../renderers/braille.js";

export function line(opts: LineChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 15;
  const renderer = opts.renderer ?? "braille";
  const showAxes = opts.showAxes !== false;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti
    ? (rawData as number[][])
    : [rawData as number[]];

  const allValues = series.flat();
  const { min: dataMin, max: dataMax } = minMax(allValues);
  const yMin = opts.yMin ?? dataMin;
  const yMax = opts.yMax ?? dataMax;

  const yAxisWidth = Math.max(formatNumber(yMax).length, formatNumber(yMin).length) + 1;
  const plotCols = width - yAxisWidth - 2;
  const plotRows = height;

  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);

  function renderBraille(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const canvases = series.map(() => new BrailleCanvas(plotCols, plotRows));
    series.forEach((s, si) => {
      plotLineOnBrailleCanvas(canvases[si], s, yMin, yMax);
    });

    const yLabelStep = Math.max(1, Math.floor(plotRows / 5));

    for (let row = 0; row < plotRows; row++) {
      const yVal = yMax - (row / (plotRows - 1)) * (yMax - yMin);
      const yLabel =
        row % yLabelStep === 0 || row === plotRows - 1
          ? padStart(formatNumber(yVal), yAxisWidth)
          : " ".repeat(yAxisWidth);

      const axisChar = showAxes ? colorize("│", theme.axis, noColor) : " ";
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      const rowChars = canvases.map((c) => c.toLines()[row] ?? "");

      if (series.length === 1) {
        rowStr += colorize(rowChars[0], theme.colors[0], noColor);
      } else {
        const merged = mergeCanvasRows(rowChars, series.length, theme.colors, noColor);
        rowStr += merged;
      }

      lines.push(rowStr);
    }

    if (showAxes) {
      lines.push(
        " ".repeat(yAxisWidth) + colorize("└" + "─".repeat(plotCols * 2), theme.axis, noColor)
      );

      if (opts.labels) {
        const labelStr = buildXLabels(opts.labels, plotCols * 2);
        lines.push(" ".repeat(yAxisWidth + 1) + colorize(labelStr, theme.label, noColor));
      }
    }

    if (opts.legend !== false && series.length > 1) {
      lines.push("");
      lines.push(
        seriesLabels
          .map((sl, i) => colorize("─ " + sl, theme.colors[i % theme.colors.length], noColor))
          .join("  ")
      );
    }

    return lines;
  }

  function renderBlocks(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const yLabelStep = Math.max(1, Math.floor(plotRows / 5));

    for (let row = 0; row < plotRows; row++) {
      const yVal = yMax - (row / (plotRows - 1)) * (yMax - yMin);
      const yLabel =
        row % yLabelStep === 0 || row === plotRows - 1
          ? padStart(formatNumber(yVal), yAxisWidth)
          : " ".repeat(yAxisWidth);

      const axisChar = showAxes ? colorize("│", theme.axis, noColor) : " ";
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      for (let col = 0; col < plotCols; col++) {
        let ch = " ";
        for (let si = series.length - 1; si >= 0; si--) {
          const s = series[si];
          const xIdx = Math.round((col / (plotCols - 1)) * (s.length - 1));
          const yNorm = (yMax === yMin) ? 0.5 : (s[xIdx] - yMin) / (yMax - yMin);
          const yRow = Math.round((1 - yNorm) * (plotRows - 1));
          if (row === yRow) {
            const color = theme.colors[si % theme.colors.length];
            ch = colorize("●", color, noColor);
            break;
          }
        }
        rowStr += ch;
      }
      lines.push(rowStr);
    }

    return lines;
  }

  function buildLines(): string[] {
    if (renderer === "braille") return renderBraille();
    return renderBlocks();
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
      };
    },
  };
}

function mergeCanvasRows(
  rows: string[],
  _numSeries: number,
  colors: string[],
  noColor: boolean
): string {
  if (rows.length === 0) return "";
  const len = rows[0].length;
  let result = "";
  for (let i = 0; i < len; i++) {
    let found = false;
    for (let si = 0; si < rows.length; si++) {
      const ch = rows[si][i];
      if (ch && ch !== "\u2800") {
        result += colorize(ch, colors[si % colors.length], noColor);
        found = true;
        break;
      }
    }
    if (!found) result += rows[0][i] ?? " ";
  }
  return result;
}

function buildXLabels(labels: string[], totalWidth: number): string {
  const n = labels.length;
  if (n === 0) return "";
  const positions = labels.map((_, i) => Math.round((i / (n - 1)) * (totalWidth - 1)));
  let line = " ".repeat(totalWidth);
  const arr = line.split("");
  labels.forEach((label, i) => {
    const pos = positions[i];
    const truncated = label.slice(0, Math.max(1, Math.floor(totalWidth / n) - 1));
    for (let j = 0; j < truncated.length; j++) {
      if (pos + j < totalWidth) arr[pos + j] = truncated[j];
    }
  });
  return arr.join("");
}
