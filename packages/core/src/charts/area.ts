import type { AreaChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, stripAnsi } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";
import { BrailleCanvas, plotAreaOnBrailleCanvas, plotLineOnBrailleCanvas } from "../renderers/braille.js";

export function area(opts: AreaChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 15;
  const showAxes = opts.showAxes !== false;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti
    ? (rawData as number[][])
    : [rawData as number[]];

  const allValues = series.flat();
  const { min: dataMin, max: dataMax } = minMax(allValues);
  const yMin = opts.yMin ?? Math.min(0, dataMin);
  const yMax = opts.yMax ?? dataMax;

  const yAxisWidth = Math.max(formatNumber(yMax).length, formatNumber(yMin).length) + 1;
  const plotCols = width - yAxisWidth - 2;
  const plotRows = height;
  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const fillCanvas = new BrailleCanvas(plotCols, plotRows);
    const lineCanvas = new BrailleCanvas(plotCols, plotRows);

    series.forEach((s) => {
      plotAreaOnBrailleCanvas(fillCanvas, s, yMin, yMax);
      plotLineOnBrailleCanvas(lineCanvas, s, yMin, yMax);
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

      const fillRow = fillCanvas.toLines()[row] ?? "";
      const lineRow = lineCanvas.toLines()[row] ?? "";

      for (let i = 0; i < fillRow.length; i++) {
        const lCh = lineRow[i] ?? "\u2800";
        const fCh = fillRow[i] ?? "\u2800";
        if (lCh !== "\u2800") {
          rowStr += colorize(lCh, theme.colors[0], noColor);
        } else if (fCh !== "\u2800") {
          rowStr += colorize(fCh, theme.colors[1] ?? theme.colors[0], noColor);
        } else {
          rowStr += "\u2800";
        }
      }

      lines.push(rowStr);
    }

    if (showAxes) {
      lines.push(
        " ".repeat(yAxisWidth) + colorize("└" + "─".repeat(plotCols * 2), theme.axis, noColor)
      );
    }

    if (opts.legend !== false && series.length > 1) {
      lines.push("");
      lines.push(
        seriesLabels
          .map((sl, i) => colorize("▓ " + sl, theme.colors[i % theme.colors.length], noColor))
          .join("  ")
      );
    }

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
        type: "area",
        data: opts.data,
        title: opts.title,
        plain: stripAnsi(output),
      };
    },
  };
}
