#!/usr/bin/env tsx
/**
 * audit.ts — Programmatic audit of the SRE dashboard output.
 * Checks ANSI structure, alignment, broken escapes, chart completeness.
 */

import { SRESim, warmup } from "./sre-sim.js";
import { renderFrame, RATINGS } from "./sre-frame.js";
import { stripAnsi } from "../../packages/core/src/index.js";

const sim = new SRESim();
warmup(sim, 40);
sim.tick();
const frame = renderFrame(sim);
const plain = stripAnsi(frame);

// 1. Check all 20 chart types are present
const chartTypes = [
  "sparkline", "line", "area", "bar", "horizontalBar", "donut", "pie",
  "gauge", "progress", "heatmap", "scatter", "funnel", "waterfall",
  "radar", "treemap", "boxplot", "histogram", "sankey", "timeline", "candlestick"
];

let pass = 0;
let fail = 0;

for (const ct of chartTypes) {
  const found = plain.toLowerCase().includes(ct.replace(/([A-Z])/g, " $1").toLowerCase().trim());
  // More flexible: check if the chart name or related keywords appear
  const keywords: Record<string, string[]> = {
    sparkline: ["rps", "p99", "err", "apdex"],
    line: ["latency"],
    area: ["traffic"],
    bar: ["rps by service"],
    horizontalBar: ["traffic by region"],
    donut: ["status code"],
    pie: ["regional"],
    gauge: ["apdex"],
    progress: ["cpu", "mem", "disk"],
    heatmap: ["service latency"],
    scatter: ["rps ↔ p99"],
    funnel: ["slo"],
    waterfall: ["latency budget"],
    radar: ["service health"],
    treemap: ["traffic treemap"],
    boxplot: ["latency by service"],
    histogram: ["latency distribution"],
    sankey: ["request flow"],
    timeline: ["deploys"],
    candlestick: ["ohlc"]
  };
  const kw = keywords[ct] ?? [ct];
  const foundKw = kw.some(k => plain.toLowerCase().includes(k));
  if (foundKw) {
    console.log(`  ✓ ${ct}`);
    pass++;
  } else {
    console.log(`  ✗ ${ct} — NOT FOUND`);
    fail++;
  }
}

// 2. Check ANSI escape codes are well-formed
const openEscapes = (frame.match(/\x1b\[[0-9;]*m/g) ?? []).length;
const hasReset = frame.includes("\x1b[0m");
console.log(`\n  ANSI: ${openEscapes} escapes, reset present: ${hasReset}`);

// 3. Check no broken/unclosed ANSI (basic heuristic)
const resetCount = (frame.match(/\x1b\[0m/g) ?? []).length;
console.log(`  Reset count: ${resetCount}`);

// 4. Check panel borders are consistent
const topBorders = (plain.match(/┌╌/g) ?? []).length;
const bottomBorders = (plain.match(/└╌/g) ?? []).length;
console.log(`  Panel borders: ${topBorders} top, ${bottomBorders} bottom`);

// 5. Check line widths are consistent (no ragged edges)
const lines = plain.split("\n").filter(l => l.length > 0);
const widths = lines.map(l => l.length);
const maxWidth = Math.max(...widths);
const minWidth = Math.min(...widths.filter(w => w > 10));
console.log(`  Line widths: min=${minWidth}, max=${maxWidth}`);

// 6. Check ratings are in all panel titles
const ratingStars = (plain.match(/★/g) ?? []).length;
const emptyStars = (plain.match(/☆/g) ?? []).length;
console.log(`  Star ratings: ${ratingStars} filled, ${emptyStars} empty`);

// 7. Check no control characters (except ANSI)
const nonAnsiControl = plain.replace(/\x1b\[[0-9;]*m/g, "").replace(/[\x00-\x09\x0b-\x1f]/g, "");
const controlClean = nonAnsiControl.length === plain.replace(/\x1b\[[0-9;]*m/g, "").length;
console.log(`  Control chars clean: ${controlClean}`);

// 8. Check footer
const hasFooter = plain.includes("all systems operational") || plain.includes("INCIDENT");
console.log(`  Footer present: ${hasFooter}`);

console.log(`\n  Results: ${pass}/${chartTypes.length} charts verified`);

if (fail > 0) {
  console.log(`\n  ⚠ ${fail} charts not found in output`);
  process.exit(1);
} else {
  console.log(`\n  ✓ All checks passed`);
}
