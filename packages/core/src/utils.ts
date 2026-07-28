export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

export function normalize(
  value: number,
  min: number,
  max: number,
  targetMin = 0,
  targetMax = 1
): number {
  if (max === min) return targetMin;
  return targetMin + ((value - min) / (max - min)) * (targetMax - targetMin);
}

export function range(start: number, end: number, step = 1): number[] {
  const result: number[] = [];
  for (let i = start; i < end; i += step) result.push(i);
  return result;
}

export function minMax(data: number[]): { min: number; max: number } {
  let min = Infinity;
  let max = -Infinity;
  for (const v of data) {
    if (v < min) min = v;
    if (v > max) max = v;
  }
  return { min, max };
}

export function minMaxFlat(data: number[][]): { min: number; max: number } {
  return minMax(data.flat());
}

export function niceTicks(min: number, max: number, maxTicks = 5): { min: number; max: number; step: number; ticks: number[] } {
  if (min === max) return { min, max, step: 1, ticks: [min] };
  const range = max - min;
  const rawStep = range / (maxTicks - 1);
  const mag = Math.pow(10, Math.floor(Math.log10(rawStep)));
  const norm = rawStep / mag;
  
  let step: number;
  if (norm < 1.5) step = 1 * mag;
  else if (norm < 3) step = 2 * mag;
  else if (norm < 7.5) step = 5 * mag;
  else step = 10 * mag;

  // STRICT bounds: Do not force 0 if min is > 0. Just step down once.
  let niceMin = Math.floor(min / step) * step;
  let niceMax = Math.ceil(max / step) * step;
  
  const ticks: number[] = [];
  for (let t = niceMin; t <= niceMax + 1e-9; t += step) {
    ticks.push(t);
  }
  return { min: niceMin, max: niceMax, step, ticks: ticks.reverse() };
}

export function formatNumber(value: number, precision = 2): string {
  if (Math.abs(value) >= 1_000_000) return (value / 1_000_000).toFixed(1) + "M";
  if (Math.abs(value) >= 1_000) return (value / 1_000).toFixed(1) + "K";
  if (Number.isInteger(value)) return value.toString();
  return value.toFixed(precision);
}

export function createGrid(rows: number, cols: number, fill = " "): string[][] {
  return Array.from({ length: rows }, () => Array(cols).fill(fill));
}

export function gridToString(grid: string[][]): string {
  return grid.map((row) => row.join("")).join("\n");
}

export function wrapLines(lines: string[]): string {
  return lines.join("\n");
}

export function ensureArray<T>(v: T | T[]): T[] {
  return Array.isArray(v) ? v : [v];
}

export function percentile(sorted: number[], p: number): number {
  const idx = (p / 100) * (sorted.length - 1);
  const lo = Math.floor(idx);
  const hi = Math.ceil(idx);
  if (lo === hi) return sorted[lo];
  return sorted[lo] + (sorted[hi] - sorted[lo]) * (idx - lo);
}

export function quartiles(data: number[]): {
  q1: number;
  median: number;
  q3: number;
  min: number;
  max: number;
  iqr: number;
} {
  const sorted = [...data].sort((a, b) => a - b);
  const q1 = percentile(sorted, 25);
  const median = percentile(sorted, 50);
  const q3 = percentile(sorted, 75);
  const iqr = q3 - q1;
  return { q1, median, q3, min: sorted[0], max: sorted[sorted.length - 1], iqr };
}

export function repeat(char: string, n: number): string {
  return n <= 0 ? "" : char.repeat(n);
}

export function center(text: string, width: number): string {
  const len = text.length;
  if (len >= width) return text;
  const leftPad = Math.floor((width - len) / 2);
  const rightPad = width - len - leftPad;
  return " ".repeat(leftPad) + text + " ".repeat(rightPad);
}

export function truncate(text: string, maxLen: number): string {
  if (text.length <= maxLen) return text;
  return text.slice(0, maxLen - 1) + "…";
}
