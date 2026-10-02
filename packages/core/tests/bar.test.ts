import { describe, it, expect } from "vitest";
import { bar } from "../src/charts/bar.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme } from "../src/themes/index.js";

const SPARK_CHARS = /[▁▂▃▄▅▆▇█]/;

// Helper: get plain (ANSI-stripped) output as lines
function plainLines(opts: Parameters<typeof bar>[0]): string[] {
  return stripAnsi(bar(opts).toString()).split("\n");
}

describe("bar chart — locked S12 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    const lines = plainLines({ data: [10, 20, 30] });
    expect(lines[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ data: [10, 20, 30] });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has exactly one frame rule separator (│ ╌) — S29 B-diet+", () => {
    const lines = plainLines({ data: [10, 20, 30] });
    expect(lines.filter((l) => /^│ ╌+ │$/.test(l))).toHaveLength(1);
  });

  it("has eyebrow row (uppercase VALUES by default)", () => {
    const plain = stripAnsi(bar({ data: [10, 20, 30] }).toString());
    expect(plain).toContain("VALUES");
  });

  it("respects xLabel as eyebrow caption", () => {
    const plain = stripAnsi(bar({ data: [10, 20, 30], xLabel: "revenue" }).toString());
    expect(plain).toContain("REVENUE");
  });

  it("includes title in frame top when provided", () => {
    const plain = stripAnsi(bar({ data: [1, 2, 3], title: "Deploys" }).toString());
    expect(plain).toContain("Deploys");
  });

  // ── Axis ticks ─────────────────────────────────────────────────
  it("has + at top of y-axis guide", () => {
    const plain = stripAnsi(bar({ data: [10, 20, 30], showAxes: true }).toString());
    expect(plain).toMatch(/\+/);
  });

  it("has + x-tick row between plot and labels", () => {
    const result = bar({
      data: [10, 20, 30],
      labels: ["A", "B", "C"],
      showAxes: true,
    });
    const plain = stripAnsi(result.toString());
    // There should be a row of `+` marks (x-ticks) between the plot and labels
    const lines = plain.split("\n");
    const tickRowIdx = lines.findIndex((l) => /│ [ +]{2,}│/.test(l) && l.includes("+"));
    expect(tickRowIdx).toBeGreaterThan(-1);
  });

  // ── Summary rows ───────────────────────────────────────────────
  it("has per-series summary row with avg/peak", () => {
    const plain = stripAnsi(bar({ data: [10, 20, 30, 15, 25] }).toString());
    expect(plain).toContain("avg");
    expect(plain).toContain("peak");
    expect(plain).not.toContain("min ");
    expect(plain).not.toContain("last ");
  });

  it("summary contains correct peak value", () => {
    const plain = stripAnsi(bar({ data: [10, 50, 30] }).toString());
    expect(plain).toContain("peak 50");
  });

  it("summary contains correct avg value", () => {
    const plain = stripAnsi(bar({ data: [10, 50, 30] }).toString());
    expect(plain).toContain("avg 30");
  });

  // ── Color contract ─────────────────────────────────────────────
  it("produces no ANSI in noColor mode", () => {
    expect(bar({ data: [1, 2, 3], noColor: true }).toString()).not.toContain("\x1b[");
  });

  it("applies accent to the peak bar and tone ramp to all others (no rainbow)", () => {
    const plain = stripAnsi(bar({ data: [10, 99, 30], noColor: true }).toString());
    expect(plain).toContain("█");
    expect(plain).toContain("peak 99");
  });

  it("colors the peak bar with theme.accent and every other bar with a theme.tones entry (real color check)", () => {
    const theme = resolveTheme("default");
    // showAxes: false isolates the plot's bar cells from y-axis-label/x-tick/x-label chrome,
    // which are colored with theme.axis/theme.label and would otherwise pollute the scan below.
    const raw = bar({ data: [10, 99, 30], theme: "default", showAxes: false }).toString();
    // The peak (value 99) bar must use the accent color at least once (its tallest cell).
    expect(raw).toContain(theme.accent);
    // Every colorize()'d bar cell must be either the accent or a grey tone — never a raw
    // `theme.colors[s % n]` rainbow entry (a regression this specifically guards against).
    // Only `█` cells are ever colorize()'d in the plot (blank cells are plain spaces); scoping
    // the lookahead to the glyph itself excludes unrelated chrome (e.g. the frame's title).
    const cellColorCodes = [...raw.matchAll(/\x1b\[[0-9;]*m(?=█)/g)].map((m) => m[0]);
    expect(cellColorCodes.length).toBeGreaterThan(0);
    for (const code of cellColorCodes) {
      expect(code === theme.accent || theme.tones!.includes(code)).toBe(true);
    }
  });

  it("never uses a raw theme.colors[] rainbow entry for bar fill color, across every built-in theme", () => {
    const themeNames = [
      "default",
      "nord",
      "dracula",
      "github-dark",
      "tokyo-night",
      "solarized",
      "monochrome",
    ] as const;
    for (const name of themeNames) {
      const theme = resolveTheme(name);
      const raw = bar({ data: [10, 99, 30, 55], theme: name, showAxes: false }).toString();
      const cellColorCodes = [...raw.matchAll(/\x1b\[[0-9;]*m(?=█)/g)].map((m) => m[0]);
      const rainbowOnly = theme.colors.filter(
        (c) => c !== theme.accent && !theme.tones!.includes(c)
      );
      for (const code of cellColorCodes) {
        expect(rainbowOnly).not.toContain(code);
      }
    }
  });

  it("renders a real sparkline glyph in the default-width summary row (not silently starved to width 0)", () => {
    // Regression test: the panel's own auto-width formula used to size itself exactly to the
    // summary text with zero room left over for the spark, so sparkStr() always returned "".
    const plain = stripAnsi(bar({ data: [10, 20, 30, 15, 25] }).toString());
    const summaryLine = plain.split("\n").find((l) => l.includes("peak 30"));
    expect(summaryLine).toBeDefined();
    expect(summaryLine).toMatch(SPARK_CHARS);
  });

  it("renders a sparkline for every series in a multi-series chart's default width", () => {
    const plain = stripAnsi(
      bar({
        data: [
          [10, 20, 15],
          [8, 25, 12],
        ],
        seriesLabels: ["Up", "Down"],
      }).toString()
    );
    const lines = plain.split("\n").filter((l) => l.includes("avg") && l.includes("peak"));
    expect(lines.length).toBe(2);
    for (const line of lines) {
      expect(line).toMatch(SPARK_CHARS);
    }
  });

  // ── Multi-series ───────────────────────────────────────────────
  it("renders multi-series with legend", () => {
    const plain = stripAnsi(
      bar({
        data: [
          [10, 20],
          [15, 25],
        ],
        seriesLabels: ["Alpha", "Beta"],
      }).toString()
    );
    expect(plain).toContain("Alpha");
    expect(plain).toContain("Beta");
  });

  it("multi-series summary has a row per series", () => {
    const plain = stripAnsi(
      bar({
        data: [
          [10, 20],
          [15, 25],
        ],
        seriesLabels: ["A", "B"],
      }).toString()
    );
    // Both series appear in summary (each has avg/peak)
    const peakMatches = (plain.match(/peak /g) ?? []).length;
    expect(peakMatches).toBeGreaterThanOrEqual(2);
  });

  // ── Edge cases ─────────────────────────────────────────────────
  it("handles single value", () => {
    expect(bar({ data: [42] }).toString()).toBeTruthy();
  });

  it("handles negative values", () => {
    const plain = stripAnsi(bar({ data: [-10, 5, -3, 15], yMin: -15 }).toString());
    expect(plain).toBeTruthy();
  });

  it("handles yMin/yMax override and shows max in frame", () => {
    const plain = stripAnsi(bar({ data: [1, 2, 3], yMin: 0, yMax: 100 }).toString());
    expect(plain).toContain("100");
  });

  it("supports all themes without error", () => {
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
      expect(bar({ data: [1, 2, 3], theme }).toString()).toBeTruthy();
    }
  });

  it("supports ascii renderer", () => {
    const plain = stripAnsi(bar({ data: [10, 20, 30], renderer: "ascii" }).toString());
    expect(plain).toContain("avg");
    expect(plain).toContain("peak");
  });

  it("toMarkdown wraps in code block", () => {
    const md = bar({ data: [1, 2, 3] }).toMarkdown();
    expect(md).toMatch(/^```\n/);
    expect(md).toMatch(/\n```$/);
  });

  it("toJSON returns structured data with type bar", () => {
    const json = bar({ data: [10, 20, 30], title: "Test" }).toJSON() as Record<string, unknown>;
    expect(json.type).toBe("bar");
    expect(json.title).toBe("Test");
    expect(json.plain).toBeTruthy();
  });

  it("renders x-axis labels when provided", () => {
    const plain = stripAnsi(
      bar({ data: [10, 20, 30], labels: ["Jan", "Feb", "Mar"], showAxes: true }).toString()
    );
    expect(plain).toMatch(/J/);
  });
});
