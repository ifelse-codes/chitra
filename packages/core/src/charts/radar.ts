import type { RadarChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi, truncateAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { BrailleCanvas } from "../renderers/braille.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Ring fractions: five dashed hexagonal rings at 20/40/60/80/100% of range
// with `+` ticks and a `0..max` eyebrow scale — the reference-image grammar.
const RING_FRACS = [0.2, 0.4, 0.6, 0.8, 1.0];

const BRAILLE_BASE = 0x2800;
const DOT_BITS = [
  [0x01, 0x08],
  [0x02, 0x10],
  [0x04, 0x20],
  [0x40, 0x80],
];

/** Renders a chitra-standard TUI panel carrying the LOCKED S26 design language —
 *  the spider/radar chart on a braille web, rebuilt from a founder-supplied
 *  reference image after two char-cell cuts failed live review (scattered
 *  dots, then a solid blob). Braille dots are square, so the web needs no
 *  aspect compensation — the S09 circular playbook:
 *  - **Dashed hexagonal grid.** Five dashed hex rings (20–100% of range) with
 *    `+` ticks where spokes cross rings; the `0..<max>` scale rides the
 *    eyebrow (in-web numbers collide at terminal density).
 *  - **Thick glowing primary, dashed hollow secondaries, haze wash.**
 *    Series 0 draws a thickened sub-pixel braille rim (perpendicular
 *    doubling) with halo-ringed `●` vertices over a sparse wash haze one
 *    tone dimmer — the rim spent EXACTLY once. Tuned side-by-side against
 *    the reference: thin rim vanished beside neon; full tint buried the
 *    grid. Every other series draws a DASHED polygon in its grey tone with
 *    hollow `○` vertices. The old `theme.colors[si % n]` rainbow is retired.
 *    Mass and kind survive `stripAnsi` / `noColor` (shape, not hue).
 *  - **The `renderer` option stays accepted; the locked design supersedes
 *    it** (the S23 progress precedent): braille web in every mode.
 *  - Magnitudes clamp at zero (negatives and non-finite samples collapse to
 *    the center, never `NaN`).
 *  - Same panel language as all locked charts: dashed frame, `AXES · SERIES`
 *    eyebrow, glyph legend, two rules, `AVG · PEAK` foot (peak accented).
 *    Width auto-expands (explicit `width` is a floor, not a cap). */
export function radar(opts: RadarChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti ? (rawData as number[][]) : [rawData as number[]];
  const axisLabels = opts.labels ?? [];
  const numAxes = axisLabels.length;
  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);
  const empty = numAxes === 0 || series.length === 0 || series.every((s) => s.length === 0);

  const acc = theme.accent!;
  const tones = theme.tones!;
  // The grid is the reading surface: the lightest tone, bright enough to
  // read against near-black — not the dim axis grey that vanished.
  const gridColor = tones[0]!;

  // Magnitude only: negatives and non-finite samples collapse to the center.
  const clean = series.map((s) => s.map((v) => (Number.isFinite(v) && v > 0 ? v : 0)));
  const flat = clean.flat();
  const yMax = opts.yMax ?? (flat.length > 0 ? Math.max(...flat, 0) : 0);
  const overallMax = flat.length > 0 ? Math.max(...flat) : 0;
  const overallAvg = flat.length > 0 ? flat.reduce((a, b) => a + b, 0) / flat.length : 0;
  // First axis (in axis order) carrying the overall peak.
  let peakAxis = 0;
  if (!empty && overallMax > 0) {
    outer: for (let a = 0; a < numAxes; a++) {
      for (const s of clean) {
        if ((s[a] ?? 0) === overallMax) {
          peakAxis = a;
          break outer;
        }
      }
    }
  }

  const eyebrow = empty
    ? "AXES 0"
    : `AXES ${numAxes} · SERIES ${series.length} · 0..${formatNumber(yMax)}`;
  const footPlain = empty
    ? "AXES 0 · (no data)"
    : `AVG ${formatNumber(overallAvg)} · PEAK ${axisLabels[peakAxis] ?? ""} ${formatNumber(overallMax)}`;

  // Plot area in character cells; the web lives in square braille dots.
  const plotCols = Math.max(24, Math.min(opts.width ?? 56, 76));
  const plotRows = Math.max(12, Math.min(opts.height ?? 24, 30));
  const dotCols = plotCols * 2;
  const dotRows = plotRows * 4;
  const cxd = Math.floor(dotCols / 2);
  const cyd = Math.floor(dotRows / 2);
  // 7-char label margin on x, 2-row margin on y.
  const Rd = Math.max(10, Math.min(Math.floor(dotCols / 2) - 14, Math.floor(dotRows / 2) - 8));

  // Braille chars are 1 terminal column in most terminals.
  const effectiveWidth = Math.max(
    plotCols + 4,
    eyebrow.length + 4,
    footPlain.length + 4,
    40,
    ...seriesLabels.map((l) => l.length + 8)
  );

  function seriesColor(si: number): string {
    if (si === 0) return acc;
    return tones[(si - 1) % tones.length]!;
  }

  /** Dots along a segment (inclusive), for edges and dashed chrome. */
  function segmentDots(x0: number, y0: number, x1: number, y1: number): Array<[number, number]> {
    const cells: Array<[number, number]> = [];
    const dx = Math.abs(x1 - x0);
    const dy = Math.abs(y1 - y0);
    const sx = x0 < x1 ? 1 : -1;
    const sy = y0 < y1 ? 1 : -1;
    let err = dx - dy;
    let xa = x0;
    let ya = y0;
    for (let guard = 0; guard < dotCols + dotRows + 10; guard++) {
      cells.push([xa, ya]);
      if (xa === x1 && ya === y1) break;
      const e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        xa += sx;
      }
      if (e2 < dx) {
        err += dx;
        ya += sy;
      }
    }
    return cells;
  }

  /** Read one braille cell of a canvas as a character ("" when blank). */
  function cellChar(canvas: BrailleCanvas, c: number, r: number): string {
    let bits = 0;
    for (let dr = 0; dr < 4; dr++) {
      for (let dc = 0; dc < 2; dc++) {
        if (canvas.isSet(c * 2 + dc, r * 4 + dr)) bits |= DOT_BITS[dr]![dc]!;
      }
    }
    return bits === 0 ? "" : String.fromCodePoint(BRAILLE_BASE + bits);
  }

  function buildWeb(): string[] {
    const axisAngles = Array.from(
      { length: numAxes },
      (_, i) => (i * 2 * Math.PI) / numAxes - Math.PI / 2
    );
    const polar = (angle: number, r: number): [number, number] => [
      Math.round(cxd + r * Math.cos(angle)),
      Math.round(cyd + r * Math.sin(angle)),
    ];

    const grid = new BrailleCanvas(plotCols, plotRows);
    const serieCanvases = clean.map(() => new BrailleCanvas(plotCols, plotRows));
    // Wash fill on its own layer: one tone dimmer than the rim, quarter
    // density — the target's translucent haze, not a blob.

    // Hex rings solid and thin (the reading surface), spokes dashed dimmer.
    for (const frac of RING_FRACS) {
      const ringPts = axisAngles.map((a) => polar(a, frac * Rd));
      for (let i = 0; i < ringPts.length; i++) {
        const a = ringPts[i]!;
        const b = ringPts[(i + 1) % ringPts.length]!;
        segmentDots(a[0], a[1], b[0], b[1]).forEach(([x, y]) => {
          grid.set(x, y);
        });
      }
    }
    const outer = axisAngles.map((a) => polar(a, Rd));
    for (const [ex, ey] of outer) {
      segmentDots(cxd, cyd, ex, ey).forEach(([x, y], k) => {
        if (k % 3 === 0) grid.set(x, y);
      });
    }

    // Series polygons: primary solid and THICK, secondaries dashed.
    const polys: Array<Array<[number, number]>> = clean.map((s) =>
      s.slice(0, numAxes).map((v, i) => polar(axisAngles[i]!, yMax <= 0 ? 0 : (v / yMax) * Rd))
    );
    const wash = new BrailleCanvas(plotCols, plotRows);
    const washColor = tones[Math.min(1, tones.length - 1)]!;
    const primary = polys[0] ?? [];
    // Wash haze inside the primary mass (the target's translucency): sparse
    // enough to stay haze, yielding to chrome.
    if (!empty && yMax > 0 && primary.length >= 3) {
      const inPoly = (x: number, y: number): boolean => {
        let inside = false;
        for (let i = 0, j = primary.length - 1; i < primary.length; j = i++) {
          const xi = primary[i]![0];
          const yi = primary[i]![1];
          const xj = primary[j]![0];
          const yj = primary[j]![1];
          if (yi > y !== yj > y && x < ((xj - xi) * (y - yi)) / (yj - yi) + xi) inside = !inside;
        }
        return inside;
      };
      for (let y = 0; y < dotRows; y++) {
        for (let x = 0; x < dotCols; x++) {
          if ((x + 2 * y) % 4 === 0 && !grid.isSet(x, y) && inPoly(x, y)) wash.set(x, y);
        }
      }
    }
    polys.forEach((pts, si) => {
      if (empty || yMax <= 0 || pts.length === 0) return;
      const canvas = serieCanvases[si]!;
      for (let p = 0; p < pts.length; p++) {
        const curr = pts[p]!;
        const next = pts[(p + 1) % pts.length]!;
        const cells = segmentDots(curr[0], curr[1], next[0], next[1]);
        // Segment orientation picks the thickening axis: horizontals grow
        // down, verticals grow right — a rim with real presence.
        const horiz = Math.abs(next[0] - curr[0]) >= Math.abs(next[1] - curr[1]) * 2;
        cells.forEach(([x, y], k) => {
          // Primary solid; secondaries dashed with a coarse rhythm so they
          // read as lines, not dust.
          const on = si === 0 ? true : si === 1 ? k % 6 < 4 : k % 6 < 2;
          if (!on) return;
          canvas.set(x, y);
          if (si === 0) {
            if (horiz) {
              canvas.set(x, y + 1);
              canvas.set(x, y - 1);
            } else {
              canvas.set(x + 1, y);
              canvas.set(x - 1, y);
            }
          }
        });
      }
      // Halo: a wider ring of series dots around each primary vertex — the
      // reference-image glow, in terminal dots. Set pre-merge so it counts.
      if (si === 0) {
        for (const [x, y] of pts) {
          for (let a = 0; a < 16; a++) {
            canvas.set(
              Math.round(x + 4 * Math.cos((a / 16) * 2 * Math.PI)),
              Math.round(y + 4 * Math.sin((a / 16) * 2 * Math.PI))
            );
          }
        }
      }
    });

    // Merge per cell: primary rim > wash > secondaries > grid. One hue per
    // cell — priority order is the tone system, not a blend.
    const rows: string[][] = Array.from({ length: plotRows }, () => Array(plotCols).fill(""));
    for (let r = 0; r < plotRows; r++) {
      for (let c = 0; c < plotCols; c++) {
        const b0 = cellChar(serieCanvases[0]!, c, r);
        if (b0) {
          rows[r]![c] = colorize(b0, seriesColor(0), noColor);
          continue;
        }
        const w = cellChar(wash, c, r);
        if (w) {
          rows[r]![c] = colorize(w, washColor, noColor);
          continue;
        }
        let placed = false;
        for (let si = 1; si < serieCanvases.length; si++) {
          const b = cellChar(serieCanvases[si]!, c, r);
          if (b) {
            rows[r]![c] = colorize(b, seriesColor(si), noColor);
            placed = true;
            break;
          }
        }
        if (placed) continue;
        const g = cellChar(grid, c, r);
        rows[r]![c] = g ? colorize(g, gridColor, noColor) : " ";
      }
    }

    // Text overlay, drawn last so it always reads: `+` ticks, vertices,
    // axis labels.
    const put = (c: number, r: number, ch: string): void => {
      if (c >= 0 && c < plotCols && r >= 0 && r < plotRows) rows[r]![c] = ch;
    };
    for (const frac of RING_FRACS) {
      for (const a of axisAngles) {
        const [x, y] = polar(a, frac * Rd);
        put(Math.floor(x / 2), Math.floor(y / 4), colorize("+", theme.axis, noColor));
      }
    }
    polys.forEach((pts, si) => {
      if (empty || yMax <= 0) return;
      for (const [x, y] of pts) {
        put(
          Math.floor(x / 2),
          Math.floor(y / 4),
          colorize(si === 0 ? "●" : "○", seriesColor(si), noColor)
        );
      }
    });
    axisAngles.forEach((a, i) => {
      const [vx, vy] = polar(a, Rd);
      const m = 1.15;
      const lx = Math.round(cxd + Rd * m * Math.cos(a));
      const ly = Math.round(cyd + Rd * m * Math.sin(a));
      void vx;
      void vy;
      const label = (axisLabels[i] ?? "").slice(0, 12);
      // Clamped into the canvas — long side labels survive narrow webs.
      const cc = Math.max(
        0,
        Math.min(plotCols - label.length, Math.floor(lx / 2) - Math.floor(label.length / 2))
      );
      const cr = Math.max(0, Math.min(plotRows - 1, Math.floor(ly / 4)));
      for (let j = 0; j < label.length; j++) {
        put(cc + j, cr, colorize(label[j]!, theme.label, noColor));
      }
    });

    return rows.map((row) => row.join(""));
  }

  function legendRow(): string {
    return seriesLabels
      .map((sl, i) => {
        const mark = i === 0 ? "●" : "○";
        const line = i === 0 ? "──" : "╌╌";
        return colorize(`${mark} ${line} ${sl}`, seriesColor(i), noColor);
      })
      .join("  ");
  }

  function buildSummary(): string {
    if (empty) return colorize(footPlain, theme.label, noColor);
    const head = colorize(
      `AVG ${formatNumber(overallAvg)} · PEAK ${axisLabels[peakAxis] ?? ""} `,
      theme.label,
      noColor
    );
    return head + colorize(formatNumber(overallMax), acc, noColor);
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    if (useFrame && !useCompact) {
      lines.push(
        frameTop(effectiveWidth, opts.title ?? "RADAR", undefined, theme.axis, theme.title, noColor, true)
      );
      lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
    }
    if (!empty) {
      for (const row of buildWeb()) lines.push(useFrame && !useCompact ? frameRow(effectiveWidth, row, theme.axis, noColor) : row);
      if (!useCompact) {
        lines.push(useFrame ? frameRow(effectiveWidth, legendRow(), theme.axis, noColor) : legendRow());
      }
    }
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
    render() {
      process.stdout.write(output + "\n");
    },
    toString() {
      return output;
    },
    toPlain() {
      return stripAnsi(output);
    },
    toContent() { return radar({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
    toJSON() {
      return {
        type: "radar",
        data: opts.data,
        labels: opts.labels,
        // Additive S26 facts: overall peak (+axis) and mean (null when empty).
        max: empty ? null : { value: overallMax, axis: axisLabels[peakAxis] ?? null },
        avg: empty ? null : overallAvg,
        plain: stripAnsi(output),
      };
    },
  };
}
