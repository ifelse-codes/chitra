import type { TimelineOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, stripAnsi, truncateAnsi } from "../ansi.js";
import { fitBodyLines, formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Plain-text shade ramp, one glyph per grey tone bucket (light → dark by span
// length), in lock-step with the LOCKED heatmap language: the intensity reads
// even after stripAnsi (noColor / toPlain / toMarkdown). The peak event leaves
// the ramp and takes the solid accent block instead.
const SPAN_SHADES = ["░", "▒", "▓", "█"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S21 design language —
 *  the S18/S19 panel language applied to the Gantt/timeline: dashed frame,
 *  uppercase eyebrow, ONE accent hue spent exactly once on the longest-span
 *  event (ties → first in event order, deterministic) as a solid `█` run, with
 *  the grey tone ramp for every other event (never a `theme.colors` rainbow —
 *  an explicit `event.color` stays a user override, not a theme rainbow). The
 *  ramp is ALSO the texture: each bar's shade glyph (`░ ▒ ▓ █`, light → dark by
 *  span bucket) carries the ordering through noColor, exactly like the LOCKED
 *  heatmap. The dim `─`
 *  track behind each event IS the shared time scale (axis colour), so spans
 *  read against the full range; a `+╌…╌+` value-axis guide and a `min..max`
 *  scale row anchor it. One `│ ╌…╌ │` rule separator and a
 *  `N events · longest <label>` footer naming the longest event in the accent
 *  hue. Point events (no `end`) render a single lightest-shade glyph — the old
 *  `▶`/`◀` markers are retired glyphs, outside the locked vocabulary. */
export function timeline(opts: TimelineOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const showAxes = opts.showAxes !== false;
  const events = opts.events;
  const hasData = events.length > 0;

  const acc = theme.accent!;
  const tones = theme.tones!;

  const allStarts = events.map((e) => e.start);
  const allEnds = events.map((e) => e.end ?? e.start);
  const rangeMin = hasData ? (opts.min ?? Math.min(...allStarts)) : 0;
  const rangeMax = hasData ? (opts.max ?? Math.max(...allEnds)) : 0;
  // A collapsed range (every event shares one instant, or min==max overrides)
  // must never divide by zero — freeze the scale instead of NaN-ing the row.
  const range = rangeMax > rangeMin ? rangeMax - rangeMin : 1;

  // Span of each event (an `end` before its `start` is honestly zero-length).
  const spans = events.map((e) => Math.max(0, (e.end ?? e.start) - e.start));
  const minSpan = hasData ? Math.min(...spans) : 0;
  const maxSpan = hasData ? Math.max(...spans) : 0;
  const spanRange = maxSpan > minSpan ? maxSpan - minSpan : 1;

  // The one accent: the LONGEST span, first in event order on ties (strict `>`
  // never reassigns on a later equal) — the same deterministic rule as bar,
  // heatmap, horizontalBar and treemap.
  let peakIdx = 0;
  let peakSpan = -Infinity;
  spans.forEach((span, i) => {
    if (span > peakSpan) { peakSpan = span; peakIdx = i; }
  });
  const peakLabel = hasData ? events[peakIdx]!.label : "";

  // Bucket a span onto the grey tone ramp (light → dark by length). One bucket
  // per tone, guarded so a collapsed spanRange lands in the lightest tone.
  function toneIdx(span: number): number {
    const normalized = (span - minSpan) / spanRange;
    return Math.min(Math.floor(normalized * tones.length), tones.length - 1);
  }

  const labelWidth = hasData ? Math.max(...events.map((e) => e.label.length)) : 0;
  const eyebrow = (opts.xLabel ?? "SPAN").toUpperCase();
  const summaryPlain = hasData
    ? `${events.length} events · longest ${peakLabel}`
    : "0 events · (no data)";

  // Auto-width: expand the panel so the widest of {label + a readable track},
  // the eyebrow, and the summary row is never clipped by the frame. `+4` is
  // the frame padding (2 border cols + 2 inner pad — panel's inner = width-4).
  const TRACK_MIN = 12;
  const effectiveWidth = opts.width ?? Math.max(
    labelWidth + 1 + TRACK_MIN + 4,
    eyebrow.length + 4,
    summaryPlain.length + 4,
    36
  );
  const innerWidth = effectiveWidth - 4;
  const trackWidth = Math.max(1, innerWidth - labelWidth - 1);

  const rawPos = (value: number): number =>
    Math.max(0, Math.round(((value - rangeMin) / range) * trackWidth));

  function buildEventRows(): string[] {
    return events.map((event, i) => {
      const label = colorize(padEnd(event.label, labelWidth), theme.label, noColor);
      const startPos = Math.min(rawPos(event.start), Math.max(0, trackWidth - 1));
      const end = event.end ?? event.start;
      // A point event renders ONE block; a real span always renders at least
      // one block, even when the scale clamps it against a panel edge.
      const endPos = end > event.start
        ? Math.min(Math.max(rawPos(end), startPos + 1), trackWidth)
        : Math.min(startPos + 1, trackWidth);
      const isPeak = i === peakIdx;
      const color = event.color ?? (isPeak ? acc : tones[toneIdx(spans[i]!)]!);
      const left = colorize("─".repeat(startPos), theme.axis, noColor);
      // Intensity IS the shade ramp (light → dark by span bucket) so the
      // ordering survives noColor; the peak leaves the ramp for solid accent.
      const glyph = isPeak
        ? "█"
        : SPAN_SHADES[Math.min(toneIdx(spans[i]!), SPAN_SHADES.length - 1)]!;
      const blocks = colorize(glyph.repeat(endPos - startPos), color, noColor);
      const right = colorize("─".repeat(trackWidth - endPos), theme.axis, noColor);
      return `${label} ${left}${blocks}${right}`;
    });
  }

  // Rotated value-axis guide: the same `+`-tick vocabulary as the locked
  // line/bar charts — `+` at the range's two ends under the event rows.
  function buildGuide(): string {
    const gutter = " ".repeat(labelWidth + 1);
    const inner = trackWidth <= 1 ? "+" : "+" + "╌".repeat(trackWidth - 2) + "+";
    return gutter + colorize(inner, theme.axis, noColor);
  }

  function buildScale(): string {
    const gutter = " ".repeat(labelWidth + 1);
    const lo = formatNumber(rangeMin);
    const hi = formatNumber(rangeMax);
    const room = Math.max(0, trackWidth - lo.length - hi.length);
    return gutter + colorize(lo + " ".repeat(room) + hi, theme.label, noColor);
  }

  function buildSummary(): string {
    if (!hasData) return colorize(summaryPlain, theme.label, noColor);
    const head = colorize(
      `${events.length} events · `,
      theme.label,
      noColor
    );
    const tail = colorize(`longest ${peakLabel}`, acc, noColor);
    return head + tail;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    if (useFrame && !useCompact) {
      lines.push(frameTop(effectiveWidth, opts.title ?? "TIMELINE", undefined, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
    }

    const bodyRows = [...buildEventRows()];
    if (showAxes && hasData) bodyRows.push(buildGuide(), buildScale());
    for (const row of fitBodyLines(bodyRows, opts.height)) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row);

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
    toContent() { return timeline({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "timeline",
        events: opts.events,
        min: rangeMin,
        max: rangeMax,
        peak: hasData ? { index: peakIdx, label: peakLabel, span: spans[peakIdx]! } : null,
        plain: stripAnsi(output),
      };
    },
  };
}
