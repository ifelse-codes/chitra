import type { BarChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { minMax, minMaxFlat, formatNumber, normalize, clamp } from "../utils.js";
import { buildBlockBar } from "../renderers/blocks.js";
import { buildAsciiBar } from "../renderers/ascii.js";

export function bar(opts: BarChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 10;
  const renderer = opts.renderer ?? "blocks";
  const showAxes = opts.showAxes !== false;
  const barWidth = 1;
  const barGap = 1;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti
    ? (rawData as number[][])
    : [rawData as number[]];

  const allValues = series.flat();
  const { min: dataMin, max: dataMax } = minMax(allValues);
  const yMin = opts.yMin ?? Math.min(0, dataMin);
  const yMax = opts.yMax ?? dataMax;

  const numBars = series[0].length;
  const numSeries = series.length;
  const labels = opts.labels ?? series[0].map((_, i) => String(i + 1));
  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);

  const yAxisWidth = formatNumber(yMax).length + 1;
  const plotWidth = Math.max(numBars * (numSeries * barWidth + barGap) - barGap, 1);
  const effectiveWidth = Math.min(width, Math.max(plotWidth + yAxisWidth + 2, 20));

  function buildColumns(): string[][] {
    const cols: string[][] = [];
    for (let b = 0; b < numBars; b++) {
      for (let s = 0; s < numSeries; s++) {
        const value = series[s][b];
        const color = theme.colors[s % theme.colors.length];
        let cells: string[];

        if (renderer === "ascii") {
          cells = buildAsciiBar(value, yMin, yMax, height, "#", " ");
        } else {
          cells = buildBlockBar(value, yMin, yMax, height, "█", " ");
        }

        cells = cells.map((c) =>
          c === " " ? " " : colorize(c, color, noColor)
        );
        cols.push(cells);
      }
      if (b < numBars - 1) {
        cols.push(Array(height).fill(" "));
      }
    }
    return cols;
  }

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
      lines.push("");
    }

    const cols = buildColumns();
    const yLabelStep = Math.max(1, Math.floor(height / 4));

    for (let row = 0; row < height; row++) {
      const yVal = yMax - (row / (height - 1)) * (yMax - yMin);
      const yLabel =
        row % yLabelStep === 0 || row === height - 1
          ? padStart(formatNumber(yVal), yAxisWidth)
          : " ".repeat(yAxisWidth);

      const axisChar = showAxes ? colorize("│", theme.axis, noColor) : " ";
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      for (const col of cols) {
        rowStr += col[row];
      }
      lines.push(rowStr);
    }

    if (showAxes) {
      const axisLine =
        " ".repeat(yAxisWidth) +
        colorize("└" + "─".repeat(cols.length), theme.axis, noColor);
      lines.push(axisLine);

      const labelLine =
        " ".repeat(yAxisWidth + 1) +
        labels
          .map((l) => {
            const seg = l.slice(0, numSeries * barWidth + barGap - 1);
            return padEnd(seg, numSeries * barWidth + barGap);
          })
          .join("")
          .slice(0, cols.length);
      lines.push(colorize(labelLine, theme.label, noColor));
    }

    if (opts.legend !== false && numSeries > 1) {
      lines.push("");
      const legendLine = seriesLabels
        .map((sl, i) => {
          const color = theme.colors[i % theme.colors.length];
          return colorize("■ " + sl, color, noColor);
        })
        .join("  ");
      lines.push(legendLine);
    }

    if (opts.xLabel) {
      lines.push(colorize(opts.xLabel, theme.label, noColor));
    }

    return lines;
  }

  const output = buildLines().join("\n");

  return {
    render() {
      process.stdout.write(output + "\n");
    },
    toString() {
      return output;
    },
    toPlain() {
      return stripAnsi(output);
    },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
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
