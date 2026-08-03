import { describe, it, expect } from "vitest";
import {
  area,
  histogram,
  scatter,
  pie,
  donut,
  heatmap,
  progress,
  gauge,
  horizontalBar,
  timeline,
  radar,
  boxplot,
  waterfall,
  funnel,
  candlestick,
  treemap,
  sankey,
} from "../src/charts/index.js";

describe("area chart", () => {
  it("renders without errors", () => {
    expect(area({ data: [1, 3, 2, 5, 4] }).toString()).toBeTruthy();
  });
  it("toJSON has type area", () => {
    const j = area({ data: [1, 2, 3] }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("area");
  });
  it("draws the fill as braille with the line as its top edge", () => {
    const out = area({ data: [12, 19, 15, 28, 34, 31, 42, 38, 52, 47, 61, 58] }).toString();
    expect(out).toMatch(/[\u2801-\u28FF]/); // lit braille dots present
  });
  it("uses the dashed panel frame + eyebrow like the LOCKED circular look", () => {
    const out = area({ data: [12, 19, 15], title: "REVENUE", eyebrow: "Monthly · Trend" }).toString();
    expect(out).toContain("┌╌");
    expect(out).toContain("╌┐");
    expect(out).toContain("MONTHLY · TREND");
    expect(out).toContain("╌┘");
  });
  it("renders empty cells as spaces, never blank-braille", () => {
    const out = area({ data: [12, 19, 15] }).toString();
    expect(out).not.toContain("\u2800");
  });
  it("auto-scales the y-range to the data and accents only the peak + footer max", () => {
    const out = area({ data: [12, 19, 15, 28, 34, 31, 42, 38, 52, 47, 61, 58] }).toString();
    expect(out).toContain("max 61");
    expect(out).toContain("min 12");
    const accent = "\x1b[38;2;139;124;246m";
    expect(out).toContain(accent + "max 61");
  });
});

describe("histogram", () => {
  it("renders without errors", () => {
    const data = Array.from({ length: 100 }, () => Math.random() * 100);
    expect(histogram({ data, bins: 10 }).toString()).toBeTruthy();
  });
  it("toJSON contains binCounts", () => {
    const data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    const j = histogram({ data }).toJSON() as Record<string, unknown>;
    expect(Array.isArray(j.binCounts)).toBe(true);
  });
});

describe("scatter plot", () => {
  it("renders without errors", () => {
    const data = [
      { x: 1, y: 2 },
      { x: 3, y: 4 },
      { x: 5, y: 1 },
    ];
    expect(scatter({ data }).toString()).toBeTruthy();
  });
  it("supports multi-series", () => {
    const s1 = [{ x: 1, y: 2 }, { x: 2, y: 3 }];
    const s2 = [{ x: 4, y: 1 }, { x: 5, y: 4 }];
    expect(scatter({ data: [s1, s2] }).toString()).toBeTruthy();
  });
});

describe("pie chart", () => {
  it("renders without errors", () => {
    expect(pie({ data: [30, 40, 20, 10], labels: ["A", "B", "C", "D"] }).toString()).toBeTruthy();
  });
  it("toJSON has percentages", () => {
    const j = pie({ data: [50, 50] }).toJSON() as Record<string, unknown>;
    const pcts = j.percentages as number[];
    expect(pcts[0]).toBe(50);
    expect(pcts[1]).toBe(50);
  });
  it("draws a perfect round circle via braille sub-pixels", () => {
    const out = pie({ data: [35, 25, 20, 12, 8], labels: ["A", "B", "C", "D", "E"] }).toPlain();
    expect(out).toMatch(/[\u2801-\u28FF]/); // lit braille dots present
    expect(out).toContain("█"); // legend swatches still block glyphs
  });
  it("spends the accent on one slice only in colour mode", () => {
    const out = pie({ data: [40, 30, 30], theme: "default" }).toString();
    expect(out).toContain("\x1b[38;2;139;124;246m"); // accent violet
  });
});

describe("donut chart", () => {
  it("renders without errors", () => {
    expect(donut({ data: [30, 40, 30], labels: ["X", "Y", "Z"] }).toString()).toBeTruthy();
  });
  it("toJSON has type donut", () => {
    const j = donut({ data: [1, 2] }).toJSON() as Record<string, unknown>;
    expect(j.type).toBe("donut");
  });
  it("renders the dashed panel frame with title and timestamp", () => {
    const out = donut({
      data: [30, 40, 30],
      title: "SYS",
      timestamp: "10:42 IST",
    }).toPlain();
    expect(out).toContain("┌╌");
    expect(out).toContain("╌┐");
    expect(out).toContain("SYS");
    expect(out).toContain("10:42 IST");
  });
  it("renders the eyebrow caption uppercase", () => {
    const out = donut({ data: [30, 40, 30], eyebrow: "Distribution · Requests" }).toPlain();
    expect(out).toContain("DISTRIBUTION · REQUESTS");
  });
  it("pie renders the eyebrow caption and status row", () => {
    const out = pie({ data: [30, 40, 30], eyebrow: "Requests by env", status: "ok" }).toPlain();
    expect(out).toContain("REQUESTS BY ENV");
    expect(out).toContain("Status: ok");
  });
  it("renders the pattern glyph legend", () => {
    const out = donut({ data: [30, 40, 30], labels: ["CPU", "MEM", "NET"] }).toPlain();
    expect(out).toContain("CPU");
    expect(out).toContain("MEM");
    expect(out).toContain("NET");
    expect(out).toContain("30 (30.0%)");
  });
  it("renders metric cells with value and pct", () => {
    const out = donut({ data: [50, 50], labels: ["A", "B"] }).toPlain();
    expect(out).toContain("50.0%");
    expect(out).toContain("A");
    expect(out).toContain("B");
  });
  it("summary: false suppresses legend values", () => {
    const out = donut({ data: [50, 50], labels: ["A", "B"], summary: false }).toPlain();
    expect(out).not.toContain("50.0%");
    expect(out).toContain("A");
    expect(out).toContain("B");
  });
  it("renders the status footer", () => {
    const out = donut({ data: [30, 40, 30], status: "All systems operational" }).toPlain();
    expect(out).toContain("Status: All systems operational");
  });
  it("noColor produces no ANSI escapes", () => {
    const out = donut({ data: [30, 40, 30], noColor: true }).toString();
    expect(out).not.toContain("\x1b[");
  });
});

describe("heatmap", () => {
  it("renders without errors", () => {
    const data = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ];
    expect(heatmap({ data }).toString()).toBeTruthy();
  });
  it("toJSON has min/max", () => {
    const j = heatmap({ data: [[1, 9]] }).toJSON() as Record<string, unknown>;
    expect(j.min).toBe(1);
    expect(j.max).toBe(9);
  });
});

