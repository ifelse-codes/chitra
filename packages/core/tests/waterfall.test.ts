import { describe, it, expect } from "vitest";
import { waterfall } from "../src/charts/waterfall.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const DATA = [500, -120, 80, -60, 150];
const LABELS = ["Start", "COGS", "Rev", "OpEx", "Sales"];

function plainLines(opts: Parameters<typeof waterfall>[0]): string[] {
  return stripAnsi(waterfall(opts).toString()).split("\n");
}

// A waterfall bar cell is a run of block glyphs (█ anchors, ▓ ups) or outline
// pieces (┌╌╌┐ │ │ └╌╌┘ downs). The Total anchor takes the solid `█` run in
// the accent hue; everything else sits on the grey tone ramp.
const BAR = /[█▓┌╌┐│└┘]/;

/** Count coloured BAR segments by category (the S17 raw-ANSI census method).
 *  The accent must NEVER touch a non-total bar (no `theme.colors[i]`
 *  rainbow), and every grey segment must be a documented tone. */
function tonalCensus(opts: Parameters<typeof waterfall>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const out = waterfall(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    // Axis-coloured structure (frame, guides, ┄ connectors, zero-line ─,
    // dashed baseline) is never bar mass — the census counts bars only.
    if (code === theme.axis) continue;
    if (!BAR.test(body)) continue; // count bar segments only, not labels/footer
    if (code === theme.accent) {
      accent++;
      // The accent is block mass only — never an outline piece.
      expect(body.replace(/\s/g, "")).toMatch(/^█+$/);
    } else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("waterfall chart — locked S26 design", () => {
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

  it("carries the NET metric in the eyebrow row", () => {
    expect(plainLines({ data: DATA, labels: LABELS })).toContainEqual(
      expect.stringContaining("NET +550")
    );
  });

  it("titles the frame WATERFALL by default", () => {
    expect(plainLines({ data: DATA, labels: LABELS })[0]).toContain("WATERFALL");
  });

  it("keeps every panel row the same visible width", () => {
    const widths = new Set(plainLines({ data: DATA, labels: LABELS }).map((l) => [...l].length));
    expect(widths.size).toBe(1);
  });

  // ── P0: down-deltas are visible outline boxes, never flat dashes ──
  it("renders negative deltas as dashed outline boxes (┌╌╌┐)", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    expect(text).toContain("┌╌");
    expect(text).toContain("└╌");
    expect(text).toContain("│");
  });

  it("gives even a sub-row delta a minimum one-row outline (never a flat dash)", () => {
    // −1 against a 0..1000 range is far below one row at height 12.
    const text = plainLines({ data: [1000, -1], noColor: true }).join("\n");
    expect(text).toContain("┌╌");
  });

  it("renders zero deltas as empty columns — no fill, no outline", () => {
    const lines = plainLines({ data: [100, 0, 50], noColor: true });
    // The zero column carries no block mass and no outline corners.
    for (const line of lines) {
      if (!/^\│ /.test(line)) continue; // plot rows live inside the frame
      expect(line).not.toContain("┌╌");
    }
    const text = lines.join("\n");
    expect(text).toContain("+0");
  });

  // ── Tonal kinds, never rainbow ────────────────────────────────
  it("spends the accent only on the Total anchor, grey ramp elsewhere", () => {
    const { accent, grey, other } = tonalCensus({ data: DATA, labels: LABELS });
    expect(accent).toBeGreaterThan(0);
    expect(grey).toBeGreaterThan(0);
    expect(other).toBe(0);
  });

  it("renders up-steps solid (▓) and start/total anchors solid (█)", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    expect(text).toContain("▓");
    expect(text).toContain("█");
  });

  // ── Integer y-axis (the retired decimal-label bug) ───────────
  it("never prints decimal y-axis labels", () => {
    const lines = plainLines({ data: DATA, labels: LABELS, noColor: true });
    let labels = 0;
    for (const line of lines) {
      const m = line.match(/^│ (\s*\S*)([+│])/);
      if (!m) continue;
      labels++;
      expect(m[1]).not.toContain(".");
    }
    expect(labels).toBeGreaterThanOrEqual(3);
  });

  // ── Connectors + signed delta labels ──────────────────────────
  it("draws ┄ connectors between steps at their running levels", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    expect(text).toContain("┄");
  });

  it("prints signed delta facts above the plot (+80 / −120)", () => {
    const text = plainLines({ data: DATA, labels: LABELS, noColor: true }).join("\n");
    expect(text).toContain("+80");
    expect(text).toContain("−120");
  });

  // ── Foot facts ────────────────────────────────────────────────
  it("reports START · Δ · TOTAL facts, TOTAL accented", () => {
    const theme = resolveTheme("default");
    const raw = waterfall({ data: DATA, labels: LABELS }).toString();
    const foot = raw.split("\n").find((l) => l.includes("TOTAL "))!;
    expect(foot).toBeDefined();
    expect(foot.includes(theme.accent!)).toBe(true);
    const text = stripAnsi(raw);
    expect(text).toContain("START 500");
    expect(text).toContain("TOTAL 550");
  });

  // ── Degenerate-safe ───────────────────────────────────────────
  it("renders empty data as a framed TOTAL 0 · (no data) panel", () => {
    const w = waterfall({ data: [] });
    const text = w.toPlain();
    expect(text).toMatch(/^┌╌/);
    expect(text).toContain("TOTAL 0 · (no data)");
    expect(text).not.toContain("NaN");
    const j = w.toJSON() as Record<string, unknown>;
    expect(j.total).toBe(0);
    expect(j.steps).toEqual([]);
  });

  it("renders all-zero deltas with no NaN and honest TOTAL 0", () => {
    const w = waterfall({ data: [0, 0, 0], noColor: true });
    expect(w.toPlain()).not.toContain("NaN");
    expect((w.toJSON() as Record<string, unknown>).total).toBe(0);
  });

  // ── Agent surface ─────────────────────────────────────────────
  it("toJSON carries additive per-step running levels with kinds", () => {
    const j = waterfall({ data: DATA, labels: LABELS }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("waterfall");
    expect(j.total).toBe(550);
    const steps = j.steps as Array<Record<string, unknown>>;
    expect(steps.length).toBe(5);
    expect(steps[0]).toMatchObject({
      label: "Start",
      delta: 500,
      start: 0,
      end: 500,
      kind: "start",
    });
    expect(steps[1]).toMatchObject({
      label: "COGS",
      delta: -120,
      start: 500,
      end: 380,
      kind: "down",
    });
    expect(steps[2]).toMatchObject({ label: "Rev", delta: 80, start: 380, end: 460, kind: "up" });
  });

  it("keeps the legacy surface: renders truthy, toJSON has total", () => {
    expect(
      waterfall({
        data: [100, -30, 20, -10, 50],
        labels: ["Start", "Q1", "Q2", "Q3", "Q4"],
      }).toString()
    ).toBeTruthy();
    expect((waterfall({ data: [10, -5, 5] }).toJSON() as Record<string, unknown>).total).toBe(10);
  });
});
