import type { DonutChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";

const DONUT_CHARS = ["█", "▓", "▒", "░", "▪", "▫", "◼", "◻"];

export function donut(opts: DonutChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Item ${i + 1}`);
  const total = data.reduce((a, b) => a + b, 0);
  const radius = opts.radius ?? 8;
  const innerRadius = opts.innerRadius ?? Math.floor(radius * 0.5);

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

    const centerText = formatNumber(total);
    const centerRow = Math.floor(rows / 2);

    for (let row = 0; row < rows; row++) {
      let rowStr = "";
      for (let col = 0; col < cols; col++) {
        const dx = (col - cx) / 2;
        const dy = row - cy;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist >= innerRadius && dist <= radius) {
          const angle = (Math.atan2(dy, dx) + Math.PI * 2) % (Math.PI * 2);
          let seriesIdx = data.length - 1;
          for (let i = 0; i < cumulative.length; i++) {
            if (angle < cumulative[i]) {
              seriesIdx = i;
              break;
            }
          }
          const color = theme.colors[seriesIdx % theme.colors.length];
          const ch = DONUT_CHARS[seriesIdx % DONUT_CHARS.length];
          rowStr += colorize(ch, color, noColor);
        } else if (dist < innerRadius) {
          if (row === centerRow) {
            const offset = col - cx + Math.floor(centerText.length / 2);
            if (offset >= 0 && offset < centerText.length) {
              rowStr += colorize(centerText[offset], theme.label, noColor);
            } else {
              rowStr += " ";
            }
          } else {
            rowStr += " ";
          }
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
      const ch = DONUT_CHARS[i % DONUT_CHARS.length];
      lines.push(colorize(`${ch} ${label}: ${formatNumber(v)} (${pct}%)`, color, noColor));
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
        type: "donut",
        data: opts.data,
        labels,
        total,
        percentages: data.map((v) => +((v / total) * 100).toFixed(2)),
        plain: stripAnsi(output),
      };
    },
  };
}
