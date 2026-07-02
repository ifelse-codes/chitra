import { describe, it, expect } from "vitest";
import { BrailleCanvas, plotLineOnBrailleCanvas } from "../src/renderers/braille.js";
import { sparklineBlocks, buildHorizontalBlockBar, blockHeight, shadeCell } from "../src/renderers/blocks.js";
import { sparklineAscii, buildAsciiHBar } from "../src/renderers/ascii.js";
import { ansi, colorize, stripAnsi, hexToAnsi, padEnd, padStart } from "../src/ansi.js";
import { normalize, clamp, minMax, formatNumber, quartiles, center, truncate } from "../src/utils.js";

describe("BrailleCanvas", () => {
  it("initializes with correct dimensions", () => {
    const c = new BrailleCanvas(10, 5);
    expect(c.cols).toBe(10);
    expect(c.rows).toBe(5);
    expect(c.dotCols).toBe(20);
    expect(c.dotRows).toBe(20);
  });

  it("toLines returns correct row count", () => {
    const c = new BrailleCanvas(10, 5);
    expect(c.toLines().length).toBe(5);
  });

  it("set and isSet work correctly", () => {
    const c = new BrailleCanvas(5, 5);
    c.set(0, 0);
    expect(c.isSet(0, 0)).toBe(true);
    expect(c.isSet(1, 0)).toBe(false);
  });

  it("unset clears a dot", () => {
    const c = new BrailleCanvas(5, 5);
    c.set(0, 0);
    c.unset(0, 0);
    expect(c.isSet(0, 0)).toBe(false);
  });

  it("clear empties all dots", () => {
    const c = new BrailleCanvas(5, 5);
    c.set(0, 0);
    c.set(1, 1);
    c.clear();
    expect(c.isSet(0, 0)).toBe(false);
    expect(c.isSet(1, 1)).toBe(false);
  });

  it("ignores out-of-bounds set", () => {
    const c = new BrailleCanvas(5, 5);
    expect(() => c.set(-1, 0)).not.toThrow();
    expect(() => c.set(100, 100)).not.toThrow();
  });

  it("fillColumn sets all dots in range", () => {
    const c = new BrailleCanvas(5, 5);
    c.fillColumn(0, 0, 3);
    for (let r = 0; r <= 3; r++) {
      expect(c.isSet(0, r)).toBe(true);
    }
  });

  it("plotLineOnBrailleCanvas produces non-empty output", () => {
    const c = new BrailleCanvas(20, 10);
    plotLineOnBrailleCanvas(c, [1, 2, 3, 2, 1], 1, 3);
    const lines = c.toLines();
    const hasContent = lines.some((l) =>
      l.split("").some((ch) => ch.codePointAt(0)! !== 0x2800)
    );
    expect(hasContent).toBe(true);
  });
});

describe("block renderer", () => {
  it("sparklineBlocks returns correct length", () => {
    const result = sparklineBlocks([1, 2, 3, 4, 5], 5);
    expect(result.length).toBe(5);
  });

  it("uses block chars", () => {
    const result = sparklineBlocks([0, 5, 10]);
    expect(result).toMatch(/[▁▂▃▄▅▆▇█ ]/);
  });

  it("handles empty data", () => {
    expect(sparklineBlocks([])).toBe("");
  });

  it("blockHeight returns correct chars", () => {
    expect(blockHeight(0)).toBe(" ");
    expect(blockHeight(1)).toBe("█");
    expect(blockHeight(0.5)).toBe("▄");
  });

  it("buildHorizontalBlockBar returns correct length", () => {
    const bar = buildHorizontalBlockBar(50, 0, 100, 10);
    expect(bar.length).toBe(10);
  });

  it("shadeCell returns correct char", () => {
    expect(shadeCell(0)).toBe(" ");
    expect(shadeCell(1)).toBe("█");
  });
});

describe("ascii renderer", () => {
  it("sparklineAscii returns correct length", () => {
    const result = sparklineAscii([1, 2, 3, 4, 5], 5);
    expect(result.length).toBe(5);
  });

  it("buildAsciiHBar respects width", () => {
    const bar = buildAsciiHBar(50, 0, 100, 10);
    expect(bar.length).toBe(10);
  });

  it("handles zero range", () => {
    expect(() => sparklineAscii([5, 5, 5])).not.toThrow();
  });
});

describe("ANSI utilities", () => {
  it("colorize wraps with reset", () => {
    const c = colorize("hello", ansi.red, false);
    expect(c).toContain("\x1b[");
    expect(c).toContain("hello");
    expect(c).toContain("\x1b[0m");
  });

  it("colorize returns plain text in noColor mode", () => {
    const c = colorize("hello", ansi.red, true);
    expect(c).toBe("hello");
  });

  it("stripAnsi removes escape codes", () => {
    const input = "\x1b[31mred\x1b[0m";
    expect(stripAnsi(input)).toBe("red");
  });

  it("hexToAnsi produces valid escape", () => {
    const c = hexToAnsi("#ff0000");
    expect(c).toContain("\x1b[38;2;255;0;0m");
  });

  it("padEnd pads correctly", () => {
    expect(padEnd("hi", 5)).toBe("hi   ");
    expect(padEnd("hello world", 5)).toBe("hello world");
  });

  it("padStart pads correctly", () => {
    expect(padStart("hi", 5)).toBe("   hi");
  });
});

describe("utils", () => {
  it("clamp works", () => {
    expect(clamp(5, 0, 10)).toBe(5);
    expect(clamp(-5, 0, 10)).toBe(0);
    expect(clamp(15, 0, 10)).toBe(10);
  });

  it("normalize maps range", () => {
    expect(normalize(5, 0, 10)).toBe(0.5);
    expect(normalize(0, 0, 10)).toBe(0);
    expect(normalize(10, 0, 10)).toBe(1);
  });

  it("normalize handles zero range", () => {
    expect(normalize(5, 5, 5)).toBe(0);
  });

  it("minMax finds correct values", () => {
    const { min, max } = minMax([3, 1, 4, 1, 5, 9, 2, 6]);
    expect(min).toBe(1);
    expect(max).toBe(9);
  });

  it("formatNumber formats correctly", () => {
    expect(formatNumber(1000)).toBe("1.0K");
    expect(formatNumber(1_000_000)).toBe("1.0M");
    expect(formatNumber(42)).toBe("42");
    expect(formatNumber(3.14159)).toBe("3.14");
  });

  it("quartiles computes correctly", () => {
    const stats = quartiles([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    expect(stats.median).toBeCloseTo(5.5, 1);
    expect(stats.min).toBe(1);
    expect(stats.max).toBe(10);
    expect(stats.iqr).toBeGreaterThan(0);
  });

  it("center centers text", () => {
    expect(center("hi", 6)).toBe("  hi  ");
  });

  it("truncate truncates long text", () => {
    const t = truncate("hello world", 8);
    expect(t.length).toBe(8);
    expect(t).toContain("…");
  });
});
