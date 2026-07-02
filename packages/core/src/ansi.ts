export const ESC = "\x1b";

export const ansi = {
  reset: `${ESC}[0m`,
  bold: `${ESC}[1m`,
  dim: `${ESC}[2m`,
  italic: `${ESC}[3m`,
  underline: `${ESC}[4m`,

  black: `${ESC}[30m`,
  red: `${ESC}[31m`,
  green: `${ESC}[32m`,
  yellow: `${ESC}[33m`,
  blue: `${ESC}[34m`,
  magenta: `${ESC}[35m`,
  cyan: `${ESC}[36m`,
  white: `${ESC}[37m`,

  brightBlack: `${ESC}[90m`,
  brightRed: `${ESC}[91m`,
  brightGreen: `${ESC}[92m`,
  brightYellow: `${ESC}[93m`,
  brightBlue: `${ESC}[94m`,
  brightMagenta: `${ESC}[95m`,
  brightCyan: `${ESC}[96m`,
  brightWhite: `${ESC}[97m`,

  rgb(r: number, g: number, b: number): string {
    return `${ESC}[38;2;${r};${g};${b}m`;
  },

  bg: {
    black: `${ESC}[40m`,
    red: `${ESC}[41m`,
    green: `${ESC}[42m`,
    yellow: `${ESC}[43m`,
    blue: `${ESC}[44m`,
    magenta: `${ESC}[45m`,
    cyan: `${ESC}[46m`,
    white: `${ESC}[47m`,

    rgb(r: number, g: number, b: number): string {
      return `${ESC}[48;2;${r};${g};${b}m`;
    },
  },
};

export function colorize(text: string, colorCode: string, noColor = false): string {
  if (noColor) return text;
  return `${colorCode}${text}${ansi.reset}`;
}

export function stripAnsi(str: string): string {
  return str.replace(/\x1b\[[0-9;]*m/g, "");
}

export function visibleLength(str: string): number {
  return stripAnsi(str).length;
}

export function padEnd(str: string, width: number, char = " "): string {
  const visible = visibleLength(str);
  if (visible >= width) return str;
  return str + char.repeat(width - visible);
}

export function padStart(str: string, width: number, char = " "): string {
  const visible = visibleLength(str);
  if (visible >= width) return str;
  return char.repeat(width - visible) + str;
}

export function hexToAnsi(hex: string): string {
  const h = hex.replace("#", "");
  const r = parseInt(h.substring(0, 2), 16);
  const g = parseInt(h.substring(2, 4), 16);
  const b = parseInt(h.substring(4, 6), 16);
  return ansi.rgb(r, g, b);
}
