import type { Theme } from "../types.js";
import { GREY_TONES } from "../themes/index.js";
import { colorize, padEnd, padStart, visibleLength } from "../ansi.js";
import { formatNumber } from "../utils.js";

export interface RingSlice {
  label: string;
  value: number;
  pct: number;
  color: string;
  glyph: string;
  textColor: string;
  accent: boolean;
}

export interface RingBuild {
  slices: RingSlice[];
  accentIndex: number;
  total: number;
}

/** Build per-slice style: accent on the largest slice, grey tone ramp on the
 *  rest. Every slice is drawn as a solid block — the circle itself is the
 *  shape, separation comes from colour (and the legend in plain mode). */
export function buildSlices(
  data: number[],
  labels: string[],
  theme: Theme,
  accentIndex?: number
): RingBuild {
  const total = data.reduce((a, b) => a + b, 0) || 1;
  const accent = theme.accent ?? theme.colors[0] ?? GREY_TONES[0]!;
  const tones = theme.tones ?? GREY_TONES;
  const idx = accentIndex ?? data.indexOf(Math.max(...data));

  const slices = data.map((value, i) => {
    const accentSlice = i === idx;
    const tone = tones[i % tones.length];
    const color = accentSlice ? accent : tone;
    const lightTone = i % tones.length < 2;
    const textColor = accentSlice ? GREY_TONES[3]! : lightTone ? GREY_TONES[3]! : GREY_TONES[0]!;
    return {
      label: labels[i] ?? `Item ${i + 1}`,
      value,
      pct: (value / total) * 100,
      color,
      glyph: "█",
      textColor,
      accent: accentSlice,
    };
  });

  return { slices, accentIndex: idx, total };
}
/** Braille dot mapping: each cell is 2 dots wide × 4 dots tall. Dot (x,y)
 *  lights bit at position `x * 4 + y` of the braille char. Square dots let
 *  the circle be drawn at 2×4 sub-pixel resolution — genuinely round. */
const BRAILLE_BITS = [
  [0x01, 0x02, 0x04, 0x08],
  [0x10, 0x20, 0x40, 0x80],
];
function braille(dots: number[][]): string {
  let v = 0;
  for (let x = 0; x < 2; x++) {
    for (let y = 0; y < 4; y++) {
      if (dots[x][y]) v += BRAILLE_BITS[x][y];
    }
  }
  return String.fromCharCode(0x2800 + v);
}

/** Render the ring (or pie) as rows. The circle is drawn directly at 2×4
 *  sub-pixel resolution using braille dots, so the curve reads as a perfect
 *  round circle — matching the reference's stroked SVG circles. Each cell is
 *  coloured by the slice its dots belong to. Angle frame: 0 = top, increasing
 *  clockwise (screen y-down). Center text (donut) is passed by the caller. */
export function renderRing(
  slices: RingSlice[],
  radius: number,
  innerRadius: number,
  noColor: boolean,
  centerText?: string,
  centerColor?: string
): string[] {
  const cx = radius * 2;
  const cy = radius;
  const rows = radius * 2 + 1;
  const cols = radius * 4 + 1;

  // dot grid is 2× cols wide, 4× rows tall; centre and radius in dot units
  const cxd = (cols * 2) / 2;
  const cyd = (rows * 4) / 2;
  const rd = radius * 4;
  const ird = innerRadius * 4;

  const cumulative: number[] = [];
  let cum = 0;
  for (const s of slices) {
    cum += (s.pct / 100) * Math.PI * 2;
    cumulative.push(cum);
  }
  const phi = (dx: number, dy: number) => {
    let a = Math.atan2(dx, -dy);
    return a < 0 ? a + Math.PI * 2 : a;
  };
  const sliceAt = (dx: number, dy: number): RingSlice | null => {
    const dist = Math.sqrt(dx * dx + dy * dy);
    if (dist <= rd && dist >= ird) {
      const angle = phi(dx, dy);
      for (let i = 0; i < cumulative.length; i++) {
        if (angle < cumulative[i]) return slices[i]!;
      }
      return slices[slices.length - 1]!;
    }
    return null;
  };

  const grid: string[][] = Array.from({ length: rows }, () => Array(cols).fill(" "));
  const colors: string[][] = Array.from({ length: rows }, () => Array(cols).fill(""));

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      const dots: number[][] = [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      const counts = new Map<RingSlice, number>();
      let lit = 0;
      for (let dx = 0; dx < 2; dx++) {
        for (let dy = 0; dy < 4; dy++) {
          // supersample each braille dot at 2×2 sub-points; light it when the
          // majority of sub-points fall inside the ring (smoother rim)
          let inside = 0;
          const litDots = new Map<RingSlice, number>();
          for (const [sx, sy] of [
            [0.25, 0.25],
            [0.75, 0.25],
            [0.25, 0.75],
            [0.75, 0.75],
          ]) {
            const x = col * 2 + dx + sx;
            const y = row * 4 + dy + sy;
            const s = sliceAt(x - cxd, y - cyd);
            if (s) {
              inside++;
              litDots.set(s, (litDots.get(s) ?? 0) + 1);
            }
          }
          if (inside < 2) continue;
          dots[dx][dy] = 1;
          lit++;
          for (const [s, n] of litDots) counts.set(s, (counts.get(s) ?? 0) + n);
        }
      }
      if (lit === 0) continue;
      grid[row][col] = braille(dots);
      let best: RingSlice | null = null;
      let bestN = -1;
      for (const [s, n] of counts) {
        if (n > bestN) {
          best = s;
          bestN = n;
        }
      }
      colors[row][col] = best!.color;
    }
  }

  if (centerText && innerRadius > 0) {
    const midRow = Math.floor(rows / 2);
    const startCol = cx - Math.floor(centerText.length / 2);
    for (let k = 0; k < centerText.length; k++) {
      const c = startCol + k;
      if (c >= 0 && c < cols) {
        grid[midRow]![c] = centerText[k]!;
        colors[midRow]![c] = centerColor ?? "";
      }
    }
  }

  return grid.map((rowArr, r) =>
    rowArr.map((ch, c) => colorize(ch, colors[r][c], noColor)).join("")
  );
}

/** Right-aligned legend: solid swatch + label on the left, value + pct on the right. */
export function renderLegend(
  slices: RingSlice[],
  noColor: boolean,
  theme: Theme,
  showValues = true
): { rows: string[]; width: number } {
  const nameW = Math.max(...slices.map((s) => visibleLength(s.label)));
  const valStrs = slices.map((s) =>
    showValues ? `${formatNumber(s.value)} (${s.pct.toFixed(1)}%)` : ""
  );
  const valW = Math.max(0, ...valStrs.map((v) => visibleLength(v)));

  const rows = slices.map((s, i) => {
    const glyph = colorize(s.glyph, s.color, noColor);
    const name = colorize(
      padEnd(s.label, nameW),
      s.accent ? theme.title : theme.label,
      noColor
    );
    const val = showValues
      ? colorize(padStart(valStrs[i]!, valW), s.accent ? theme.title : theme.label, noColor)
      : "";
    return `${glyph} ${name}  ${val}`;
  });

  const width = 1 + 1 + nameW + 2 + (showValues ? valW : 0);
  return { rows, width };
}
