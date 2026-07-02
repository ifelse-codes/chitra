import type { HeatmapOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, padStart, stripAnsi } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";
import { shadeCell } from "../renderers/blocks.js";
import { hexToAnsi } from "../ansi.js";

const HEAT_CHARS = [" ", "░", "▒", "▓", "█"];
const HEAT_COLORS_DARK = [
  "#0a0a2e",
  "#1a1a5e",
  "#1e3a8a",
  "#1d4ed8",
  "#3b82f6",
  "#60a5fa",
  "#93c5fd",
  "#bfdbfe",
  "#f97316",
  "#ef4444",
];

export function heatmap(opts: HeatmapOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const data = opts.data;
  const rows = data.length;
  const cols = data[0]?.length ?? 0;
  const cellWidth = opts.cellWidth ?? 3;
  const xLabels = opts.xLabels ?? Array.from({ length: cols }, (_, i) => String(i));
  const yLabels = opts.yLabels ?? Array.from({ length: rows }, (_, i) => String(i));
  const yLabelWidth = Math.max(...yLabels.map((l) => l.length)) + 1;

  const allValues = data.flat();
  const { min, max } = minMax(allValues);

  function getColor(value: number): string {
    if (noColor) return "";
    const normalized = max === min ? 0.5 : (value - min) / (max - min);
    const idx = Math.min(Math.floor(normalized * HEAT_COLORS_DARK.length), HEAT_COLORS_DARK.length - 1);
    return hexToAnsi(HEAT_COLORS_DARK[idx]);
  }

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
      lines.push("");
    }

    const xLabelLine =
      " ".repeat(yLabelWidth) +
      xLabels
        .map((l) => padEnd(l.slice(0, cellWidth), cellWidth))
        .join("");
    lines.push(colorize(xLabelLine, theme.label, noColor));

    for (let r = 0; r < rows; r++) {
      const yLabel = padStart(yLabels[r] ?? String(r), yLabelWidth);
      let rowStr = colorize(yLabel, theme.label, noColor);

      for (let c = 0; c < cols; c++) {
        const value = data[r][c];
        const normalized = max === min ? 0.5 : (value - min) / (max - min);
        const ch = HEAT_CHARS[Math.min(Math.floor(normalized * HEAT_CHARS.length), HEAT_CHARS.length - 1)];
        const cell = ch.repeat(cellWidth);
        const color = getColor(value);
        rowStr += colorize(cell, color, noColor);
      }
      lines.push(rowStr);
    }

    lines.push("");
    const legend = buildLegend(min, max);
    lines.push(colorize(" ".repeat(yLabelWidth) + legend, theme.label, noColor));

    return lines;
  }

  function buildLegend(min: number, max: number): string {
    const steps = 10;
    let legend = "low ";
    for (let i = 0; i < steps; i++) {
      const normalized = i / (steps - 1);
      const ch = HEAT_CHARS[Math.min(Math.floor(normalized * HEAT_CHARS.length), HEAT_CHARS.length - 1)];
      const value = min + normalized * (max - min);
      if (!noColor) {
        legend += colorize(ch, getColor(value), false);
      } else {
        legend += ch;
      }
    }
    legend += ` high [${formatNumber(min)}–${formatNumber(max)}]`;
    return legend;
  }

  const output = buildLines().join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "heatmap",
        data: opts.data,
        xLabels,
        yLabels,
        min,
        max,
        plain: stripAnsi(output),
      };
    },
  };
}
