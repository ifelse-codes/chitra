import { describe, it, expect } from "vitest";
import { sparkline } from "../src/charts/sparkline.js";

describe("sparkline", () => {
  it("renders blocks by default", () => {
    const result = sparkline({ data: [1, 3, 2, 5, 4] });
    expect(result.toString()).toBeTruthy();
  });

  it("renders braille", () => {
    const result = sparkline({ data: [1, 3, 2, 5, 4], renderer: "braille" });
    expect(result.toString()).toBeTruthy();
  });

  it("renders ascii", () => {
    const result = sparkline({ data: [1, 3, 2, 5, 4], renderer: "ascii" });
    expect(result.toString()).toBeTruthy();
  });

  it("uses block characters for blocks renderer", () => {
    const result = sparkline({ data: [1, 3, 2, 5, 4], renderer: "blocks", noColor: true });
    const str = result.toString();
    expect(str).toMatch(/[▁▂▃▄▅▆▇█]/);
  });

  it("shows label when provided", () => {
    const result = sparkline({ data: [1, 2, 3], label: "CPU", noColor: true });
    expect(result.toString()).toContain("CPU");
  });

  it("shows value when showValue is true", () => {
    const result = sparkline({ data: [1, 2, 42], showValue: true, noColor: true });
    expect(result.toString()).toContain("42");
  });

  it("handles empty data", () => {
    const result = sparkline({ data: [] });
    expect(result.toString()).toBe("");
  });

  it("toMarkdown uses backticks", () => {
    const md = sparkline({ data: [1, 2, 3] }).toMarkdown();
    expect(md).toMatch(/^`.*`$/);
  });

  it("toJSON has correct type", () => {
    const json = sparkline({ data: [1, 2, 3] }).toJSON() as Record<string, unknown>;
    expect(json.type).toBe("sparkline");
  });

  it("respects width option", () => {
    const result = sparkline({ data: [1, 2, 3, 4, 5], width: 3, renderer: "blocks", noColor: true });
    const str = result.toString();
    expect(str.length).toBe(3);
  });
});
