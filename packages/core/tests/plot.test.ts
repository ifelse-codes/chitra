import { describe, it, expect } from "vitest";
import { plot } from "../src/plot.js";

describe("PlotBuilder", () => {
  it("builds a line chart", () => {
    const result = plot([1, 2, 3, 4, 5]).line();
    expect(result.toString()).toBeTruthy();
  });

  it("builds an area chart", () => {
    const result = plot([1, 2, 3]).area();
    expect(result.toString()).toBeTruthy();
  });

  it("builds a bar chart", () => {
    const result = plot([10, 20, 30]).bar();
    expect(result.toString()).toBeTruthy();
  });

  it("builds a horizontal bar chart", () => {
    const result = plot([10, 20, 30]).horizontalBar();
    expect(result.toString()).toBeTruthy();
  });

  it("builds a sparkline", () => {
    const result = plot([1, 2, 3]).sparkline();
    expect(result.toString()).toBeTruthy();
  });

  it("builds a histogram", () => {
    const data = Array.from({ length: 50 }, (_, i) => i);
    const result = plot(data).histogram(5);
    expect(result.toString()).toBeTruthy();
  });

  it("builds a pie chart", () => {
    const result = plot([30, 40, 30]).pie();
    expect(result.toString()).toBeTruthy();
  });

  it("builds a donut chart", () => {
    const result = plot([30, 40, 30]).donut();
    expect(result.toString()).toBeTruthy();
  });

  it("supports chaining", () => {
    const result = plot([1, 2, 3])
      .title("Test")
      .theme("nord")
      .width(50)
      .height(10)
      .noColor()
      .line();
    const plain = result.toPlain();
    expect(plain).toContain("Test");
  });

  it("supports multi-series", () => {
    const result = plot([
      [1, 2, 3],
      [3, 2, 1],
    ])
      .seriesLabels(["Alpha", "Beta"])
      .line();
    const plain = result.toPlain();
    expect(plain).toContain("Alpha");
    expect(plain).toContain("Beta");
  });

  it("supports all themes", () => {
    const themes = [
      "default",
      "nord",
      "dracula",
      "github-dark",
      "tokyo-night",
      "solarized",
      "monochrome",
    ] as const;
    for (const theme of themes) {
      expect(plot([1, 2, 3]).theme(theme).line().toString()).toBeTruthy();
    }
  });

  it("toString calls line render", () => {
    const result = plot([1, 2, 3]).toString();
    expect(typeof result).toBe("string");
    expect(result.length).toBeGreaterThan(0);
  });

  it("yRange clamps data", () => {
    const result = plot([10, 50, 90]).yRange(0, 100).noColor().line();
    const plain = result.toPlain();
    expect(plain).toContain("100");
  });
});
