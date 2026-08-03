#!/usr/bin/env node
/**
 * ============================================================================
 *  RING / PIE / DONUT — POLISH HANDOFF
 * ============================================================================
 *  Self-contained. No imports. Run with:  node scripts/ring-polish-handoff.mjs
 *
 *  TASK FOR THE OTHER LLM
 *  ----------------------
 *  Make this look MORE POLISHED and MORE GOOD-LOOKING. The current version
 *  draws a perfectly round circle from Unicode Braille sub-pixels (2 dots wide
 *  x 4 dots tall per cell) inside a dashed terminal panel, with a right-aligned
 *  legend. It is already CORRECT. We want BEAUTIFUL.
 *
 *  THE LINES WE WILL NOT CROSS (user has rejected these repeatedly):
 *    - NO per-slice fill patterns (█▓▒░▚▞ stripes/bars/noise).  [REJECTED x2]
 *    - NO in-wedge labels / percentage labels inside the circle. [REJECTED]
 *    - The circle must stay a clean, full, round circle (like the reference
 *      HTML's stroked SVG circles) - not a pixelated blob.
 *
 *  IDEAS YOU MAY IMPLEMENT (pick the highest-leverage ones, keep it classy):
 *    1. Slice separation that survives PLAIN mode (toPlain / non-ANSI). Right
 *       now slices are only told apart by ANSI color, so plain output is one
 *       uniform disc. Options: subtle radial divider marks on the rim, a thin
 *       gap between slices, distinct braille edge dots at boundaries, or a
 *       small percentage tick on the rim.
 *    2. Center text treatment in the donut (currently plain text "100").
 *       Maybe styled, or a percentage breakdown, or subtle.
 *    3. Panel polish: consistent padding, the eyebrow row, status row,
 *       alignment of the legend vs the ring, frame weight.
 *    4. A "gloss/shine" arc on the top-left of the ring, mirroring the
 *       reference HTML's subtle stroke - but keep it mono-safe.
 *    5. Better braille edge anti-aliasing: supersample each dot (e.g. 4 points
 *       per dot) so edges light gradually instead of popping.
 *    6. Legend: compact value formatting, better rhythm, the accent slice
 *       standing out without noise.
 *
 *  CONSTRAINTS
 *  -----------
 *    - Terminal-native, monospace. Braille chars are FINE (that's the whole
 *      point). Full-block █ is fine for legend swatches.
 *    - Must work in color mode AND in plain mode (stripAnsi output).
 *    - Keep the dashed-panel design language (frameTop/rule/row/bottom).
 *    - Keep it a single file, still runnable with plain `node`, no imports.
 *    - Do not change the public call shape:
 *        pie({ data, labels, title, theme, noColor })
 *        donut({ data, labels, title, eyebrow, status, noColor, radius, innerRadius })
 *    - return a result with .toPlain(), .toString(), .render()
 *
 *  OUTPUT YOU SHOULD RETURN
 *  ------------------------
 *  - The full modified script (paste it back in this file).
 *  - A 2-3 line note on what you changed and why it looks better.
 *  - Run it and paste the resulting plain AND color output so the
 *    originator can see the improvement.
 * ============================================================================
 */

