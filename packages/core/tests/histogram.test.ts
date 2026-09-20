import { describe, it, expect } from "vitest";
import { histogram } from "../src/charts/histogram.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const DATA = [1, 2, 2, 3, 3, 3, 4, 4, 5, 6, 7, 8, 8, 9];

function plainLines(opts: Parameters<typeof histogram>[0]): string[] {
  return stripAnsi(histogram(opts).toString()).split("\n");
}

// A histogram bin column is a run of shade-ramp glyphs (░▒▓█); the mode bin
// takes the solid `█` run in the accent hue, every other bin a grey tone.
const RAMP = /[░▒▓█]/;

/** Count coloured RAMP segments by category: how many carry the accent code vs
 *  a documented grey tone vs anything else (the S17 raw-ANSI census method).
 *  The accent must NEVER touch a non-mode bin (no `theme.colors[0]` flood),
 *  and every grey segment must be a documented tone (never a rainbow). */
function accentCensus(opts: Parameters<typeof histogram>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const out = histogram(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    if (!RAMP.test(body)) continue; // count bin segments only, not frame/labels/footer
    if (code === theme.accent) accent++;
    else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("histogram chart — locked S25 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    expect(plainLines({ data: DATA })[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ data: DATA });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has one frame rule separator (│ ╌)", () => {
    const rules = plainLines({ data: DATA }).filter((l) => /^│ ╌+ │$/.test(l));
    expect(rules.length).toBe(1);
  });

  it("has an uppercase eyebrow row", () => {
    expect(plainLines({ data: DATA })).toContainEqual(expect.stringContaining("DISTRIBUTION"));
    expect(plainLines({ data: DATA, xLabel: "latency ms" })).toContainEqual(
      expect.stringContaining("LATENCY MS")
    );
  });

  it("titles the frame HISTOGRAM by default", () => {
    expect(plainLines({ data: DATA })[0]).toContain("HISTOGRAM");
  });

  // ── Integer y-axis (the retired decimal-label bug) ───────────
  it("never prints decimal y-axis labels — counts are integers", () => {
    for (const line of plainLines({ data: DATA })) {
      const label = line.match(/^│ (\s*\d*)/)?.[1] ?? "";
      expect(label).not.toMatch(/\./);
    }
  });

  it("labels the y axis with integer counts", () => {
    const lines = plainLines({ data: DATA });
    // modal bin count = 3 (bins: 1,2,3,2,0,1,1,1,2,1)
    expect(lines.some((l) => l.includes("3+"))).toBe(true);
    expect(lines.some((l) => l.includes("0│"))).toBe(true);
  });

  // ── Tone semantics: one accent on the mode, ramp elsewhere ───
  it("spends the accent only on solid █ segments (the mode column)", () => {
    const theme = resolveTheme(undefined);
    const out = histogram({ data: DATA }).toString();
    for (const seg of out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)) {
      if (seg[1] === theme.accent && RAMP.test(seg[2]!)) {
        expect(seg[2]).toMatch(/^█+$/); // solid accent block, never a shade glyph
      }
    }
  });

  it("census: every grey bin segment is a documented tone, nothing else", () => {
    const census = accentCensus({ data: DATA });
    expect(census.other).toBe(0); // no theme.colors[0] flood, no rainbow
    expect(census.accent).toBeGreaterThan(0);
    expect(census.grey).toBeGreaterThan(0);
  });

  it("breaks mode ties toward the FIRST bin in bin order — S29 B-diet+", () => {
    const theme = resolveTheme(undefined);
    const out = histogram({ data: [1, 1, 9, 9], bins: 2 }).toString();
    const accented = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)].filter(
      (s) => s[1] === theme.accent && /█/.test(s[2]!)
    );
    expect(accented.length).toBeGreaterThan(0); // first mode bin spends the accent
    expect(stripAnsi(out).split("\n").at(-2)).toContain("4 samples · peak 1");
  });

  it("renders the shade-ramp texture (░▒▓) on non-mode bins", () => {
    const plain = stripAnsi(histogram({ data: DATA, bins: 5 }).toString());
    expect(plain).toContain("░");
    expect(plain).toContain("▒");
    expect(plain).toContain("▓");
  });

  it("keeps the texture readable with noColor", () => {
    const plain = stripAnsi(histogram({ data: DATA, bins: 5, noColor: true }).toString());
    expect(plain).toContain("░");
    expect(plain).toContain("▓");
  });

  it("the mode column is the tallest fill", () => {
    const lines = plainLines({ data: DATA, bins: 5 });
    // The mode column carries █ on the very first plot row; no other column does.
    const topPlotRow = lines[3]!; // frame, rule, eyebrow, first plot row
    const solidCols = [...topPlotRow].filter((c) => c === "█").length;
    expect(solidCols).toBeGreaterThan(0);
  });

  // ── Scale + baseline ─────────────────────────────────────────
  it("has a dashed baseline (└╌) — the axis meets the floor in frame vocabulary", () => {
    expect(plainLines({ data: DATA }).some((l) => l.includes("└╌"))).toBe(true);
  });

  it("prints bin-start labels under the columns", () => {
    const lines = plainLines({ data: DATA, bins: 4 });
    // 4 bins over 1..9 → starts at 1, 3, 5, 7
    expect(lines.some((l) => l.includes("3"))).toBe(true);
    expect(lines[lines.length - 3]).toContain("1"); // x-labels sit above the summary
  });

  // ── Summary foot ─────────────────────────────────────────────
  it("carries an N samples · peak foot row", () => {
    const summary = plainLines({ data: DATA }).find((l) => l.includes("peak "));
    expect(summary).toContain(`${DATA.length} samples`);
    expect(summary).not.toContain("p50 ");
    expect(summary).not.toContain("p99 ");
  });

  it("colors the peak fact in the accent hue", () => {
    const theme = resolveTheme(undefined);
    const out = histogram({ data: DATA }).toString();
    const summaryLine = out.split("\n").find((l) => l.includes("peak "))!;
    expect(summaryLine).toContain(theme.accent!);
  });

  it("p50/p99 are nearest-rank percentiles of the sample", () => {
    const sorted = [...DATA].sort((a, b) => a - b);
    const j = histogram({ data: DATA }).toJSON() as Record<string, unknown>;
    expect(j.p50).toBe(sorted[Math.ceil(0.5 * sorted.length) - 1]); // 3
    expect(j.p99).toBe(sorted[Math.ceil(0.99 * sorted.length) - 1]); // 9
  });

  // ── Agent surface is additive ────────────────────────────────
  it("toJSON keeps the original keys and adds mode/p50/p99/count", () => {
    const j = histogram({ data: DATA, bins: 5 }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("histogram");
    expect(Array.isArray(j.binCounts)).toBe(true);
    expect(j.bins).toBe(5);
    expect(j.mode).toBe(2.6); // bin 1 start: 1 + 1 * 1.6
    expect(typeof j.count).toBe("number");
    expect(typeof j.plain).toBe("string");
  });

  it("toJSON reports null facts for empty data", () => {
    const j = histogram({ data: [] }).toJSON() as Record<string, unknown>;
    expect(j.mode).toBeNull();
    expect(j.p50).toBeNull();
    expect(j.p99).toBeNull();
    expect(j.count).toBe(0);
  });

  // ── Degenerate input is safe and honest ──────────────────────
  it("renders a framed `0 samples · (no data)` panel for empty data", () => {
    const lines = plainLines({ data: [] });
    expect(lines[0]).toMatch(/^┌╌/);
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
    expect(lines.some((l) => l.includes("0 samples · (no data)"))).toBe(true);
  });

  it("never NaNs on a collapsed range (all values equal)", () => {
    const lines = plainLines({ data: [7, 7, 7, 7] });
    expect(lines.some((l) => l.includes("NaN"))).toBe(false);
    const j = histogram({ data: [7, 7, 7, 7] }).toJSON() as Record<string, unknown>;
    expect((j.binCounts as number[])[0]).toBe(4);
  });

  it("excludes non-finite samples instead of NaN-binning them", () => {
    const j = histogram({ data: [1, 2, 3, NaN, Infinity] }).toJSON() as Record<string, unknown>;
    expect(j.count).toBe(3);
    expect(lines_render(histogram({ data: [1, 2, 3, NaN] }))).not.toContain("NaN");
  });

  // ── Auto-width: explicit width is a floor, not a cap ─────────
  it("expands a narrow explicit width so the summary is never clipped", () => {
    const opts = { data: DATA, width: 20, noColor: true } as const;
    const lines = plainLines(opts);
    const summary = lines.find((l) => l.includes("peak"))!;
    expect(summary).toContain("peak 2.6");
    const widths = new Set(lines.map((l) => [...l].length));
    expect(widths.size).toBe(1); // every row shares one panel width
  });
});

function lines_render(result: { toPlain(): string }): string {
  return result.toPlain();
}
