import type { ProgressOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";
import { buildHorizontalBlockBar } from "../renderers/blocks.js";
import { buildAsciiHBar } from "../renderers/ascii.js";

export function progress(opts: ProgressOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const max = opts.max ?? 100;
  const value = Math.min(Math.max(opts.value, 0), max);
  const width = opts.width ?? 30;
  const style = opts.style ?? "blocks";

  function buildOutput(): string {
    const parts: string[] = [];

    if (opts.label) {
      parts.push(colorize(opts.label + " ", theme.label, noColor));
    }

    parts.push(colorize("[", theme.axis, noColor));

    let bar: string;
    if (style === "braille" || style === "blocks") {
      bar = buildHorizontalBlockBar(value, 0, max, width);
    } else if (style === "ascii") {
      bar = buildAsciiHBar(value, 0, max, width, "=", ".");
    } else {
      bar = buildHorizontalBlockBar(value, 0, max, width);
    }

    const normalized = max === 0 ? 0 : value / max;
    const colorIdx = normalized < 0.33 ? 2 : normalized < 0.66 ? 3 : 1;
    parts.push(colorize(bar, theme.colors[colorIdx % theme.colors.length], noColor));
    parts.push(colorize("]", theme.axis, noColor));

    if (opts.showPercent !== false) {
      const pct = ((value / max) * 100).toFixed(1) + "%";
      parts.push(" " + colorize(pct, theme.label, noColor));
    }

    return parts.join("");
  }

  const output = buildOutput();

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "`" + stripAnsi(output) + "`"; },
    toJSON() {
      return {
        type: "progress",
        value,
        max,
        percent: +((value / max) * 100).toFixed(2),
        plain: stripAnsi(output),
      };
    },
  };
}
