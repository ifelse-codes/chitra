// Session 09 demo — the design-reference language applied to a DONUT chart.
// Shows the CURRENT bare donut vs the TARGET look (dashed frame, one accent
// hue + tone ramp, glyph legend, metric cells, status footer, eyebrow caption).
// Demo only — no library code changes.

import { donut } from "../../packages/core/src/charts/donut.js";
import {
  colorize,
  hexToAnsi,
  stripAnsi,
  visibleLength,
  ansi,
} from "../../packages/core/src/ansi.js";
import { formatNumber } from "../../packages/core/src/utils.js";

const h = hexToAnsi;

// ── design-language tokens (mudra-chart + mudra-dashboard terminal theme) ──
const TOKENS = {
  frame: "#8B7CF6", // violet — the ONE accent hue
  frameSoft: "#3A3A44",
  ink: "#ECECEF",
  ink2: "#A4A4AE",
  ink3: "#6A6A75",
  tones: ["#ECECEF", "#C6C6CE", "#A4A4AE", "#6A6A75"], // greyscale ramp
  grid: "rgba(255,255,255,0.055)",
};
const GLYPHS = ["*", "o", "+", "x"];

interface Slice {
  name: string;
  value: number;
  unit: string;
  primary: boolean;
  tone: number;
}

const SLICES: Slice[] = [
  { name: "CPU", value: 1240000, unit: "rpm", primary: true, tone: 0 },
  { name: "MEM", value: 380000, unit: "rpm", primary: false, tone: 1 },
  { name: "NET", value: 170000, unit: "rpm", primary: false, tone: 2 },
  { name: "IO", value: 14000, unit: "rpm", primary: false, tone: 3 },
];

const total = SLICES.reduce((a, s) => a + s.value, 0);
const pct = (s: Slice) => (s.value / total) * 100;
const fmt = (n: number) => {
  if (n >= 1e6) return (n / 1e6).toFixed(2) + "M";
  if (n >= 1e3) return (n / 1e3).toFixed(0) + "K";
  return String(n);
};

// slice color: primary gets the accent hue, others get the tone ramp
const sliceColor = (s: Slice) => (s.primary ? h(TOKENS.frame) : h(TOKENS.tones[s.tone]));

// ── tui-chart variant: distinct hue per series (cpu/mem/net/io palette) ──
const TUI_COLORS = ["#8ae234", "#e9b83c", "#34e2e2", "#f25fd0"];
const tuiColor = (i: number) => h(TUI_COLORS[i % TUI_COLORS.length]!);
const TUI_FRAME = "#4ee06a";

function sliceChar(i: number): string {
  return ["█", "▓", "▒", "░"][i % 4]!;
}

// ── render the donut ring ──
// sliceColorAt(i, primary) chooses the color; inkColor for the center value.
function renderRing(radius: number, inner: number, colorAt: (i: number, primary: boolean) => string, inkColor: string): string[] {
  const cx = radius * 2;
  const cy = radius;
  const rows = radius * 2 + 1;
  const cols = radius * 4 + 1;
  const cumulative: number[] = [];
  let cum = 0;
  for (const s of SLICES) {
    cum += (s.value / total) * Math.PI * 2;
    cumulative.push(cum);
  }
  const centerText = fmt(total);
  const centerRow = Math.floor(rows / 2);
  const out: string[] = [];

  for (let row = 0; row < rows; row++) {
    let rowStr = "";
    for (let col = 0; col < cols; col++) {
      const dx = (col - cx) / 2;
      const dy = row - cy;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist >= inner && dist <= radius) {
        const angle = (Math.atan2(dy, dx) + Math.PI * 2) % (Math.PI * 2);
        let idx = SLICES.length - 1;
        for (let i = 0; i < cumulative.length; i++) {
          if (angle < cumulative[i]) {
            idx = i;
            break;
          }
        }
        rowStr += colorize(sliceChar(idx), colorAt(idx, SLICES[idx]!.primary), false);
      } else if (dist < inner) {
        if (row === centerRow) {
          const offset = col - cx + Math.floor(centerText.length / 2);
          if (offset >= 0 && offset < centerText.length) {
            rowStr += colorize(centerText[offset]!, inkColor, false);
          } else {
            rowStr += " ";
          }
        } else {
          rowStr += " ";
        }
      } else {
        rowStr += " ";
      }
    }
    out.push(rowStr);
  }
  return out;
}

// ── panel primitives (dashed frame, per design language) ──
function dashTop(width: number, title: string, stamp: string, frame: string, frameSoft: string): string {
  const inner = width - 2;
  const left = ` ${title} `;
  const right = ` ${stamp} `;
  const mid = Math.max(1, inner - 2 - visibleLength(left) - visibleLength(right));
  return (
    colorize("┌╌", h(frame), false) +
    colorize(left, h(TOKENS.ink), false) +
    colorize("╌".repeat(mid), h(frameSoft), false) +
    colorize(right, h(frame), false) +
    colorize("╌┐", h(frame), false)
  );
}

