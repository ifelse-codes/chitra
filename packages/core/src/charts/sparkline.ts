import type { SparklineOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Plain-text shade ramp, one glyph per grey tone bucket (light → dark by
// share of the range), in lock-step with the LOCKED heatmap/timeline/gauge/
// progress language: the intensity reads even after stripAnsi (noColor /
// toPlain / toMarkdown). The peak reading leaves the ramp and takes the
// solid accent block, spent EXACTLY once.
const LEVEL_SHADES = ["░", "▒", "▓", "█"];

// Plot geometry: every plotted point is one CELLW-wide column, ROWS tall at
// most — the v8 shape+shade grammar the founder locked (height reads the
// trend, shade reads the intensity, exactly like a one-row heatmap with a
// pulse). CELLW 2 keeps the dither glyphs rendering as solid cells in
// browser fonts (1-wide ░▒▓ speckles outside the terminal).
const CELLW = 2;
const ROWS = 4;

/** Renders a chitra-standard TUI panel carrying the LOCKED S28 design
 *  language — the S18–S27 panel language applied to the inline sparkline.
 *  The old single-teal `theme.colors[0]` strip is retired: every column is
 *  one tone from the grey ramp (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`) with its
 *  matching shade glyph (`░ ▒ ▓ █` by share of the data range, so intensity
 *  survives noColor), and the theme's ONE accent hue is spent EXACTLY once
 *  on the peak reading (ties → first in data order) as a solid `█` column.
 *  The `renderer` option stays accepted (public API unchanged) but the
 *  locked design supersedes it — no `▁▂▃` sub-blocks, no braille line, no
 *  ascii glyphs, ever. Panel chrome: dashed frame, uppercase `SPARKLINE`
 *  eyebrow, two rule separators, and an `n · min · max · last · peak` footer
 *  (the peak fact accented; `showValue: false` drops the `last` fact).
 *  `width` keeps its meaning (plotted data columns; longer input is
 *  deterministically downsampled to fit) and stays a floor for the panel,
 *  never a cap. Non-finite samples are excluded from the plot and every
 *  fact — never plotted, never counted; empty / all-non-finite input
 *  renders a framed `n 0 · (no data)` panel with null JSON facts. */
export function sparkline(opts: SparklineOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;

  const acc = theme.accent!;
  const tones = theme.tones!;

  // Only finite readings are plotted or counted — never NaN/Infinity.
  const finite = opts.data.filter((v) => typeof v === "number" && Number.isFinite(v));

  // Plotted columns: `width` keeps its meaning (data columns). Longer input
  // is downsampled on evenly spaced indices — deterministic, ties stable.
  const cols = Math.max(1, opts.width ?? Math.max(1, finite.length));
  const pts = downsample(finite, cols);
  // Every fact below describes the PLOTTED points (post-downsample), so the
  // foot can never disagree with the strip; `data` in toJSON keeps input.
  const count = pts.length;

  const min = count === 0 ? NaN : Math.min(...pts);
  const max = count === 0 ? NaN : Math.max(...pts);
  const last = count === 0 ? NaN : pts[pts.length - 1]!;
  // Peak reading (ties → first in data order, the family peak rule).
  const peakIndex = count === 0 ? -1 : pts.indexOf(max);

  const eyebrow = "SPARKLINE";
  const title = opts.label ?? "SPARKLINE";
  const summaryPlain =
    count === 0
      ? `n 0 · (no data)`
      : `n ${count} · min ${formatNumber(min)} · max ${formatNumber(max)}` +
        (opts.showValue === false ? `` : ` · last ${formatNumber(last)}`) +
        ` · peak ${formatNumber(max)}`;

  // Auto-width: expand the panel so the strip and the summary are never
  // clipped — an explicit `width` shaped the columns above and stays a
  // floor here, never a cap. `+4` is the frame padding.
  const stripWidth = CELLW * pts.length;
  const effectiveWidth = Math.max(stripWidth + 4, eyebrow.length + 4, summaryPlain.length + 4);

  function columnAt(i: number): { h: number; glyph: string; color: string } {
    const v = pts[i]!;
    const share = max === min ? 1 : (v - min) / (max - min);
    const h = 1 + Math.round(share * (ROWS - 1));
    if (i === peakIndex) return { h, glyph: "█", color: acc };
    const ti = Math.min(tones.length - 1, Math.floor(share * tones.length));
    return { h, glyph: LEVEL_SHADES[ti]!, color: tones[ti]! };
  }

  function buildStrip(): string[] {
    const columns = pts.map((_, i) => columnAt(i));
    const rows: string[] = [];
    for (let r = ROWS; r >= 1; r--) {
      let row = "";
      for (const col of columns) {
        row += r <= col.h ? colorize(col.glyph.repeat(CELLW), col.color, noColor) : " ".repeat(CELLW);
      }
      rows.push(row);
    }
    return rows;
  }

  function buildSummary(): string {
    if (count === 0) return colorize(summaryPlain, theme.label, noColor);
    const head = colorize(
      `n ${count} · min ${formatNumber(min)} · max ${formatNumber(max)}` +
        (opts.showValue === false ? `` : ` · last ${formatNumber(last)}`) +
        ` · `,
      theme.label,
      noColor
    );
    return head + colorize(`peak ${formatNumber(max)}`, acc, noColor);
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    lines.push(frameTop(effectiveWidth, title, undefined, theme.axis, theme.title, noColor, true));
    lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    lines.push(frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor));
    for (const row of buildStrip()) lines.push(frameRow(effectiveWidth, row, theme.axis, noColor));
    lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    lines.push(frameRow(effectiveWidth, buildSummary(), theme.axis, noColor));
    lines.push(frameBottom(effectiveWidth, theme.axis, noColor, true));
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
        type: "sparkline",
        data: opts.data,
        label: opts.label,
        count,
        min: count === 0 ? null : min,
        max: count === 0 ? null : max,
        last: count === 0 ? null : last,
        peak: count === 0 ? null : { index: peakIndex, value: max },
        plain: stripAnsi(output),
      };
    },
  };
}

/** Evenly spaced downsample to at most `cols` points — deterministic, order
 *  preserving. Short input passes through untouched. */
function downsample(values: number[], cols: number): number[] {
  if (values.length <= cols) return [...values];
  if (cols === 1) return [values[0]!];
  const out: number[] = [];
  for (let i = 0; i < cols; i++) out.push(values[Math.round((i * (values.length - 1)) / (cols - 1))]!);
  return out;
}
