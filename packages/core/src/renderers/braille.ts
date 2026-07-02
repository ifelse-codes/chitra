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

  toLines(): string[] {
    const lines: string[] = [];
    for (let r = 0; r < this.rows; r++) {
      let line = "";
      for (let c = 0; c < this.cols; c++) {
        const bits = this.dots[r * this.cols + c];
        line += String.fromCodePoint(BRAILLE_BASE + bits);
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

export function plotLineOnBrailleCanvas(
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

  while (true) {
    canvas.set(x0, y0);
    if (x0 === x1 && y0 === y1) break;
    const e2 = 2 * err;
    if (e2 > -dy) { err -= dy; x0 += sx; }
    if (e2 < dx) { err += dx; y0 += sy; }
  }
}
