import { describe, it, expect } from "vitest";
import { line } from "../src/charts/line.js";
import { lineModelToSvg } from "../src/charts/line-model.js";

// Drift guard: the SVG rendition must mirror the terminal surface. Both read
// the one LineChartModel, so if a future change re-colours the terminal without
// updating the model (or vice versa) these assertions go red.

type Model = {
  seriesColors: string[];
  strokeSteps: number[];
  style: { accent: string; axis: string };
};

function modelFor(opts: Parameters<typeof line>[0]): Model {
  return (line(opts).toJSON() as { model: Model }).model;
}

function rgbOf(ansi: string): string {
  const m = ansi.match(/38;2;(\d+);(\d+);(\d+)/)!;
  return `rgb(${m[1]},${m[2]},${m[3]})`;
}

const EIGHT = [1, 2, 3, 4, 5, 6, 7, 8];
const TWO = [[1, 2, 3, 4, 5, 6, 7, 8], [8, 7, 6, 5, 4, 3, 2, 1]];

describe("line SVG parity with terminal", () => {
  it("paints every series with the terminal's exact colour (no drift)", () => {
    const opts = { data: TWO, seriesLabels: ["A", "B"], theme: "default" as const };
    const result = line(opts);
    const model = modelFor(opts);
    const term = result.toString();
    const svg = result.toSVG!();

    // Every canonical series colour actually appears in the terminal render...
    for (const c of model.seriesColors) expect(term).toContain(c);
    // ...and the SVG carries the same colour converted to CSS rgb().
    for (const c of model.seriesColors) expect(svg).toContain(rgbOf(c));
    expect(svg.startsWith("<svg")).toBe(true);
    expect(svg.endsWith("</svg>")).toBe(true);
  });

  it("drops glyph markers at every 2nd point, exactly like the terminal", () => {
    const svg = line({ data: EIGHT }).toSVG!();
    const markerGlyphs = (svg.match(/font-size="18"/g) ?? []).length;
    // indices 0,2,4,6 → 4 markers
    expect(markerGlyphs).toBe(4);
  });

  it("spends the accent exactly once, on the primary peak marker", () => {
    const opts = { data: EIGHT };
    const accent = rgbOf(modelFor(opts).style.accent);
    const svg = line(opts).toSVG!();
    const accentMarkers = svg.split(`fill="${accent}" font-size="18"`).length - 1;
    expect(accentMarkers).toBe(1);
  });

  it("only draws gridlines when the terminal `grid` option is on", () => {
    const off = line({ data: EIGHT }).toSVG!();
    const on = line({ data: EIGHT, grid: true }).toSVG!();
    const count = (s: string) => (s.match(/stroke-dasharray="2 8"/g) ?? []).length;
    expect(count(off)).toBe(0);
    expect(count(on)).toBeGreaterThan(0);
  });

  it("uses solid strokes in colour mode and monochrome dash textures in noColor", () => {
    const color = line({ data: TWO, seriesLabels: ["A", "B"] }).toSVG!();
    const monoModel = modelFor({ data: TWO, seriesLabels: ["A", "B"], noColor: true });
    const mono = line({ data: TWO, seriesLabels: ["A", "B"], noColor: true }).toSVG!();
    // Terminal texture steps: primary solid (1), first extra dashed (2).
    expect(monoModel.strokeSteps).toEqual([1, 2]);
    expect((color.match(/stroke-dasharray="none"/g) ?? []).length).toBe(2);
    expect(mono).toContain('stroke-dasharray="12 10"');
  });

  it("renders the shared eyebrow and axis/label colours from the model", () => {
    const opts = { data: EIGHT, eyebrow: "throughput", theme: "nord" as const };
    const model = modelFor(opts);
    const svg = line(opts).toSVG!();
    expect(model.style.accent).toBeTruthy();
    expect(svg).toContain("THROUGHPUT");
    expect(svg).toContain(rgbOf(model.style.axis));
  });

  it("is a pure function of the model (same model → same SVG)", () => {
    const model = modelFor({ data: EIGHT });
    expect(lineModelToSvg(model as never)).toBe(lineModelToSvg(model as never));
  });
});
