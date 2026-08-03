import type { Theme, ThemeName } from "../types.js";
import { hexToAnsi, ansi } from "../ansi.js";

const h = hexToAnsi;

/** Greyscale tone ramp for mudra-style "one hue + tone ramp" separation. */
export const GREY_TONES: string[] = ["#ECECEF", "#C6C6CE", "#A4A4AE", "#6A6A75"].map(hexToAnsi);

export const themes: Record<ThemeName, Theme> = {
  default: {
    name: "default",
    colors: [
      ansi.brightCyan,
      ansi.brightMagenta,
      ansi.brightGreen,
      ansi.brightYellow,
      ansi.brightBlue,
      ansi.brightRed,
      ansi.brightWhite,
    ],
    accent: h("#8B7CF6"),
    tones: GREY_TONES,
    axis: ansi.brightBlack,
    label: ansi.white,
    title: ansi.bold + ansi.brightWhite,
    grid: ansi.brightBlack,
  },

  nord: {
    name: "nord",
    colors: [
      h("#88c0d0"),
      h("#81a1c1"),
      h("#a3be8c"),
      h("#ebcb8b"),
      h("#b48ead"),
      h("#bf616a"),
      h("#d08770"),
    ],
    accent: h("#88c0d0"),
    tones: GREY_TONES,
    axis: h("#4c566a"),
    label: h("#d8dee9"),
    title: h("#eceff4"),
    grid: h("#3b4252"),
  },

  dracula: {
    name: "dracula",
    colors: [
      h("#bd93f9"),
      h("#ff79c6"),
      h("#50fa7b"),
      h("#f1fa8c"),
      h("#8be9fd"),
      h("#ff5555"),
      h("#ffb86c"),
    ],
    accent: h("#bd93f9"),
    tones: GREY_TONES,
    axis: h("#6272a4"),
    label: h("#f8f8f2"),
    title: h("#ffffff"),
    grid: h("#44475a"),
  },

  "github-dark": {
    name: "github-dark",
    colors: [
      h("#58a6ff"),
      h("#f78166"),
      h("#3fb950"),
      h("#d29922"),
      h("#bc8cff"),
      h("#ff7b72"),
      h("#39c5cf"),
    ],
    accent: h("#58a6ff"),
    tones: GREY_TONES,
    axis: h("#30363d"),
    label: h("#8b949e"),
    title: h("#f0f6fc"),
    grid: h("#21262d"),
  },

  "tokyo-night": {
    name: "tokyo-night",
    colors: [
      h("#7aa2f7"),
      h("#bb9af7"),
      h("#9ece6a"),
      h("#e0af68"),
      h("#7dcfff"),
      h("#f7768e"),
      h("#73daca"),
    ],
    accent: h("#7aa2f7"),
    tones: GREY_TONES,
    axis: h("#3b4261"),
    label: h("#a9b1d6"),
    title: h("#c0caf5"),
    grid: h("#292e42"),
  },

  solarized: {
    name: "solarized",
    colors: [
      h("#268bd2"),
      h("#d33682"),
      h("#859900"),
      h("#b58900"),
      h("#2aa198"),
      h("#dc322f"),
      h("#6c71c4"),
    ],
    accent: h("#268bd2"),
    tones: GREY_TONES,
    axis: h("#586e75"),
    label: h("#93a1a1"),
    title: h("#fdf6e3"),
    grid: h("#073642"),
  },

  monochrome: {
    name: "monochrome",
    colors: [
      ansi.brightWhite,
      ansi.white,
      ansi.brightBlack,
      ansi.white,
      ansi.brightWhite,
      ansi.white,
      ansi.brightBlack,
    ],
    accent: ansi.brightWhite,
    tones: [ansi.white, ansi.brightBlack, ansi.black, ansi.brightBlack],
    axis: ansi.brightBlack,
    label: ansi.white,
    title: ansi.bold + ansi.brightWhite,
    grid: ansi.brightBlack,
  },
};

export function resolveTheme(theme: ThemeName | Theme | undefined): Theme {
  const base = typeof theme === "string" ? themes[theme] : theme;
  const t = base ?? themes.default;
  return {
    ...t,
    accent: t.accent ?? t.colors[0] ?? GREY_TONES[0]!,
    tones: t.tones ?? GREY_TONES,
  };
}

export { type Theme, type ThemeName };
