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
});
