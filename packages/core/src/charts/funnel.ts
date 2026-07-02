import type { FunnelOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";

export function funnel(opts: FunnelOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 50;
  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Stage ${i + 1}`);
  const maxValue = Math.max(...data);
  const showPercent = opts.showPercent !== false;

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
      lines.push("");
    }

    data.forEach((v, i) => {
      const color = theme.colors[i % theme.colors.length];
      const normalized = maxValue === 0 ? 0 : v / maxValue;
      const barWidth = Math.max(1, Math.round(normalized * (width - 20)));
      const leftPad = Math.floor((width - 20 - barWidth) / 2);

      const label = padEnd(labels[i] ?? "", 12);
      const value = formatNumber(v);
      const pct = showPercent && i > 0
        ? ` (${((v / data[0]) * 100).toFixed(1)}%)`
        : "";

      const bar = " ".repeat(leftPad) + colorize("█".repeat(barWidth), color, noColor);
      lines.push(
        colorize(label, theme.label, noColor) +
          " " +
          bar +
          " " +
          colorize(value + pct, theme.label, noColor)
      );

      if (i < data.length - 1) {
        const curr = Math.round(normalized * (width - 20));
        const next = Math.max(1, Math.round((maxValue === 0 ? 0 : data[i + 1] / maxValue) * (width - 20)));
        const connWidth = Math.floor((curr + next) / 4);
        const connLeft = Math.floor((width - 20 - connWidth) / 2);
        lines.push(
          " ".repeat(12) +
            " " +
            " ".repeat(connLeft) +
            colorize("▼".repeat(Math.max(1, connWidth)), theme.axis, noColor)
        );
      }
    });

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
        type: "funnel",
        data: opts.data,
        labels,
        conversionRates: data.map((v, i) =>
          i === 0 ? 1 : +(v / data[0]).toFixed(4)
        ),
        plain: stripAnsi(output),
      };
    },
  };
}
