import type { ProgressOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi, truncateAnsi, upperAnsi, visibleLength } from "../ansi.js";
import { fitBodyLines, formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Plain-text shade ramp, one glyph per grey tone bucket (light → dark by
// level), in lock-step with the LOCKED heatmap/timeline/gauge language: the
// intensity reads even after stripAnsi (noColor / toPlain / toMarkdown). The
// fill's leading edge leaves the ramp and takes the solid accent block.
const LEVEL_SHADES = ["░", "▒", "▓", "█"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S23 design language —
 *  the S18–S22 panel language applied to the single-value progress bar,
 *  completing the founder-named trio (`timeline` → `gauge` → `progress`). The
 *  old `theme.colors[2/3/1]` traffic-light band rainbow is gone: the fill is
 *  the grey tone ramp AND the texture — the level's shade glyph (`░ ▒ ▓ █`,
 *  light → dark by bucket) carries the intensity through noColor, and the
 *  theme's ONE accent hue is spent EXACTLY once on the bar as a solid `█`
 *  marking the fill's leading edge (the gauge's reading-edge element). The
 *  `style` option stays accepted (public API unchanged) but the locked design
 *  supersedes it — no `▁▂▃` sub-block texture, no `=`/`.` ascii glyphs, no
 *  naked `[`…`]` bracket bar, ever. Panel chrome: dashed frame, uppercase
 *  eyebrow (`PROGRESS`, or `opts.label` uppercased), a `+╌…╌+` value-axis
 *  guide with a `0..max` scale row, two rule separators, and the dim `─`
 *  track (axis colour) as the shared scale. A `value <v> · 0..max · pct`
 *  footer carries the reading in the accent hue. The fill length clamps to
 *  the track, but the footer and `toJSON()` report the TRUE value and TRUE
 *  percent — the old silent clamp (which reported a clamped value and a
 *  percent that could never exceed 100) is retired as a lie. A non-finite
 *  `value` renders a framed `value n/a` panel; a collapsed range
 *  (`max === 0`) never divides by zero. */
export function progress(opts: ProgressOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const value = opts.value;
  const max = opts.max ?? 100;
  const min = 0; // the progress range is 0..max (no `min` option — by design)

  const acc = theme.accent!;
  const tones = theme.tones!;

  // A non-finite reading renders an honest `value n/a` panel — never NaN.
  const finite = Number.isFinite(value) && Number.isFinite(max);
  // A collapsed range (max == min == 0) must never divide by zero — the level
  // reads full when the reading reaches max, empty otherwise.
  const collapsed = max === min;
  // TRUE level (may sit outside 0..1 — the footer and toJSON report it
  // honestly); the bar/bucket use the clamped level so the fill never
  // overruns the track.
  const trueLevel = finite ? (collapsed ? (value >= max ? 1 : 0) : value / max) : 0;
  const level = Math.min(1, Math.max(0, trueLevel));

  // Bucket the level onto the grey tone ramp (light → dark). One bucket per
  // tone, guarded so the top of the scale lands in the darkest tone.
  const bucket = Math.min(Math.floor(level * tones.length), tones.length - 1);

  const fillColor = tones[bucket]!;

  const eyebrow = upperAnsi(opts.label ?? "PROGRESS");
  const pct = finite ? (trueLevel * 100).toFixed(1) + "%" : "n/a";
  const pctTail = opts.showPercent === false ? "" : ` · ${pct}`;
  const summaryPlain = finite
    ? `value ${formatNumber(value)} · ${formatNumber(min)}..${formatNumber(max)}${pctTail}`
    : `value n/a · ${formatNumber(min)}..${formatNumber(max)}`;

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
  // clips at full width (never a negative `repeat`), below 0 clips empty.
  const filled = Math.min(trackWidth, Math.max(0, Math.round(level * trackWidth)));

  function buildBar(): string {
    if (filled === 0) return colorize("─".repeat(trackWidth), theme.axis, noColor);
    // Intensity IS the shade ramp (light → dark by level bucket) so the level
    // reads through noColor; the leading edge is the solid accent block.
    const glyph = LEVEL_SHADES[bucket]!;
    const run = colorize(glyph.repeat(filled - 1), fillColor, noColor);
    const edge = colorize("█", acc, noColor);
    const rest = colorize("─".repeat(trackWidth - filled), theme.axis, noColor);
    return run + edge + rest;
  }

  // Value-axis guide: the same `+`-tick vocabulary as the locked line/bar/
  // gauge/timeline charts — `+` at the range's two ends under the bar.
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
      ` · ${formatNumber(min)}..${formatNumber(max)}${pctTail}`,
      theme.label,
      noColor
    );
    const reading = colorize(`value ${formatNumber(value)}`, acc, noColor);
    return reading + head;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    if (useFrame && !useCompact) {
      lines.push(frameTop(effectiveWidth, "PROGRESS", undefined, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
    }
    const progBody = fitBodyLines([buildBar(), buildGuide(), buildScale()], opts.height);
    for (const row of progBody) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row);
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
    toContent() { return progress({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "progress",
        value,
        max,
        percent: finite ? +((trueLevel * 100).toFixed(2)) : null,
        bucket: finite ? bucket : null,
        plain: stripAnsi(output),
      };
    },
  };
}
