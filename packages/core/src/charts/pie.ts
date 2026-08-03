import type { PieChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { stripAnsi } from "../ansi.js";
import { buildSlices, renderRing, renderLegend } from "./ring.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

export function pie(opts: PieChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Item ${i + 1}`);

  const radius = opts.radius ?? 8;
  const innerRadius = 0;

  const { slices, total } = buildSlices(data, labels, theme);

  function buildLines(): string[] {
    const ring = renderRing(slices, radius, innerRadius, noColor);
    const legend = renderLegend(slices, noColor, theme);
    const ringCols = radius * 4 + 1;
    const width = opts.width ?? Math.max(ringCols + legend.width + 8, 52);

    const lines: string[] = [];
    lines.push(frameTop(width, opts.title ?? "PIE", undefined, theme.axis, theme.title, noColor, true));
    lines.push(frameRule(width, theme.axis, noColor));

    // ring on the left, legend on the right, vertically centred
    const legendGap = 3;
    const h = Math.max(ring.length, legend.rows.length);
    const legendOffset = Math.max(0, Math.floor((ring.length - legend.rows.length) / 2));
    for (let i = 0; i < h; i++) {
      const ringRow = i < ring.length ? ring[i]! : "";
      const legRow = i >= legendOffset && i < legendOffset + legend.rows.length
        ? legend.rows[i - legendOffset]!
        : "";
      const content = padRow(ringRow, ringCols) + " ".repeat(legendGap) + legRow;
      lines.push(frameRow(width, content, theme.axis, noColor));
    }

    lines.push(frameRule(width, theme.axis, noColor));
    const foot = `${slices.length} slices · total ${formatTotal(total)}`;
    lines.push(frameRow(width, foot, theme.axis, noColor));
    lines.push(frameBottom(width, theme.axis, noColor, true));
    return lines;
  }

  function formatTotal(t: number): string {
    if (t >= 1_000_000) return (t / 1_000_000).toFixed(2) + "M";
    if (t >= 1_000) return (t / 1_000).toFixed(1) + "k";
    return String(Math.round(t));
  }

  const output = buildLines().join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "pie",
        data: opts.data,
        labels,
        total,
        percentages: data.map((v) => +((v / total) * 100).toFixed(2)),
        plain: stripAnsi(output),
      };
    },
  };
}

function padRow(row: string, width: number): string {
  const len = stripAnsi(row).length;
  return len >= width ? row : row + " ".repeat(width - len);
}
