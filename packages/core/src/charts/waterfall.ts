import type { WaterfallOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";

export function waterfall(opts: WaterfallOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 12;
  const showTotal = opts.showTotal !== false;

  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Step ${i + 1}`);

  const values: Array<{ start: number; end: number; value: number }> = [];
  let running = 0;
  for (const v of data) {
    const start = running;
    running += v;
    values.push({ start, end: running, value: v });
  }

  const totalValue = running;
  const allVals = values.flatMap((v) => [v.start, v.end]);
  const yMin = Math.min(0, ...allVals);
  const yMax = Math.max(0, ...allVals);

  const barData = showTotal
    ? [...values, { start: 0, end: totalValue, value: totalValue }]
    : values;
  const barLabels = showTotal ? [...labels, "Total"] : labels;
  const numBars = barData.length;

  const yAxisWidth = Math.max(formatNumber(yMax).length, formatNumber(yMin).length) + 1;
  const barWidth = Math.max(1, Math.floor((width - yAxisWidth - 2) / numBars) - 1);

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const yRange = yMax - yMin;
    const yLabelStep = Math.max(1, Math.floor(height / 4));

    for (let row = 0; row < height; row++) {
      const yVal = yMax - (row / (height - 1)) * yRange;
      const yLabel =
        row % yLabelStep === 0 || row === height - 1
          ? padStart(formatNumber(yVal), yAxisWidth)
          : " ".repeat(yAxisWidth);

      const axisChar = colorize("│", theme.axis, noColor);
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      barData.forEach((bar, i) => {
        const isTotal = showTotal && i === barData.length - 1;
        const isPositive = bar.value >= 0;

        const rowFrac = row / (height - 1);
        const yRowVal = yMax - rowFrac * yRange;
        const barTop = Math.max(bar.start, bar.end);
        const barBot = Math.min(bar.start, bar.end);
        const isFilled = yRowVal <= barTop && yRowVal >= barBot;
        const isZeroLine = Math.abs(yRowVal) < yRange / height;

        let color: string;
        if (isTotal) {
          color = opts.totalColor ?? theme.colors[2] ?? theme.colors[0];
        } else if (isPositive) {
          color = opts.positiveColor ?? theme.colors[1] ?? theme.colors[0];
        } else {
          color = opts.negativeColor ?? theme.colors[5] ?? theme.colors[0];
        }

        const ch = isFilled ? "█" : isZeroLine ? "─" : " ";
        rowStr += colorize(ch.repeat(barWidth), isFilled || isZeroLine ? color : "", noColor);
        rowStr += " ";
      });

      lines.push(rowStr);
    }

    lines.push(
      " ".repeat(yAxisWidth) +
        colorize("└" + "─".repeat(numBars * (barWidth + 1)), theme.axis, noColor)
    );

    const labelLine =
      " ".repeat(yAxisWidth + 1) +
      barLabels
        .map((l) => padEnd(l.slice(0, barWidth), barWidth + 1))
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
      return {
        type: "waterfall",
        data: opts.data,
        labels,
        total: totalValue,
        plain: stripAnsi(output),
      };
    },
  };
}
