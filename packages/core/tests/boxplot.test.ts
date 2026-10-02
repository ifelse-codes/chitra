import { describe, it, expect } from "vitest";
import { boxplot } from "../src/charts/boxplot.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const DATA = [
  [1, 2, 3, 4, 5, 6, 7, 8, 9],
  [2, 3, 4, 5, 6],
  [10, 12, 14, 16, 18, 20, 22],
];
const LABELS = ["A", "B", "C"];

function plainLines(opts: Parameters<typeof boxplot>[0]): string[] {
  return stripAnsi(boxplot(opts).toString()).split("\n");
}

// A group column is box edges (│), shade/`█` fill (░▒▓█), whiskers/caps
// (│┬┴), and the horizontal median run (───/═══). The peak group takes the
// accent; every other group sits on the grey tone ramp.
const BOX = /[│┬┴─═░▒▓█]/;

/** Count coloured BOX segments by category (the S17 raw-ANSI census method).
 *  The accent must touch peak-group mass only, every grey segment must be a
 *  documented tone (no `theme.colors[si % n]` rainbow). */
function tonalCensus(opts: Parameters<typeof boxplot>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const out = boxplot(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    // Axis-coloured structure (frame, guides, baseline) is never box mass.
    if (code === theme.axis) continue;
    if (!BOX.test(body)) continue; // count box segments only, not labels/footer
    if (/[A-Za-z0-9]/.test(body)) continue; // skip text runs that share a line
    if (code === theme.accent) accent++;
    else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("boxplot chart — locked S27 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    expect(plainLines({ data: DATA, labels: LABELS })[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ data: DATA, labels: LABELS });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has one frame rule separator (│ ╌)", () => {
    const rules = plainLines({ data: DATA, labels: LABELS }).filter((l) => /^│ ╌+ │$/.test(l));
    expect(rules.length).toBe(1);
  });

  it("carries the SPREAD eyebrow row", () => {
    expect(plainLines({ data: DATA, labels: LABELS })).toContainEqual(
      expect.stringContaining("SPREAD")
    );
  });

  it("titles the frame BOXPLOT by default", () => {
    expect(plainLines({ data: DATA, labels: LABELS })[0]).toContain("BOXPLOT");
  });

  it("keeps every panel row the same visible width", () => {
    const widths = new Set(plainLines({ data: DATA, labels: LABELS }).map((l) => [...l].length));
    expect(widths.size).toBe(1);
  });

  // ── Tonal groups, never rainbow ───────────────────────────────
  it("spends the accent on the peak group, grey ramp elsewhere", () => {
    const { accent, grey, other } = tonalCensus({ data: DATA, labels: LABELS });
    expect(accent).toBeGreaterThan(0);
    expect(grey).toBeGreaterThan(0);
    expect(other).toBe(0);
  });

  it("peaks on the highest median, ties go to the first group", () => {
    const j = boxplot({
      data: [
        [1, 2, 3],
        [1, 2, 3],
      ],
      labels: ["P", "Q"],
    }).toJSON() as Record<string, unknown>;
    expect(j.peakGroup).toMatchObject({ label: "P", index: 0, median: 2 });
  });

  it("keeps the median marker visually distinct from the box edges", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    // Horizontal median runs (───/═══) vs vertical box edges (│).
    expect(text).toMatch(/───|═══/);
    expect(text).toContain("│");
  });

  it("gives non-peak boxes shade texture (░▒▓) and the peak a solid (█) fill", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    expect(text).toMatch(/[░▒▓]/);
    expect(text).toContain("█");
  });

  // ── Foot facts ────────────────────────────────────────────────
  it("reports groups · median · peak facts, peak accented", () => {
    const theme = resolveTheme("default");
    const raw = boxplot({ data: DATA, labels: LABELS }).toString();
    const foot = raw.split("\n").find((l) => l.includes("peak "))!;
    expect(foot).toBeDefined();
    expect(foot.includes(theme.accent!)).toBe(true);
    const text = stripAnsi(raw);
    expect(text).toContain("3 groups");
    expect(text).toContain("peak C (16)");
  });

  // ── Degenerate-safe ───────────────────────────────────────────
  it("renders empty data as a framed 0 groups · (no data) panel", () => {
    const b = boxplot({ data: [] });
    const text = b.toPlain();
    expect(text).toMatch(/^┌╌/);
    expect(text).toContain("0 groups · (no data)");
    expect(text).not.toContain("NaN");
    const j = b.toJSON() as Record<string, unknown>;
    expect(j.stats).toBeNull();
    expect(j.peakGroup).toBeNull();
  });

  it("renders single-value groups safely (flat-range guard, never NaN)", () => {
    const b = boxplot({ data: [[5], [5], [5]], labels: ["X", "Y", "Z"], noColor: true });
    expect(b.toPlain()).not.toContain("NaN");
    expect(b.toPlain()).toMatch(/───|═══/);
  });

  it("excludes non-finite samples before quartiles(), never plots them", () => {
    const b = boxplot({ data: [[1, 2, NaN, Infinity, 3]], labels: ["M"], noColor: true });
    expect(b.toPlain()).not.toContain("NaN");
    expect(b.toPlain()).not.toContain("Infinity");
    const j = b.toJSON() as Record<string, unknown>;
    expect(j.stats).not.toBeNull();
  });

  it("never RangeErrors on narrow widths", () => {
    const b = boxplot({ data: DATA, labels: LABELS, width: 10, noColor: true });
    expect(b.toPlain()).toMatch(/^┌╌/);
    expect(b.toPlain()).not.toContain("NaN");
  });

  // ── Agent surface ─────────────────────────────────────────────
  it("toJSON carries stats plus the additive peakGroup fact", () => {
    const j = boxplot({ data: DATA, labels: LABELS }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("boxplot");
    expect(Array.isArray(j.stats)).toBe(true);
    expect(j.peakGroup).toMatchObject({ label: "C", index: 2, median: 16 });
  });

  it("keeps the legacy surface: renders truthy, toJSON has stats", () => {
    expect(
      boxplot({ data: [1, 3, 5, 7, 9, 2, 4, 6, 8, 10], labels: ["Data"] }).toString()
    ).toBeTruthy();
    expect(
      Array.isArray((boxplot({ data: [1, 2, 3, 4, 5] }).toJSON() as Record<string, unknown>).stats)
    ).toBe(true);
  });
});
