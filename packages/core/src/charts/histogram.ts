import type { HistogramOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";

export function histogram(opts: HistogramOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 10;
  const numBins = opts.bins ?? 10;
  const showAxes = opts.showAxes !== false;

  const data = opts.data;
  const { min: dataMin, max: dataMax } = minMax(data);
  const binSize = (dataMax - dataMin) / numBins;

  const bins = new Array(numBins).fill(0);
  for (const v of data) {
    const idx = Math.min(Math.floor((v - dataMin) / binSize), numBins - 1);
    bins[idx]++;
  }

  const maxCount = Math.max(...bins);
  const yMin = opts.yMin ?? 0;
  const yMax = opts.yMax ?? maxCount;
  const yAxisWidth = formatNumber(yMax).length + 1;

  const barWidth = Math.max(1, Math.floor((width - yAxisWidth - 2) / numBins));

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const yLabelStep = Math.max(1, Math.floor(height / 4));

    for (let row = 0; row < height; row++) {
      const yVal = yMax - (row / (height - 1)) * (yMax - yMin);
      const yLabel =
        row % yLabelStep === 0 || row === height - 1
          ? padStart(formatNumber(yVal), yAxisWidth)
          : " ".repeat(yAxisWidth);

      const axisChar = showAxes ? colorize("│", theme.axis, noColor) : " ";
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      for (let b = 0; b < numBins; b++) {
        const normalized = yMax === yMin ? 0 : (bins[b] - yMin) / (yMax - yMin);
        const fillHeight = Math.round(normalized * height);
        const isFilled = row >= height - fillHeight;
        const ch = isFilled ? "█" : " ";
        const color = theme.colors[0];
        rowStr += colorize(ch.repeat(barWidth), isFilled ? color : "", noColor).replace(
          /\x1b\[0m$/,
          isFilled ? "\x1b[0m" : ""
        );
        if (b < numBins - 1) rowStr += " ";
      }

      lines.push(rowStr);
    }

    if (showAxes) {
      const totalBarWidth = numBins * barWidth + (numBins - 1);
      lines.push(
        " ".repeat(yAxisWidth) + colorize("└" + "─".repeat(totalBarWidth), theme.axis, noColor)
      );

      const labelLine =
        " ".repeat(yAxisWidth + 1) +
        bins
          .map((_, i) => {
            const rangeStart = dataMin + i * binSize;
            return padEnd(formatNumber(rangeStart, 0), barWidth + 1);
          })
          .join("");
      lines.push(colorize(labelLine, theme.label, noColor));
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
        type: "histogram",
        data: opts.data,
        bins: numBins,
        binCounts: bins,
        title: opts.title,
        plain: stripAnsi(output),
      };
    },
  };
}
