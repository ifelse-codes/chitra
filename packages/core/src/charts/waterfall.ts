import type { WaterfallOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

type BarKind = "start" | "up" | "down" | "total";

/** Signed delta label in the audit's vocabulary (`+80` / `−120`). */
function signed(v: number): string {
  if (v > 0) return "+" + formatNumber(v);
  if (v < 0) return "−" + formatNumber(Math.abs(v));
  return "+0";
}

/** Renders a chitra-standard TUI panel carrying the LOCKED S26 design language —
 *  the audit's mudra waterfall card (§3.5) in the S18–S25 family vocabulary:
 *  dashed frame, uppercase eyebrow, tonal kinds with shade texture, integer
 *  y-labels, `┄` step connectors, signed delta labels, and a facts foot row.
 *  - **Down-deltas are visible by design.** Every negative step renders a
 *    dashed outline box (`┌╌╌┐` top / `│  │` sides / `└╌╌┘` bottom); a sub-row
 *    delta still renders a minimum one `┌╌╌┐` row. The old flat `─` dash on
 *    the baseline — indistinguishable from zero — is retired (the P0 bug).
 *  - **Tonal kinds, never rainbow.** Start and Total are solid `█` anchors
 *    (Start on the darkest grey tone, Total in the theme's accent hue, spent
 *    EXACTLY once); up-steps are solid `▓` on a mid grey tone; down-steps are
 *    the dashed outline on a light grey tone. The old `theme.colors[i]`
 *    positive/negative/total rainbow is retired. The kind reads through
 *    `stripAnsi` / `noColor`: `█` anchors vs `▓` ups vs outlined downs.
 *  - **Explicit color options stay user overrides** (like gauge thresholds):
 *    `positiveColor` / `negativeColor` / `totalColor` replace the locked tone
 *    for their kind when given; the glyph vocabulary never changes.
 *  - Zero deltas render an empty column (no mass, no outline) with the
 *    connector passing through at their level — never a dash, never a fill.
 *  - Panel width auto-expands so facts are never clipped (an explicit `width`
 *    is a floor, not a cap); bar width fits the longest delta fact (min 4 so
 *    outlines stay legible). */
export function waterfall(opts: WaterfallOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const height = Math.max(2, opts.height ?? 12);
  const showAxes = opts.showAxes !== false;
  const showTotal = opts.showTotal !== false;

  const acc = theme.accent!;
  const tones = theme.tones!;
  const tAnchor = tones[tones.length - 1]!;
  const tUp = tones[Math.min(2, tones.length - 1)]!;
  const tDown = tones[0]!;

  const upColor = opts.positiveColor ?? tUp;
  const downColor = opts.negativeColor ?? tDown;
  const totalColor = opts.totalColor ?? acc;

  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Step ${i + 1}`);
  const empty = data.length === 0;

  interface Bar {
    label: string;
    delta: number;
    start: number;
    end: number;
    kind: BarKind;
  }

  let running = 0;
  const bars: Bar[] = data.map((v, i) => {
    const start = running;
    running += v;
    return {
      label: labels[i] ?? `Step ${i + 1}`,
      delta: v,
      start,
      end: running,
      kind: (i === 0 ? "start" : v < 0 ? "down" : "up") as BarKind,
    };
  });
  const totalValue = running;
  if (showTotal && !empty) {
    bars.push({ label: "Total", delta: totalValue, start: 0, end: totalValue, kind: "total" });
  }

  const footPlain = empty
    ? "TOTAL 0 · (no data)"
    : `START ${formatNumber(bars[0]!.end)} · Δ ${bars
        .filter((b) => b.kind === "up" || b.kind === "down")
        .map((b) => signed(b.delta))
        .join(" ")} · TOTAL ${formatNumber(totalValue)}`;
  // The NET metric cell: mudra's header fact, carried in the eyebrow row.
  const eyebrow = `NET ${signed(totalValue)}`;

  // Delta facts sit above their columns — the bar width fits the longest one.
  const deltaStrs = bars.map((b) =>
    b.kind === "up" || b.kind === "down" ? signed(b.delta) : formatNumber(b.end)
  );
  const barW = Math.max(4, ...deltaStrs.map((s) => [...s].length));
  const numBars = bars.length;

  const yLabelW = Math.max(
    formatNumber(Math.round(Math.max(0, ...bars.flatMap((b) => [b.start, b.end]), 0))).length,
    formatNumber(Math.round(Math.min(0, ...bars.flatMap((b) => [b.start, b.end]), 0))).length,
    1
  );
  const gutter = showAxes ? yLabelW + 1 : 0;
  const plotCols = numBars > 0 ? numBars * (barW + 1) - 1 : 0;

  // Auto-width: the panel expands so the plot, eyebrow, delta facts, step
  // labels, and foot are never clipped — an explicit `width` is a floor.
  const effectiveWidth = Math.max(
    opts.width ?? 60,
    numBars > 0 ? gutter + plotCols + 4 : 0,
    eyebrow.length + 4,
    footPlain.length + 4,
    gutter + 1 + numBars * (barW + 1) + 4,
    40
  );

  const allVals = bars.flatMap((b) => [b.start, b.end]);
  const yMin = Math.min(0, ...allVals);
  const yMax = Math.max(0, ...allVals);
  const yRange = yMax - yMin;
  // Rounding (not truncation) guarantees every non-zero bar owns ≥1 row —
  // sub-row deltas stay visible instead of collapsing onto the baseline.
  const rowOf = (v: number): number =>
    yRange === 0 ? height - 1 : Math.round(((yMax - v) / yRange) * (height - 1));

  function yRowLabel(row: number): string {
    if (!showAxes) return "";
    const yLabelStep = Math.max(1, Math.floor(height / 4));
    const yVal = yMax - (row / Math.max(1, height - 1)) * yRange;
    // Money-axis labels are integers — the old decimal labels are retired.
    const label =
      row % yLabelStep === 0 || row === height - 1
        ? padStart(formatNumber(Math.round(yVal)), yLabelW)
        : " ".repeat(yLabelW);
    return colorize(label, theme.label, noColor);
  }

  function yGuide(row: number): string {
    if (!showAxes) return "";
    return colorize(row === 0 ? "+" : "│", theme.axis, noColor);
  }

  function outlineCell(row: number, rTop: number, rBot: number, color: string): string {
    if (rTop === rBot) return colorize("┌" + "╌".repeat(Math.max(0, barW - 2)) + "┐", color, noColor);
    if (row === rTop) return colorize("┌" + "╌".repeat(Math.max(0, barW - 2)) + "┐", color, noColor);
    if (row === rBot) return colorize("└" + "╌".repeat(Math.max(0, barW - 2)) + "┘", color, noColor);
    return colorize("│" + " ".repeat(Math.max(0, barW - 2)) + "│", color, noColor);
  }

  function buildDeltaRow(): string {
    let line = " ".repeat(gutter);
    bars.forEach((b, i) => {
      const s = deltaStrs[i]!;
      const pad = barW - [...s].length;
      const left = Math.floor(pad / 2);
      line += " ".repeat(left) + colorize(s, theme.label, noColor) + " ".repeat(pad - left);
      if (i < bars.length - 1) line += " ";
    });
    return line;
  }

  function buildPlotRows(): string[] {
    const rows: string[] = [];
    const zeroRow = yMin < 0 ? rowOf(0) : -1;
    for (let row = 0; row < height; row++) {
      let line = yRowLabel(row) + yGuide(row);
      bars.forEach((b, i) => {
        const top = Math.max(b.start, b.end);
        const bot = Math.min(b.start, b.end);
        const rTop = rowOf(top);
        const rBot = rowOf(bot);
        const inSpan = row >= rTop && row <= rBot;
        let cell: string;
        if (b.kind === "down") {
          cell = inSpan ? outlineCell(row, rTop, rBot, downColor) : " ".repeat(barW);
        } else if (b.kind === "start") {
          cell =
            inSpan && yRange > 0
              ? colorize("█".repeat(barW), tAnchor, noColor)
              : " ".repeat(barW);
        } else if (b.kind === "total") {
          cell =
            inSpan && yRange > 0
              ? colorize("█".repeat(barW), totalColor, noColor)
              : " ".repeat(barW);
        } else {
          // Up-steps carry mass; zero deltas carry none — an empty column
          // with the connector passing through, never a dash, never a fill.
          cell =
            inSpan && b.delta !== 0 && yRange > 0
              ? colorize("▓".repeat(barW), upColor, noColor)
              : " ".repeat(barW);
        }
        if (cell === " ".repeat(barW) && row === zeroRow) {
          cell = colorize("─".repeat(barW), theme.axis, noColor);
        }
        line += cell;
        if (i < bars.length - 1) {
          // The `┄` connector: each running level bridges its two bars.
          line += colorize(row === rowOf(b.end) ? "┄" : " ", theme.axis, noColor);
        }
      });
      rows.push(line);
    }
    return rows;
  }

  function buildBaseline(): string {
    if (!showAxes || numBars === 0) return "";
    return " ".repeat(yLabelW) + colorize("└" + "╌".repeat(plotCols), theme.axis, noColor);
  }

  function buildStepLabels(): string {
    if (!showAxes || numBars === 0) return "";
    return (
      " ".repeat(gutter) +
      colorize(
        bars.map((b) => padEnd(b.label.slice(0, barW), barW + 1)).join(""),
        theme.label,
        noColor
      )
    );
  }

  function buildSummary(): string {
    if (empty) return colorize(footPlain, theme.label, noColor);
    const head = colorize(
      `START ${formatNumber(bars[0]!.end)} · Δ ${bars
        .filter((b) => b.kind === "up" || b.kind === "down")
        .map((b) => signed(b.delta))
        .join(" ")} · `,
      theme.label,
      noColor
    );
    const totalFact = colorize(`TOTAL ${formatNumber(totalValue)}`, acc, noColor);
    return head + totalFact;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    lines.push(
      frameTop(effectiveWidth, opts.title ?? "WATERFALL", undefined, theme.axis, theme.title, noColor, true)
    );
    lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    lines.push(frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor));
    if (!empty) {
      lines.push(frameRow(effectiveWidth, buildDeltaRow(), theme.axis, noColor));
      for (const row of buildPlotRows()) lines.push(frameRow(effectiveWidth, row, theme.axis, noColor));
      const baseline = buildBaseline();
      if (baseline) lines.push(frameRow(effectiveWidth, baseline, theme.axis, noColor));
      const stepLabels = buildStepLabels();
      if (stepLabels.trim()) lines.push(frameRow(effectiveWidth, stepLabels, theme.axis, noColor));
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
        type: "waterfall",
        data: opts.data,
        labels,
        total: totalValue,
        // Additive S26 facts: the per-step running levels with their locked
        // kind (empty when there is no data).
        steps: bars
          .filter((b) => b.kind !== "total")
          .map((b) => ({ label: b.label, delta: b.delta, start: b.start, end: b.end, kind: b.kind })),
        plain: stripAnsi(output),
      };
    },
  };
}