// ---------------------------------------------------------------------------
// 1. ANSI helpers
// ---------------------------------------------------------------------------
const ESC = "\x1b";
const ANSI = {
  reset: `${ESC}[0m`, bold: `${ESC}[1m`, dim: `${ESC}[2m`,
  brightBlack: `${ESC}[90m`, white: `${ESC}[37m`, brightWhite: `${ESC}[97m`,
  rgb(r, g, b) { return `${ESC}[38;2;${r};${g};${b}m`; },
};
const colorize = (t, c, no = false) => (no ? t : `${c}${t}${ANSI.reset}`);
const stripAnsi = (s) => s.replace(/\x1b\[[0-9;]*m/g, "");
const visible = (s) => stripAnsi(s).length;
const padEnd = (s, w) => s + " ".repeat(Math.max(0, w - visible(s)));
const padStart = (s, w) => " ".repeat(Math.max(0, w - visible(s))) + s;
const hexAnsi = (h) => {
  const x = h.replace("#", "");
  return ANSI.rgb(parseInt(x.slice(0, 2), 16), parseInt(x.slice(2, 4), 16), parseInt(x.slice(4, 6), 16));
};

// ---------------------------------------------------------------------------
// 2. Theme: one accent hue + grey tone ramp (mudra design language)
// ---------------------------------------------------------------------------
const GREY_TONES = ["#ECECEF", "#C6C6CE", "#A4A4AE", "#6A6A75"].map(hexAnsi);
const THEME = {
  accent: hexAnsi("#8B7CF6"),
  tones: GREY_TONES,
  title: ANSI.bold + ANSI.brightWhite,
  label: ANSI.white,
  axis: ANSI.brightBlack,
};

// ---------------------------------------------------------------------------
// 3. Slice build: accent on the largest slice, grey tone ramp elsewhere
// ---------------------------------------------------------------------------
function buildSlices(data, labels) {
  const total = data.reduce((a, b) => a + b, 0) || 1;
  const accentIdx = data.indexOf(Math.max(...data));
  return {
    total,
    accentIndex: accentIdx,
    slices: data.map((value, i) => {
      const isAccent = i === accentIdx;
      const tone = THEME.tones[i % THEME.tones.length];
      return {
        label: labels[i] ?? `Item ${i + 1}`,
        value,
        pct: (value / total) * 100,
        color: isAccent ? THEME.accent : tone,
        textColor: isAccent || i % THEME.tones.length < 2 ? GREY_TONES[3] : GREY_TONES[0],
        accent: isAccent,
      };
    }),
  };
}

// ---------------------------------------------------------------------------
// 4. Braille sub-pixel circle renderer  (the core)
// ---------------------------------------------------------------------------
const BRAILLE_BITS = [
  [0x01, 0x02, 0x04, 0x08],
  [0x10, 0x20, 0x40, 0x80],
];
function braille(dots) {
  let v = 0;
  for (let x = 0; x < 2; x++) for (let y = 0; y < 4; y++) if (dots[x][y]) v += BRAILLE_BITS[x][y];
  return String.fromCharCode(0x2800 + v);
}

function renderRing(slices, radius, innerRadius, noColor, centerText = "", centerColor = "") {
  const rows = radius * 2 + 1;
  const cols = radius * 4 + 1;
  const cx = radius * 2;
  // dot-space: 2 dots per col, 4 dots per row; centre & radius in dots
  const cxd = (cols * 2) / 2;
  const cyd = (rows * 4) / 2;
  const rd = radius * 4;
  const ird = innerRadius * 4;

  const cumulative = [];
  let cum = 0;
  for (const s of slices) { cum += (s.pct / 100) * Math.PI * 2; cumulative.push(cum); }
  const phi = (dx, dy) => { let a = Math.atan2(dx, -dy); return a < 0 ? a + Math.PI * 2 : a; };
  const sliceAt = (dx, dy) => {
    const d = Math.hypot(dx, dy);
    if (d <= rd && d >= ird) {
      const a = phi(dx, dy);
      for (let i = 0; i < cumulative.length; i++) if (a < cumulative[i]) return slices[i];
      return slices[slices.length - 1];
    }
    return null;
  };

  const grid = Array.from({ length: rows }, () => Array(cols).fill(" "));
  const colors = Array.from({ length: rows }, () => Array(cols).fill(""));

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      const dots = [[0, 0, 0, 0], [0, 0, 0, 0]];
      const counts = new Map();
      let lit = 0;
      for (let dx = 0; dx < 2; dx++) {
        for (let dy = 0; dy < 4; dy++) {
          // supersample each braille dot at 2x2 sub-points; light it when the
          // majority of sub-points fall inside the ring (smoother, symmetric rim)
          let inside = 0;
          const litDots = new Map();
          for (const [sx, sy] of [[0.25, 0.25], [0.75, 0.25], [0.25, 0.75], [0.75, 0.75]]) {
            const x = col * 2 + dx + sx, y = row * 4 + dy + sy;
            const s = sliceAt(x - cxd, y - cyd);
            if (s) { inside++; litDots.set(s, (litDots.get(s) ?? 0) + 1); }
          }
          if (inside < 2) continue;
          dots[dx][dy] = 1;
          lit++;
          for (const [s, n] of litDots) counts.set(s, (counts.get(s) ?? 0) + n);
        }
      }
      if (lit === 0) continue;
      grid[row][col] = braille(dots);
      let best = null, bestN = -1;
      for (const [s, n] of counts) if (n > bestN) { best = s; bestN = n; }
      colors[row][col] = best.color;
    }
  }

  if (centerText && innerRadius > 0) {
    const midRow = Math.floor(rows / 2);
    const startCol = cx - Math.floor(centerText.length / 2);
    for (let k = 0; k < centerText.length; k++) {
      const c = startCol + k;
      if (c >= 0 && c < cols) { grid[midRow][c] = centerText[k]; colors[midRow][c] = centerColor; }
    }
  }

  return grid.map((rowArr, r) => rowArr.map((ch, c) => colorize(ch, colors[r][c], noColor)).join(""));
}