function dashBottom(width: number, frameSoft: string): string {
  return colorize("└" + "╌".repeat(width - 2) + "┘", h(frameSoft), false);
}

function dashRow(width: number, content: string, frameSoft: string): string {
  const inner = width - 4;
  const pad = " ".repeat(Math.max(0, inner - visibleLength(content)));
  return colorize("│ ", h(frameSoft), false) + content + pad + colorize(" │", h(frameSoft), false);
}

function dashRule(width: number, frameSoft: string): string {
  return colorize("│ " + "╌".repeat(width - 4) + " │", h(frameSoft), false);
}

// ── metric cells: value big, pct beneath ──
function metricCells(width: number, colorAt: (i: number, primary: boolean) => string): string[] {
  const inner = width - 4;
  const cols = SLICES.length;
  const cellW = Math.floor(inner / cols);
  const header = SLICES.map((s, i) =>
    colorize((s.primary ? "● " : "· ") + s.name.toUpperCase(), colorAt(i, s.primary), false)
  ).map((x) => padV(x, cellW)).join("");
  const val = SLICES.map((s, i) =>
    colorize(fmt(s.value), colorAt(i, s.primary), false) +
    colorize(` ${pct(s).toFixed(1)}%`, h(TOKENS.ink3), false)
  ).map((x) => padV(x, cellW)).join("");
  return [header, val];
}

function padV(str: string, width: number): string {
  return str + " ".repeat(Math.max(0, width - visibleLength(str)));
}

// ── glyph legend ──
function glyphLegend(width: number, colorAt: (i: number, primary: boolean) => string): string {
  const items = SLICES.map((s, i) => {
    const glyph = colorize(GLYPHS[i % GLYPHS.length]!, colorAt(i, s.primary), false);
    const name = colorize(s.name, colorAt(i, s.primary), false);
    return `${glyph}─${name}`;
  });
  return items.join("   ");
}

// ── status footer ──
function statusFooter(width: number, frame: string): string {
  const inner = width - 4;
  const status = colorize("Status: ", h(TOKENS.ink3), false) + colorize("all systems operational ✓", h(frame), false);
  return status + " ".repeat(Math.max(0, inner - visibleLength(status)));
}

// ──────────────────────────────────────────────────────────────
// TARGET — design-language donut (variant switchable)
// ──────────────────────────────────────────────────────────────
type Variant = "mudra" | "tui";

function variantOf(v: Variant) {
  if (v === "mudra") {
    return {
      frame: TOKENS.frame,
      frameSoft: TOKENS.frameSoft,
      colorAt: (i: number, primary: boolean) => (primary ? h(TOKENS.frame) : h(TOKENS.tones[i % TOKENS.tones.length]!)),
      caption: "DISTRIBUTION · BY REQUESTS · ONE HUE + TONE RAMP",
    };
  }
  return {
    frame: TUI_FRAME,
    frameSoft: "#24432a",
    colorAt: (i: number) => tuiColor(i),
    caption: "DISTRIBUTION · BY REQUESTS · DISTINCT HUES",
  };
}

function targetDonut(variant: Variant): string {
  const { frame, frameSoft, colorAt, caption } = variantOf(variant);
  const width = 72;
  const lines: string[] = [];
  lines.push(dashTop(width, "SHARE OF TRAFFIC (Last 24h)", "2026-07-29 10:42:17 IST", frame, frameSoft));
  lines.push(dashRule(width, frameSoft));
  lines.push(dashRow(width, colorize(caption, h(TOKENS.ink3), false), frameSoft));
  lines.push(dashRow(width, "", frameSoft));
  for (const r of renderRing(6, 3, colorAt, h(TOKENS.ink))) lines.push(dashRow(width, r, frameSoft));
  lines.push(dashRow(width, "", frameSoft));
  lines.push(dashRow(width, glyphLegend(width, colorAt), frameSoft));
  lines.push(dashRule(width, frameSoft));
  for (const r of metricCells(width, colorAt)) lines.push(dashRow(width, r, frameSoft));
  lines.push(dashRow(width, statusFooter(width, frame), frameSoft));
  lines.push(dashBottom(width, frameSoft));
  return lines.join("\n");
}

// ──────────────────────────────────────────────────────────────
// CURRENT — what the lib renders today
// ──────────────────────────────────────────────────────────────
function currentDonut(): string {
  return donut({
    title: "Share of Traffic",
    data: SLICES.map((s) => s.value),
    labels: SLICES.map((s) => s.name),
  }).toPlain();
}

const both = [
  colorize(ansi.bold + "CURRENT — bare donut (today)", h(TOKENS.ink2), false),
  currentDonut(),
  "",
  colorize(ansi.bold + "TARGET A — mudra language (one hue + tone ramp)", h(TOKENS.frame), false),
  targetDonut("mudra"),
  "",
  colorize(ansi.bold + "TARGET B — tui-chart language (distinct hues per series)", h(TUI_FRAME), false),
  targetDonut("tui"),
].join("\n");

console.log(both);
console.log("\n" + stripAnsi(""));
