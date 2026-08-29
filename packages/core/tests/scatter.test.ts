import { describe, it, expect } from "vitest";
import { scatter } from "../src/charts/scatter.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme } from "../src/themes/index.js";
import { GREY_TONES } from "../src/themes/index.js";

const DATA = [
  { x: 1, y: 2 },
  { x: 2, y: 4 },
  { x: 3, y: 3 },
  { x: 4, y: 7 },
  { x: 5, y: 5 },
  { x: 6, y: 9 },
  { x: 7, y: 6 },
  { x: 10, y: 12 },
];

function plainLines(opts: Parameters<typeof scatter>[0]): string[] {
  return stripAnsi(scatter(opts).toString()).split("\n");
}

// A plot glyph is a braille cell or one of the scatter marker glyphs.
const GLYPH = /[⠁-⣿●○◆◇▲△]/;

/** Count coloured plot glyphs by category: how many carry the accent code vs a
 *  grey-ramp code vs anything else. This is the S134 RGB method — the accent
 *  must be spent exactly ONCE and every other point must be a documented grey. */
function accentCensus(opts: Parameters<typeof scatter>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const acc = theme.accent!;
  const out = scatter(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    for (const ch of body) {
      if (!GLYPH.test(ch)) continue;
      if (code === acc) accent++;
      else if (GREY_TONES.includes(code)) grey++;
      else other++;
    }
  }
  return { accent, grey, other };
}

describe("scatter chart — locked S17 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    expect(plainLines({ data: DATA })[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ data: DATA });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has two frame rule separators (│ ╌)", () => {
    const rules = plainLines({ data: DATA }).filter((l) => /^│ ╌/.test(l));
    expect(rules.length).toBe(2);
  });

  it("has eyebrow row (uppercase CORRELATION by default)", () => {
    expect(stripAnsi(scatter({ data: DATA }).toString())).toMatch(/CORRELATION/);
  });

  it("honours an eyebrow override", () => {
    expect(stripAnsi(scatter({ data: DATA, eyebrow: "signal" }).toString())).toMatch(/SIGNAL/);
  });

  it("has the +/│ y-guide (+ on the top plot row, │ below)", () => {
    const plain = stripAnsi(scatter({ data: DATA }).toString());
    expect(plain).toMatch(/\d\+/); // a y-label followed by + on the top row
    expect(plain).toMatch(/\d│/); // a y-label followed by │ elsewhere
  });

  // ── Summary footer ────────────────────────────────────────────
  it("footer reports n · x-range · y-range · peak", () => {
    const plain = stripAnsi(scatter({ data: DATA }).toString());
    expect(plain).toMatch(/n 8 · x 1\.\.10 · y 2\.\.12 · peak \(10, 12\)/);
  });

  it("does NOT report a Pearson r / correlation coefficient by default", () => {
    // The eyebrow caption CORRELATION is fine; a numeric `r=` coefficient is not.
    const plain = stripAnsi(scatter({ data: DATA }).toString()).toLowerCase();
    expect(plain).not.toMatch(/\br\s*=\s*-?[0-9.]/);
    expect(plain).not.toMatch(/pearson|coefficient|\bρ\b/);
  });

  // ── The one accent, spent once (S134 RGB method) ──────────────
  it("spends the accent hue EXACTLY once — braille path (no rainbow leak)", () => {
    const c = accentCensus({ data: DATA, renderer: "braille" });
    expect(c.accent).toBe(1);
    expect(c.other).toBe(0); // every non-accent point is a documented grey tone
    expect(c.grey).toBeGreaterThan(0);
  });

  it("spends the accent hue EXACTLY once — blocks path (no rainbow leak)", () => {
    const c = accentCensus({ data: DATA, renderer: "blocks" });
    expect(c.accent).toBe(1);
    expect(c.other).toBe(0);
    expect(c.grey).toBeGreaterThan(0);
  });

  it("accent follows the primary series max-y point, not the global max", () => {
    // series 0's max-y is (2,5); series 1 has a higher point (9,20) but is NOT primary.
    const multi = [
      [
        { x: 1, y: 1 },
        { x: 2, y: 5 },
      ],
      [
        { x: 9, y: 20 },
        { x: 8, y: 3 },
      ],
    ];
    const plain = stripAnsi(scatter({ data: multi }).toString());
    expect(plain).toMatch(/peak \(2, 5\)/);
  });

  it("respects an explicit highlight override", () => {
    const plain = stripAnsi(scatter({ data: DATA, highlight: 0 }).toString());
    expect(plain).toMatch(/peak \(1, 2\)/); // index 0 = (1,2), not the max-y (10,12)
  });

  // ── Degenerate data is safe ───────────────────────────────────
  it("empty data renders a framed n 0 panel with no Infinity/NaN", () => {
    const plain = stripAnsi(scatter({ data: [] }).toString());
    expect(plain).toMatch(/n 0/);
    expect(plain).not.toMatch(/Infinity|NaN/);
  });

  it("a single point renders honestly (collapsed range, itself as peak)", () => {
    const plain = stripAnsi(scatter({ data: [{ x: 3, y: 5 }] }).toString());
    expect(plain).toMatch(/n 1 · x 3\.\.3 · y 5\.\.5 · peak \(3, 5\)/);
    expect(plain).not.toMatch(/NaN/);
  });
});
