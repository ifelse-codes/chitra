import type { CandlestickOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Minimum candle width so the dashed down-outline (`┌╌╌┐`) stays legible.
const CANDLE_MIN = 4;

/** Adaptive price-axis precision (the S27 precision rule): integers once the
 *  range spans 100+, otherwise ≤1dp (range ≥ 10) or ≤2dp, trimmed — compact
 *  labels, never float sprawl. Foot facts use the same rule. */
export function axisPriceFmt(v: number, range: number): string {
  if (!Number.isFinite(range) || range >= 100) return formatNumber(Math.round(v));
  const dp = range >= 10 ? 1 : 2;
  const n = Number(v.toFixed(dp));
  if (n === 0) return "0";
  if (Number.isInteger(n)) return formatNumber(n);
  return String(n);
}

/** Renders a chitra-standard TUI panel carrying the LOCKED S27 design language —
 *  the S26 waterfall card applied to OHLC data: dashed frame, uppercase
 *  eyebrow, tonal kinds with shade texture, adaptive price labels, and a facts
 *  foot row.
 *  - **Tonal kinds, never rainbow.** Up candles are solid `▓` fills on a mid
 *    grey tone; down candles are the dashed outline (`┌╌╌┐` top / `│  │`
 *    sides / `└╌╌┘` bottom, the waterfall down language) on a light grey
 *    tone — direction reads through `stripAnsi` / `noColor`. The old
 *    `theme.colors[2]` green / `theme.colors[5]` red flood is retired. Doji
 *    candles (open == close) count as up (a 1-row solid).
 *  - **One accent, spent EXACTLY once.** The peak candle (highest close, ties
 *    → first in data order, the family peak rule) renders its body as solid
 *    `█` in the theme's accent hue. Wicks always stay in the candle's own
 *    kind tone (never accent), so at raw-ANSI level the accent touches only
 *    solid `█` body mass plus non-block text (the `LAST` foot fact).
 *  - **Adaptive price labels** (`axisPriceFmt`): integers when the range is
 *    wide, ≤2dp when tight — never the old `162.55`-style sprawl, and never
 *    silent integer rounding of real prices. `│`/`+` guide, dashed `└╌`
 *    baseline, full period labels under their candles, two rule separators.
 *  - Panel width auto-expands (explicit `width` is a floor, candles fit the
 *    longest period label — never the old 4-char `Jan`/`Jan1` mush — with a
 *    `CANDLE_MIN` floor so outlines never clip). The frame top carries
 *    `opts.title`; the eyebrow stays `OHLC` (never an uppercased title echo).
 *  - **Degenerate input is safe.** Empty / all-non-finite renders a framed `N 0 · (no data)` panel with
 *    null JSON facts; a flat range (all OHLC equal) pads ±1 so candles stay
 *    visible (never `NaN` rows); non-finite candles are excluded, never
 *    plotted. No `NaN`/`Infinity` anywhere. */
export function candlestick(opts: CandlestickOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const height = Math.max(2, opts.height ?? 15);
  const showAxes = opts.showAxes !== false;

  const acc = theme.accent!;
  const tones = theme.tones!;
  const tUp = tones[Math.min(2, tones.length - 1)]!;
  const tDown = tones[0]!;

  const raw = opts.data ?? [];
  const valid = raw.filter(
    (c) => Number.isFinite(c.open) && Number.isFinite(c.high) && Number.isFinite(c.low) && Number.isFinite(c.close)
  );
  const n = valid.length;
  const empty = n === 0;

  let yMin = empty ? 0 : Math.min(...valid.map((c) => c.low));
  let yMax = empty ? 0 : Math.max(...valid.map((c) => c.high));
  if (Number.isFinite(opts.yMin)) yMin = opts.yMin!;
  if (Number.isFinite(opts.yMax)) yMax = opts.yMax!;
  // Flat-range guard: every OHLC equal (or a collapsed override) pads ±1 so
  // every candle owns visible rows instead of NaN.
  if (!empty && yMax === yMin) {
    yMin -= 1;
    yMax += 1;
  }
  const yRange = yMax - yMin;

  // The one accent: highest close, first in data order on ties (strict `>`).
  let peakIdx = 0;
  valid.forEach((c, i) => {
    if (c.close > valid[peakIdx]!.close) peakIdx = i;
  });
  const high = empty ? null : Math.max(...valid.map((c) => c.high));
  const low = empty ? null : Math.min(...valid.map((c) => c.low));
  const last = empty ? null : valid[valid.length - 1]!.close;

  const eyebrow = "OHLC";

  // Candles fit the longest period label (never the 4-char `Jan`/`Jan1`
  // mush), with a floor so outlines stay legible.
  const candleW = Math.max(CANDLE_MIN, ...valid.map((c) => (c.label ?? "").length));
  const footPlain = empty
    ? "N 0 · (no data)"
    : `N ${n} · HI ${axisPriceFmt(high!, yRange)} · LO ${axisPriceFmt(low!, yRange)} · LAST ${axisPriceFmt(last!, yRange)}`;

  const mid = Math.floor(candleW / 2);
  const plotCols = n > 0 ? n * (candleW + 1) - 1 : 0;

  // Y-label width fits the widest printed tick (intermediate prices can be
  // wider than the min/max — the old fixed-width clipping bug).
  const yLabelStep = Math.max(1, Math.floor(height / 4));
  function tickLabel(row: number): string {
    const yVal = yMax - (row / Math.max(1, height - 1)) * yRange;
    return axisPriceFmt(yVal, empty ? 0 : yRange);
  }
  const yLabelW = Math.max(
    1,
    ...Array.from({ length: height }, (_, row) =>
      row % yLabelStep === 0 || row === height - 1 ? tickLabel(row).length : 1
    )
  );
  const gutter = showAxes ? yLabelW + 1 : 0;

  // Auto-width: the panel expands so plot, eyebrow, labels, and foot are
  // never clipped — an explicit `width` is a floor, not a cap.
  const effectiveWidth = Math.max(
    opts.width ?? 60,
    gutter + plotCols + 4,
    eyebrow.length + 4,
    footPlain.length + 4,
    40
  );

  const rowOf = (v: number): number =>
    yRange === 0
      ? height - 1
      : Math.min(height - 1, Math.max(0, Math.round(((yMax - v) / yRange) * (height - 1))));

  function yRowLabel(row: number): string {
    if (!showAxes) return "";
    const label =
      row % yLabelStep === 0 || row === height - 1 ? padStart(tickLabel(row), yLabelW) : " ".repeat(yLabelW);
    return colorize(label, theme.label, noColor);
  }

  function yGuide(row: number): string {
    if (!showAxes) return "";
    return colorize(row === 0 ? "+" : "│", theme.axis, noColor);
  }

  function outlineCell(row: number, rTop: number, rBot: number, color: string): string {
    if (rTop === rBot) return colorize("┌" + "╌".repeat(Math.max(0, candleW - 2)) + "┐", color, noColor);
    if (row === rTop) return colorize("┌" + "╌".repeat(Math.max(0, candleW - 2)) + "┐", color, noColor);
    if (row === rBot) return colorize("└" + "╌".repeat(Math.max(0, candleW - 2)) + "┘", color, noColor);
    return colorize("│" + " ".repeat(Math.max(0, candleW - 2)) + "│", color, noColor);
  }

  function wickCell(color: string): string {
    return colorize(" ".repeat(mid) + "│" + " ".repeat(Math.max(0, candleW - mid - 1)), color, noColor);
  }

  function buildPlotRows(): string[] {
    const rows: string[] = [];
    for (let row = 0; row < height; row++) {
      let line = yRowLabel(row) + yGuide(row);
      valid.forEach((c, i) => {
        const highRow = rowOf(c.high);
        const lowRow = rowOf(c.low);
        const bodyTop = Math.min(rowOf(c.open), rowOf(c.close));
        const bodyBot = Math.max(rowOf(c.open), rowOf(c.close));
        const isUp = c.close >= c.open;
        const isPeak = i === peakIdx;
        const kindTone = isUp ? tUp : tDown;
        let cell: string;
        if (row >= bodyTop && row <= bodyBot) {
          if (isPeak) cell = colorize("█".repeat(candleW), acc, noColor);
          else if (isUp) cell = colorize("▓".repeat(candleW), kindTone, noColor);
          else cell = outlineCell(row, bodyTop, bodyBot, kindTone);
        } else if ((row >= highRow && row < bodyTop) || (row > bodyBot && row <= lowRow)) {
          cell = wickCell(kindTone);
        } else {
          cell = " ".repeat(candleW);
        }
        line += cell;
        if (i < valid.length - 1) line += " ";
      });
      rows.push(line);
    }
    return rows;
  }

  function buildBaseline(): string {
    if (!showAxes || empty) return "";
    return " ".repeat(yLabelW) + colorize("└" + "╌".repeat(plotCols), theme.axis, noColor);
  }

  function buildPeriodLabels(): string {
    if (!showAxes || empty) return "";
    return (
      " ".repeat(gutter) +
      colorize(
        valid.map((c) => padEnd((c.label ?? "").slice(0, candleW), candleW + 1)).join(""),
        theme.label,
        noColor
      )
    );
  }

  function buildSummary(): string {
    if (empty) return colorize(footPlain, theme.label, noColor);
    const head = colorize(
      `N ${n} · HI ${axisPriceFmt(high!, yRange)} · LO ${axisPriceFmt(low!, yRange)} · `,
      theme.label,
      noColor
    );
    return head + colorize(`LAST ${axisPriceFmt(last!, yRange)}`, acc, noColor);
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    lines.push(
      frameTop(effectiveWidth, opts.title ?? "CANDLESTICK", undefined, theme.axis, theme.title, noColor, true)
    );
    lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    lines.push(frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor));
    if (!empty) {
      for (const row of buildPlotRows()) lines.push(frameRow(effectiveWidth, row, theme.axis, noColor));
      const baseline = buildBaseline();
      if (baseline) lines.push(frameRow(effectiveWidth, baseline, theme.axis, noColor));
      const labels = buildPeriodLabels();
      if (labels.trim()) lines.push(frameRow(effectiveWidth, labels, theme.axis, noColor));
    }
    lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    lines.push(frameRow(effectiveWidth, buildSummary(), theme.axis, noColor));
    lines.push(frameBottom(effectiveWidth, theme.axis, noColor, true));
    return lines;
  }

  const output = buildLines().join("\n");

  return {
    render() {
      process.stdout.write(output + "\n");
    },
    toString() {
      return output;
    },
    toPlain() {
      return stripAnsi(output);
    },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
    toJSON() {
      return {
        type: "candlestick",
        data: opts.data,
        plain: stripAnsi(output),
        // Additive S27 facts (null when there is no data).
        count: n,
        high,
        low,
        last,
      };
    },
  };
}
