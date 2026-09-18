import type { HorizontalBarChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, padStart, stripAnsi, truncateAnsi } from "../ansi.js";
import { fitBodyLines, formatNumber, minMax } from "../utils.js";
import { buildHorizontalBlockBar } from "../renderers/blocks.js";
import { buildAsciiHBar } from "../renderers/ascii.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

/** Renders a chitra-standard TUI panel carrying the LOCKED S19 design language —
 *  the S12 `bar` language rotated to the horizontal orientation: dashed frame,
 *  uppercase eyebrow, one accent hue spent once on the peak bar with the grey
 *  tone ramp for every other bar (never a `theme.colors` rainbow), a rotated
 *  `+` value-axis guide, `│ ╌…╌ │` rule separators, per-item value labels (the
 *  peak item's value in accent), auto-scale + auto-width, and SPACE empty cells
 *  (never the `░` phantom filler). */
export function horizontalBar(opts: HorizontalBarChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const renderer = opts.renderer ?? "blocks";
  const showAxes = opts.showAxes !== false;
  const data = opts.data;
  const hasData = data.length > 0;
  const labels = opts.labels ?? data.map((_, i) => `Item ${i + 1}`);

  const { min: dataMin, max: dataMax } = hasData ? minMax(data) : { min: 0, max: 0 };
  const yMin = opts.yMin ?? Math.min(0, dataMin);
  const yMax = opts.yMax ?? dataMax;

  // One accent + grey tone ramp — the same locked language as bar/area/line/circular.
  // The single bar with the globally highest value gets the accent (spent once);
  // every other bar uses one grey tone from the ramp. Deterministic tie-break: the
  // FIRST maximum in data order wins (strict `>` never reassigns on a later equal).
  const acc = theme.accent!;
  const tones = theme.tones!;
  const grey = tones[2] ?? tones[0]!;
  let accentIdx = 0;
  let maxVal = -Infinity;
  data.forEach((v, i) => {
    if (v > maxVal) { maxVal = v; accentIdx = i; }
  });

  const labelWidth = labels.length ? Math.max(...labels.map((l) => l.length)) : 0;
  const valueWidth = Math.max(
    ...(hasData ? data.map((v) => formatNumber(v).length) : [1]),
    formatNumber(yMax).length,
    formatNumber(yMin).length
  );

  const eyebrow = (opts.xLabel ?? "VALUES").toUpperCase();
  const stats = {
    min: hasData ? dataMin : 0,
    max: hasData ? dataMax : 0,
    avg: hasData ? data.reduce((a, b) => a + b, 0) / data.length : 0,
  };
  const peakLabel = hasData ? labels[accentIdx]! : "";
  const summaryPlain = hasData
    ? `n ${data.length} · min ${formatNumber(stats.min)} · max ${formatNumber(stats.max)} · avg ${formatNumber(stats.avg)} · peak ${peakLabel}`
    : "n 0 · (no data)";

  // Auto-width: expand the panel so the widest of {a real bar + its label/value},
  // the eyebrow, and the summary row is never clipped by the frame. `+4` is the
  // frame padding (2 border cols + 2 inner pad — panel's inner = width-4).
  const BAR_MIN = 12;
  const effectiveWidth = opts.width ?? Math.max(
    labelWidth + 1 + BAR_MIN + 1 + valueWidth + 4,
    eyebrow.length + 4,
    summaryPlain.length + 4,
    36
  );
  const innerWidth = effectiveWidth - 4;
  const barWidth = Math.max(1, innerWidth - labelWidth - valueWidth - 2);

  function buildBarRows(): string[] {
    return data.map((v, i) => {
      const isPeak = i === accentIdx;
      const color = isPeak ? acc : grey;
      const label = colorize(padEnd(labels[i]!, labelWidth), theme.label, noColor);
      const bar = renderer === "ascii"
        ? buildAsciiHBar(v, yMin, yMax, barWidth, "#", " ")
        : buildHorizontalBlockBar(v, yMin, yMax, barWidth, "█", " ");
      const valueStr = padStart(formatNumber(v), valueWidth);
      const value = colorize(valueStr, isPeak ? acc : theme.label, noColor);
      return `${label} ${colorize(bar, color, noColor)} ${value}`;
    });
  }

  // Rotated value-axis guide: the vertical bar's `│`/`+` y-guide becomes a single
  // horizontal tick row under the bars — `+` at the baseline and max columns, the
  // same `+`-tick vocabulary as the locked line/bar charts.
  function buildAxisGuide(): string {
    const gutter = " ".repeat(labelWidth + 1);
    const inner = barWidth <= 1 ? "+" : "+" + "╌".repeat(barWidth - 2) + "+";
    return gutter + colorize(inner, theme.axis, noColor);
  }

  function buildAxisScale(): string {
    const gutter = " ".repeat(labelWidth + 1);
    const lo = formatNumber(yMin);
    const hi = formatNumber(yMax);
    const room = Math.max(0, barWidth - lo.length - hi.length);
    return gutter + colorize(lo + " ".repeat(room) + hi, theme.label, noColor);
  }

  function buildSummary(): string {
    if (!hasData) return colorize(summaryPlain, theme.label, noColor);
    const maxPart = colorize(`max ${formatNumber(stats.max)}`, acc, noColor);
    return (
      colorize(`n ${data.length} · min ${formatNumber(stats.min)} · `, theme.label, noColor) +
      maxPart +
      colorize(` · avg ${formatNumber(stats.avg)} · peak ${peakLabel}`, theme.label, noColor)
    );
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    if (useFrame && !useCompact) {
      lines.push(frameTop(effectiveWidth, opts.title ?? "HORIZONTAL BAR", undefined, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
    }

    const bodyRows = [...buildBarRows()];
    if (showAxes && hasData) bodyRows.push(buildAxisGuide(), buildAxisScale());
    for (const row of fitBodyLines(bodyRows, opts.height)) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row);

    if (useFrame && !useCompact) lines.push(frameRule(effectiveWidth, theme.axis, noColor));
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
    toContent() { return horizontalBar({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "horizontalBar",
        data: opts.data,
        labels,
        plain: stripAnsi(output),
      };
    },
  };
}
