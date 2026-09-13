import { describe, it, expect } from "vitest";
import { sankey } from "../src/charts/sankey.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const NODES = ["Visitors", "Free", "Paid", "Churned"];
const LINKS = [
  { source: "Visitors", target: "Free", value: 60 },
  { source: "Free", target: "Paid", value: 25 },
  { source: "Free", target: "Churned", value: 20 },
  { source: "Visitors", target: "Paid", value: 5 },
];

function plainLines(opts: Parameters<typeof sankey>[0]): string[] {
  return stripAnsi(sankey(opts).toString()).split("\n");
}

// A sankey flow is a shade-ramp run (░▒▓); the peak flow takes the solid `█`
// run in the accent hue. Node ledger marks (■) ride the grey ramp.
const FLOW = /[░▒▓█■]/;

/** Count coloured FLOW segments by category (the S17 raw-ANSI census method).
 *  The accent must NEVER touch a non-peak flow or a ledger mark (no
 *  `theme.colors[i % n]` rainbow), and every grey segment must be a
 *  documented tone. */
function tonalCensus(opts: Parameters<typeof sankey>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const out = sankey(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    if (code === theme.axis) continue; // frame + rules, never flows
    if (!FLOW.test(body)) continue; // count flow segments only, not labels/footer
    if (code === theme.accent) {
      accent++;
      expect(body.replace(/\s/g, "")).toMatch(/^[█0-9.,KM%]+$/);
    } else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("sankey chart — locked S26 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌) and bottom (└╌)", () => {
    const lines = plainLines({ nodes: NODES, links: LINKS });
    expect(lines[0]).toMatch(/^┌╌/);
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has two frame rule separators (│ ╌)", () => {
    const rules = plainLines({ nodes: NODES, links: LINKS }).filter((l) => /^│ ╌+ │$/.test(l));
    expect(rules.length).toBe(2);
  });

  it("carries the total-flow metric in the eyebrow row", () => {
    expect(plainLines({ nodes: NODES, links: LINKS })).toContainEqual(
      expect.stringContaining("FLOW 110")
    );
  });

  it("titles the frame SANKEY by default", () => {
    expect(plainLines({ nodes: NODES, links: LINKS })[0]).toContain("SANKEY");
  });

  it("keeps every panel row the same visible width", () => {
    const widths = new Set(plainLines({ nodes: NODES, links: LINKS }).map((l) => [...l].length));
    expect(widths.size).toBe(1);
  });

  // ── Arrows deleted ────────────────────────────────────────────
  it("renders no ▶ arrow decoration anywhere", () => {
    const text = plainLines({ nodes: NODES, links: LINKS, noColor: true }).join("\n");
    expect(text).not.toContain("▶");
  });

  // ── Tonal peak + ramp, never rainbow ──────────────────────────
  it("spends the accent only on the peak flow, grey ramp elsewhere", () => {
    const { accent, grey, other } = tonalCensus({ nodes: NODES, links: LINKS });
    expect(accent).toBeGreaterThan(0);
    expect(grey).toBeGreaterThan(0);
    expect(other).toBe(0);
  });

  it("renders the peak flow solid (█) and lesser flows shaded (░▒▓)", () => {
    const text = plainLines({ nodes: NODES, links: LINKS, noColor: true }).join("\n");
    expect(text).toContain("█");
    expect(text).toMatch(/[░▒▓]/);
  });

  it("keeps the node ledger with in/out facts on toned marks", () => {
    const text = plainLines({ nodes: NODES, links: LINKS, noColor: true }).join("\n");
    expect(text).toContain("Nodes:");
    expect(text).toContain("in:60");
    expect(text).toContain("out:45");
  });

  // ── Foot facts ────────────────────────────────────────────────
  it("reports NODES · LINKS · PEAK facts, PEAK value accented", () => {
    const theme = resolveTheme("default");
    const raw = sankey({ nodes: NODES, links: LINKS }).toString();
    const footLine = raw.split("\n").find((l) => l.includes("PEAK "))!;
    expect(footLine.includes(theme.accent!)).toBe(true);
    const text = stripAnsi(raw);
    expect(text).toContain("NODES 4 · LINKS 4");
    expect(text).toContain("PEAK Visitors → Free 60");
  });

  // ── Degenerate-safe ───────────────────────────────────────────
  it("renders empty links as a framed NODES 0 · (no data) panel", () => {
    const s = sankey({ nodes: [], links: [] });
    const text = s.toPlain();
    expect(text).toMatch(/^┌╌/);
    expect(text).toContain("NODES 0 · (no data)");
    expect(text).not.toContain("NaN");
    const j = s.toJSON() as Record<string, unknown>;
    expect(j.peakFlow).toBeNull();
  });

  // ── Agent surface ─────────────────────────────────────────────
  it("toJSON carries the peak flow with the legacy nodes/links", () => {
    const j = sankey({ nodes: NODES, links: LINKS }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("sankey");
    expect(j.nodes).toEqual(NODES);
    expect(j.links).toEqual(LINKS);
    expect(j.peakFlow).toMatchObject({ source: "Visitors", target: "Free", value: 60 });
  });
});