describe("progress", () => {
  it("renders without errors", () => {
    expect(progress({ value: 75 }).toString()).toBeTruthy();
  });
  it("shows percent by default", () => {
    const plain = progress({ value: 50, noColor: true }).toPlain();
    expect(plain).toContain("50.0%");
  });
  it("clamps value to max", () => {
    const j = progress({ value: 200, max: 100 }).toJSON() as Record<string, unknown>;
    expect(j.value).toBe(100);
  });
  it("supports all styles", () => {
    for (const style of ["bar", "blocks", "braille", "ascii"] as const) {
      expect(progress({ value: 50, style }).toString()).toBeTruthy();
    }
  });
});

describe("gauge", () => {
  it("renders without errors", () => {
    expect(gauge({ value: 75, min: 0, max: 100 }).toString()).toBeTruthy();
  });
  it("toJSON has percent", () => {
    const j = gauge({ value: 50, min: 0, max: 100 }).toJSON() as Record<string, unknown>;
    expect(j.percent).toBe(50);
  });
});

describe("horizontal bar chart", () => {
  it("renders without errors", () => {
    expect(
      horizontalBar({ data: [30, 60, 90], labels: ["A", "B", "C"] }).toString()
    ).toBeTruthy();
  });
  it("shows labels", () => {
    const plain = horizontalBar({ data: [10], labels: ["Alpha"], noColor: true }).toPlain();
    expect(plain).toContain("Alpha");
  });
});

