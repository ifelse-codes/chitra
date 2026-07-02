import type { BoxPlotOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { minMax, quartiles, formatNumber } from "../utils.js";

export function boxplot(opts: BoxPlotOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 8;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti
    ? (rawData as number[][])
    : [rawData as number[]];

  const labels = opts.labels ?? series.map((_, i) => `Group ${i + 1}`);

  const allValues = series.flat();
  const { min: globalMin, max: globalMax } = minMax(allValues);
  const yMin = opts.yMin ?? globalMin;
  const yMax = opts.yMax ?? globalMax;

  const yAxisWidth = Math.max(formatNumber(yMax).length, formatNumber(yMin).length) + 1;
  const plotWidth = width - yAxisWidth - 2;

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const stats = series.map((s) => quartiles(s));
    const boxHeight = Math.max(3, height);
    const seriesWidth = Math.floor(plotWidth / series.length);

    const yLabelStep = Math.max(1, Math.floor(boxHeight / 4));

    for (let row = 0; row < boxHeight; row++) {
      const yVal = yMax - (row / (boxHeight - 1)) * (yMax - yMin);
      const yLabel =
        row % yLabelStep === 0 || row === boxHeight - 1
          ? padStart(formatNumber(yVal), yAxisWidth)
          : " ".repeat(yAxisWidth);

      const axisChar = colorize("│", theme.axis, noColor);
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      stats.forEach((stat, si) => {
        const color = theme.colors[si % theme.colors.length];
        const toRow = (v: number) =>
          Math.round(((yMax - v) / (yMax - yMin)) * (boxHeight - 1));

        const q1Row = toRow(stat.q1);
        const q3Row = toRow(stat.q3);
        const medRow = toRow(stat.median);
        const minRow = toRow(stat.min);
        const maxRow = toRow(stat.max);

        const boxStart = Math.min(q1Row, q3Row);
        const boxEnd = Math.max(q1Row, q3Row);

        let seg = " ".repeat(seriesWidth);
        const mid = Math.floor(seriesWidth / 2);

        if (row >= boxStart && row <= boxEnd) {
          if (row === medRow) {
            seg = " ".repeat(mid - 1) + colorize("┼─┼", color, noColor) + " ".repeat(seriesWidth - mid - 2);
          } else {
            seg = " ".repeat(mid - 1) + colorize("│ │", color, noColor) + " ".repeat(seriesWidth - mid - 2);
          }
        } else if (row === minRow) {
          seg = " ".repeat(mid) + colorize("┴", color, noColor) + " ".repeat(seriesWidth - mid - 1);
        } else if (row === maxRow) {
          seg = " ".repeat(mid) + colorize("┬", color, noColor) + " ".repeat(seriesWidth - mid - 1);
        } else if (row > maxRow && row < boxStart) {
          seg = " ".repeat(mid) + colorize("│", color, noColor) + " ".repeat(seriesWidth - mid - 1);
        } else if (row > boxEnd && row < minRow) {
          seg = " ".repeat(mid) + colorize("│", color, noColor) + " ".repeat(seriesWidth - mid - 1);
        }

        rowStr += seg;
      });

      lines.push(rowStr);
    }

    lines.push(
      " ".repeat(yAxisWidth) +
        colorize("└" + "─".repeat(plotWidth), theme.axis, noColor)
    );

    const labelLine =
      " ".repeat(yAxisWidth + 1) +
      labels
        .map((l) => padEnd(l.slice(0, seriesWidth - 1), seriesWidth))
        .join("");
    lines.push(colorize(labelLine, theme.label, noColor));

    return lines;
  }

  const output = buildLines().join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      const stats = series.map((s) => quartiles(s));
      return {
        type: "boxplot",
        data: opts.data,
        labels,
        stats,
        plain: stripAnsi(output),
      };
    },
  };
}
