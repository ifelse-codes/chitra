import { describe, it, expect } from "vitest";
import { funnel } from "../src/charts/funnel.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const DATA = [10000, 6800, 3400, 1200, 340];
const LABELS = ["Visitors", "Sign-ups", "Trials", "Paid", "Enterprise"];

function plainLines(opts: Parameters<typeof funnel>[0]): string[] {
  return stripAnsi(funnel(opts).toString()).split("\n");
}

// A funnel stage bar is a shade-ramp run (░▒▓) with a ▓ end-cap; the peak
// stage takes the solid `█` run in the accent hue.
const BAR = /[░▒▓█]/;

/** Count coloured BAR segments by category (the S17 raw-ANSI census method).
 *  The accent must NEVER touch a non-peak stage (no `theme.colors[i % n]`
 *  rainbow), and every grey segment must be a documented tone. */
function tonalCensus(opts: Parameters<typeof funnel>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const out = funnel(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    if (code === theme.axis) continue; // frame + rules, never bars
    if (!BAR.test(body)) continue; // count bar segments only, not labels/footer
    if (code === theme.accent) {
      accent++;
      expect(body.replace(/\s/g, "")).toMatch(/^█+$/);
    } else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("funnel chart — locked S26 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌) and bottom (└╌)", () => {
    const lines = plainLines({ data: DATA, labels: LABELS });
    expect(lines[0]).toMatch(/^┌╌/);
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has one frame rule separator (│ ╌)", () => {
    const rules = plainLines({ data: DATA, labels: LABELS }).filter((l) => /^│ ╌+ │$/.test(l));
    expect(rules.length).toBe(1);
  });

  it("carries the conversion metric in the eyebrow row", () => {
    expect(plainLines({ data: DATA, labels: LABELS })).toContainEqual(
      expect.stringContaining("CONVERSION 3%")
    );
  });

  it("titles the frame FUNNEL by default", () => {
    expect(plainLines({ data: DATA, labels: LABELS })[0]).toContain("FUNNEL");
  });

  it("keeps every panel row the same visible width", () => {
    const widths = new Set(plainLines({ data: DATA, labels: LABELS }).map((l) => [...l].length));
    expect(widths.size).toBe(1);
  });

  // ── Arrows deleted; rows left-anchored ─────────────────────────
  it("renders no ▼ arrow connectors anywhere", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    expect(text).not.toContain("▼");
  });

  it("centers every stage bar — the symmetric funnel silhouette, not left-anchored bars", () => {
    const lines = plainLines({ data: DATA, labels: LABELS, noColor: true }).filter(
      (l) => /Visitors|Sign-ups|Trials|Paid|Enterprise/.test(l) && /[░▒▓█]/.test(l)
    );
    expect(lines.length).toBe(5);
    // Left padding grows down the stages: each narrower bar sits centered
    // inside the same field (the audit's left-anchor is reversed).
    const pads = lines.map((l) => {
      const m = l.match(/[░▒▓█]/)!;
      return l.indexOf(m[0]) - (l.indexOf("│") + 2 + 12 + 1);
    });
    for (let i = 1; i < pads.length; i++) expect(pads[i]!).toBeGreaterThanOrEqual(pads[i - 1]!);
    expect(pads[pads.length - 1]!).toBeGreaterThan(pads[0]!);
  });

  // ── Tonal peak + ramp, never rainbow ──────────────────────────
  it("spends the accent only on the peak stage, grey ramp elsewhere", () => {
    const { accent, grey, other } = tonalCensus({ data: DATA, labels: LABELS });
    expect(accent).toBeGreaterThan(0);
    expect(grey).toBeGreaterThan(0);
    expect(other).toBe(0);
  });

  it("prints integer percentages (68%, never 68.0%)", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    expect(text).toContain("(68%)");
    expect(text).not.toMatch(/\(\d+\.\d+%/);
  });

  // ── Foot facts ────────────────────────────────────────────────
  it("reports IN · OUT · CONVERSION · DROP facts, CONVERSION accented", () => {
    const theme = resolveTheme("default");
    const raw = funnel({ data: DATA, labels: LABELS }).toString();
    const footLine = raw.split("\n").find((l) => l.includes("IN "))!;
    expect(footLine.includes(theme.accent!)).toBe(true);
    const text = stripAnsi(raw);
    expect(text).toContain("IN 10.0K");
    expect(text).toContain("OUT 340");
    expect(text).toContain("DROP Enterprise");
  });

  // ── Degenerate-safe ───────────────────────────────────────────
  it("renders empty data as a framed STAGES 0 · (no data) panel", () => {
    const f = funnel({ data: [] });
    const text = f.toPlain();
    expect(text).toMatch(/^┌╌/);
    expect(text).toContain("STAGES 0 · (no data)");
    expect(text).not.toContain("NaN");
    const j = f.toJSON() as Record<string, unknown>;
    expect(j.conversion).toBeNull();
    expect(j.biggestDrop).toBeNull();
  });

  it("reports a null conversion when the first stage is zero (no div-by-zero)", () => {
    const f = funnel({ data: [0, 0, 5] });
    expect(f.toPlain()).not.toContain("NaN");
    expect((f.toJSON() as Record<string, unknown>).conversion).toBeNull();
  });

  // ── Agent surface ─────────────────────────────────────────────
  it("toJSON carries conversion + biggestDrop with the legacy rates", () => {
    const j = funnel({ data: DATA, labels: LABELS }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("funnel");
    expect(j.conversion).toBeCloseTo(0.034, 5);
    expect(j.biggestDrop).toMatchObject({ label: "Enterprise" });
    expect(Array.isArray(j.conversionRates)).toBe(true);
  });

  it("keeps the legacy surface: renders truthy with conversion rates", () => {
    expect(
      funnel({
        data: [1000, 750, 500, 250, 100],
        labels: ["Visitors", "Leads", "Prospects", "Qualified", "Customers"],
      }).toString()
    ).toBeTruthy();
  });
});
