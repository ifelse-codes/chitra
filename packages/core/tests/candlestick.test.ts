import { describe, it, expect } from "vitest";
import { candlestick } from "../src/charts/candlestick.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const CANDLES = [
  { open: 100, high: 110, low: 95, close: 105, label: "Day1" },
  { open: 105, high: 115, low: 100, close: 98, label: "Day2" },
  { open: 98, high: 108, low: 96, close: 107, label: "Day3" },
];

function plainLines(opts: Parameters<typeof candlestick>[0]): string[] {
  return stripAnsi(candlestick(opts).toString()).split("\n");
}

// A candle cell is solid block mass (█ peak, ▓ ups), outline pieces (┌╌╌┐
// │ │ └╌╌┘ downs), or a │ wick. The peak candle takes the solid `█` body in
// the accent hue; everything else sits on the grey tone ramp.
const BAR = /[█▓┌╌┐│└┘]/;

/** Count coloured BAR segments by category (the S17 raw-ANSI census method).
 *  The accent must NEVER touch a wick or an outline — solid `█` bodies plus
 *  non-block text (the LAST foot fact) only — and every grey segment must be
 *  a documented tone (no `theme.colors[i]` rainbow). */
function tonalCensus(opts: Parameters<typeof candlestick>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const out = candlestick(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    // Axis-coloured structure (frame, guides, baseline) is never candle
    // mass — the census counts candles only.
    if (code === theme.axis) continue;
    if (!BAR.test(body)) continue; // count candle segments only, not labels/footer
    if (code === theme.accent) {
      // Accent bodies are solid mass; accent text (LAST fact) carries no
      // block glyphs at all.
      if (BAR.test(body)) expect(body.replace(/\s/g, "")).toMatch(/^█+$/);
      accent++;
    } else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("candlestick chart — locked S27 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    expect(plainLines({ data: CANDLES })[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ data: CANDLES });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has one frame rule separator (│ ╌)", () => {
    const rules = plainLines({ data: CANDLES }).filter((l) => /^│ ╌+ │$/.test(l));
    expect(rules.length).toBe(1);
  });

  it("carries the OHLC eyebrow row", () => {
    expect(plainLines({ data: CANDLES })).toContainEqual(expect.stringContaining("OHLC"));
  });

  it("titles the frame CANDLESTICK by default", () => {
    expect(plainLines({ data: CANDLES })[0]).toContain("CANDLESTICK");
  });

  it("fits the longest period label in full (never Jan/Jan1 mush)", () => {
    const dated = [
      { open: 142, high: 158, low: 138, close: 155, label: "Jan 8" },
      { open: 155, high: 168, low: 148, close: 151, label: "Jan 9" },
      { open: 195, high: 215, low: 190, close: 210, label: "Jan19" },
    ];
    const text = plainLines({ data: dated, noColor: true }).join("\n");
    expect(text).toContain("Jan 8");
    expect(text).toContain("Jan 9");
    expect(text).toContain("Jan19");
  });

  it("keeps the eyebrow OHLC even when a title is set (no title echo)", () => {
    const lines = plainLines({ data: CANDLES, title: "CHRX", noColor: true });
    expect(lines[0]).toContain("CHRX");
    expect(lines).toContainEqual(expect.stringContaining("OHLC"));
    expect(lines.filter((l) => l.includes("CHRX")).length).toBe(1);
  });

  it("keeps every panel row the same visible width", () => {
    const widths = new Set(plainLines({ data: CANDLES }).map((l) => [...l].length));
    expect(widths.size).toBe(1);
  });

  // ── Tonal kinds, never rainbow ────────────────────────────────
  it("renders down candles as dashed outline boxes (┌╌╌┐)", () => {
    const text = plainLines({ data: CANDLES, noColor: true }).join("\n");
    expect(text).toContain("┌╌");
    expect(text).toContain("└╌");
  });

  it("renders up candles solid (▓) and the peak candle solid (█)", () => {
    const text = plainLines({ data: CANDLES, noColor: true }).join("\n");
    expect(text).toContain("▓");
    expect(text).toContain("█");
  });

  it("spends the accent only on the peak body, grey ramp elsewhere", () => {
    const { accent, grey, other } = tonalCensus({ data: CANDLES });
    expect(accent).toBeGreaterThan(0);
    expect(grey).toBeGreaterThan(0);
    expect(other).toBe(0);
  });

  it("peaks on the highest close, ties go to the first candle", () => {
    const tied = [
      { open: 10, high: 12, low: 9, close: 11, label: "A" },
      { open: 9, high: 12, low: 8, close: 11, label: "B" },
    ];
    const theme = resolveTheme("default");
    const raw = candlestick({ data: tied }).toString();
    // Exactly one candle's bodies carry the accent: first-tie wins, so the
    // accent block rows equal A's body rows only.
    const accentBlocks = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)].filter(
      (s) => s[1] === theme.accent && /^█+$/.test(s[2]!.replace(/\s/g, ""))
    );
    expect(accentBlocks.length).toBeGreaterThan(0);
    expect(raw.split("\n").filter((l) => l.includes(theme.accent!)).length).toBeGreaterThan(0);
  });

  it("ties go to the first candle — the SECOND tied candle is never accented", () => {
    const tied = [
      { open: 10, high: 12, low: 9, close: 11, label: "A" },
      { open: 9, high: 12, low: 8, close: 11, label: "B" },
    ];
    const theme = resolveTheme("default");
    const raw = candlestick({ data: tied }).toString();
    const plainLines = stripAnsi(raw).split("\n");

    // Period-label row carries both labels; locate each candle's body column.
    const labelRow = plainLines.find((l) => l.includes("A") && l.includes("B"))!;
    expect(labelRow).toBeTruthy();
    const aCol = labelRow.indexOf("A");
    const bCol = labelRow.indexOf("B");
    expect(bCol).toBeGreaterThan(aCol);
    const candleW = bCol - aCol - 1;

    // Walk each raw line tracking visible columns; collect accent-coloured `█`
    // body cells (accent is spent exactly once, on the peak body).
    const accentCols = new Set<number>();
    const TOKEN = /\x1b\[[0-9;]*m|[^\x1b]+/g;
    for (const line of raw.split("\n")) {
      let col = 0;
      let active = "";
      for (const tok of line.match(TOKEN) ?? []) {
        if (tok.startsWith("\x1b[")) {
          active = tok === "\x1b[0m" ? "" : tok;
          continue;
        }
        if (active === theme.accent && /^█+$/.test(tok)) {
          for (let i = 0; i < tok.length; i++) accentCols.add(col + i);
        }
        col += tok.length;
      }
    }

    expect(accentCols.size).toBeGreaterThan(0);
    // Every accent block sits inside candle A's body span; the second tied
    // candle B stays entirely on the grey ramp (no accent anywhere in its span).
    for (const col of accentCols) {
      expect(col).toBeGreaterThanOrEqual(aCol);
      expect(col).toBeLessThan(aCol + candleW);
    }
    for (const col of [bCol, bCol + candleW - 1]) {
      expect(accentCols.has(col)).toBe(false);
    }
  });

  // ── Adaptive price labels (the S27 precision rule) ───────────
  it("prints integer y-labels when the range spans 100+", () => {
    const wide = [
      { open: 100, high: 500, low: 50, close: 450, label: "W" },
      { open: 450, high: 480, low: 200, close: 300, label: "X" },
    ];
    const lines = plainLines({ data: wide, noColor: true });
    let labels = 0;
    for (const line of lines) {
      const m = line.match(/^│ (\s*\S*)([+│])/);
      if (!m) continue;
      labels++;
      expect(m[1]).not.toContain(".");
    }
    expect(labels).toBeGreaterThanOrEqual(3);
  });

  it("never prints float sprawl on tight prices (≤2dp, trimmed)", () => {
    const lines = plainLines({ data: CANDLES, noColor: true });
    let labels = 0;
    for (const line of lines) {
      const m = line.match(/^│ (\s*\S*)([+│])/);
      if (!m || !m[1]?.trim()) continue;
      labels++;
      expect(m[1]?.trim()).toMatch(/^-?\d+(\.\d{1,2})?$/);
    }
    expect(labels).toBeGreaterThanOrEqual(3);
  });

  // ── Foot facts ────────────────────────────────────────────────
  it("reports candles · high · low · last facts, last accented", () => {
    const theme = resolveTheme("default");
    const raw = candlestick({ data: CANDLES }).toString();
    const foot = raw.split("\n").find((l) => l.includes("last "))!;
    expect(foot).toBeDefined();
    expect(foot.includes(theme.accent!)).toBe(true);
    const text = stripAnsi(raw);
    expect(text).toContain("3 candles");
    expect(text).toContain("high 115");
    expect(text).toContain("low 95");
    expect(text).toContain("last 107");
  });

  // ── Degenerate-safe ───────────────────────────────────────────
  it("renders empty data as a framed 0 candles · (no data) panel", () => {
    const c = candlestick({ data: [] });
    const text = c.toPlain();
    expect(text).toMatch(/^┌╌/);
    expect(text).toContain("0 candles · (no data)");
    expect(text).not.toContain("NaN");
    expect(text).not.toContain("Infinity");
    const j = c.toJSON() as Record<string, unknown>;
    expect(j.count).toBe(0);
    expect(j.high).toBeNull();
    expect(j.low).toBeNull();
    expect(j.last).toBeNull();
  });

  it("renders a flat range with visible candles (never NaN rows)", () => {
    const flat = [{ open: 50, high: 50, low: 50, close: 50, label: "F" }];
    const c = candlestick({ data: flat, noColor: true });
    expect(c.toPlain()).not.toContain("NaN");
    expect(c.toPlain()).toContain("█");
  });

  it("excludes non-finite candles, never plots them", () => {
    const mixed = [
      { open: 100, high: 110, low: 95, close: 105, label: "Ok" },
      { open: NaN, high: Infinity, low: -Infinity, close: NaN, label: "Bad" },
    ];
    const c = candlestick({ data: mixed, noColor: true });
    expect(c.toPlain()).not.toContain("NaN");
    expect(c.toPlain()).not.toContain("Infinity");
    expect((c.toJSON() as Record<string, unknown>).count).toBe(1);
  });

  it("never RangeErrors on narrow widths", () => {
    const c = candlestick({ data: CANDLES, width: 10, noColor: true });
    expect(c.toPlain()).toMatch(/^┌╌/);
    expect(c.toPlain()).not.toContain("NaN");
  });

  // ── Agent surface ─────────────────────────────────────────────
  it("toJSON carries additive high/low/last/count facts", () => {
    const j = candlestick({ data: CANDLES }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("candlestick");
    expect(j.count).toBe(3);
    expect(j.high).toBe(115);
    expect(j.low).toBe(95);
    expect(j.last).toBe(107);
  });

  it("keeps the legacy surface: renders truthy", () => {
    expect(
      candlestick({
        data: [
          { open: 100, high: 110, low: 95, close: 105, label: "Day1" },
          { open: 105, high: 115, low: 100, close: 98, label: "Day2" },
        ],
      }).toString()
    ).toBeTruthy();
  });
});
