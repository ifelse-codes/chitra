import { describe, it, expect } from "vitest";
import {
  line,
  area,
  bar,
  horizontalBar,
  scatter,
  histogram,
  heatmap,
  funnel,
  pie,
  donut,
  radar,
  boxplot,
  waterfall,
  candlestick,
  treemap,
  sankey,
  timeline,
  sparkline,
  progress,
  gauge,
  VERSION,
} from "../src/index.js";
import { stripAnsi } from "../src/ansi.js";

const BOX = /[┌┐└┘]/;

function bodyLines(r: { toContent(): string }): string[] {
  return r.toContent().split("\n");
}

describe("composability — frame/compact/height/toContent/maxWidth", () => {
  const hbData = [12, 47, 23, 8, 35];
  const hbLabels = ["a", "b", "c", "d", "e"];

  it("compact:true strips box corners on categorical charts", () => {
    expect(
      stripAnsi(horizontalBar({ data: hbData, labels: hbLabels, compact: true }).toString())
    ).not.toMatch(BOX);
    expect(
      stripAnsi(timeline({ events: [{ label: "a", start: 0, end: 5 }], compact: true }).toString())
    ).not.toMatch(BOX);
    expect(stripAnsi(gauge({ value: 50, compact: true }).toString())).not.toMatch(BOX);
    expect(stripAnsi(pie({ data: [10, 20, 30], compact: true }).toString())).not.toMatch(BOX);
    expect(stripAnsi(donut({ data: [10, 20, 30], compact: true }).toString())).not.toMatch(BOX);
  });

  it("frame:false keeps content but drops box corners", () => {
    const out = stripAnsi(
      horizontalBar({ data: hbData, labels: hbLabels, frame: false }).toString()
    );
    expect(out).not.toMatch(BOX);
    expect(out).toContain("VALUES");
  });

  it("explicit height is body-exact (compact)", () => {
    expect(
      bodyLines(
        horizontalBar({ data: hbData, labels: hbLabels, height: 3, showAxes: false, compact: true })
      ).length
    ).toBe(3);
    expect(bodyLines(gauge({ value: 50, height: 1, compact: true })).length).toBe(1);
    expect(bodyLines(progress({ value: 50, height: 2, compact: true })).length).toBe(2);
    expect(
      bodyLines(
        timeline({
          events: [
            { label: "a", start: 0, end: 5 },
            { label: "b", start: 1, end: 2 },
          ],
          height: 2,
          showAxes: false,
          compact: true,
        })
      ).length
    ).toBe(2);
    expect(bodyLines(pie({ data: [10, 20, 30], height: 8, compact: true })).length).toBe(8);
    expect(bodyLines(funnel({ data: [100, 60, 30], height: 2, compact: true })).length).toBe(2);
    expect(
      bodyLines(
        heatmap({
          data: [
            [1, 2],
            [3, 4],
          ],
          height: 2,
          compact: true,
        })
      ).length
    ).toBe(2);
    expect(bodyLines(sparkline({ data: [1, 2, 3, 2, 1], height: 2, compact: true })).length).toBe(
      2
    );
  });

  it("toContent() has no box corners and matches compact body", () => {
    const charts = [
      line({ data: [1, 2, 3] }),
      area({ data: [1, 2, 3] }),
      bar({ data: [1, 2, 3] }),
      horizontalBar({ data: hbData, labels: hbLabels }),
      scatter({ data: [{ x: 1, y: 2 }] }),
      histogram({ data: [1, 2, 2, 3] }),
      heatmap({
        data: [
          [1, 2],
          [3, 4],
        ],
      }),
      funnel({ data: [100, 60, 30] }),
      pie({ data: [10, 20, 30] }),
      donut({ data: [10, 20, 30] }),
      radar({ data: [10, 20, 30], labels: ["a", "b", "c"] }),
      boxplot({ data: [[1, 2, 3]] }),
      waterfall({ data: [10, -5, 8] }),
      candlestick({ data: [{ open: 1, high: 3, low: 0, close: 2 }] }),
      treemap({ data: [{ label: "a", value: 10 }] }),
      sankey({ nodes: ["a", "b"], links: [{ source: "a", target: "b", value: 5 }] }),
      timeline({ events: [{ label: "a", start: 0, end: 5 }] }),
      sparkline({ data: [1, 2, 3] }),
      progress({ value: 50 }),
      gauge({ value: 50 }),
    ];
    for (const c of charts) {
      expect(c.toContent().length).toBeGreaterThan(0);
    }
    // Charts without box glyphs in their plot vocabulary carry no corners.
    for (const c of [
      charts[0]!,
      charts[2]!,
      charts[3]!,
      charts[8]!,
      charts[9]!,
      charts[16]!,
      charts[17]!,
      charts[18]!,
      charts[19]!,
    ]) {
      expect(c.toContent()).not.toMatch(BOX);
    }
    // waterfall/candlestick/boxplot legitimately use ┌╌┐/└╌┘ as plot glyphs
    // (total blocks, wicks, axis) — toContent must equal the compact render.
    expect(charts[12]!.toContent()).toBe(
      waterfall({ data: [10, -5, 8], frame: false, compact: true }).toPlain()
    );
    const framed = line({ data: [1, 2, 3] });
    expect(framed.toContent()).toBe(
      line({ data: [1, 2, 3], frame: false, compact: true }).toPlain()
    );
  });

  it("maxWidth caps visible width (ANSI-safe)", () => {
    const out = stripAnsi(bar({ data: [1, 2, 3], width: 80, maxWidth: 40 }).toString()).split("\n");
    expect(Math.max(...out.map((l) => l.length))).toBeLessThanOrEqual(40);
    const hb = stripAnsi(
      horizontalBar({ data: hbData, labels: hbLabels, width: 80, maxWidth: 40 }).toString()
    ).split("\n");
    expect(Math.max(...hb.map((l) => l.length))).toBeLessThanOrEqual(40);
  });

  it("toJSON data is unaffected by height/maxWidth/compact", () => {
    const full = horizontalBar({ data: hbData, labels: hbLabels }).toJSON() as { data: number[] };
    const clipped = horizontalBar({
      data: hbData,
      labels: hbLabels,
      height: 2,
      maxWidth: 30,
      compact: true,
    }).toJSON() as { data: number[] };
    expect(clipped.data).toEqual(full.data);
    expect((pie({ data: [10, 20, 30], height: 5 }).toJSON() as { data: number[] }).data).toEqual([
      10, 20, 30,
    ]);
  });

  it("defaults are unchanged (framed panels by default)", () => {
    expect(stripAnsi(line({ data: [1, 2, 3] }).toString())).toMatch(/^┌/m);
    expect(stripAnsi(gauge({ value: 50 }).toString())).toMatch(/^┌/m);
    expect(stripAnsi(horizontalBar({ data: hbData }).toString())).toMatch(/^┌/m);
  });
});

// S41 requirement 2. VERSION is exported public API and once shipped to npm as
// "0.1.0" while package.json said 0.3.0. src/version.ts is generated from the
// manifest, so this compares the two directly — if the generator is ever skipped,
// the suite fails here rather than the package quietly lying.
describe("package metadata — VERSION cannot drift from the manifest", () => {
  it("VERSION equals package.json's version", async () => {
    const pkg = (await import("../package.json", { with: { type: "json" } })).default;
    expect(VERSION).toBe(pkg.version);
  });
});
