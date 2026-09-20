import type { HeatmapOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, padStart, stripAnsi, truncateAnsi } from "../ansi.js";
import { fitBodyLines, formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Plain-text shade ramp, one glyph per grey tone bucket (light → dark by
// magnitude). Kept in lock-step with the theme's grey tone ramp so the
// intensity reads even after stripAnsi (noColor / toPlain / toMarkdown).
const HEAT_SHADES = ["░", "▒", "▓", "█"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S18 design language:
 *  dashed frame, uppercase eyebrow row, `│` y-guide with a `+` at the top row,
 *  and a grid whose intensity IS the grey tone ramp (`#ECECEF → #C6C6CE →
 *  #A4A4AE → #6A6A75`, light → dark by magnitude). The single accent hue is
 *  spent EXACTLY once, on the maximum-value cell (ties → first in row-major
 *  order, deterministic). A `R×C grid · peak (r, c)` summary footer
 *  carries the peak coords in the accent hue. No `theme.colors[i % n]` rainbow —
 *  exactly like the LOCKED scatter/bar/line/area/circular charts. */
export function heatmap(opts: HeatmapOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 40;
  const showAxes = opts.showAxes !== false;
  const cellWidth = opts.cellWidth ?? 3;

  const acc = theme.accent!;
  const tones = theme.tones!;

  const data = opts.data ?? [];
  const rows = data.length;
  const cols = rows > 0 ? Math.max(...data.map((r) => r.length)) : 0;
  const cells = data.flat();
  const empty = cells.length === 0;

  // Ranges — guarded against empty data so the panel never emits Infinity/NaN.
  const minVal = empty ? 0 : Math.min(...cells);
  const maxVal = empty ? 0 : Math.max(...cells);
  const span = maxVal === minVal ? 1 : maxVal - minVal;

  const xLabels = opts.xLabels ?? Array.from({ length: cols }, (_, i) => String(i));
  const yLabels = opts.yLabels ?? Array.from({ length: rows }, (_, i) => String(i));
  const yLabelWidth = rows > 0 ? Math.max(...yLabels.map((l) => l.length)) + 1 : 0;

  // The one accent: the maximum-value cell, first in row-major order on ties.
  let peakR = -1;
  let peakC = -1;
  if (!empty) {
    let best = -Infinity;
    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < data[r]!.length; c++) {
        if (data[r]![c]! > best) {
          best = data[r]![c]!;
          peakR = r;
          peakC = c;
        }
      }
    }
  }

  // Bucket a value onto the grey tone ramp (light → dark). One bucket per tone.
  function toneIdx(value: number): number {
    const normalized = (value - minVal) / span;
    return Math.min(Math.floor(normalized * tones.length), tones.length - 1);
  }

  function guideFor(row: number): string {
    if (!showAxes) return "";
    // `+` on the top grid row mirrors the LOCKED scatter/line/bar y-tick language.
    return colorize(row === 0 ? "+" : "│", theme.axis, noColor);
  }

  function buildGridRows(): string[] {
    const out: string[] = [];

    // x-label header, aligned over the cells (past the y-label + guide gutter).
    const gutter = " ".repeat(yLabelWidth) + (showAxes ? " " : "");
    const xLabelLine =
      gutter + xLabels.map((l) => padEnd(l.slice(0, cellWidth), cellWidth)).join("");
    out.push(colorize(xLabelLine, theme.label, noColor));

    for (let r = 0; r < rows; r++) {
      let rowStr = colorize(padStart(yLabels[r] ?? String(r), yLabelWidth), theme.label, noColor);
      rowStr += guideFor(r);
      for (let c = 0; c < cols; c++) {
        const value = data[r]![c];
        if (value === undefined) {
          rowStr += " ".repeat(cellWidth); // ragged rows: honest empty cell
          continue;
        }
        if (r === peakR && c === peakC) {
          rowStr += colorize("█".repeat(cellWidth), acc, noColor);
          continue;
        }
        const idx = toneIdx(value);
        const glyph = HEAT_SHADES[Math.min(idx, HEAT_SHADES.length - 1)]!;
        rowStr += colorize(glyph.repeat(cellWidth), tones[idx]!, noColor);
      }
      out.push(rowStr);
    }
    return out;
  }

  function buildFooter(): string {
    if (empty) return colorize("0 cells · (no data)", theme.label, noColor);
    const head = colorize(
      `${rows}×${cols} grid`,
      theme.label,
      noColor
    );
    const peakCell = colorize(`peak (${peakR}, ${peakC})`, acc, noColor);
    return head + colorize(" · ", theme.label, noColor) + peakCell;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    const eyebrow = "DENSITY";
    if (useFrame && !useCompact) {
      lines.push(frameTop(width, opts.title ?? "HEATMAP", undefined, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(width, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(width, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
    }

    const gridRows = empty ? [] : fitBodyLines(buildGridRows(), opts.height);
    for (const row of gridRows) lines.push(useFrame && !useCompact ? frameRow(width, row, theme.axis, noColor) : row);

    if (!useCompact) {
      lines.push(useFrame ? frameRow(width, buildFooter(), theme.axis, noColor) : buildFooter());
    }
    if (useFrame && !useCompact) lines.push(frameBottom(width, theme.axis, noColor, true));
    return lines;
  }

  const rawLines = buildLines();
  const clippedLines = opts.maxWidth === undefined ? rawLines : rawLines.map((l) => truncateAnsi(l, opts.maxWidth!));
  const output = clippedLines.join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toContent() { return heatmap({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "heatmap",
        data: opts.data,
        xLabels,
        yLabels,
        min: minVal,
        max: maxVal,
        peak: empty ? null : { row: peakR, col: peakC },
        plain: stripAnsi(output),
      };
    },
  };
}
