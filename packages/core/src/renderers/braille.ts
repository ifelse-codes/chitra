const BRAILLE_BASE = 0x2800;

const DOT_OFFSETS: number[][] = [
  [0x01, 0x08],
  [0x02, 0x10],
  [0x04, 0x20],
  [0x40, 0x80],
];

export class BrailleCanvas {
  private dots: Uint8Array;
  readonly cols: number;
  readonly rows: number;
  readonly dotCols: number;
  readonly dotRows: number;

  constructor(cols: number, rows: number) {
    this.cols = cols;
    this.rows = rows;
    this.dotCols = cols * 2;
    this.dotRows = rows * 4;
    this.dots = new Uint8Array(rows * cols);
  }

  set(dotCol: number, dotRow: number): void {
    if (dotCol < 0 || dotCol >= this.dotCols) return;
    if (dotRow < 0 || dotRow >= this.dotRows) return;
    const charCol = Math.floor(dotCol / 2);
    const charRow = Math.floor(dotRow / 4);
    const bitOffset = DOT_OFFSETS[dotRow % 4][dotCol % 2];
    this.dots[charRow * this.cols + charCol] |= bitOffset;
  }

  unset(dotCol: number, dotRow: number): void {
    if (dotCol < 0 || dotCol >= this.dotCols) return;
    if (dotRow < 0 || dotRow >= this.dotRows) return;
    const charCol = Math.floor(dotCol / 2);
    const charRow = Math.floor(dotRow / 4);
    const bitOffset = DOT_OFFSETS[dotRow % 4][dotCol % 2];
    this.dots[charRow * this.cols + charCol] &= ~bitOffset;
  }

  isSet(dotCol: number, dotRow: number): boolean {
    if (dotCol < 0 || dotCol >= this.dotCols) return false;
    if (dotRow < 0 || dotRow >= this.dotRows) return false;
    const charCol = Math.floor(dotCol / 2);
    const charRow = Math.floor(dotRow / 4);
    const bitOffset = DOT_OFFSETS[dotRow % 4][dotCol % 2];
    return (this.dots[charRow * this.cols + charCol] & bitOffset) !== 0;
  }

  fillColumn(dotCol: number, fromDotRow: number, toDotRow: number): void {
    const lo = Math.min(fromDotRow, toDotRow);
    const hi = Math.max(fromDotRow, toDotRow);
    for (let r = lo; r <= hi; r++) this.set(dotCol, r);
  }

  /** Texture mask for line strokes: keeps only every `step`-th character
   *  column and blanks the rest, so the same drawn line can be rendered
   *  solid (step 1), dashed (step 2) or dotted (step 3). */
  thin(step: number): void {
    if (step <= 1) return;
    for (let r = 0; r < this.rows; r++) {
      for (let c = 0; c < this.cols; c++) {
        if (c % step !== 0) {
          for (let dr = 0; dr < 4; dr++) {
            for (let dc = 0; dc < 2; dc++) this.unset(c * 2 + dc, r * 4 + dr);
          }
        }
      }
    }
  }

  toLines(emptyChar: string = "\u2800"): string[] {
    const lines: string[] = [];
    for (let r = 0; r < this.rows; r++) {
      let line = "";
      for (let c = 0; c < this.cols; c++) {
        const bits = this.dots[r * this.cols + c];
        if (bits === 0) {
          line += emptyChar;
        } else {
          line += String.fromCodePoint(BRAILLE_BASE + bits);
        }
      }
      lines.push(line);
    }
    return lines;
  }

  toString(): string {
    return this.toLines().join("\n");
  }

  clear(): void {
    this.dots.fill(0);
  }
}

/** Centripetal-ish Catmull-Rom sample through control points `data` at real
 *  index `u` (0..n-1). Endpoints are duplicated so the curve passes through the
 *  first/last points. Returns a smoothly-interpolated value. */
