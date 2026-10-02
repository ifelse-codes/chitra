import type { BoxPlotOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, padStart, stripAnsi, truncateAnsi } from "../ansi.js";
import { quartiles, percentile } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";
import { axisPriceFmt } from "./candlestick.js";

// Minimum group width so box edges, fill, and the median marker never
// collapse into negative repeats (the old `" ".repeat(mid - 1)` RangeError).
const GROUP_MIN = 7;

// Plain-text shade ramp for box fill by share of the peak median (light →
// dark), in lock-step with the LOCKED heatmap/timeline language: spread reads
// even after stripAnsi. The peak group leaves the ramp for solid `█`.
const SPREAD_SHADES = ["░", "▒", "▓"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S27 design language —
 *  the S26 panel vocabulary on grouped spread data: dashed frame, uppercase
 *  eyebrow, tonal groups with shade texture, adaptive value labels, and a
 *  facts foot row.
 *  - **Tonal groups, never rainbow.** The peak group (highest median, ties →
 *    first in group order, the family peak rule) renders box + whiskers +
 *    caps + median in the theme's accent hue, spent EXACTLY once; every other
 *    group sits on the grey tone ramp with its matching shade fill (`░▒▓` by
 *    share of the peak median — the 2026-09-11 shade-texture ruling, so spread
 *    survives noColor). The old `theme.colors[si % n]` rainbow is retired.
 *  - **The median stays distinct from the box edges.** Box edges are vertical
 *    `│` with a shade/`█` fill between them; the median is a horizontal
 *    `───` run (`═══` on the peak group) — direction tells them apart with or
 *    without colour.
 *  - **Adaptive value labels** (`axisPriceFmt`, shared with candlestick):
 *    integers when the range is wide, ≤2dp when tight. `│`/`+` guide, dashed
 *    `└╌` baseline, truncated group labels, one rule separator. Width is a
 *    floor (auto-expand, never clip, never `RangeError` on narrow widths).
 *  - Degenerate input is safe: empty / all-non-finite renders a framed
 *    `0 groups · (no data)` panel with null `stats`/`peakGroup` facts;
 *    single-value groups render via the flat-range guard (never `NaN`);
 *    non-finite samples are excluded before `quartiles()`, never plotted;
 *    groups left with no finite samples are dropped with their labels. */
export function boxplot(opts: BoxPlotOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const boxHeight = Math.max(3, opts.height ?? 8);
  const showAxes = opts.showAxes !== false;

  const acc = theme.accent!;
  const tones = theme.tones!;

  const rawData = opts.data ?? [];
  const isMulti = Array.isArray(rawData[0]);
  const inputSeries: number[][] = (isMulti ? (rawData as number[][]) : [rawData as number[]]).map(
    (s) => (Array.isArray(s) ? s : [s])
  );
  const inputLabels = opts.labels ?? inputSeries.map((_, i) => `Group ${i + 1}`);

  // Non-finite samples are excluded before quartiles(); groups left empty are
  // dropped with their labels (never plotted, never NaN).
  const kept: Array<{ values: number[]; label: string }> = [];
  inputSeries.forEach((s, i) => {
    const values = s.filter((v) => Number.isFinite(v));
    if (values.length > 0) kept.push({ values, label: inputLabels[i] ?? `Group ${i + 1}` });
  });
  const g = kept.length;
  const empty = g === 0;

  // Non-finite samples never reach quartiles() — same helper as before,
  // now fed cleaned values only.
  const stats = kept.map((k) => quartiles(k.values));

  // The one accent: highest median, first in group order on ties (strict `>`).
  let peakIdx = 0;
  stats.forEach((s, i) => {
    if (s.median > stats[peakIdx]!.median) peakIdx = i;
  });
  const peakMedian = empty ? null : stats[peakIdx]!.median;
  const peakLabel = empty ? null : kept[peakIdx]!.label;

  const allValues = kept.flatMap((k) => k.values);
  let yMin = empty ? 0 : Math.min(...allValues);
  let yMax = empty ? 0 : Math.max(...allValues);
  if (Number.isFinite(opts.yMin)) yMin = opts.yMin!;
  if (Number.isFinite(opts.yMax)) yMax = opts.yMax!;
  // Flat-range guard (single-value groups, collapsed overrides): pad ±1 so
  // every box owns visible rows instead of NaN.
  if (!empty && yMax === yMin) {
    yMin -= 1;
    yMax += 1;
  }
  const yRange = yMax - yMin;

  const allSorted = [...allValues].sort((a, b) => a - b);
  const med = empty ? null : percentile(allSorted, 50);

  const eyebrow = (opts.title ?? "SPREAD").toUpperCase();
  const footPlain = empty
    ? "0 groups · (no data)"
    : `${g} groups · median ${axisPriceFmt(med!, yRange)} · peak ${peakLabel} (${axisPriceFmt(peakMedian!, yRange)})`;

  const sw = GROUP_MIN;
  const mid = Math.floor(sw / 2);
  const plotCols = g > 0 ? g * (sw + 1) - 1 : 0;

  const yLabelStep = Math.max(1, Math.floor(boxHeight / 4));
  function tickLabel(row: number): string {
    const yVal = yMax - (row / Math.max(1, boxHeight - 1)) * yRange;
    return axisPriceFmt(yVal, empty ? 0 : yRange);
  }
  const yLabelW = Math.max(
    1,
    ...Array.from({ length: boxHeight }, (_, row) =>
      row % yLabelStep === 0 || row === boxHeight - 1 ? tickLabel(row).length : 1
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

  // Bucket a group's median onto the grey tone ramp (light → dark by share
  // of the peak median). Guarded so the peak lands darkest — from which it
  // leaves for the solid accent treatment.
  function toneIdx(median: number): number {
    if (peakMedian === null || peakMedian === 0) return tones.length - 1;
    const share = Math.min(1, Math.max(0, median / peakMedian));
    return Math.min(Math.floor(share * tones.length), tones.length - 1);
  }

  function shadeOf(median: number): string {
    if (peakMedian === null || peakMedian === 0) return SPREAD_SHADES[SPREAD_SHADES.length - 1]!;
    const share = Math.min(1, Math.max(0, median / peakMedian));
    return SPREAD_SHADES[
      Math.min(Math.floor(share * SPREAD_SHADES.length), SPREAD_SHADES.length - 1)
    ]!;
  }

  const rowOf = (v: number): number =>
    yRange === 0
      ? boxHeight - 1
      : Math.min(boxHeight - 1, Math.max(0, Math.round(((yMax - v) / yRange) * (boxHeight - 1))));

  function yRowLabel(row: number): string {
    if (!showAxes) return "";
    const label =
      row % yLabelStep === 0 || row === boxHeight - 1
        ? padStart(tickLabel(row), yLabelW)
        : " ".repeat(yLabelW);
    return colorize(label, theme.label, noColor);
  }

  function yGuide(row: number): string {
    if (!showAxes) return "";
    return colorize(row === 0 ? "+" : "│", theme.axis, noColor);
  }

  function buildPlotRows(): string[] {
    const rows: string[] = [];
    for (let row = 0; row < boxHeight; row++) {
      let line = yRowLabel(row) + yGuide(row);
      stats.forEach((stat, si) => {
        const isPeak = si === peakIdx;
        const tone = isPeak ? acc : tones[toneIdx(stat.median)]!;
        const toRow = rowOf;
        const q1Row = toRow(stat.q1);
        const q3Row = toRow(stat.q3);
        const medRow = toRow(stat.median);
        const minRow = toRow(stat.min);
        const maxRow = toRow(stat.max);
        const boxStart = Math.min(q1Row, q3Row);
        const boxEnd = Math.max(q1Row, q3Row);
        const pad = (n: number): string => " ".repeat(Math.max(0, n));
        let seg: string;
        if (row >= boxStart && row <= boxEnd) {
          if (row === medRow) {
            // Horizontal median run — never confused with the vertical edges.
            seg =
              pad(mid - 1) + colorize(isPeak ? "═══" : "───", tone, noColor) + pad(sw - mid - 2);
          } else {
            const fill = isPeak ? "█" : shadeOf(stat.median);
            seg =
              pad(mid - 1) +
              colorize("│", tone, noColor) +
              colorize(fill, tone, noColor) +
              colorize("│", tone, noColor) +
              pad(sw - mid - 2);
          }
        } else if (row === minRow) {
          seg = pad(mid) + colorize("┴", tone, noColor) + pad(sw - mid - 1);
        } else if (row === maxRow) {
          seg = pad(mid) + colorize("┬", tone, noColor) + pad(sw - mid - 1);
        } else if ((row > maxRow && row < boxStart) || (row > boxEnd && row < minRow)) {
          seg = pad(mid) + colorize("│", tone, noColor) + pad(sw - mid - 1);
        } else {
          seg = " ".repeat(sw);
        }
        line += seg;
        if (si < stats.length - 1) line += " ";
      });
      rows.push(line);
    }
    return rows;
  }

  function buildBaseline(): string {
    if (!showAxes || empty) return "";
    return " ".repeat(yLabelW) + colorize("└" + "╌".repeat(plotCols), theme.axis, noColor);
  }

  function buildGroupLabels(): string {
    if (!showAxes || empty) return "";
    return (
      " ".repeat(gutter) +
      colorize(kept.map((k) => padEnd(k.label.slice(0, sw), sw + 1)).join(""), theme.label, noColor)
    );
  }

  function buildSummary(): string {
    if (empty) return colorize(footPlain, theme.label, noColor);
    const head = colorize(
      `${g} groups · median ${axisPriceFmt(med!, yRange)} · `,
      theme.label,
      noColor
    );
    return (
      head + colorize(`peak ${peakLabel} (${axisPriceFmt(peakMedian!, yRange)})`, acc, noColor)
    );
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    if (useFrame && !useCompact) {
      lines.push(
        frameTop(
          effectiveWidth,
          opts.title ?? "BOXPLOT",
          undefined,
          theme.axis,
          theme.title,
          noColor,
          true
        )
      );
      lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(
        useFrame
          ? frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor)
          : colorize(eyebrow, theme.label, noColor)
      );
    }
    if (!empty) {
      for (const row of buildPlotRows())
        lines.push(
          useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row
        );
      const baseline = buildBaseline();
      if (baseline)
        lines.push(
          useFrame && !useCompact
            ? frameRow(effectiveWidth, baseline, theme.axis, noColor)
            : baseline
        );
      const labels = buildGroupLabels();
      if (labels.trim())
        lines.push(
          useFrame && !useCompact ? frameRow(effectiveWidth, labels, theme.axis, noColor) : labels
        );
    }
    if (!useCompact) {
      lines.push(
        useFrame ? frameRow(effectiveWidth, buildSummary(), theme.axis, noColor) : buildSummary()
      );
    }
    if (useFrame && !useCompact) lines.push(frameBottom(effectiveWidth, theme.axis, noColor, true));
    return lines;
  }

  const rawLines = buildLines();
  const clippedLines =
    opts.maxWidth === undefined ? rawLines : rawLines.map((l) => truncateAnsi(l, opts.maxWidth!));
  const output = clippedLines.join("\n");

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
    toContent() {
      return boxplot({ ...opts, frame: false, compact: true }).toPlain();
    },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
    toJSON() {
      return {
        type: "boxplot",
        data: opts.data,
        labels: kept.map((k) => k.label),
        stats: empty ? null : stats,
        // Additive S27 fact: the peak group (null when there is no data).
        peakGroup: empty ? null : { label: peakLabel, index: peakIdx, median: peakMedian },
        plain: stripAnsi(output),
      };
    },
  };
}
