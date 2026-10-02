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

  it("has exactly one frame rule separator (│ ╌) — S29 B-diet+", () => {
    const lines = line({ data: [1, 2, 3] })
      .toPlain()
      .split("\n");
    expect(lines.filter((l) => /^│ ╌+ │$/.test(l))).toHaveLength(1);
  });

  it("texture-codes series strokes in monochrome (solid primary, dashed, dotted)", () => {
    const result = line({
      data: [
        [1, 1, 1, 1],
        [2, 2, 2, 2],
        [3, 3, 3, 3],
      ],
      seriesLabels: ["A", "B", "C"],
      noColor: true,
      height: 15,
      renderer: "braille",
    });
    const rows = result.toPlain().split("\n");
    const brailleCount = (s: string): number =>
      [...s].filter((ch) => {
        const code = ch.charCodeAt(0);
        return code >= 0x2800 && code <= 0x28ff;
      }).length;
    const counts = rows
      .map(brailleCount)
      .filter((n) => n > 0)
      .sort((a, b) => b - a);
    expect(counts.length).toBe(3);
    expect(counts[0]!).toBeGreaterThan(counts[1]!);
    expect(counts[1]!).toBeGreaterThan(counts[2]!);
  });

  it("renders solid strokes in colour mode (texture is monochrome-only)", () => {
    const opts = {
      data: [
        [2, 2, 2, 2],
        [3, 3, 3, 3],
        [4, 4, 4, 4],
      ],
      seriesLabels: ["A", "B", "C"],
      yMin: 1,
      yMax: 5,
      height: 15,
      renderer: "braille" as const,
    };
    const totalBraille = (noColor: boolean): number =>
      line({ ...opts, noColor })
        .toPlain()
        .split("\n")
        .map(
          (s) =>
            [...s].filter((ch) => {
              const code = ch.charCodeAt(0);
              return code >= 0x2800 && code <= 0x28ff;
            }).length
        )
        .reduce((a, b) => a + b, 0);
    const colour = totalBraille(false);
    const mono = totalBraille(true);
    expect(colour).toBeGreaterThan(mono * 1.5);
  });

  it("draws solid legend dashes in colour mode", () => {
    const result = line({
      data: [
        [1, 2, 3, 4, 5, 6, 7, 8],
        [8, 7, 6, 5, 4, 3, 2, 1],
        [4, 5, 4, 5, 4, 5, 4, 5],
      ],
      seriesLabels: ["A", "B", "C"],
      renderer: "braille",
    });
    const plain = result.toPlain();
    expect(plain).toContain("──○── B");
    expect(plain).toContain("──+── C");
    expect(plain).not.toContain("╌╌○╌╌");
    expect(plain).not.toContain("··+··");
  });

  it("renders + x-tick marks under the plot and a + at the top of the y-guide", () => {
    const plain = line({ data: [1, 2, 3, 4, 5, 6, 7, 8], noColor: true, height: 15 }).toPlain();
    const lines = plain.split("\n");
    const labelIdx = lines.findIndex((l) => l.includes("7") && /\d\s+\d/.test(l));
    expect(labelIdx).toBeGreaterThan(0);
    expect(lines[labelIdx - 1]!.replace(/[│]/g, " ").trim()).toMatch(/^\+(\s*\+)*$/);
    expect(plain).toContain("│ 8+");
  });

  it("renders per-series spark bars in the summary rows", () => {
    const plain = line({
      data: [
        [1, 2, 3, 4],
        [4, 3, 2, 1],
      ],
      seriesLabels: ["A", "B"],
      noColor: true,
    }).toPlain();
    expect(plain).toContain("▁");
    expect(plain).toContain("█");
  });

  it("renders per-series lowest/highest/avg/last summary rows", () => {
    const result = line({
      data: [
        [1, 2, 3, 4],
        [4, 3, 2, 1],
      ],
      seriesLabels: ["A", "B"],
    });
    const plain = result.toPlain();
    expect(plain).toContain("lowest");
    expect(plain).toContain("highest");
    expect(plain).toContain("avg");
    expect(plain).toContain("last");
    expect(plain).toContain("lowest 1");
    expect(plain).toContain("highest 4");
    expect(plain).toContain("avg 2.5");
    expect(plain).toContain("last 1");
  });

  it("renders dashed gridlines on y-step rows when grid is enabled", () => {
    const result = line({
      data: [10, 20, 15, 30, 25, 40, 35, 50],
      height: 16,
      noColor: true,
      grid: true,
    });
    expect(result.toPlain()).toContain("· · ·"); // the dotted grid cadence
  });

  it("omits the dotted grid backdrop by default", () => {
    const result = line({ data: [10, 20, 15, 30, 25, 40, 35, 50], height: 16, noColor: true });
    expect(result.toPlain()).not.toContain("· · ·");
  });

  it("summary: false suppresses the stats block", () => {
    const result = line({ data: [1, 2, 3], summary: false });
    const plain = result.toPlain();
    expect(plain).not.toContain("lowest");
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
