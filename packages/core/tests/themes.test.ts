import { describe, it, expect } from "vitest";
import { themes, resolveTheme } from "../src/themes/index.js";

describe("themes", () => {
  const themeNames = ["default", "nord", "dracula", "github-dark", "tokyo-night", "solarized", "monochrome"] as const;

  it("all themes are defined", () => {
    for (const name of themeNames) {
      expect(themes[name]).toBeDefined();
    }
  });

  it("each theme has required fields", () => {
    for (const name of themeNames) {
      const t = themes[name];
      expect(Array.isArray(t.colors)).toBe(true);
      expect(t.colors.length).toBeGreaterThanOrEqual(1);
      expect(typeof t.axis).toBe("string");
      expect(typeof t.label).toBe("string");
      expect(typeof t.title).toBe("string");
      expect(t.name).toBe(name);
    }
  });

  it("resolveTheme returns default for undefined", () => {
    const t = resolveTheme(undefined);
    expect(t.name).toBe("default");
  });

  it("resolveTheme resolves by name", () => {
    const t = resolveTheme("nord");
    expect(t.name).toBe("nord");
  });

  it("resolveTheme returns custom theme as-is", () => {
    const custom = {
      name: "custom",
      colors: ["red"],
      axis: "gray",
      label: "white",
      title: "bold",
    };
    const t = resolveTheme(custom);
    expect(t.name).toBe("custom");
    expect(t.colors[0]).toBe("red");
  });

  it("resolveTheme falls back to default for unknown name", () => {
    const t = resolveTheme("nonexistent" as never);
    expect(t.name).toBe("default");
  });
});