function catmullRom(data: number[], u: number): number {
  const n = data.length;
  if (n === 1) return data[0]!;
  const i = Math.min(n - 2, Math.max(0, Math.floor(u)));
  const t = u - i;
  const p0 = data[Math.max(0, i - 1)]!;
  const p1 = data[i]!;
  const p2 = data[Math.min(n - 1, i + 1)]!;
  const p3 = data[Math.min(n - 1, i + 2)]!;
  const t2 = t * t;
  const t3 = t2 * t;
  return 0.5 * (
    2 * p1 +
    (-p0 + p2) * t +
    (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
    (-p0 + 3 * p1 - 3 * p2 + p3) * t3
  );
}

export function plotLineOnBrailleCanvas(
  canvas: BrailleCanvas,
  data: number[],
  yMin: number,
  yMax: number,
  smooth: boolean = false
): void {
  const n = data.length;
  if (n === 0) return;
  const { dotCols, dotRows } = canvas;

  // Smooth mode: sample a Catmull-Rom spline at every dot-column so the curve
  // reads as a continuous bend instead of angular straight segments between the
  // few raw data points. Falls back to raw-point Bresenham when disabled or when
  // there are too few points to interpolate.
  if (smooth && n >= 3) {
    const yFor = (v: number): number => {
      const norm = yMax === yMin ? 0.5 : (v - yMin) / (yMax - yMin);
      const clamped = Math.max(0, Math.min(1, norm));
      return dotRows - 1 - Math.round(clamped * (dotRows - 1));
    };
    let prevX = 0;
    let prevY = yFor(catmullRom(data, 0));
    canvas.set(prevX, prevY);
    for (let x = 1; x < dotCols; x++) {
      const u = (x / (dotCols - 1)) * (n - 1);
      const y = yFor(catmullRom(data, u));
      drawBrailleLine(canvas, prevX, prevY, x, y);
      prevX = x;
      prevY = y;
    }
    return;
  }

  for (let i = 0; i < n; i++) {
    const x = Math.round((i / (n - 1)) * (dotCols - 1));
    const normalized = yMax === yMin ? 0.5 : (data[i] - yMin) / (yMax - yMin);
    const y = dotRows - 1 - Math.round(normalized * (dotRows - 1));
    canvas.set(x, y);

    if (i > 0) {
      const prevX = Math.round(((i - 1) / (n - 1)) * (dotCols - 1));
      const prevNormalized = yMax === yMin ? 0.5 : (data[i - 1] - yMin) / (yMax - yMin);
      const prevY = dotRows - 1 - Math.round(prevNormalized * (dotRows - 1));
      drawBrailleLine(canvas, prevX, prevY, x, y);
    }
  }
}

export function plotAreaOnBrailleCanvas(
  canvas: BrailleCanvas,
  data: number[],
  yMin: number,
  yMax: number
): void {
  const n = data.length;
  if (n === 0) return;
  const { dotCols, dotRows } = canvas;

  for (let i = 0; i < n; i++) {
    const x = Math.round((i / (n - 1)) * (dotCols - 1));
    const normalized = yMax === yMin ? 0.5 : (data[i] - yMin) / (yMax - yMin);
    const y = dotRows - 1 - Math.round(normalized * (dotRows - 1));
    canvas.fillColumn(x, y, dotRows - 1);
  }
}

function drawBrailleLine(
  canvas: BrailleCanvas,
  x0: number,
  y0: number,
  x1: number,
  y1: number
): void {
  const dx = Math.abs(x1 - x0);
  const dy = Math.abs(y1 - y0);
  const sx = x0 < x1 ? 1 : -1;
  const sy = y0 < y1 ? 1 : -1;
  let err = dx - dy;

  // Track if we've actually moved to prevent infinite loops in degenerate cases
  let lastX = -1;
  let lastY = -1;

  while (true) {
    if (x0 === lastX && y0 === lastY) break; // safeguard
    canvas.set(x0, y0);
    lastX = x0;
    lastY = y0;
    
    if (x0 === x1 && y0 === y1) break;
    
    const e2 = 2 * err;
    if (e2 > -dy) { err -= dy; x0 += sx; }
    if (e2 < dx) { err += dx; y0 += sy; }
  }
}
