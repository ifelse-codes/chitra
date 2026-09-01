import { describe, it, expect } from "vitest";
import { heatmap } from "../src/charts/heatmap.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const DATA = [
  [1, 3, 5, 7, 9],
  [2, 4, 6, 8, 10],
  [3, 5, 7, 9, 11],
  [4, 6, 8, 10, 12],
];

function plainLines(opts: Parameters<typeof heatmap>[0]): string[] {
  return stripAnsi(heatmap(opts).toString()).split("\n");
}

// A heatmap cell is one of the grey-ramp shade glyphs or the accent block.
const CELL = /[░▒▓█]/;

/** Count coloured CELL segments by category: how many carry the accent code vs
 *  a grey-ramp code vs anything else. This is the S17 raw-ANSI census method —
 *  the accent must be spent on EXACTLY one cell (one segment), and every other
 *  cell must be a documented grey tone (never a `theme.colors[i % n]` rainbow). */
function accentCensus(opts: Parameters<typeof heatmap>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const acc = theme.accent!;
  const out = heatmap(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    if (!CELL.test(body)) continue; // count cell segments only, not labels/footer
    if (code === acc) accent++;
    else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("heatmap chart — locked S18 design", () => {
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

  it("has the uppercase eyebrow row (DENSITY)", () => {
    expect(stripAnsi(heatmap({ data: DATA }).toString())).toMatch(/DENSITY/);
  });

  it("has the +/│ y-guide (+ on the top grid row, │ below)", () => {
    const plain = stripAnsi(heatmap({ data: DATA }).toString());
    expect(plain).toMatch(/\d\+[░▒▓█]/); // a y-label, + on the top row, then a cell
    expect(plain).toMatch(/\d│[░▒▓█]/); // a y-label, │ elsewhere, then a cell
  });

  // ── Summary footer ────────────────────────────────────────────
  it("footer reports rows×cols · min..max · peak (r, c)", () => {
    const plain = stripAnsi(heatmap({ data: DATA }).toString());
    expect(plain).toMatch(/4×5 · 1\.\.12 · peak \(3, 4\)/);
  });

  // ── The one accent, spent once on the max cell (S17 RGB method) ─
  it("spends the accent hue EXACTLY once — on a single cell, no rainbow leak", () => {
    const c = accentCensus({ data: DATA });
    expect(c.accent).toBe(1);
    expect(c.other).toBe(0); // every non-accent cell is a documented grey tone
    expect(c.grey).toBeGreaterThan(0);
  });

  it("intensity encoding IS the documented grey tone ramp (light → dark)", () => {
    // The four documented greys must all appear across a graded grid, and no
    // other hue may — the ramp is the intensity encoding, not a colour wheel.
    const acc = resolveTheme(undefined).accent!;
    const out = heatmap({ data: DATA }).toString();
    const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
    const cellCodes = new Set(
      segs.filter((s) => CELL.test(s[2]!)).map((s) => s[1]!)
    );
    for (const code of cellCodes) {
      expect(code === acc || GREY_TONES.includes(code)).toBe(true);
    }
    // both ends of the ramp are exercised by a 1..12 gradient
    expect(cellCodes.has(GREY_TONES[0]!)).toBe(true); // lightest
    expect(cellCodes.has(GREY_TONES[GREY_TONES.length - 1]!)).toBe(true); // darkest
  });

  it("accent lands on the max-value cell (ties → first in row-major order)", () => {
    // Two cells share the maximum 9; the accent must mark the FIRST (0,2).
    const tie = [
      [1, 2, 9],
      [9, 3, 4],
    ];
    const plain = stripAnsi(heatmap({ data: tie }).toString());
    expect(plain).toMatch(/peak \(0, 2\)/);
    expect(accentCensus({ data: tie }).accent).toBe(1);
  });

  // ── Degenerate data is safe ───────────────────────────────────
  it("empty data renders a framed n 0 panel with no Infinity/NaN", () => {
    const plain = stripAnsi(heatmap({ data: [] }).toString());
    expect(plain).toMatch(/n 0/);
    expect(plain).not.toMatch(/Infinity|NaN/);
    expect(plain).toMatch(/^┌╌/m);
    expect(plain).toMatch(/^└╌/m);
  });

  it("an all-equal grid renders honestly with a collapsed range", () => {
    const plain = stripAnsi(heatmap({ data: [[5, 5], [5, 5]] }).toString());
    expect(plain).toMatch(/2×2 · 5\.\.5 · peak \(0, 0\)/);
    expect(plain).not.toMatch(/NaN|Infinity/);
    // even with zero variance the accent is still spent exactly once
    expect(accentCensus({ data: [[5, 5], [5, 5]] }).accent).toBe(1);
  });

  it("noColor renders plain shade glyphs and no escape codes", () => {
    const out = heatmap({ data: DATA, noColor: true }).toString();
    expect(out).not.toMatch(/\x1b\[/);
    expect(out).toMatch(/[░▒▓█]/);
  });
});
