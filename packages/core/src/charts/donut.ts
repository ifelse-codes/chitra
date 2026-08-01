import type { DonutChartOptions, ChartResult } from "../types.js";
import { resolveTheme, GREY_TONES } from "../themes/index.js";
import { colorize, stripAnsi, visibleLength } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

const SLICE_CHARS = ["█", "▓", "▒", "░"];
const GLYPHS = ["*", "o", "+", "x"];

function padV(str: string, width: number): string {
  const len = visibleLength(str);
  return len >= width ? str : str + " ".repeat(width - len);
}

export function donut(opts: DonutChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Item ${i + 1}`);
  const total = data.reduce((a, b) => a + b, 0);
  const radius = opts.radius ?? 6;
  const innerRadius = opts.innerRadius ?? Math.max(2, Math.floor(radius * 0.5));

  const accent = theme.accent ?? theme.colors[0] ?? GREY_TONES[0]!;
  const tones = theme.tones ?? GREY_TONES;

  // slice color: the primary (first) slice gets the accent hue; the rest get
  // the greyscale tone ramp (mudra "one hue + tone ramp" separation).
  const colorAt = (i: number) => (i === 0 ? accent : tones[(i - 1) % tones.length]);

  function renderRing(): string[] {
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
    const out: string[] = [];

    for (let row = 0; row < rows; row++) {
      let rowStr = "";
      for (let col = 0; col < cols; col++) {
        const dx = (col - cx) / 2;
        const dy = row - cy;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist >= innerRadius && dist <= radius) {
          const angle = (Math.atan2(dy, dx) + Math.PI * 2) % (Math.PI * 2);
          let idx = data.length - 1;
          for (let i = 0; i < cumulative.length; i++) {
            if (angle < cumulative[i]) {
              idx = i;
              break;
            }
          }
          rowStr += colorize(SLICE_CHARS[idx % SLICE_CHARS.length], colorAt(idx), noColor);
        } else if (dist < innerRadius) {
          if (row === centerRow) {
            const offset = col - cx + Math.floor(centerText.length / 2);
            if (offset >= 0 && offset < centerText.length) {
              rowStr += colorize(centerText[offset]!, theme.label, noColor);
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
      out.push(rowStr);
    }
    return out;
  }

  function buildLines(): string[] {
    const ring = renderRing();
    const ringCols = radius * 4 + 1;
    const eyebrow = (opts.eyebrow ?? "DISTRIBUTION").toUpperCase();
    const width = opts.width ?? Math.max(ringCols + 8, 48);
    const inner = width - 4;

    const lines: string[] = [];
    lines.push(frameTop(width, opts.title ?? "DONUT", opts.timestamp, theme.axis, theme.title, noColor, true));
    lines.push(frameRule(width, theme.axis, noColor));
    lines.push(frameRow(width, colorize(eyebrow, theme.label, noColor), theme.axis, noColor));
    lines.push(frameRow(width, "", theme.axis, noColor));

    const padLeft = Math.max(0, Math.floor((inner - ringCols) / 2));
    for (const r of ring) lines.push(frameRow(width, " ".repeat(padLeft) + r, theme.axis, noColor));

    lines.push(frameRow(width, "", theme.axis, noColor));
    lines.push(frameRow(width, glyphLegend(inner), theme.axis, noColor));

    if (opts.summary !== false) {
      lines.push(frameRule(width, theme.axis, noColor));
      for (const row of metricCells(inner)) lines.push(frameRow(width, row, theme.axis, noColor));
    }

    if (opts.status) {
      lines.push(frameRule(width, theme.axis, noColor));
      lines.push(frameRow(width, colorize(`Status: ${opts.status}`, theme.title, noColor), theme.axis, noColor));
    }
    lines.push(frameBottom(width, theme.axis, noColor, true));
    return lines;
  }

  function glyphLegend(inner: number): string {
    const items = labels.map((label, i) => {
      const glyph = colorize(GLYPHS[i % GLYPHS.length]!, colorAt(i), noColor);
      const name = colorize(label, colorAt(i), noColor);
      return `${glyph}─${name}`;
    });
    return items.join("   ");
  }

  function metricCells(inner: number): string[] {
    const colW = Math.max(12, Math.floor(inner / Math.max(1, data.length)));
    const header = labels
      .map((label, i) => colorize(`${i === 0 ? "●" : "·"} ${label.toUpperCase()}`, colorAt(i), noColor))
      .map((s) => padV(s, colW))
      .join("");
    const values = data
      .map((v, i) => {
        const pct = ((v / total) * 100).toFixed(1);
        const cell = colorize(formatNumber(v), colorAt(i), noColor) + colorize(` ${pct}%`, theme.label, noColor);
        return cell;
      })
      .map((s) => padV(s, colW))
      .join("");
    return [header, values];
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
