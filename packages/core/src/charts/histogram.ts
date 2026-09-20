import type { HistogramOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, padStart, stripAnsi, truncateAnsi } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Plain-text shade ramp, one glyph per grey tone bucket (light → dark by bin
// count), in lock-step with the LOCKED heatmap/timeline/gauge/progress
// language: the intensity reads even after stripAnsi (noColor / toPlain /
// toMarkdown). The mode bin leaves the ramp and takes the solid accent block.
const COUNT_SHADES = ["░", "▒", "▓", "█"];

/** Nearest-rank percentile of an ascending-sorted sample. */
function percentile(sorted: number[], p: number): number {
  if (sorted.length === 0) return 0;
  const idx = Math.max(0, Math.min(sorted.length - 1, Math.ceil((p / 100) * sorted.length) - 1));
  return sorted[idx]!;
}

/** Renders a chitra-standard TUI panel carrying the LOCKED S25 design language —
 *  the S12 `bar` orientation applied to binned distribution data: dashed frame,
 *  uppercase eyebrow, one accent hue spent EXACTLY once on the mode bin (the
 *  highest count, ties → first bin in order, deterministic — the same rule as
 *  bar/timeline/horizontalBar) as a solid `█` column, with the grey tone ramp
 *  for every other bin (never a `theme.colors` flood — the old
 *  `theme.colors[0]` wall is retired). The ramp is ALSO the texture: each
 *  bin's shade glyph (`░ ▒ ▓ █`, light → dark by count bucket) carries the
 *  density through noColor, exactly like the LOCKED heatmap/timeline. Y-axis
 *  labels are INTEGER counts (counts are integers — the old decimal y-labels
 *  `36.56` were a lie the axis told); the baseline is the dashed `└╌…╌`
 *  vocabulary, bin-start labels sit under their columns in the label tone.
 *  One `│ ╌…╌ │` rule separator and a `N samples · peak` foot row with
 *  the `peak` fact in the accent hue (nearest-rank mode over the
 *  sample). Degenerate input is safe: empty / all-non-finite data renders a
 *  framed `0 samples · (no data)` panel; a collapsed range (every value equal)
 *  lands every sample in the first bin — never NaN. Panel width auto-expands
 *  so the eyebrow, x-labels, and summary are never clipped (an explicit
 *  `width` is a floor, not a cap). */
export function histogram(opts: HistogramOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const height = opts.height ?? 10;
  const numBins = Math.max(1, opts.bins ?? 10);
  const showAxes = opts.showAxes !== false;

  const acc = theme.accent!;
  const tones = theme.tones!;

  // Non-finite samples are excluded from the distribution (never NaN-binned).
  const values = opts.data.filter((v) => Number.isFinite(v));
  const hasData = values.length > 0;
  const sorted = [...values].sort((a, b) => a - b);
  const { min: dataMin, max: dataMax } = hasData ? minMax(values) : { min: 0, max: 0 };

  const binSize = (dataMax - dataMin) / numBins;
  const bins = new Array<number>(numBins).fill(0);
  for (const v of values) {
    // A collapsed range (every value equal → binSize 0) lands in bin 0 —
    // never a NaN index.
    const idx = binSize > 0 ? Math.min(Math.floor((v - dataMin) / binSize), numBins - 1) : 0;
    bins[idx]++;
  }

  const maxCount = hasData ? Math.max(...bins) : 0;
  const yMin = opts.yMin ?? 0;
  const yMax = opts.yMax ?? maxCount;

  // The one accent: the MODE bin (highest count), first in bin order on ties
  // (strict `>` never reassigns on a later equal).
  let modeIdx = 0;
  let modeCount = -1;
  bins.forEach((c, i) => {
    if (c > modeCount) { modeCount = c; modeIdx = i; }
  });
  const modeValue = hasData ? dataMin + modeIdx * binSize : 0;
  const p50 = percentile(sorted, 50);
  const p99 = percentile(sorted, 99);

  const eyebrow = (opts.xLabel ?? "DISTRIBUTION").toUpperCase();
  const summaryPlain = hasData
    ? `${values.length} samples · peak ${formatNumber(modeValue)}`
    : "0 samples · (no data)";

  const yLabelW = Math.max(formatNumber(Math.max(0, yMax)).length, 1);
  const gutter = yLabelW + 1; // label chars + the axis guide char
  const BAR_MIN = 3;
  const plotMin = numBins * BAR_MIN + (numBins - 1);

  // Auto-width: expand the panel so the plot, eyebrow, x-labels, and summary
  // are never clipped by the frame — an explicit `width` is a floor, not a
  // cap. `+4` is the frame padding (2 border cols + 2 inner pad).
  const effectiveWidth = Math.max(
    opts.width ?? 36,
    gutter + plotMin + 4,
    eyebrow.length + 4,
    summaryPlain.length + 4,
    36
  );
  const innerWidth = effectiveWidth - 4;
  const plotCols = Math.max(1, innerWidth - gutter);
  const barWidth = Math.max(1, Math.floor((plotCols - (numBins - 1)) / numBins));

  // Bucket a bin count onto the grey tone ramp (light → dark by share of the
  // modal count). One bucket per tone, guarded so the mode lands in the
  // darkest bucket — from which it leaves for the solid accent block.
  function toneIdx(count: number): number {
    if (maxCount <= 0) return 0;
    return Math.min(Math.floor((count / maxCount) * tones.length), tones.length - 1);
  }

  function yRowLabel(row: number): string {
    if (!showAxes) return " ".repeat(yLabelW);
    const yLabelStep = Math.max(1, Math.floor(height / 4));
    const yVal = yMax - (row / Math.max(1, height - 1)) * (yMax - yMin);
    // Counts are integers — the y axis never prints decimals.
    const label = row % yLabelStep === 0 || row === height - 1
      ? padStart(formatNumber(Math.round(yVal)), yLabelW)
      : " ".repeat(yLabelW);
    return colorize(label, theme.label, noColor);
  }

  function yGuide(row: number): string {
    if (!showAxes) return "";
    // `+` at the top row mirrors the y-axis tick mark (LOCKED line/bar chart).
    return colorize(row === 0 ? "+" : "│", theme.axis, noColor);
  }

  function buildPlotRows(): string[] {
    const rows: string[] = [];
    for (let row = 0; row < height; row++) {
      let line = yRowLabel(row) + yGuide(row);
      for (let b = 0; b < numBins; b++) {
        const count = bins[b]!;
        const normalized = yMax === yMin ? (count > 0 ? 1 : 0) : (count - yMin) / (yMax - yMin);
        const fillHeight = Math.min(height, Math.max(0, Math.round(normalized * height)));
        const isFilled = row >= height - fillHeight;
        const isMode = hasData && b === modeIdx;
        const cell = !isFilled
          ? " ".repeat(barWidth)
          : colorize(
              (isMode ? "█" : COUNT_SHADES[Math.min(toneIdx(count), COUNT_SHADES.length - 1)]!).repeat(barWidth),
              isMode ? acc : tones[toneIdx(count)]!,
              noColor
            );
        line += cell;
        if (b < numBins - 1) line += " "; // the real gap between thin bars
      }
      rows.push(line);
    }
    return rows;
  }

  // Dashed baseline — the axis meeting the floor in the frame's own vocabulary.
  function buildBaseline(): string {
    if (!showAxes) return "";
    return " ".repeat(yLabelW) + colorize("└" + "╌".repeat(plotCols), theme.axis, noColor);
  }

  function buildBinLabels(): string {
    if (!showAxes || !hasData) return "";
    const cells = bins.map((_, i) =>
      padEnd(formatNumber(dataMin + i * binSize, 0), barWidth + 1)
    );
    return " ".repeat(gutter) + colorize(cells.join("").slice(0, plotCols), theme.label, noColor);
  }

  function buildSummary(): string {
    if (!hasData) return colorize(summaryPlain, theme.label, noColor);
    const head = colorize(`${values.length} samples · `, theme.label, noColor);
    const peakFact = colorize(`peak ${formatNumber(modeValue)}`, acc, noColor);
    return head + peakFact;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    if (useFrame && !useCompact) {
      lines.push(frameTop(effectiveWidth, opts.title ?? "HISTOGRAM", undefined, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
    }

    for (const row of buildPlotRows()) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row);
    const baseline = buildBaseline();
    if (baseline) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, baseline, theme.axis, noColor) : baseline);
    const binLabels = buildBinLabels();
    if (binLabels.trim()) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, binLabels, theme.axis, noColor) : binLabels);

    if (!useCompact) {
      lines.push(useFrame ? frameRow(effectiveWidth, buildSummary(), theme.axis, noColor) : buildSummary());
    }
    if (useFrame && !useCompact) lines.push(frameBottom(effectiveWidth, theme.axis, noColor, true));
    return lines;
  }

  const rawLines = buildLines();
  const clippedLines = opts.maxWidth === undefined ? rawLines : rawLines.map((l) => truncateAnsi(l, opts.maxWidth!));
  const output = clippedLines.join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toContent() { return histogram({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "histogram",
        data: opts.data,
        bins: numBins,
        binCounts: bins,
        title: opts.title,
        // Additive S25 facts: the modal bin's start value and nearest-rank
        // percentiles over the sample (null when there is no data).
        mode: hasData ? modeValue : null,
        p50: hasData ? p50 : null,
        p99: hasData ? p99 : null,
        count: values.length,
        plain: stripAnsi(output),
      };
    },
  };
}
