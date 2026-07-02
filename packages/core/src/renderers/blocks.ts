export const BLOCK_CHARS = " ▁▂▃▄▅▆▇█";
export const BLOCK_FULL = "█";
export const BLOCK_EMPTY = " ";
export const BLOCK_HALF = "▄";
export const SHADE_CHARS = " ░▒▓█";

export function blockHeight(normalizedValue: number): string {
  const idx = Math.round(normalizedValue * 8);
  return BLOCK_CHARS[Math.min(idx, 8)];
}

export function buildBlockBar(
  value: number,
  min: number,
  max: number,
  height: number,
  char = BLOCK_FULL,
  emptyChar = " "
): string[] {
  const normalized = max === min ? 0 : (value - min) / (max - min);
  const filled = Math.round(normalized * height);
  const lines: string[] = [];
  for (let row = height - 1; row >= 0; row--) {
    lines.push(row < filled ? char : emptyChar);
  }
  return lines;
}

export function buildHorizontalBlockBar(
  value: number,
  min: number,
  max: number,
  width: number,
  fullChar = BLOCK_FULL,
  emptyChar = "░"
): string {
  const normalized = max === min ? 0 : (value - min) / (max - min);
  const totalDots = width * 8;
  const filledDots = Math.round(normalized * totalDots);
  const fullChars = Math.floor(filledDots / 8);
  const remainder = filledDots % 8;

  let bar = fullChar.repeat(fullChars);
  if (remainder > 0 && fullChars < width) {
    bar += BLOCK_CHARS[remainder];
  }
  const padding = width - bar.length;
  if (padding > 0) bar += emptyChar.repeat(padding);
  return bar;
}

export function sparklineBlocks(data: number[], width?: number): string {
  if (data.length === 0) return "";
  const n = width ?? data.length;

  let sampled: number[];
  if (data.length === n) {
    sampled = data;
  } else if (data.length < n) {
    sampled = new Array(n).fill(0).map((_, i) => {
      const idx = (i / (n - 1)) * (data.length - 1);
      const lo = Math.floor(idx);
      const hi = Math.ceil(idx);
      return data[lo] + (data[hi] - data[lo]) * (idx - lo);
    });
  } else {
    sampled = new Array(n).fill(0).map((_, i) => {
      const idx = Math.round((i / (n - 1)) * (data.length - 1));
      return data[idx];
    });
  }

  const min = Math.min(...sampled);
  const max = Math.max(...sampled);
  return sampled.map((v) => blockHeight(max === min ? 0.5 : (v - min) / (max - min))).join("");
}

export function shadeCell(normalizedValue: number): string {
  const idx = Math.round(normalizedValue * 4);
  return SHADE_CHARS[Math.min(idx, 4)];
}
