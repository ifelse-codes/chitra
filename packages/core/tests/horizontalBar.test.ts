import { describe, it, expect } from "vitest";
import { horizontalBar } from "../src/charts/horizontalBar.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme } from "../src/themes/index.js";

// Helper: get plain (ANSI-stripped) output as lines
function plainLines(opts: Parameters<typeof horizontalBar>[0]): string[] {
  return stripAnsi(horizontalBar(opts).toString()).split("\n");
}

const ALL_THEMES = [
  "default",
  "nord",
  "dracula",
  "github-dark",
  "tokyo-night",
  "solarized",
  "monochrome",
] as const;

describe("horizontalBar chart — locked S19 design", () => {
  // ── Panel chrome (criterion 2) ─────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    const lines = plainLines({ data: [10, 20, 30] });
    expect(lines[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ data: [10, 20, 30] });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has exactly one frame rule separator (│ ╌) — S29 B-diet+", () => {
    const plain = stripAnsi(horizontalBar({ data: [10, 20, 30] }).toString());
    expect(plain.split("\n").filter((l) => /^│ ╌+ │$/.test(l))).toHaveLength(1);
  });

  it("has eyebrow row (uppercase VALUES by default)", () => {
    const plain = stripAnsi(horizontalBar({ data: [10, 20, 30] }).toString());
    expect(plain).toContain("VALUES");
  });

  it("respects xLabel as eyebrow caption (uppercased)", () => {
    const plain = stripAnsi(horizontalBar({ data: [10, 20, 30], xLabel: "revenue" }).toString());
    expect(plain).toContain("REVENUE");
  });

  it("includes title in frame top when provided", () => {
    const plain = stripAnsi(horizontalBar({ data: [1, 2, 3], title: "Deploys" }).toString());
    expect(plain).toContain("Deploys");
  });

  it("has a rotated value-axis guide with + tick marks", () => {
    const plain = stripAnsi(horizontalBar({ data: [10, 20, 30], showAxes: true }).toString());
    // A tick row carrying the `+` value-axis vocabulary (baseline + max columns).
    expect(plain).toMatch(/\+╌+\+/);
  });

  // ── Color contract: accent-once + grey ramp, raw-RGB (criterion 1) ─────────
  it("produces no ANSI in noColor mode", () => {
    expect(horizontalBar({ data: [1, 2, 3], noColor: true }).toString()).not.toContain("\x1b[");
  });

  it("spends the accent hue EXACTLY once — on the global-max bar (raw-RGB accent count == 1)", () => {
    const theme = resolveTheme("default");
    // showAxes:false isolates the bar cells from axis/label chrome (colored with
    // theme.axis/theme.label), so the scan below only sees bar glyphs.
    const raw = horizontalBar({
      data: [12, 47, 23, 8, 35],
      theme: "default",
      showAxes: false,
    }).toString();
    // Only `█` cells are colorize()'d in the plot; each bar contributes one color
    // code immediately before its `█` run. Scope the lookahead to the glyph itself.
    const cellCodes = [...raw.matchAll(/\x1b\[[0-9;]*m(?=█)/g)].map((m) => m[0]);
    const accentCount = cellCodes.filter((c) => c === theme.accent).length;
    expect(accentCount).toBe(1);
  });

  it("colors every non-peak bar with a grey tone — never a raw theme.colors rainbow entry, across all themes", () => {
    for (const name of ALL_THEMES) {
      const theme = resolveTheme(name);
      const raw = horizontalBar({
        data: [12, 47, 23, 8, 35],
        theme: name,
        showAxes: false,
      }).toString();
      const cellCodes = [...raw.matchAll(/\x1b\[[0-9;]*m(?=█)/g)].map((m) => m[0]);
      expect(cellCodes.length).toBeGreaterThan(0);
      // Every bar cell code must be the accent or a grey tone — never a rainbow hue.
      for (const code of cellCodes) {
        expect(code === theme.accent || theme.tones!.includes(code)).toBe(true);
      }
      const rainbowOnly = theme.colors.filter(
        (c) => c !== theme.accent && !theme.tones!.includes(c)
      );
      for (const code of cellCodes) {
        expect(rainbowOnly).not.toContain(code);
      }
    }
  });

  // ── No phantom fill (criterion 3) ──────────────────────────────
  it("NEVER writes the ░ phantom filler — empty cells are spaces (blocks renderer)", () => {
    const raw = horizontalBar({ data: [12, 47, 23, 8, 35] }).toString();
    expect(raw).not.toContain("░");
  });

  it("NEVER writes the ░ phantom filler — ascii renderer either", () => {
    const raw = horizontalBar({ data: [12, 47, 23, 8, 35], renderer: "ascii" }).toString();
    expect(raw).not.toContain("░");
  });

  // ── Value labels + accent peak (criterion 4) ───────────────────
  it("renders each item's value label", () => {
    const plain = stripAnsi(
      horizontalBar({ data: [12, 47, 23], labels: ["a", "b", "c"] }).toString()
    );
    expect(plain).toContain("12");
    expect(plain).toContain("47");
    expect(plain).toContain("23");
  });

  it("renders the peak item's value in the accent hue", () => {
    const theme = resolveTheme("default");
    const raw = horizontalBar({ data: [12, 47, 23], theme: "default" }).toString();
    // The peak value (47) label must be wrapped in the accent color.
    expect(raw).toContain(theme.accent + "47");
  });

  it("names the peak item in the summary row", () => {
    const plain = stripAnsi(
      horizontalBar({ data: [12, 47, 23], labels: ["a", "b", "c"] }).toString()
    );
    expect(plain).toContain("3 items · peak b (47)");
  });

  // ── Auto-scale + auto-width (criterion 5) ──────────────────────
  it("auto-expands panel width so long labels are never clipped", () => {
    const lines = plainLines({ data: [1, 2], labels: ["a-very-long-label-name", "b"] });
    const barRow = lines.find((l) => l.includes("a-very-long-label-name"));
    expect(barRow).toBeDefined();
    // The full label survives inside the frame (not truncated).
    expect(barRow).toContain("a-very-long-label-name");
    expect(barRow!.trimEnd().endsWith("│")).toBe(true);
  });

  it("auto-scales the value axis with a min(0, dataMin) baseline", () => {
    const plain = stripAnsi(horizontalBar({ data: [10, 20, 30] }).toString());
    // The rotated axis-scale row shows the baseline 0 at the left.
    expect(plain).toMatch(/\n│\s+0\s+30\s+│/);
  });

  it("respects an explicit yMax override", () => {
    const plain = stripAnsi(horizontalBar({ data: [1, 2, 3], yMin: 0, yMax: 100 }).toString());
    expect(plain).toContain("100");
  });

  // ── Degenerate input (criterion 6) ─────────────────────────────
  it("renders empty data safely (no crash, no NaN)", () => {
    const plain = stripAnsi(horizontalBar({ data: [] }).toString());
    expect(plain).toContain("0 items · (no data)");
    expect(plain).not.toContain("NaN");
    expect(plain.split("\n")[0]).toMatch(/^┌╌/);
  });

  it("renders a single item safely", () => {
    const plain = stripAnsi(horizontalBar({ data: [42], labels: ["only"] }).toString());
    expect(plain).toContain("42");
    expect(plain).toContain("peak only");
    expect(plain).not.toContain("NaN");
  });

  it("renders all-equal values safely (no NaN)", () => {
    const plain = stripAnsi(horizontalBar({ data: [5, 5, 5], labels: ["a", "b", "c"] }).toString());
    expect(plain).not.toContain("NaN");
    expect(plain).toContain("peak a"); // first max wins the tie
  });

  it("breaks accent ties toward the FIRST maximum in data order", () => {
    const theme = resolveTheme("default");
    // Two equal maxima (9) at index 1 and 2 — the accent must land on index 1 only.
    const raw = horizontalBar({
      data: [5, 9, 9, 2],
      labels: ["a", "b", "c", "d"],
      showAxes: false,
    }).toString();
    const cellCodes = [...raw.matchAll(/\x1b\[[0-9;]*m(?=█)/g)].map((m) => m[0]);
    expect(cellCodes.filter((c) => c === theme.accent).length).toBe(1);
    const plain = stripAnsi(raw);
    expect(plain).toContain("peak b");
  });

  // ── API stability + formats ────────────────────────────────────
  it("toJSON returns structured data with type horizontalBar", () => {
    const json = horizontalBar({ data: [10, 20, 30], labels: ["a", "b", "c"] }).toJSON() as Record<
      string,
      unknown
    >;
    expect(json.type).toBe("horizontalBar");
    expect(json.data).toEqual([10, 20, 30]);
    expect(json.labels).toEqual(["a", "b", "c"]);
    expect(json.plain).toBeTruthy();
  });

  it("toMarkdown wraps in a code block", () => {
    const md = horizontalBar({ data: [1, 2, 3] }).toMarkdown();
    expect(md).toMatch(/^```\n/);
    expect(md).toMatch(/\n```$/);
  });

  it("supports all themes without error", () => {
    for (const theme of ALL_THEMES) {
      expect(horizontalBar({ data: [1, 2, 3], theme }).toString()).toBeTruthy();
    }
  });
});
