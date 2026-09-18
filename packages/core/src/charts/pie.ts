import type { PieChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi, truncateAnsi } from "../ansi.js";
import { buildSlices, renderRing, renderLegend } from "./ring.js";
import { fitBodyLines } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

export function pie(opts: PieChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Item ${i + 1}`);

  const baseRadius = opts.radius ?? 8;
  const radius = opts.height === undefined ? baseRadius : Math.max(2, Math.min(baseRadius, Math.floor((opts.height - 1) / 2)));
  const innerRadius = 0;

  const { slices, total } = buildSlices(data, labels, theme);

  function buildLines(): string[] {
    const ring = renderRing(slices, radius, innerRadius, noColor);
    const legend = renderLegend(slices, noColor, theme);
    const ringCols = radius * 4 + 1;
    const width = opts.width ?? Math.max(ringCols + legend.width + 8, 52);
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;

    const lines: string[] = [];
    if (useFrame && !useCompact) {
      lines.push(frameTop(width, opts.title ?? "PIE", opts.timestamp, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(width, theme.axis, noColor));
    }
    if (opts.eyebrow && !useCompact) {
      lines.push(useFrame ? frameRow(width, colorize(opts.eyebrow.toUpperCase(), theme.label, noColor), theme.axis, noColor) : colorize(opts.eyebrow.toUpperCase(), theme.label, noColor));
    }

    // ring on the left, legend on the right, vertically centred
    const legendGap = 3;
    const h = Math.max(ring.length, legend.rows.length);
    const legendOffset = Math.max(0, Math.floor((ring.length - legend.rows.length) / 2));
    const combined: string[] = [];
    for (let i = 0; i < h; i++) {
      const ringRow = i < ring.length ? ring[i]! : "";
      const legRow = i >= legendOffset && i < legendOffset + legend.rows.length
        ? legend.rows[i - legendOffset]!
        : "";
      combined.push(padRow(ringRow, ringCols) + " ".repeat(legendGap) + legRow);
    }
    for (const content of fitBodyLines(combined, opts.height)) lines.push(useFrame && !useCompact ? frameRow(width, content, theme.axis, noColor) : content);

    if (useFrame && !useCompact) lines.push(frameRule(width, theme.axis, noColor));
    if (!useCompact) {
      const foot = `${slices.length} slices · total ${formatTotal(total)}`;
      lines.push(useFrame ? frameRow(width, foot, theme.axis, noColor) : foot);
    }
    if (opts.status && !useCompact) {
      if (useFrame) lines.push(frameRule(width, theme.axis, noColor));
      lines.push(useFrame ? frameRow(width, colorize(`Status: ${opts.status}`, theme.title, noColor), theme.axis, noColor) : colorize(`Status: ${opts.status}`, theme.title, noColor));
    }
    if (useFrame && !useCompact) lines.push(frameBottom(width, theme.axis, noColor, true));
    return lines;
  }

  function formatTotal(t: number): string {
    if (t >= 1_000_000) return (t / 1_000_000).toFixed(2) + "M";
    if (t >= 1_000) return (t / 1_000).toFixed(1) + "k";
    return String(Math.round(t));
  }

  const rawLines = buildLines();
  const clippedLines = opts.maxWidth === undefined ? rawLines : rawLines.map((l) => truncateAnsi(l, opts.maxWidth!));
  const output = clippedLines.join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toContent() { return pie({ ...opts, frame: false, compact: true }).toPlain(); },
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
