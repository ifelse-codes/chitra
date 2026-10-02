import type { GaugeOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi, truncateAnsi, upperAnsi, visibleLength } from "../ansi.js";
import { fitBodyLines, formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Plain-text shade ramp, one glyph per grey tone bucket (light → dark by
// level), in lock-step with the LOCKED heatmap/timeline language: the
// intensity reads even after stripAnsi (noColor / toPlain / toMarkdown). The
// reading's leading edge leaves the ramp and takes the solid accent block.
const LEVEL_SHADES = ["░", "▒", "▓", "█"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S22 design language —
 *  the S18–S21 panel language applied to the single-value gauge: dashed frame,
 *  uppercase eyebrow (`LEVEL`, or `opts.label` uppercased), ONE accent hue spent
 *  exactly once on the bar as a solid `█` marking the reading's leading edge
 *  (the single-value analog of the locked peak element), with the fill as the
 *  grey tone ramp (never a `theme.colors` band rainbow — explicit `thresholds`
 *  stay a user override of the fill colour, glyph texture unchanged). The ramp
 *  is ALSO the texture: the level's shade glyph (`░ ▒ ▓ █`, light → dark by
 *  bucket) carries the intensity through noColor, exactly like the LOCKED
 *  heatmap/timeline. The dim `─` track behind the fill IS the shared scale
 *  (axis colour); a `+╌…╌+` value-axis guide and a `min..max` scale row anchor
 *  it. One `│ ╌…╌ │` rule separator and a `<v> of min..max · pct` footer
 *  carrying the reading in the accent hue. Out-of-range readings clip to the track
 *  (footer still reports the true value/percent); the retired `┤`/`├` endcaps
 *  are glyphs outside the locked vocabulary. */
export function gauge(opts: GaugeOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const value = opts.value;
  const min = opts.min ?? 0;
  const max = opts.max ?? 100;

  const acc = theme.accent!;
  const tones = theme.tones!;

  // A non-finite reading renders an honest `n/a of min..max` panel — never NaN.
  const finite = Number.isFinite(value) && Number.isFinite(min) && Number.isFinite(max);
  // A collapsed range (min == max) must never divide by zero — the level reads
  // full when the reading reaches max, empty otherwise.
  const collapsed = max === min;
  // TRUE level (may sit outside 0..1 — the footer reports it honestly); the
  // bar/bucket use the clamped level so the fill never overruns the track.
  const trueLevel = finite ? (collapsed ? (value >= max ? 1 : 0) : (value - min) / (max - min)) : 0;
  const level = Math.min(1, Math.max(0, trueLevel));

  // Bucket the level onto the grey tone ramp (light → dark). One bucket per
  // tone, guarded so the top of the scale lands in the darkest tone.
  const bucket = Math.min(Math.floor(level * tones.length), tones.length - 1);

  // The one accent: the reading's leading edge, a solid block that marks
  // exactly where the fill stops. An explicit threshold colour is a user
  // override — it replaces the ramp tone on the whole fill, edge included.
  let override: string | undefined;
  if (opts.thresholds && finite) {
    for (let i = opts.thresholds.length - 1; i >= 0; i--) {
      if (value >= opts.thresholds[i]!.value) {
        override = opts.thresholds[i]!.color;
        break;
      }
    }
  }
  const fillColor = override ?? tones[bucket]!;
  const edgeColor = override ?? acc;

  const eyebrow = upperAnsi(opts.label ?? "LEVEL");
  const pct = finite ? (trueLevel * 100).toFixed(1) + "%" : "n/a";
  const summaryPlain = finite
    ? `${formatNumber(value)} of ${formatNumber(min)}..${formatNumber(max)} · ${pct}`
    : `n/a of ${formatNumber(min)}..${formatNumber(max)}`;

  // Auto-width: expand the panel so the eyebrow and the summary row are never
  // clipped by the frame — an explicit `width` is a floor, not a cap. `+4` is
  // the frame padding (2 border cols + 2 inner pad — panel's inner = width-4).
  const effectiveWidth = Math.max(
    opts.width ?? 36,
    visibleLength(eyebrow) + 4,
    summaryPlain.length + 4
  );
  const trackWidth = Math.max(1, effectiveWidth - 4);

  // Fill length is the CLAMPED level against the track — a reading past `max`
  // clips at full width (never a negative `repeat`), below `min` clips empty.
  const filled = Math.min(trackWidth, Math.max(0, Math.round(level * trackWidth)));

  function buildBar(): string {
    if (filled === 0) return colorize("─".repeat(trackWidth), theme.axis, noColor);
    // Intensity IS the shade ramp (light → dark by level bucket) so the level
    // reads through noColor; the leading edge is the solid accent block.
    const glyph = LEVEL_SHADES[bucket]!;
    const run = colorize(glyph.repeat(filled - 1), fillColor, noColor);
    const edge = colorize("█", edgeColor, noColor);
    const rest = colorize("─".repeat(trackWidth - filled), theme.axis, noColor);
    return run + edge + rest;
  }

  // Value-axis guide: the same `+`-tick vocabulary as the locked line/bar/
  // timeline charts — `+` at the range's two ends under the bar.
  function buildGuide(): string {
    const inner = trackWidth <= 1 ? "+" : "+" + "╌".repeat(trackWidth - 2) + "+";
    return colorize(inner, theme.axis, noColor);
  }

  function buildScale(): string {
    const lo = formatNumber(min);
    const hi = formatNumber(max);
    const room = Math.max(0, trackWidth - lo.length - hi.length);
    return colorize(lo + " ".repeat(room) + hi, theme.label, noColor);
  }

  function buildSummary(): string {
    if (!finite) return colorize(summaryPlain, theme.label, noColor);
    const head = colorize(
      ` of ${formatNumber(min)}..${formatNumber(max)} · ${pct}`,
      theme.label,
      noColor
    );
    const reading = colorize(`${formatNumber(value)}`, acc, noColor);
    return reading + head;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    if (useFrame && !useCompact) {
      lines.push(
        frameTop(
          effectiveWidth,
          opts.title ?? "GAUGE",
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
    const gaugeBody = [buildBar()];
    if (opts.showAxes !== false) gaugeBody.push(buildGuide(), buildScale());
    for (const row of fitBodyLines(gaugeBody, opts.height))
      lines.push(
        useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row
      );
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
      return gauge({ ...opts, frame: false, compact: true }).toPlain();
    },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
    toJSON() {
      return {
        type: "gauge",
        value,
        min,
        max,
        percent: finite ? +(trueLevel * 100).toFixed(2) : null,
        bucket: finite ? bucket : null,
        plain: stripAnsi(output),
      };
    },
  };
}
