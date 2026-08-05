import { describe, it, expect } from "vitest";
import { line } from "../src/charts/line.js";
import { stripAnsi } from "../src/ansi.js";

describe("line chart", () => {
  it("renders without errors", () => {
    const result = line({ data: [10, 20, 15, 30, 25] });
    expect(result.toString()).toBeTruthy();
  });

  it("supports braille renderer", () => {
    const result = line({ data: [1, 2, 3, 4, 5], renderer: "braille" });
    expect(result.toString()).toBeTruthy();
  });

  it("supports blocks renderer", () => {
    const result = line({ data: [1, 2, 3, 4, 5], renderer: "blocks" });
    expect(result.toString()).toBeTruthy();
  });

  it("supports multi-series", () => {
    const result = line({
      data: [
        [1, 2, 3],
        [3, 2, 1],
      ],
      seriesLabels: ["Up", "Down"],
    });
    const plain = result.toPlain();
    expect(plain).toContain("Up");
    expect(plain).toContain("Down");
  });

  it("differentiates overlapping series by glyph marker, not colour alone", () => {
    const result = line({
      data: [
        [1, 2, 3, 4, 5, 6, 7, 8],
        [8, 7, 6, 5, 4, 3, 2, 1],
        [4, 5, 4, 5, 4, 5, 4, 5],
      ],
      seriesLabels: ["A", "B", "C"],
      noColor: true,
    });
    const plain = result.toPlain();
    expect(plain).toContain("──*── A");
    expect(plain).toContain("╌╌○╌╌ B");
    expect(plain).toContain("··+·· C");
    expect(plain).toContain("○");
    expect(plain).toContain("+");
  });

  it("renders glyph markers on every series (including the primary)", () => {
    const result = line({
      data: [
        [1, 2, 3, 4, 5, 6, 7, 8],
        [8, 7, 6, 5, 4, 3, 2, 1],
      ],
      seriesLabels: ["Up", "Down"],
      noColor: true,
      renderer: "ascii",
    });
    const plain = result.toPlain();
    expect(plain).toContain("──*── Up");
    expect(plain).toContain("╌╌○╌╌ Down");
    expect(plain).toContain("○");
    expect(plain).toContain("avg");
  });

  it("includes title", () => {
    const result = line({ data: [1, 2, 3], title: "Revenue Trend" });
    expect(result.toPlain()).toContain("Revenue Trend");
  });

  it("noColor produces no ANSI escapes", () => {
    const result = line({ data: [1, 2, 3], noColor: true });
    expect(result.toString()).not.toContain("\x1b[");
  });

  it("toMarkdown wraps in code block", () => {
    const md = line({ data: [1, 2, 3] }).toMarkdown();
    expect(md).toMatch(/^```\n/);
  });

  it("toJSON has correct structure", () => {
    const json = line({ data: [1, 2, 3] }).toJSON() as Record<string, unknown>;
    expect(json.type).toBe("line");
    expect(typeof json.plain).toBe("string");
  });

  it("handles constant data", () => {
    const result = line({ data: [5, 5, 5, 5] });
    expect(result.toString()).toBeTruthy();
  });

  it("handles yMin/yMax", () => {
    const result = line({ data: [10, 20, 30], yMin: 0, yMax: 100 });
    expect(result.toPlain()).toContain("100");
  });

  it("renders the dashed panel frame with a top-right timestamp", () => {
    const result = line({ data: [1, 2, 3], title: "SYS", timestamp: "10:42 IST" });
    const plain = result.toPlain();
    expect(plain).toContain("┌╌ SYS");
    expect(plain).toContain("10:42 IST");
    expect(plain).toContain("╌┐");
  });

  it("renders the status footer line", () => {
    const result = line({ data: [1, 2, 3], status: "All systems operational" });
    expect(result.toPlain()).toContain("Status: All systems operational");
  });

  it("renders per-series min/max/avg/last summary rows", () => {
    const result = line({
      data: [
        [1, 2, 3, 4],
        [4, 3, 2, 1],
      ],
      seriesLabels: ["A", "B"],
    });
    const plain = result.toPlain();
    expect(plain).toContain("min");
    expect(plain).toContain("max");
    expect(plain).toContain("avg");
    expect(plain).toContain("last");
    expect(plain).toContain("min 1");
    expect(plain).toContain("max 4");
    expect(plain).toContain("avg 2.5");
    expect(plain).toContain("last 1");
  });

  it("renders dashed gridlines on y-step rows", () => {
    const result = line({ data: [10, 20, 15, 30, 25, 40, 35, 50], height: 16, noColor: true });
    expect(result.toPlain()).toContain("·");
  });

  it("summary: false suppresses the stats block", () => {
    const result = line({ data: [1, 2, 3], summary: false });
    const plain = result.toPlain();
    expect(plain).not.toContain("min");
    expect(plain).not.toContain("last");
  });

  it("noColor keeps the panel frame free of ANSI escapes", () => {
    const result = line({
      data: [1, 2, 3],
      title: "SYS",
      timestamp: "10:42 IST",
      status: "ok",
      noColor: true,
    });
    expect(result.toString()).not.toContain("\x1b[");
    expect(result.toPlain()).toContain("┌╌");
    expect(result.toPlain()).toContain("└╌");
  });
});