// ---------------------------------------------------------------------------
// 5. Right-aligned legend
// ---------------------------------------------------------------------------
function renderLegend(slices, noColor, showValues = true) {
  const nameW = Math.max(...slices.map((s) => visible(s.label)));
  const valStrs = slices.map((s) => (showValues ? `${fmt(s.value)} (${s.pct.toFixed(1)}%)` : ""));
  const valW = Math.max(0, ...valStrs.map(visible));
  const rows = slices.map((s, i) => {
    const glyph = colorize("█", s.color, noColor);
    const name = colorize(padEnd(s.label, nameW), s.accent ? THEME.title : THEME.label, noColor);
    const val = showValues ? colorize(padStart(valStrs[i], valW), s.accent ? THEME.title : THEME.label, noColor) : "";
    return `${glyph} ${name}  ${val}`;
  });
  return { rows, width: 1 + 1 + nameW + 2 + (showValues ? valW : 0) };
}

// ---------------------------------------------------------------------------
// 6. Dashed panel primitives
// ---------------------------------------------------------------------------
function frameTop(width, title, meta) {
  const inner = width - 2;
  const left = title ? ` ${title} ` : "";
  const right = meta ? ` ${meta} ` : "";
  const dashes = Math.max(1, inner - 2 - visible(left) - visible(right));
  return colorize("┌╌", THEME.axis, false) + colorize(left, THEME.title, false) +
    colorize("╌".repeat(dashes), THEME.axis, false) + colorize(right, THEME.label, false) +
    colorize("╌┐", THEME.axis, false);
}
function frameBottom(width) { return colorize("└" + "╌".repeat(width - 2) + "┘", THEME.axis, false); }
function frameRule(width) { return colorize("│ " + "╌".repeat(width - 4) + " │", THEME.axis, false); }
function frameRow(width, content, noColor) {
  const inner = width - 4;
  const pad = content + " ".repeat(Math.max(0, inner - visible(content)));
  return (noColor ? "│ " : colorize("│ ", THEME.axis)) + pad + (noColor ? " │" : colorize(" │", THEME.axis));
}
function frame(rows, width, noColor) {
  return [frameTop(width, "PIE", undefined), frameRule(width), ...rows, frameBottom(width)];
}

// ---------------------------------------------------------------------------
// 7. Public chart builders
// ---------------------------------------------------------------------------
function pie(opts) {
  const noColor = opts.noColor ?? false;
  const { slices, total } = buildSlices(opts.data, opts.labels);
  const radius = opts.radius ?? 8;
  const ring = renderRing(slices, radius, 0, noColor);
  const legend = renderLegend(slices, noColor);
  const ringCols = radius * 4 + 1;
  const width = opts.width ?? Math.max(ringCols + legend.width + 8, 52);
  const legendGap = 3;
  const h = Math.max(ring.length, legend.rows.length);
  const off = Math.max(0, Math.floor((ring.length - legend.rows.length) / 2));
  const rows = [];
  for (let i = 0; i < h; i++) {
    const r = i < ring.length ? ring[i] : "";
    const l = i >= off && i < off + legend.rows.length ? legend.rows[i - off] : "";
    rows.push(frameRow(width, r + " ".repeat(Math.max(0, ringCols - visible(r))) + " ".repeat(legendGap) + l, noColor));
  }
  rows.push(frameRule(width));
  rows.push(frameRow(width, `${slices.length} slices · total ${fmt(total)}`, noColor));
  const out = [frameTop(width, opts.title ?? "PIE", undefined), frameRule(width), ...rows, frameBottom(width)].join("\n");
  return { toString: () => out, toPlain: () => stripAnsi(out), render: () => console.log(out) };
}

