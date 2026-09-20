import { describe, it, expect } from "vitest";
import { radar } from "../src/charts/radar.js";
import { stripAnsi, visibleLength } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const DATA = [80, 60, 90, 70, 85];
const LABELS = ["Speed", "Power", "Range", "Accuracy", "Stamina"];
const MULTI = [
  [80, 60, 90, 70, 85],
  [50, 75, 55, 80, 60],
];

function plainLines(opts: Parameters<typeof radar>[0]): string[] {
  return stripAnsi(radar(opts).toString()).split("\n");
}

// A radar web is square braille dots (U+2800–U+28FF) with ● vertices for
// the primary series and ○ for the rest. The primary series takes the accent
// hue; the rest take tones. Mass and kind survive noColor (shape, not hue).
const SERIES = /[⠀-⣿●○]/;

/** Count coloured SERIES segments by category (the S17 raw-ANSI census
 *  method). The accent must NEVER touch a non-primary series (no
 *  `theme.colors[si % n]` rainbow), and every grey segment must be a
 *  documented tone. */
function tonalCensus(opts: Parameters<typeof radar>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const out = radar(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    if (code === theme.axis || code === (theme.grid ?? theme.axis)) continue; // web chrome, never series
    if (!SERIES.test(body)) continue; // count series segments only, not labels/footer
    // Drawing cells never carry alphanumerics — eyebrow/foot text does.
    if (/[A-Za-z0-9]/.test(body)) continue;
    if (code === theme.accent) accent++;
    else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("radar chart — locked S26 design", () => {
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

  it("carries the structural facts in the eyebrow row", () => {
    expect(plainLines({ data: DATA, labels: LABELS })).toContainEqual(
      expect.stringContaining("AXES 5 · SERIES 1")
    );
  });

  it("titles the frame RADAR by default", () => {
    expect(plainLines({ data: DATA, labels: LABELS })[0]).toContain("RADAR");
  });

  it("keeps every panel row the same visible width", () => {
    const widths = new Set(plainLines({ data: DATA, labels: LABELS }).map((l) => visibleLength(l)));
    expect(widths.size).toBe(1);
  });

  it("prints every axis label unclipped beside the web", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    for (const label of LABELS) expect(text).toContain(label);
  });

  // ── Tonal primary + markers, never rainbow ────────────────────
  it("spends the accent on the primary series, grey tones elsewhere", () => {
    const { accent, grey, other } = tonalCensus({ data: MULTI, labels: LABELS });
    expect(accent).toBeGreaterThan(0);
    expect(grey).toBeGreaterThan(0);
    expect(other).toBe(0);
  });

  it("draws the web in braille dots with a tinted primary mass", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    expect(text).toMatch(/[⠀-⣿]/);
  });

  it("draws the primary solid with ● vertices, secondaries dashed with ○", () => {
    const text = plainLines({
      data: MULTI,
      labels: LABELS,
      seriesLabels: ["Alpha", "Beta"],
      noColor: true,
    }).join("\n");
    expect(text).toContain("●");
    expect(text).toContain("○");
    expect(text).toContain("● ── Alpha");
    expect(text).toContain("○ ╌╌ Beta");
  });

  // ── Foot facts ────────────────────────────────────────────────
  it("reports average · peak facts, peak accented", () => {
    const theme = resolveTheme("default");
    const raw = radar({ data: DATA, labels: LABELS }).toString();
    const footLine = raw.split("\n").find((l) => l.includes("peak "))!;
    expect(footLine.includes(theme.accent!)).toBe(true);
    const text = stripAnsi(raw);
    expect(text).toContain("average 77");
    expect(text).toContain("peak Range (90)");
  });

  // ── Degenerate-safe ───────────────────────────────────────────
  it("renders empty axes as a framed 0 axes · (no data) panel", () => {
    const r = radar({ data: [], labels: [] });
    const text = r.toPlain();
    expect(text).toMatch(/^┌╌/);
    expect(text).toContain("0 axes · (no data)");
    expect(text).not.toContain("NaN");
    const j = r.toJSON() as Record<string, unknown>;
    expect(j.max).toBeNull();
    expect(j.avg).toBeNull();
  });

  it("collapses negatives and non-finite samples to the center, never NaN", () => {
    const r = radar({ data: [-5, NaN, Infinity, 50, 30], labels: LABELS });
    expect(r.toPlain()).not.toContain("NaN");
    expect(r.toPlain()).not.toContain("Infinity");
  });

  it("renders all-zero data without dividing by zero", () => {
    const r = radar({ data: [0, 0, 0, 0, 0], labels: LABELS });
    expect(r.toPlain()).not.toContain("NaN");
  });

  // ── Agent surface ─────────────────────────────────────────────
  it("toJSON carries max (+axis) and avg with the legacy data/labels", () => {
    const j = radar({ data: DATA, labels: LABELS }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("radar");
    expect(j.data).toEqual(DATA);
    expect(j.labels).toEqual(LABELS);
    expect(j.max).toMatchObject({ value: 90, axis: "Range" });
    expect(j.avg).toBe(77);
  });

  it("keeps the legacy surface: renders truthy", () => {
    expect(radar({ data: DATA, labels: LABELS }).toString()).toBeTruthy();
  });
});
