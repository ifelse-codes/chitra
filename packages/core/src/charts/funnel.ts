import type { FunnelOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, stripAnsi, truncateAnsi } from "../ansi.js";
import { fitBodyLines, formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Plain-text shade ramp for the tone steps (light → dark by share of the
// peak stage), in lock-step with the LOCKED family language: the conversion
// story reads even after stripAnsi (noColor / toPlain / toMarkdown). The peak
// stage leaves the ramp and takes the solid accent block.
const STAGE_SHADES = ["░", "▒", "▓"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S26 design language —
 *  the audit's mudra funnel card (§3.4) with ONE founder-ordered reversal: the
 *  rows are CENTERED, not left-anchored. Industry consensus (ECharts, PowerBI,
 *  Highcharts, Evidence, Atlassian, Wikipedia) is unambiguous — the centered,
 *  symmetric, top-wide → bottom-narrow silhouette IS the funnel identity ("at
 *  its core, the funnel chart is really just a fancy-looking bar chart" whose
 *  bars align to a center line). Left-anchored rows read as a horizontal bar
 *  chart and lose the chart's entire reason to exist; the audit's §3.4 item 2
 *  is hereby reversed (disclosed, not hidden). Centered BOXES (not tapered
 *  slopes — slopes distort stage comparison and render as ragged steps in a
 *  terminal) are the recommended balance. Labels stay in a fixed left column,
 *  keeping the audit's valid row-scanning concern; only the bars center.
 *  Everything else follows the audit: no `▼` (decoration, banned), tone ramp
 *  descent, integer percents, conversion metric, biggest-drop foot,
 *  rounded-cap `▓` stand-in on non-peak bars, auto-width floor. */
export function funnel(opts: FunnelOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const data = opts.data;
  const labels = opts.labels ?? data.map((_, i) => `Stage ${i + 1}`);
  const showPercent = opts.showPercent !== false;
  const empty = data.length === 0;

  const acc = theme.accent!;
  const tones = theme.tones!;

  const maxValue = empty ? 0 : Math.max(...data);
  // The one accent: the PEAK stage (highest value), first in stage order on
  // ties (strict `>` never reassigns on a later equal).
  let peakIdx = 0;
  let peakValue = -Infinity;
  data.forEach((v, i) => {
    if (v > peakValue) {
      peakValue = v;
      peakIdx = i;
    }
  });

  const first = empty ? 0 : data[0]!;
  const last = empty ? 0 : data[data.length - 1]!;
  const conversion = !empty && first !== 0 ? last / first : null;

  // Biggest relative drop between consecutive stages (the audit's foot fact).
  let dropIdx = -1;
  let dropPct = 0;
  for (let i = 1; i < data.length; i++) {
    const prev = data[i - 1]!;
    if (prev <= 0) continue;
    const pct = (prev - data[i]!) / prev;
    if (pct > dropPct) {
      dropPct = pct;
      dropIdx = i;
    }
  }

  const pctStr = (v: number): string =>
    !empty && first !== 0 ? `${Math.round((v / first) * 100)}%` : "n/a";
  const eyebrow = conversion === null ? "FUNNEL" : `CONVERSION ${Math.round(conversion * 100)}%`;
  const footPlain = empty
    ? "STAGES 0 · (no data)"
    : `IN ${formatNumber(first)} · OUT ${formatNumber(last)} · CONVERSION ${
        conversion === null ? "n/a" : `${Math.round(conversion * 100)}%`
      }${dropIdx >= 0 ? ` · DROP ${labels[dropIdx]} −${Math.round(dropPct * 100)}%` : ""}`;

  const labelW = 12;
  // Bar width fits the longest value+percent fact (min 8 so the ramp reads).
  const factLens = data.map(
    (v) => [...formatNumber(v)].length + (showPercent ? [...pctStr(v)].length + 3 : 0)
  );
  const barMax = Math.max(8, opts.width ?? 50, ...factLens.map((l) => l + 4)) - labelW - 14;
  const barW = Math.max(8, Math.min(barMax, 40));

  // Auto-width: the panel expands so rows, eyebrow, and foot never clip.
  const rowLens = data.map(
    (v) => labelW + 1 + barW + 1 + [...formatNumber(v)].length + (showPercent ? [...pctStr(v)].length + 3 : 0)
  );
  const effectiveWidth = Math.max(
    40,
    eyebrow.length + 4,
    footPlain.length + 4,
    ...rowLens.map((l) => l + 4)
  );

  // Grey tone step per stage index: t1 → t2 → t2 → t3 … down the stages.
  function toneFor(i: number): string {
    if (tones.length <= 1) return tones[0]!;
    if (i === 0) return tones[0]!;
    if (i <= 2) return tones[1]!;
    return tones[Math.min(i - 1, tones.length - 1)]!;
  }

  function shadeFor(share: number): string {
    if (share >= 0.66) return STAGE_SHADES[2]!;
    if (share >= 0.33) return STAGE_SHADES[1]!;
    return STAGE_SHADES[0]!;
  }

  function buildStageRow(v: number, i: number): string {
    const label = colorize(padEnd((labels[i] ?? "").slice(0, labelW), labelW), theme.label, noColor);
    const share = maxValue === 0 ? 0 : v / maxValue;
    const w = Math.max(1, Math.round(share * barW));
    // Centered on the bar field: the symmetric stepped silhouette that makes
    // a funnel a funnel (the audit's left-anchor is reversed — see header).
    const left = Math.floor((barW - w) / 2);
    const isPeak = !empty && i === peakIdx;
    let bar: string;
    if (isPeak) {
      bar = colorize("█".repeat(w), acc, noColor);
    } else {
      const g = shadeFor(share);
      // The rounded-cap stand-in: one `▓` closing the shade run.
      bar =
        w <= 1
          ? colorize("▓", toneFor(i), noColor)
          : colorize(g.repeat(w - 1) + "▓", toneFor(i), noColor);
    }
    const fact = colorize(
      formatNumber(v) + (showPercent ? ` (${pctStr(v)})` : ""),
      theme.label,
      noColor
    );
    return `${label} ${" ".repeat(left)}${bar} ${fact}`;
  }

  function buildSummary(): string {
    if (empty) return colorize(footPlain, theme.label, noColor);
    const conv = conversion === null ? "n/a" : `${Math.round(conversion * 100)}%`;
    const head = colorize(
      `IN ${formatNumber(first)} · OUT ${formatNumber(last)} · CONVERSION `,
      theme.label,
      noColor
    );
    const convFact = colorize(conv, acc, noColor);
    const tail =
      dropIdx >= 0
        ? colorize(` · DROP ${labels[dropIdx]} −${Math.round(dropPct * 100)}%`, theme.label, noColor)
        : "";
    return head + convFact + tail;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    if (useFrame && !useCompact) {
      lines.push(
        frameTop(effectiveWidth, opts.title ?? "FUNNEL", undefined, theme.axis, theme.title, noColor, true)
      );
      lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
    }
    const bodyRows = fitBodyLines(data.map((v, i) => buildStageRow(v, i)), opts.height);
    for (const row of bodyRows) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row);
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
    render() {
      process.stdout.write(output + "\n");
    },
    toString() {
      return output;
    },
    toPlain() {
      return stripAnsi(output);
    },
    toContent() { return funnel({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
    toJSON() {
      return {
        type: "funnel",
        data: opts.data,
        labels,
        conversionRates: data.map((v, i) => (i === 0 ? 1 : first !== 0 ? +(v / first).toFixed(4) : 0)),
        // Additive S26 facts: end-to-end conversion and the biggest drop
        // (null when there is no data or no measurable drop).
        conversion,
        biggestDrop:
          dropIdx >= 0 ? { label: labels[dropIdx], pct: +(dropPct.toFixed(4)) } : null,
        plain: stripAnsi(output),
      };
    },
  };
}
