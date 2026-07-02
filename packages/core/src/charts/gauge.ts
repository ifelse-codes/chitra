import type { GaugeOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";

export function gauge(opts: GaugeOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const value = opts.value;
  const min = opts.min ?? 0;
  const max = opts.max ?? 100;
  const width = opts.width ?? 40;

  const normalized = max === min ? 0 : (value - min) / (max - min);
  const tickCount = width;
  const filledTicks = Math.round(normalized * tickCount);

  function getColor(): string {
    if (opts.thresholds) {
      for (let i = opts.thresholds.length - 1; i >= 0; i--) {
        if (value >= opts.thresholds[i].value) {
          return opts.thresholds[i].color;
        }
      }
    }
    if (normalized < 0.33) return theme.colors[1] ?? theme.colors[0];
    if (normalized < 0.66) return theme.colors[3] ?? theme.colors[0];
    return theme.colors[2] ?? theme.colors[0];
  }

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const color = getColor();
    const filled = "▓".repeat(filledTicks);
    const empty = "░".repeat(tickCount - filledTicks);
    const bar =
      colorize("┤", theme.axis, noColor) +
      colorize(filled, color, noColor) +
      colorize(empty, theme.axis, noColor) +
      colorize("├", theme.axis, noColor);

    lines.push(bar);

    const minLabel = formatNumber(min);
    const maxLabel = formatNumber(max);
    const pct = (normalized * 100).toFixed(1) + "%";
    const valLabel = formatNumber(value);

    const labelLine =
      minLabel +
      " ".repeat(Math.max(0, Math.floor(tickCount / 2) - minLabel.length - pct.length / 2)) +
      colorize(valLabel + " (" + pct + ")", color, noColor) +
      " ".repeat(Math.max(0, tickCount - maxLabel.length)) +
      colorize(maxLabel, theme.label, noColor);

    lines.push(colorize(minLabel, theme.label, noColor) +
      " ".repeat(Math.max(0, tickCount - minLabel.length - maxLabel.length + 2)) +
      colorize(maxLabel, theme.label, noColor));

    if (opts.label) {
      lines.push(colorize(opts.label + ": " + valLabel, theme.label, noColor));
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
        type: "gauge",
        value,
        min,
        max,
        percent: +(normalized * 100).toFixed(2),
        plain: stripAnsi(output),
      };
    },
  };
}
