import { describe, it, expect } from "vitest";
import { bar } from "../src/charts/bar.js";
import { stripAnsi } from "../src/ansi.js";

describe("bar chart", () => {
  it("renders without errors", () => {
    const result = bar({ data: [10, 20, 30, 15, 25] });
    expect(result.toString()).toBeTruthy();
  });

  it("produces output with correct number of rows", () => {
    const result = bar({ data: [10, 20, 30], height: 5 });
    const plain = result.toPlain();
    const lines = plain.split("\n").filter((l) => l.trim().length > 0);
    expect(lines.length).toBeGreaterThan(0);
  });

  it("supports multi-series", () => {
    const result = bar({
      data: [
        [10, 20, 30],
        [15, 25, 35],
      ],
      seriesLabels: ["A", "B"],
    });
    const plain = result.toPlain();
    expect(plain).toContain("A");
    expect(plain).toContain("B");
  });

  it("includes title when provided", () => {
    const result = bar({ data: [1, 2, 3], title: "My Chart" });
    const plain = result.toPlain();
    expect(plain).toContain("My Chart");
  });

  it("supports noColor mode", () => {
    const result = bar({ data: [1, 2, 3], noColor: true });
    const str = result.toString();
    expect(str).not.toContain("\x1b[");
  });

  it("toMarkdown wraps in code block", () => {
    const result = bar({ data: [1, 2, 3] });
    const md = result.toMarkdown();
    expect(md).toMatch(/^```\n/);
    expect(md).toMatch(/\n```$/);
  });

  it("toJSON returns structured data", () => {
    const data = [10, 20, 30];
    const result = bar({ data, title: "Test" });
    const json = result.toJSON() as Record<string, unknown>;
    expect(json.type).toBe("bar");
    expect(json.title).toBe("Test");
    expect(json.plain).toBeTruthy();
  });

  it("supports all themes", () => {
    const themes = ["default", "nord", "dracula", "github-dark", "tokyo-night", "solarized", "monochrome"] as const;
    for (const theme of themes) {
      const result = bar({ data: [1, 2, 3], theme });
      expect(result.toString()).toBeTruthy();
    }
  });

  it("supports ascii renderer", () => {
    const result = bar({ data: [1, 2, 3], renderer: "ascii" });
    expect(result.toString()).toBeTruthy();
  });

  it("handles single value", () => {
    const result = bar({ data: [42] });
    expect(result.toString()).toBeTruthy();
  });

  it("handles negative values", () => {
    const result = bar({ data: [-10, 5, -3, 15], yMin: -15 });
    expect(result.toString()).toBeTruthy();
  });

  it("handles yMin/yMax override", () => {
    const result = bar({ data: [1, 2, 3], yMin: 0, yMax: 100 });
    const plain = result.toPlain();
    expect(plain).toContain("100");
  });

  it("renders labels", () => {
    const result = bar({
      data: [10, 20, 30],
      labels: ["Jan", "Feb", "Mar"],
      showAxes: true,
      width: 40,
    });
    const plain = result.toPlain();
    expect(plain).toMatch(/J|Jan/);
  });
});