function donut(opts) {
  const noColor = opts.noColor ?? false;
  const { slices, total } = buildSlices(opts.data, opts.labels);
  const radius = opts.radius ?? 8;
  const innerRadius = opts.innerRadius ?? Math.max(2, Math.floor(radius * 0.5));
  const ring = renderRing(slices, radius, innerRadius, noColor, fmt(total), THEME.label);
  const legend = renderLegend(slices, noColor);
  const ringCols = radius * 4 + 1;
  const width = opts.width ?? Math.max(ringCols + legend.width + 8, 52);
  const legendGap = 3;
  const h = Math.max(ring.length, legend.rows.length);
  const off = Math.max(0, Math.floor((ring.length - legend.rows.length) / 2));
  const rows = [];
  for (let i = 0; i < h; i++) {
    const r = i < ring.length ? ring[i] : "";
    const l = i >= off && i < off + legend.rows.length ? legend.rows[i - off] : "";
    rows.push(frameRow(width, r + " ".repeat(Math.max(0, ringCols - visible(r))) + " ".repeat(legendGap) + l, noColor));
  }
  if (opts.status) {
    rows.push(frameRule(width));
    rows.push(frameRow(width, `Status: ${opts.status}`, noColor));
  }
  const out = [
    frameTop(width, opts.title ?? "DONUT", undefined),
    frameRule(width),
    frameRow(width, (opts.eyebrow ?? "DISTRIBUTION").toUpperCase(), noColor),
    ...rows,
    frameBottom(width),
  ].join("\n");
  return { toString: () => out, toPlain: () => stripAnsi(out), render: () => console.log(out) };
}

// ---------------------------------------------------------------------------
// 8. Demo
// ---------------------------------------------------------------------------
function fmt(n) {
  if (n >= 1e6) return (n / 1e6).toFixed(2) + "M";
  if (n >= 1e3) return (n / 1e3).toFixed(1) + "k";
  return String(Math.round(n));
}

console.log("════ PIE · PLAIN ════");
pie({
  title: "CLIENTS",
  data: [34.2, 28.6, 19.4, 9.8, 5.3, 2.7],
  labels: ["Web", "Mobile", "API", "Partner", "Bot", "Other"],
  noColor: true,
}).render();

console.log("\n════ DONUT · PLAIN ════");
donut({
  title: "SYSTEM",
  eyebrow: "Distribution · One hue + tone ramp",
  status: "all systems operational ✓",
  data: [1240000, 380000, 170000, 14000],
  labels: ["CPU", "MEM", "NET", "IO"],
  noColor: true,
}).render();

// ---------------------------------------------------------------------------
// COLOR DEMO — run in a real terminal (or `cat -v`/strip escapes to view raw).
// Slices are told apart by ANSI color: violet accent on the largest slice,
// grey tone ramp (ECECEF -> 6A6A75) on the rest.
// ---------------------------------------------------------------------------
console.log("\n════ PIE · COLOR ════");
pie({
  title: "CLIENTS",
  data: [34.2, 28.6, 19.4, 9.8, 5.3, 2.7],
  labels: ["Web", "Mobile", "API", "Partner", "Bot", "Other"],
}).render();

console.log("\n════ DONUT · COLOR ════");
donut({
  title: "SYSTEM",
  eyebrow: "Distribution · One hue + tone ramp",
  status: "all systems operational ✓",
  data: [1240000, 380000, 170000, 14000],
  labels: ["CPU", "MEM", "NET", "IO"],
}).render();
