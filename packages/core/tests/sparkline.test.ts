import { describe, it, expect } from "vitest";
import { sparkline } from "../src/charts/sparkline.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const theme = resolveTheme("default");

// Raw-ANSI census over strip glyph segments (no alphanumerics): every
// shaded cell must be accent (peak) or grey ramp — the old single-teal
// theme.colors[0] flood and any other hue fail the census.
function census(raw: string): { accent: number; grey: number; other: number } {
  const segs = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0, grey = 0, other = 0;
  for (const s of segs) {
    const code = s[1]!, body = s[2]!;
    if (code === theme.axis) continue;
    if (!/[░▒▓█]/.test(body)) continue;
    if (/[A-Za-z0-9]/.test(body)) continue;
    if (code === theme.accent) accent++;
    else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("sparkline (S28 LOCKED)", () => {
  it("renders the locked panel: dashed frame, eyebrow, 1 rule, uniform width", () => {
    const lines = stripAnsi(
      sparkline({ data: [1, 3, 2, 5, 4], noColor: true }).toString()
    ).split("\n");
    expect(lines[0]).toMatch(/^┌╌/);
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
    expect(lines.filter((l) => /^│ ╌+ │$/.test(l))).toHaveLength(1);
    expect(lines.some((l) => l.includes("SPARKLINE"))).toBe(true);
    expect(new Set(lines.map((l) => [...l].length)).size).toBe(1);
  });

  it("carries the label on the frame top", () => {
    const first = stripAnsi(
      sparkline({ data: [1, 2, 3], label: "CPU", noColor: true }).toString()
    ).split("\n")[0]!;
    expect(first).toContain("CPU");
  });

  it("foot reports C readings · peak with the peak accented", () => {
    const raw = sparkline({ data: [1, 3, 2, 5, 4] }).toString();
    const foot = raw.split("\n").find((l) => l.includes("peak "))!;
    expect(stripAnsi(foot)).toContain("5 readings · peak 5");
    expect(foot).toContain(theme.accent!);
  });

  it("spends the accent exactly on the peak column; grey ramp elsewhere; no teal flood", () => {
    const raw = sparkline({ data: [1, 3, 2, 5, 4] }).toString();
    const { accent, grey, other } = census(raw);
    expect(other).toBe(0);
    expect(accent).toBeGreaterThan(0);
    expect(grey).toBeGreaterThan(0);
    // Peak (max 5) renders full height: one solid accent "██" segment per
    // strip row (ROWS=4). A dark-grey non-peak █ is grey, never accent.
    const accentSolids = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)].filter(
      (s) => s[1] === theme.accent && /^█+$/.test(s[2])
    );
    expect(accentSolids).toHaveLength(4);
  });

  it("resolves peak ties to the first reading (accent exclusivity)", () => {
    const json = sparkline({ data: [5, 1, 5], noColor: true }).toJSON() as Record<string, unknown>;
    expect((json.peak as Record<string, unknown>).index).toBe(0);
    const raw = sparkline({ data: [5, 1, 5] }).toString();
    const accentSolids = [...raw.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)].filter(
      (s) => s[1] === theme.accent && /^█+$/.test(s[2])
    );
    // Peak at full height once; the tied second 5 stays on the ramp.
    expect(accentSolids).toHaveLength(4);
  });

  it("keeps shade texture through noColor (░▒▓ survive stripAnsi)", () => {
    const text = stripAnsi(sparkline({ data: [1, 3, 2, 5, 4], noColor: true }).toString());
    expect(text).toMatch(/[░▒▓]/);
  });

  it("renders a framed no-data panel with null facts on empty input", () => {
    const empty = sparkline({ data: [] });
    expect(empty.toPlain()).toContain("0 readings · (no data)");
    expect(empty.toPlain().startsWith("┌╌")).toBe(true);
    const j = empty.toJSON() as Record<string, unknown>;
    expect(j.count).toBe(0);
    expect(j.min).toBeNull();
    expect(j.max).toBeNull();
    expect(j.last).toBeNull();
    expect(j.peak).toBeNull();
  });

  it("excludes non-finite samples from plot, facts, and count", () => {
    const r = sparkline({ data: [1, NaN, 2, Infinity, 3], noColor: true });
    expect(r.toPlain()).not.toMatch(/NaN|Infinity/);
    const j = r.toJSON() as Record<string, unknown>;
    expect(j.count).toBe(3);
    expect(j.max).toBe(3);
  });

  it("renders a flat range honestly (full columns, no crash)", () => {
    const text = stripAnsi(sparkline({ data: [7, 7, 7], noColor: true }).toString());
    expect(text).not.toContain("NaN");
    expect(text).toContain("█");
  });

  it("accepts renderer but renders the same locked design (superseded)", () => {
    const base = stripAnsi(sparkline({ data: [1, 3, 2, 5, 4], noColor: true }).toString());
    for (const renderer of ["blocks", "braille", "ascii"] as const) {
      expect(stripAnsi(sparkline({ data: [1, 3, 2, 5, 4], renderer, noColor: true }).toString())).toBe(base);
    }
  });

  it("keeps width as plotted columns (downsamples deterministically)", () => {
    const text = stripAnsi(
      sparkline({ data: [1, 2, 3, 4, 5, 6, 7, 8], width: 4, noColor: true }).toString()
    );
    const rows = text.split("\n");
    const strip = rows.filter((l) => /[░▒▓█]/.test(l));
    expect(strip).toHaveLength(4);
    // Bottom strip row is always full: 4 columns × CELLW 2, then frame pad.
    const bottom = strip[strip.length - 1]!.replace(/^│ /, "").replace(/ │$/, "").trimEnd();
    expect([...bottom].length).toBe(8);
    const again = stripAnsi(
      sparkline({ data: [1, 2, 3, 4, 5, 6, 7, 8], width: 4, noColor: true }).toString()
    );
    expect(again).toBe(text);
  });

  it("showValue:false keeps the takeaway-only footer", () => {
    const text = stripAnsi(
      sparkline({ data: [1, 3, 2, 5, 4], showValue: false, noColor: true }).toString()
    );
    expect(text).not.toContain("last");
    expect(text).toContain("5 readings · peak 5");
  });

  it("toJSON is additive (legacy keys kept, facts added)", () => {
    const j = sparkline({ data: [1, 2, 42], label: "CPU" }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("sparkline");
    expect(j.data).toEqual([1, 2, 42]);
    expect(j.label).toBe("CPU");
    expect(j.count).toBe(3);
    expect(j.min).toBe(1);
    expect(j.max).toBe(42);
    expect(j.last).toBe(42);
    expect(j.peak).toEqual({ index: 2, value: 42 });
    expect(typeof j.plain).toBe("string");
  });

  it("toMarkdown uses a fenced block", () => {
    const md = sparkline({ data: [1, 2, 3] }).toMarkdown();
    expect(md.startsWith("```\n")).toBe(true);
    expect(md).toContain("SPARKLINE");
  });

  it("stays safe on narrow width", () => {
    const text = stripAnsi(sparkline({ data: [1, 2, 3], width: 1, noColor: true }).toString());
    expect(text.startsWith("┌╌")).toBe(true);
  });
});
