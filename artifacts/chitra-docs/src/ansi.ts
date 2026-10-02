interface Span {
  text: string;
  fg: string | null;
  bold: boolean;
  dim: boolean;
}

function parseAnsi(raw: string): Span[] {
  const spans: Span[] = [];
  // SGR regex: ESC [ ... m
  const re = /\u001b\[([\d;]*)m/g;
  let pos = 0;
  let fg: string | null = null;
  let bold = false;
  let dim = false;

  let match: RegExpExecArray | null;
  while ((match = re.exec(raw)) !== null) {
    if (match.index > pos) {
      spans.push({ text: raw.slice(pos, match.index), fg, bold, dim });
    }
    const codes = match[1].split(";").map(Number);
    let i = 0;
    while (i < codes.length) {
      const c = codes[i];
      if (c === 0) {
        fg = null;
        bold = false;
        dim = false;
      } else if (c === 1) {
        bold = true;
      } else if (c === 2) {
        dim = true;
      } else if (c === 22) {
        bold = false;
        dim = false;
      } else if (c === 39) {
        fg = null;
      } else if (c >= 30 && c <= 37) {
        fg = ansi16(c - 30, bold);
      } else if (c >= 90 && c <= 97) {
        fg = ansi16(c - 90 + 8, bold);
      } else if (c === 38) {
        if (codes[i + 1] === 2 && i + 4 < codes.length) {
          fg = `rgb(${codes[i + 2]},${codes[i + 3]},${codes[i + 4]})`;
          i += 4;
        } else if (codes[i + 1] === 5 && i + 2 < codes.length) {
          fg = xterm256(codes[i + 2]);
          i += 2;
        }
      }
      i++;
    }
    pos = match.index + match[0].length;
  }
  if (pos < raw.length) {
    spans.push({ text: raw.slice(pos), fg, bold, dim });
  }
  return spans;
}

const ANSI16 = [
  "#3b4252",
  "#bf616a",
  "#a3be8c",
  "#ebcb8b",
  "#81a1c1",
  "#b48ead",
  "#88c0d0",
  "#e5e9f0",
  "#4c566a",
  "#bf616a",
  "#a3be8c",
  "#ebcb8b",
  "#81a1c1",
  "#b48ead",
  "#8fbcbb",
  "#eceff4",
];

function ansi16(idx: number, bright: boolean): string {
  return ANSI16[bright ? idx + 8 : idx] ?? "#e5e9f0";
}

function xterm256(n: number): string {
  if (n < 16) return ANSI16[n] ?? "#fff";
  if (n >= 232) {
    const v = 8 + (n - 232) * 10;
    return `rgb(${v},${v},${v})`;
  }
  const i = n - 16;
  const b = i % 6,
    g = Math.floor(i / 6) % 6,
    r = Math.floor(i / 36);
  const c = (x: number) => (x === 0 ? 0 : 55 + x * 40);
  return `rgb(${c(r)},${c(g)},${c(b)})`;
}

/** Wrap braille characters in <span class="br"> for plain text (no ANSI codes). */
export function wrapBraille(text: string): string {
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/[\u2800-\u28ff]/g, '<span class="br">$&</span>');
}

export function ansiToHtml(raw: string): string {
  const spans = parseAnsi(raw);
  return spans
    .map((s) => {
      let text = s.text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
      // JetBrains Mono renders braille (U+2800-U+28FF) at 2ch advance width.
      // Wrap each braille char so CSS can force it back to 1ch.
      text = text.replace(/[\u2800-\u28ff]/g, '<span class="br">$&</span>');
      const styles: string[] = [];
      if (s.fg) styles.push(`color:${s.fg}`);
      if (s.dim) styles.push("opacity:0.55");
      if (s.bold) styles.push("font-weight:700");
      if (!styles.length) return text;
      return `<span style="${styles.join(";")}">${text}</span>`;
    })
    .join("");
}
