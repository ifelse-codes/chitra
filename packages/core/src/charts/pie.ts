import type { PieChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";

const PIE_CHARS = ["█", "▓", "▒", "░", "▪", "▫", "◼", "◻"];

export function pie(opts: PieChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 40;
  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Item ${i + 1}`);
  const total = data.reduce((a, b) => a + b, 0);
  const radius = opts.radius ?? Math.floor(Math.min(width, (opts.height ?? 20)) / 4);

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
      lines.push("");
    }

    const cx = radius * 2;
    const cy = radius;
    const rows = radius * 2 + 1;
    const cols = radius * 4 + 1;

    const cumulative: number[] = [];
    let cum = 0;
    for (const v of data) {
      cum += (v / total) * Math.PI * 2;
      cumulative.push(cum);
    }

    for (let row = 0; row < rows; row++) {
      let rowStr = "";
      for (let col = 0; col < cols; col++) {
        const dx = (col - cx) / 2;
        const dy = row - cy;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist <= radius) {
          const angle = (Math.atan2(dy, dx) + Math.PI * 2) % (Math.PI * 2);
          let seriesIdx = data.length - 1;
          for (let i = 0; i < cumulative.length; i++) {
            if (angle < cumulative[i]) {
              seriesIdx = i;
              break;
            }
          }
          const color = theme.colors[seriesIdx % theme.colors.length];
          const ch = PIE_CHARS[seriesIdx % PIE_CHARS.length];
          rowStr += colorize(ch, color, noColor);
        } else {
          rowStr += " ";
        }
      }
      lines.push(rowStr);
    }

    lines.push("");
    data.forEach((v, i) => {
      const pct = ((v / total) * 100).toFixed(1);
      const color = theme.colors[i % theme.colors.length];
      const label = labels[i];
      const ch = PIE_CHARS[i % PIE_CHARS.length];
      lines.push(
        colorize(`${ch} ${label}: ${formatNumber(v)} (${pct}%)`, color, noColor)
      );
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
