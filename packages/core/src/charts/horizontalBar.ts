import type { HorizontalBarChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";
import { buildHorizontalBlockBar } from "../renderers/blocks.js";
import { buildAsciiHBar } from "../renderers/ascii.js";

export function horizontalBar(opts: HorizontalBarChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const renderer = opts.renderer ?? "blocks";
  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Item ${i + 1}`);

  const { min: dataMin, max: dataMax } = minMax(data);
  const yMin = opts.yMin ?? Math.min(0, dataMin);
  const yMax = opts.yMax ?? dataMax;

  const labelWidth = Math.max(...labels.map((l) => l.length));
  const valueWidth = Math.max(formatNumber(yMax).length, formatNumber(yMin).length) + 1;
  const barWidth = width - labelWidth - valueWidth - 3;

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
      lines.push("");
    }

    data.forEach((v, i) => {
      const label = padEnd(labels[i], labelWidth);
      const valueStr = padStart(formatNumber(v), valueWidth);
      const color = theme.colors[i % theme.colors.length];

      let bar: string;
      if (renderer === "ascii") {
        bar = buildAsciiHBar(v, yMin, yMax, barWidth, "█", "░");
      } else {
        bar = buildHorizontalBlockBar(v, yMin, yMax, barWidth);
      }

      lines.push(
        colorize(label, theme.label, noColor) +
          " " +
          colorize(bar, color, noColor) +
          " " +
          colorize(valueStr, theme.label, noColor)
      );
    });

    if (opts.xLabel) {
      lines.push("");
      lines.push(
        " ".repeat(labelWidth + 1) + colorize(opts.xLabel, theme.label, noColor)
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
        type: "horizontalBar",
        data: opts.data,
        labels,
        plain: stripAnsi(output),
      };
    },
  };
}
