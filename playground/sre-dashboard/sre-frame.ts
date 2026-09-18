/**
 * sre-frame.ts — Dense SRE dashboard with bordered sections.
 * Custom compact sections + real chitra charts with frame stripping.
 * Mudra violet theme. ~50 lines.
 */

import { line, area, bar, horizontalBar, scatter, histogram, heatmap, funnel, pie, donut, radar, boxplot, waterfall, candlestick, treemap, sankey, timeline, sparkline, progress, gauge as gaugeChart } from "../../packages/core/src/charts/index.js";
import { resolveTheme, ansi, hexToAnsi, clamp, colorize } from "../../packages/core/src/index.js";
import { SRESim, SERVICES } from "./sre-sim.js";

const theme = resolveTheme("default");
const RST = ansi.reset;
const B = ansi.bold;
const D = ansi.dim;
const CY = ansi.brightCyan;
const GR = ansi.brightGreen;
const RD = ansi.brightRed;
const YL = ansi.brightYellow;
const V = theme.accent!;
const TONES = [hexToAnsi("#ECECEF"), hexToAnsi("#C6C6CE"), hexToAnsi("#A4A4AE"), hexToAnsi("#6A6A75")];

export const RATINGS: Record<string, number> = {
  sparkline: 4, bar: 4, line: 4, area: 4, donut: 4, progress: 4,
  gauge: 4, heatmap: 4, timeline: 4, scatter: 4, pie: 4, histogram: 4,
  horizontalBar: 4, radar: 4, boxplot: 4, waterfall: 4, funnel: 4,
  candlestick: 4, treemap: 4, sankey: 4,
};

const W = 78;

function boxTop(label: string): string {
  const pad = W - label.length - 4;
  const lp = Math.floor(pad / 2);
  const rp = pad - lp;
  return `${D}┌${"─".repeat(lp)}${RST} ${V}${B}${label}${RST} ${D}${"─".repeat(rp)}┐${RST}`;
}
function boxBot(): string { return `${D}└${"─".repeat(W - 2)}┘${RST}`; }

function miniSpark(data: number[]): string {
  if (!data.length) return "";
  const min = Math.min(...data), max = Math.max(...data), range = max - min || 1;
  const BS = ["░", "▒", "▓", "█"];
  return data.slice(-18).map((v) => {
    const norm = (v - min) / range;
    const ti = Math.min(3, Math.floor(norm * 4));
    return colorize(BS[ti]!, TONES[3 - ti]!);
  }).join("");
}

function gauge(pct: number, w: number): string {
  const f = clamp(Math.round((pct / 100) * w), 0, w);
  const c = pct > 80 ? RD : pct > 60 ? YL : V;
  return colorize("█".repeat(f), c) + D + "░".repeat(w - f) + RST;
}



