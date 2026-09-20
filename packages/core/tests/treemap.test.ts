import { describe, it, expect } from "vitest";
import { treemap } from "../src/charts/treemap.js";
import { stripAnsi, hexToAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const DATA = [
  { label: "TS", value: 45 },
  { label: "Python", value: 30 },
  { label: "Rust", value: 15 },
  { label: "Go", value: 7 },
  { label: "Ruby", value: 3 },
];

function plainLines(opts: Parameters<typeof treemap>[0]): string[] {
  return stripAnsi(treemap(opts).toString()).split("\n");
}

// A treemap cell is one of the grey-ramp shade glyphs or the accent block.
const CELL = /[░▒▓█]/;

/** Count coloured CELL segments by category: how many carry the accent code vs
 *  a grey-ramp code vs anything else. The accent must land on the peak node
 *  (one or more segments — a region, not a single cell) and every other cell
 *  must be a documented grey tone (never a `theme.colors[i % n]` rainbow). */
function accentCensus(opts: Parameters<typeof treemap>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const acc = theme.accent!;
  const out = treemap(opts).toString();
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

describe("treemap chart — locked S20 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    expect(plainLines({ data: DATA })[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ data: DATA });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has one frame rule separator (│ ╌)", () => {
    const rules = plainLines({ data: DATA }).filter((l) => /^│ ╌/.test(l));
    expect(rules.length).toBe(1);
  });

  it("has the uppercase eyebrow row (AREA)", () => {
    expect(stripAnsi(treemap({ data: DATA }).toString())).toMatch(/AREA/);
  });

  it("has the +/│ left guide (+ on the top plot row, │ below)", () => {
    const plotRows = plainLines({ data: DATA }).filter((l) => /^│ [+│]/.test(l) && CELL.test(l));
    expect(plotRows.length).toBeGreaterThan(1);
    expect(plotRows[0]).toMatch(/^│ \+/);
    for (const row of plotRows.slice(1)) {
      expect(row).toMatch(/^│ │/);
    }
  });

  it("includes title in frame top when provided", () => {
    const plain = stripAnsi(treemap({ data: DATA, title: "Codebase" }).toString());
    expect(plain).toContain("Codebase");
  });

  // ── Summary footer ────────────────────────────────────────────
  it("footer reports N leaves · peak <label>", () => {
    const plain = stripAnsi(treemap({ data: DATA }).toString());
    expect(plain).toMatch(/5 leaves · peak TS/);
  });

  // ── The one accent, spent on the max node (S18 RGB method) ────
  it("spends the accent hue on the peak node — no rainbow leak", () => {
    const c = accentCensus({ data: DATA });
    expect(c.accent).toBeGreaterThan(0);
    expect(c.other).toBe(0); // every non-accent cell is a documented grey tone
    expect(c.grey).toBeGreaterThan(0);
  });

  it("the ramp is the LITERAL documented greyscale (pinned to spec hexes)", () => {
    expect(GREY_TONES).toEqual(
      ["#ECECEF", "#C6C6CE", "#A4A4AE", "#6A6A75"].map(hexToAnsi)
    );
  });

  it("intensity encoding IS the documented grey tone ramp (light → dark)", () => {
    const acc = resolveTheme(undefined).accent!;
    const out = treemap({ data: DATA }).toString();
    const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
    const cellCodes = new Set(
      segs.filter((s) => CELL.test(s[2]!)).map((s) => s[1]!)
    );
    for (const code of cellCodes) {
      expect(code === acc || GREY_TONES.includes(code)).toBe(true);
    }
    expect(cellCodes.has(GREY_TONES[0]!)).toBe(true); // lightest
    expect(cellCodes.has(GREY_TONES[GREY_TONES.length - 1]!) || cellCodes.has(acc)).toBe(true);
  });

  it("accent lands on the max-value node (ties → first in data order)", () => {
    const tie = [
      { label: "First", value: 9 },
      { label: "Second", value: 9 },
      { label: "Low", value: 1 },
    ];
    const plain = stripAnsi(treemap({ data: tie }).toString());
    expect(plain).toMatch(/peak First/);
    expect(plain).not.toMatch(/peak Second/);
    expect(accentCensus({ data: tie }).accent).toBeGreaterThan(0);
    expect(accentCensus({ data: tie }).other).toBe(0);
  });

  it("slivers stay clean blocks — labels only where they fit whole", () => {
    const plain = stripAnsi(treemap({ data: DATA, width: 50, height: 10 }).toString());
    expect(plain).toMatch(/TS/);
    expect(plain).toMatch(/Python/);
    expect(plain).toMatch(/Rust/);
    expect(plain).not.toMatch(/…/); // no truncated-label noise in slivers
    expect(plain).toMatch(/5 leaves · peak TS/); // all five leaves still laid out
  });

  it("nested children flatten; peak is the max leaf (first in flatten order)", () => {
    const nested = [
      { label: "Lang", value: 10, children: [
        { label: "TS", value: 8 },
        { label: "Go", value: 2 },
      ]},
      { label: "Docs", value: 5 },
    ];
    const plain = stripAnsi(treemap({ data: nested }).toString());
    expect(plain).toMatch(/3 leaves · peak TS/);
  });

  // ── Degenerate data is safe ───────────────────────────────────
  it("empty data renders a framed 0 leaves panel with no Infinity/NaN", () => {
    const plain = stripAnsi(treemap({ data: [] }).toString());
    expect(plain).toMatch(/0 leaves · \(no data\)/);
    expect(plain).not.toMatch(/Infinity|NaN/);
    expect(plain).toMatch(/^┌╌/m);
    expect(plain).toMatch(/^└╌/m);
  });

  it("an all-equal set renders honestly with a collapsed range", () => {
    const data = [
      { label: "A", value: 5 },
      { label: "B", value: 5 },
    ];
    const plain = stripAnsi(treemap({ data }).toString());
    expect(plain).toMatch(/2 leaves · peak A/);
    expect(plain).not.toMatch(/NaN|Infinity/);
    expect(accentCensus({ data }).accent).toBeGreaterThan(0);
    expect(accentCensus({ data }).other).toBe(0);
  });

  it("a single node renders safely with the accent spent on it", () => {
    const data = [{ label: "Only", value: 12 }];
    const plain = stripAnsi(treemap({ data }).toString());
    expect(plain).toMatch(/1 leaves · peak Only/);
    expect(accentCensus({ data }).accent).toBeGreaterThan(0);
    expect(accentCensus({ data }).other).toBe(0);
  });

  it("noColor renders plain shade glyphs and no escape codes", () => {
    const out = treemap({ data: DATA, noColor: true }).toString();
    expect(out).not.toMatch(/\x1b\[/);
    expect(out).toMatch(/[░▒▓█]/);
  });

  it("empty cells are SPACE — no phantom filler outside the shade ramp", () => {
    const vacant = treemap({ data: [], width: 50, height: 10, noColor: true }).toString();
    expect(vacant).not.toMatch(/[░▒▓█]/); // vacant canvas: zero cells, framed 0 leaves only
    expect(vacant).toMatch(/0 leaves/);
    const out = treemap({ data: DATA, width: 50, height: 10, noColor: true }).toString();
    expect(out).toContain("░"); // lightest ramp glyph is legal fill, not phantom
    expect(out).not.toContain("⠀"); // braille-blank phantom never
    const plotRows = out.split("\n").filter((l) => /[░▒▓█]/.test(l));
    expect(plotRows.length).toBeGreaterThan(0);
    for (const row of plotRows) {
      // strip labels/values, guide +/│ and frame — residue must be ramp-or-SPACE only
      const residue = row.replace(/[A-Za-z0-9 +.,_…\-│┌┐└┘╌]/g, "");
      expect(residue).toMatch(/^[░▒▓█]*$/);
    }
  });

  it("toJSON reports n / min / max / peak", () => {
    const j = treemap({ data: DATA }).toJSON() as {
      type: string;
      n: number;
      min: number;
      max: number;
      peak: { label: string; value: number } | null;
    };
    expect(j.type).toBe("treemap");
    expect(j.n).toBe(5);
    expect(j.min).toBe(3);
    expect(j.max).toBe(45);
    expect(j.peak).toEqual({ label: "TS", value: 45 });
  });
});
