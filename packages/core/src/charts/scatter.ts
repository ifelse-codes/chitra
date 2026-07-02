import type { ScatterPlotOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";
import { BrailleCanvas } from "../renderers/braille.js";

export function scatter(opts: ScatterPlotOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 15;
  const renderer = opts.renderer ?? "braille";
  const showAxes = opts.showAxes !== false;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]) && !("x" in rawData[0]);
  const series = isMulti
    ? (rawData as Array<Array<{ x: number; y: number }>>)
    : [rawData as Array<{ x: number; y: number }>];

  const allPoints = series.flat();
  const allX = allPoints.map((p) => p.x);
  const allY = allPoints.map((p) => p.y);
  const { min: xMin } = { min: opts.xMin ?? Math.min(...allX) };
  const xMax = opts.xMax ?? Math.max(...allX);
  const xMinVal = opts.xMin ?? Math.min(...allX);
  const yMinVal = opts.yMin ?? Math.min(...allY);
  const yMaxVal = opts.yMax ?? Math.max(...allY);

  const yAxisWidth = Math.max(formatNumber(yMaxVal).length, formatNumber(yMinVal).length) + 1;
  const plotCols = width - yAxisWidth - 2;
  const plotRows = height;
  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    if (renderer === "braille") {
      const canvases = series.map((s, si) => {
        const canvas = new BrailleCanvas(plotCols, plotRows);
        for (const pt of s) {
          const dotX = Math.round(
            ((pt.x - xMinVal) / (xMax === xMinVal ? 1 : xMax - xMinVal)) * (canvas.dotCols - 1)
          );
          const dotY =
            canvas.dotRows -
            1 -
            Math.round(
              ((pt.y - yMinVal) / (yMaxVal === yMinVal ? 1 : yMaxVal - yMinVal)) *
                (canvas.dotRows - 1)
            );
          canvas.set(dotX, dotY);
        }
        return canvas;
      });

      const yLabelStep = Math.max(1, Math.floor(plotRows / 5));
      for (let row = 0; row < plotRows; row++) {
        const yVal = yMaxVal - (row / (plotRows - 1)) * (yMaxVal - yMinVal);
        const yLabel =
          row % yLabelStep === 0 || row === plotRows - 1
            ? padStart(formatNumber(yVal), yAxisWidth)
            : " ".repeat(yAxisWidth);

        const axisChar = showAxes ? colorize("│", theme.axis, noColor) : " ";
        let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

        for (let col = 0; col < plotCols; col++) {
          let ch = "\u2800";
          for (let si = series.length - 1; si >= 0; si--) {
            const rowLine = canvases[si].toLines()[row] ?? "";
            const c = rowLine[col] ?? "\u2800";
            if (c !== "\u2800") {
              ch = colorize(c, theme.colors[si % theme.colors.length], noColor);
              break;
            }
          }
          rowStr += ch;
        }
        lines.push(rowStr);
      }
    } else {
      const grid: string[][] = Array.from({ length: plotRows }, () =>
        Array(plotCols).fill(" ")
      );

      series.forEach((s, si) => {
        const ch = ["●", "○", "◆", "◇", "▲", "△"][si % 6];
        for (const pt of s) {
          const col = Math.round(
            ((pt.x - xMinVal) / (xMax === xMinVal ? 1 : xMax - xMinVal)) * (plotCols - 1)
          );
          const row = Math.round(
            (1 - (pt.y - yMinVal) / (yMaxVal === yMinVal ? 1 : yMaxVal - yMinVal)) * (plotRows - 1)
          );
          if (col >= 0 && col < plotCols && row >= 0 && row < plotRows) {
            grid[row][col] = colorize(ch, theme.colors[si % theme.colors.length], noColor);
          }
        }
      });

      const yLabelStep = Math.max(1, Math.floor(plotRows / 5));
      for (let row = 0; row < plotRows; row++) {
        const yVal = yMaxVal - (row / (plotRows - 1)) * (yMaxVal - yMinVal);
        const yLabel =
          row % yLabelStep === 0 || row === plotRows - 1
            ? padStart(formatNumber(yVal), yAxisWidth)
            : " ".repeat(yAxisWidth);
        const axisChar = showAxes ? colorize("│", theme.axis, noColor) : " ";
        lines.push(colorize(yLabel, theme.label, noColor) + axisChar + grid[row].join(""));
      }
    }

    if (showAxes) {
      const axisWidth = renderer === "braille" ? plotCols * 2 : plotCols;
      lines.push(" ".repeat(yAxisWidth) + colorize("└" + "─".repeat(axisWidth), theme.axis, noColor));

      const xLabelLine =
        padStart(formatNumber(xMinVal), yAxisWidth + 1) +
        padEnd(formatNumber((xMinVal + xMax) / 2), Math.floor(axisWidth / 2)) +
        formatNumber(xMax);
      lines.push(colorize(xLabelLine, theme.label, noColor));
    }

    if (opts.legend !== false && series.length > 1) {
      lines.push("");
      lines.push(
        seriesLabels
          .map((sl, i) => colorize("● " + sl, theme.colors[i % theme.colors.length], noColor))
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
        type: "scatter",
        data: opts.data,
        title: opts.title,
        plain: stripAnsi(output),
      };
    },
  };
}