function renderFrame(sim: SRESim): string {
  const o: string[] = [];
  const t = sim.t;
  const up = `${String(Math.floor(t / 60)).padStart(2, "0")}:${String(t % 60).padStart(2, "0")}`;
  const ts = new Date().toLocaleTimeString();

  // ━━ HEADER ━━
  const si = sim.incident ? `${RD}▲ ${sim.incident.label}` : `${GR}● nominal`;
  o.push(`${V}${B}CHITRA${RST} ${D}SRE${RST} ${si} ${D}│${RST} up ${V}${up}${RST} rps ${CY}${String(Math.round(sim.rps).toLocaleString()).padStart(5)}${RST} p99 ${YL}${String(Math.round(sim.p99)).padStart(4)}ms${RST} err ${sim.errRate > 2 ? RD : GR}${sim.errRate.toFixed(1).padStart(4)}%${RST} apdex ${sim.apdex < 0.9 ? YL : GR}${sim.apdex.toFixed(2)}${RST}`);

  // ━━ KPI SECTION ━━
  o.push(boxTop("KPI"));
  o.push(` ${D}RPS${RST} ${miniSpark(sim.rpsHist)} ${CY}${String(Math.round(sim.rps).toLocaleString()).padStart(5)}${RST}  ${D}P99${RST} ${miniSpark(sim.p99Hist)} ${YL}${String(Math.round(sim.p99)).padStart(4)}ms${RST}`);
  o.push(` ${D}ERR${RST} ${miniSpark(sim.errHist)} ${sim.errRate > 2 ? RD : GR}${sim.errRate.toFixed(1).padStart(4)}%${RST}  ${D}ADX${RST} ${miniSpark(sim.apdexHist)} ${sim.apdex < 0.9 ? YL : GR}${sim.apdex.toFixed(2)}${RST}`);
  o.push(boxBot());

  // ━━ RESOURCES ━━
  o.push(boxTop("RESOURCES"));
  o.push(` ${D}CPU${RST} ${gauge(sim.cpu, 8)} ${String(Math.round(sim.cpu)).padStart(2)}% ${D}MEM${RST} ${gauge(sim.mem, 8)} ${String(Math.round(sim.mem)).padStart(2)}% ${D}DISK${RST} ${gauge(sim.disk, 8)} ${String(Math.round(sim.disk)).padStart(2)}% ${D}NET${RST} ${gauge(sim.netMbps / 3, 8)} ${String(Math.round(sim.netMbps / 3)).padStart(2)}%`);
  o.push(boxBot());

  // ━━ CHARTS — all 20 chitra types, body-only (compact) + hard-capped width ━━
  const W2 = 70, MW = 74;
  const d = derived(sim);
  const { svcRps, netBuckets, scatterData, tlEvents, heatData, boxData, funnelOrder, candles, deltas, health } = d;

  const charts: Array<{ label: string; output: string }> = [
    { label: "SERVICES · horizontalBar", output: horizontalBar({ data: svcRps, labels: SERVICES, width: W2, maxWidth: MW, height: 6, showAxes: false, compact: true }).toString() },
    { label: "CPU · line", output: line({ data: sim.cpuHist, width: W2, maxWidth: MW, height: 5, compact: true }).toString() },
    { label: "MEMORY · area", output: area({ data: sim.memHist, width: W2, maxWidth: MW, height: 5, compact: true }).toString() },
    { label: "BANDWIDTH · bar", output: bar({ data: netBuckets, width: W2, maxWidth: MW, height: 4, labels: ["15m", "10m", "5m", "now"], showAxes: false, compact: true }).toString() },
    { label: "LATENCY · histogram", output: histogram({ data: sim.p99Hist, width: W2, maxWidth: MW, height: 4, bins: 10, showAxes: false, compact: true }).toString() },
    { label: "ERRORS × P99 · scatter", output: scatter({ data: scatterData, width: W2, maxWidth: MW, height: 4, showAxes: false, compact: true }).toString() },
    { label: "RPS TREND · sparkline", output: sparkline({ data: sim.rpsHist, width: 36, height: 2, compact: true }).toString() },
    { label: "APDEX · gauge", output: gaugeChart({ value: sim.apdex, min: 0, max: 1, width: W2, maxWidth: MW, compact: true }).toString() },
    { label: "SLO · progress", output: progress({ value: Math.round(sim.apdex * 100), width: W2, maxWidth: MW, height: 2, compact: true }).toString() },
    { label: "TRAFFIC SHARE · donut", output: donut({ data: svcRps, labels: SERVICES, width: W2, maxWidth: MW, height: 9, compact: true }).toString() },
    { label: "REQUEST MIX · pie", output: pie({ data: svcRps, labels: SERVICES, width: W2, maxWidth: MW, height: 9, compact: true }).toString() },
    { label: "LATENCY GRID · heatmap", output: heatmap({ data: heatData, xLabels: ["-30", "-25", "-20", "-15", "-10", "-5", "now"], yLabels: SERVICES, width: W2, maxWidth: MW, height: 7, compact: true }).toString() },
    { label: "SERVICE HEALTH · radar", output: radar({ data: health, labels: SERVICES, width: W2, maxWidth: MW, height: 12, compact: true }).toString() },
    { label: "LATENCY SPREAD · boxplot", output: boxplot({ data: boxData, width: W2, maxWidth: MW, height: 4, compact: true }).toString() },
    { label: "RPS BRIDGE · waterfall", output: waterfall({ data: deltas, width: W2, maxWidth: MW, height: 5, compact: true }).toString() },
    { label: "REQUEST FUNNEL · funnel", output: funnel({ data: funnelOrder.map(f => f.v), labels: funnelOrder.map(f => SERVICES[f.i]!), width: W2, maxWidth: MW, height: 4, compact: true }).toString() },
    { label: "RPS CANDLES · candlestick", output: candlestick({ data: candles.slice(-8), width: W2, maxWidth: MW, height: 5, compact: true }).toString() },
    { label: "SERVICE MAP · treemap", output: treemap({ data: SERVICES.map((s, i) => ({ label: s, value: svcRps[i]! })), width: W2, maxWidth: MW, height: 5, compact: true }).toString() },
    { label: "TRAFFIC FLOW · sankey", output: sankey({ nodes: ["ingress", ...SERVICES], links: SERVICES.map((s, i) => ({ source: "ingress", target: s, value: svcRps[i]! })), width: W2, maxWidth: MW, height: 4, compact: true }).toString() },
  ];
  if (tlEvents.length) charts.push({ label: "EVENTS · timeline", output: timeline({ events: tlEvents, width: W2, maxWidth: MW, height: 5, showAxes: false, compact: true }).toString() });

  for (const c of charts) {
    o.push(boxTop(c.label));
    o.push(c.output);
    o.push(boxBot());
  }

  // ━━ FOOTER ━━
  o.push(`${D}  chitra v0.1.0 · mudra · ${ts}${RST}`);
  return o.join("\n") + "\n";
}

