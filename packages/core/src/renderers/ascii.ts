export const ASCII_BAR_CHAR = "#";
export const ASCII_EMPTY_CHAR = ".";
export const ASCII_AXIS_H = "-";
export const ASCII_AXIS_V = "|";
export const ASCII_CORNER = "+";
export const ASCII_CROSS = "+";
export const ASCII_LINE = "*";
export const ASCII_POINT = "o";
export const ASCII_FILL = ":";

export function buildAsciiBar(
  value: number,
  min: number,
  max: number,
  height: number,
  fillChar = ASCII_BAR_CHAR,
  emptyChar = " "
): string[] {
  const normalized = max === min ? 0 : (value - min) / (max - min);
  const filled = Math.round(normalized * height);
  const lines: string[] = [];
  for (let row = height - 1; row >= 0; row--) {
    lines.push(row < filled ? fillChar : emptyChar);
  }
  return lines;
}

export function buildAsciiHBar(
  value: number,
  min: number,
  max: number,
  width: number,
  fillChar = ASCII_BAR_CHAR,
  emptyChar = ASCII_EMPTY_CHAR
): string {
  const normalized = max === min ? 0 : (value - min) / (max - min);
  const filled = Math.round(normalized * width);
  return fillChar.repeat(filled) + emptyChar.repeat(width - filled);
}

export function sparklineAscii(data: number[], width?: number): string {
  if (data.length === 0) return "";
  const n = width ?? data.length;
  const sampled =
    data.length === n
      ? data
      : new Array(n).fill(0).map((_, i) => data[Math.round((i / (n - 1)) * (data.length - 1))]);

  const min = Math.min(...sampled);
  const max = Math.max(...sampled);
  const range = max - min;
  const levels = ["_", ".", ":", "!", "|", "*", "#"];
  return sampled
    .map((v) => {
      const normalized = range === 0 ? 0.5 : (v - min) / range;
      return levels[Math.min(Math.floor(normalized * levels.length), levels.length - 1)];
    })
    .join("");
}