describe("timeline", () => {
  it("renders without errors", () => {
    expect(
      timeline({
        events: [
          { label: "Task A", start: 0, end: 3 },
          { label: "Task B", start: 2, end: 5 },
        ],
      }).toString()
    ).toBeTruthy();
  });
  it("toJSON has events", () => {
    const j = timeline({
      events: [{ label: "E", start: 0 }],
    }).toJSON() as Record<string, unknown>;
    expect(Array.isArray(j.events)).toBe(true);
  });
});

describe("radar chart", () => {
  it("renders without errors", () => {
    expect(
      radar({
        data: [80, 60, 90, 70, 85],
        labels: ["Speed", "Power", "Range", "Accuracy", "Stamina"],
      }).toString()
    ).toBeTruthy();
  });
});

describe("boxplot", () => {
  it("renders without errors", () => {
    expect(
      boxplot({
        data: [1, 3, 5, 7, 9, 2, 4, 6, 8, 10],
        labels: ["Data"],
      }).toString()
    ).toBeTruthy();
  });
  it("toJSON has stats", () => {
    const j = boxplot({ data: [1, 2, 3, 4, 5] }).toJSON() as Record<string, unknown>;
    expect(Array.isArray(j.stats)).toBe(true);
  });
});

describe("waterfall chart", () => {
  it("renders without errors", () => {
    expect(
      waterfall({
        data: [100, -30, 20, -10, 50],
        labels: ["Start", "Q1", "Q2", "Q3", "Q4"],
      }).toString()
    ).toBeTruthy();
  });
  it("toJSON has total", () => {
    const j = waterfall({ data: [10, -5, 5] }).toJSON() as Record<string, unknown>;
    expect(j.total).toBe(10);
  });
});

describe("funnel chart", () => {
  it("renders without errors", () => {
    expect(
      funnel({
        data: [1000, 750, 500, 250, 100],
        labels: ["Visitors", "Leads", "Prospects", "Qualified", "Customers"],
      }).toString()
    ).toBeTruthy();
  });
  it("toJSON has conversionRates", () => {
    const j = funnel({ data: [100, 50] }).toJSON() as Record<string, unknown>;
    const rates = j.conversionRates as number[];
    expect(rates[0]).toBe(1);
    expect(rates[1]).toBe(0.5);
  });
});

describe("candlestick chart", () => {
  it("renders without errors", () => {
    expect(
      candlestick({
        data: [
          { open: 100, high: 110, low: 95, close: 105, label: "Day1" },
          { open: 105, high: 115, low: 100, close: 98, label: "Day2" },
        ],
      }).toString()
    ).toBeTruthy();
  });
});

describe("treemap", () => {
  it("renders without errors", () => {
    expect(
      treemap({
        data: [
          { label: "A", value: 40 },
          { label: "B", value: 30 },
          { label: "C", value: 20 },
          { label: "D", value: 10 },
        ],
      }).toString()
    ).toBeTruthy();
  });
});

describe("sankey", () => {
  it("renders without errors", () => {
    expect(
      sankey({
        nodes: ["A", "B", "C"],
        links: [
          { source: "A", target: "B", value: 100 },
          { source: "B", target: "C", value: 80 },
        ],
      }).toString()
    ).toBeTruthy();
  });
  it("toJSON has nodes and links", () => {
    const j = sankey({
      nodes: ["X", "Y"],
      links: [{ source: "X", target: "Y", value: 50 }],
    }).toJSON() as Record<string, unknown>;
    expect(Array.isArray(j.nodes)).toBe(true);
    expect(Array.isArray(j.links)).toBe(true);
  });
});