function derived(sim: SRESim) {
  const svcRps = SERVICES.map((_, i) => Math.round(sim.rps * [0.32, 0.14, 0.18, 0.12, 0.16, 0.08][i]!));
  const netBuckets = [0, 1, 2, 3].map(i => {
    const slice = sim.connHist.slice(i * 7, (i + 1) * 7);
    return slice.length ? Math.round(slice.reduce((a: number, b: number) => a + b, 0) / slice.length) : 0;
  });
  const scatterData = sim.errHist.map((e, i) => ({ x: e, y: sim.p99Hist[i] ?? 0 }));
  const tlEvents = sim.events.map(e => ({ label: e.label, start: e.start, end: e.end, color: e.kind === "incident" ? RD : GR }));
  const heatData = SERVICES.map(s => {
    const samp = (sim.svcSamples[s] ?? []).slice(-7);
    while (samp.length < 7) samp.unshift(samp[0] ?? 0);
    return samp;
  });
  const boxData = SERVICES.map(s => (sim.svcSamples[s] ?? []).slice(-10));
  const funnelOrder = svcRps.map((v, i) => ({ v, i })).sort((a, b) => b.v - a.v).slice(0, 4);
  const candles: Array<{ open: number; high: number; low: number; close: number }> = [];
  for (let i = 0; i < sim.rpsHist.length; i += 5) {
    const chunk = sim.rpsHist.slice(i, i + 5);
    if (chunk.length) candles.push({ open: chunk[0]!, high: Math.max(...chunk), low: Math.min(...chunk), close: chunk[chunk.length - 1]! });
  }
  const deltas = sim.rpsHist.slice(-7).map((v, i, a) => (i === 0 ? 0 : v - a[i - 1]!)).slice(1);
  const health = SERVICES.map(s => {
    const samp = sim.svcSamples[s] ?? [];
    const avg = samp.length ? samp.reduce((a, b) => a + b, 0) / samp.length : 20;
    return Math.max(5, Math.min(100, Math.round(100 - avg)));
  });
  return { svcRps, netBuckets, scatterData, tlEvents, heatData, boxData, funnelOrder, candles, deltas, health };
}

export interface GridCell {
  label: string;
  output: string;
  span: number;
  tall?: boolean;
}

export interface GridStats {
  incident: string | null;
  up: string;
  rps: number;
  p99: number;
  errRate: number;
  apdex: number;
  cpu: number;
  mem: number;
  disk: number;
  net: number;
}

/** Grid-sized cells for the fullscreen web dashboard. Widths come from the
 *  client (measured chars per tile) so charts fill their tiles on any screen. */
