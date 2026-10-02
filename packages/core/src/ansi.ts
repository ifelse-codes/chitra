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

/** Return the display width of a single character (1 or 2 columns). */
function charWidth(ch: string): number {
  const code = ch.codePointAt(0)!;
  // CJK Unified Ideographs + extensions — 2 columns
  if (
    (code >= 0x4e00 && code <= 0x9fff) ||
    (code >= 0x3400 && code <= 0x4dbf) ||
    (code >= 0x20000 && code <= 0x2a6df)
  )
    return 2;
  // Fullwidth forms (U+FF01–U+FF60) — 2 columns
  if (code >= 0xff01 && code <= 0xff60) return 2;
  // Braille Patterns (U+2800–U+28FF) — 1 column
  if (code >= 0x2800 && code <= 0x28ff) return 1;
  // Zero-width characters
  if (code === 0x200b || code === 0x200c || code === 0x200d || code === 0xfeff) return 0;
  return 1;
}

export function visibleLength(str: string): number {
  let w = 0;
  for (const ch of stripAnsi(str)) w += charWidth(ch);
  return w;
}

/** Uppercase the visible text of a string while leaving ANSI escape
 *  sequences untouched — `.toUpperCase()` would corrupt them (`m` → `M`). */
export function upperAnsi(str: string): string {
  return str
    .split(/(\x1b\[[0-9;]*m)/)
    .map((part) => (part.startsWith("\x1b") ? part : part.toUpperCase()))
    .join("");
}

export function truncateAnsi(str: string, maxWidth: number): string {
  if (maxWidth < 1) return "";
  if (visibleLength(str) <= maxWidth) return str;
  let out = "";
  let vis = 0;
  const re = /\x1b\[[0-9;]*m/g;
  let last = 0;
  let m: RegExpExecArray | null;
  const pushText = (text: string): boolean => {
    for (const ch of text) {
      const w = charWidth(ch);
      if (vis + w > maxWidth) return true;
      out += ch;
      vis += w;
    }
    return vis >= maxWidth;
  };
  while ((m = re.exec(str)) !== null) {
    if (pushText(str.slice(last, m.index))) {
      out += ansi.reset;
      return out;
    }
    out += m[0];
    last = m.index + m[0].length;
  }
  pushText(str.slice(last));
  out += ansi.reset;
  return out;
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