function renderCells(sim: SRESim, S = 34, D = 70): { stats: GridStats; cells: GridCell[] } {
  const d = derived(sim);
  const { svcRps, netBuckets, scatterData, tlEvents, heatData, boxData, funnelOrder, candles, deltas, health } = d;
  const cells: GridCell[] = [
    { label: "CPU · line", output: line({ data: sim.cpuHist, width: S, maxWidth: S, height: 3, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "MEMORY · area", output: area({ data: sim.memHist, width: S, maxWidth: S, height: 5, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "BANDWIDTH · bar", output: bar({ data: netBuckets, width: S, maxWidth: S, height: 3, labels: ["15m", "10m", "5m", "now"], showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "SERVICES · horizontalBar", output: horizontalBar({ data: svcRps, labels: SERVICES, width: D, maxWidth: D, height: 3, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 2 },
    { label: "LATENCY · histogram", output: histogram({ data: sim.p99Hist, width: S, maxWidth: S, height: 3, bins: 8, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "ERRORS × P99 · scatter", output: scatter({ data: scatterData, width: S, maxWidth: S, height: 3, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "RPS TREND · sparkline", output: sparkline({ data: sim.rpsHist, width: Math.max(8, Math.floor(S / 2)), height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "APDEX · gauge", output: gaugeChart({ value: sim.apdex, min: 0, max: 1, width: S, maxWidth: S, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "SLO · progress", output: progress({ value: Math.round(sim.apdex * 100), width: S, maxWidth: S, height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "EVENTS · timeline", output: timeline({ events: tlEvents.length ? tlEvents : [{ label: "(no events)", start: sim.t, end: sim.t + 1 }], width: D, maxWidth: D, height: 3, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 2 },
    { label: "TRAFFIC SHARE · donut", output: donut({ data: svcRps, labels: SERVICES, width: D, maxWidth: D, height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 2 },
    { label: "LATENCY SPREAD · boxplot", output: boxplot({ data: boxData, width: S, maxWidth: S, height: 3, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "REQUEST MIX · pie", output: pie({ data: svcRps, labels: SERVICES, width: D, maxWidth: D, height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 2 },
    { label: "RPS BRIDGE · waterfall", output: waterfall({ data: deltas, width: S, maxWidth: S, height: 3, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "LATENCY GRID · heatmap", output: heatmap({ data: heatData, xLabels: ["-30", "-25", "-20", "-15", "-10", "-5", "now"], yLabels: SERVICES, width: D, maxWidth: D, height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 2 },
    { label: "REQUEST FUNNEL · funnel", output: funnel({ data: funnelOrder.map(f => f.v), labels: funnelOrder.map(f => SERVICES[f.i]!), width: S, maxWidth: S, height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "SERVICE HEALTH · radar", output: radar({ data: health, labels: SERVICES, width: D, maxWidth: D, height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 3 },
    { label: "TRAFFIC FLOW · sankey", output: sankey({ nodes: ["ingress", ...SERVICES], links: SERVICES.map((s, i) => ({ source: "ingress", target: s, value: svcRps[i]! })), width: D, maxWidth: D, height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 2 },
    { label: "RPS CANDLES · candlestick", output: candlestick({ data: candles.slice(-8), width: S, maxWidth: S, height: 3, showAxes: false, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 1 },
    { label: "SERVICE MAP · treemap", output: treemap({ data: SERVICES.map((s, i) => ({ label: s, value: svcRps[i]! })), width: D, maxWidth: D, height: 3, compact: true }).toString().split("\n").slice(0, 3).join("\n"), span: 3 },
  ];
  const stats: GridStats = {
    incident: sim.incident ? sim.incident.label : null,
    up: `${String(Math.floor(sim.t / 60)).padStart(2, "0")}:${String(sim.t % 60).padStart(2, "0")}`,
    rps: Math.round(sim.rps),
    p99: Math.round(sim.p99),
    errRate: Number(sim.errRate.toFixed(1)),
    apdex: Number(sim.apdex.toFixed(2)),
    cpu: Math.round(sim.cpu),
    mem: Math.round(sim.mem),
    disk: Math.round(sim.disk),
    net: Math.round(sim.netMbps),
  };
  return { stats, cells };
}

export { renderFrame, renderCells };
