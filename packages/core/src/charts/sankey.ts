import type { SankeyOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

// Plain-text shade ramp for the flow widths (light → dark by share of the
// peak flow), in lock-step with the LOCKED family language: how much moves
// reads even after stripAnsi (noColor / toPlain / toMarkdown). The peak flow
// leaves the ramp and takes the solid accent block.
const FLOW_SHADES = ["░", "▒", "▓"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S26 design language —
 *  the sankey flow list in the S18–S25 family vocabulary (no audit mockup
 *  exists for sankey — this is the family language applied by analogy):
 *  dashed frame, flow-metric eyebrow, tonal flows, and a facts foot row.
 *  - **One accent hue, spent EXACTLY once, on the peak flow.** The link with
 *    the highest value (ties → first in link order, deterministic — the same
 *    peak rule as bar/timeline/funnel/waterfall) renders a solid `█` run in
 *    the theme's accent hue. Every other link sits on the grey tone ramp with
 *    its matching shade glyph (`░ ▒ ▓` by share of the peak flow). The old
 *    `theme.colors[i % n]` per-link and per-node rainbow is retired.
 *  - **The `▶` arrow is deleted.** Direction already reads left-to-right
 *    (`source` flows to `target`); the arrow is decoration — the grammar's one
 *    banned category (the same ruling that retired funnel's `▼`).
 *  - **Node totals stay, toned.** The `Nodes:` ledger keeps `in:`/`out:`
 *    facts with each `■` on the grey ramp ordered by total flow — never a
 *    rainbow.
 *  - Panel width auto-expands so facts are never clipped (an explicit `width`
 *    is a floor, not a cap). */
export function sankey(opts: SankeyOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const nodes = opts.nodes;
  const links = opts.links;
  const empty = links.length === 0;

  const acc = theme.accent!;
  const tones = theme.tones!;

  const nameOf = (n: string | number): string => (typeof n === "number" ? nodes[n] ?? "" : n);
  const valueOf = (l: { value: number }): number => l.value;

  const maxFlow = empty ? 0 : Math.max(...links.map(valueOf));
  // The one accent: the PEAK flow, first in link order on ties.
  let peakIdx = 0;
  let peakValue = -Infinity;
  links.forEach((l, i) => {
    if (valueOf(l) > peakValue) {
      peakValue = valueOf(l);
      peakIdx = i;
    }
  });

  const totalFlow = links.reduce((s, l) => s + valueOf(l), 0);
  const eyebrow = `FLOW ${formatNumber(totalFlow)}`.toUpperCase();
  const peak = empty ? null : links[peakIdx]!;
  const footPlain = empty
    ? "NODES 0 · (no data)"
    : `NODES ${nodes.length} · LINKS ${links.length} · PEAK ${nameOf(peak!.source)} → ${nameOf(
        peak!.target
      )} ${formatNumber(valueOf(peak!))}`;

  const outflows = new Map<string, number>();
  const inflows = new Map<string, number>();
  for (const n of nodes) {
    outflows.set(n, 0);
    inflows.set(n, 0);
  }
  for (const l of links) {
    outflows.set(nameOf(l.source), (outflows.get(nameOf(l.source)) ?? 0) + valueOf(l));
    inflows.set(nameOf(l.target), (inflows.get(nameOf(l.target)) ?? 0) + valueOf(l));
  }
  // Nodes ordered by total flow — the ledger's loudest node first.
  const ranked = nodes
    .map((n) => ({ node: n, total: (outflows.get(n) ?? 0) + (inflows.get(n) ?? 0) }))
    .sort((a, b) => b.total - a.total);

  const nameW = Math.min(20, Math.max(4, ...nodes.map((n) => [...n].length)));
  const flowMax = Math.max(8, (opts.width ?? 70) - nameW * 2 - 16);

  // Auto-width: the panel expands so flows, ledger, and foot never clip.
  const flowLens = links.map(
    (l) => nameW + 1 + flowMax + 1 + nameW + 1 + [...formatNumber(valueOf(l))].length + 2
  );
  const ledgerLens = ranked.map(
    (r) =>
      4 +
      [...r.node].length +
      (inflows.get(r.node)! > 0 ? [...formatNumber(inflows.get(r.node)!)].length + 5 : 0) +
      (outflows.get(r.node)! > 0 ? [...formatNumber(outflows.get(r.node)!)].length + 6 : 0)
  );
  const effectiveWidth = Math.max(40, eyebrow.length + 4, footPlain.length + 4, ...flowLens.map((l) => l + 4), ...ledgerLens.map((l) => l + 4));

  function shadeFor(share: number): string {
    if (share >= 0.66) return FLOW_SHADES[2]!;
    if (share >= 0.33) return FLOW_SHADES[1]!;
    return FLOW_SHADES[0]!;
  }

  // Grey tone step per link order (peak leaves for the accent).
  function toneFor(i: number): string {
    return tones[Math.min(i, tones.length - 1)]!;
  }

  function buildFlowRow(l: (typeof links)[number], i: number): string {
    const share = maxFlow === 0 ? 0 : valueOf(l) / maxFlow;
    const w = Math.max(1, Math.round(share * flowMax));
    const isPeak = i === peakIdx;
    const flow = isPeak
      ? colorize("█".repeat(w), acc, noColor)
      : colorize(shadeFor(share).repeat(w), toneFor(i), noColor);
    return (
      colorize(padEnd(nameOf(l.source).slice(0, nameW), nameW), theme.label, noColor) +
      " " +
      flow +
      " " +
      colorize(padEnd(nameOf(l.target).slice(0, nameW), nameW), theme.label, noColor) +
      " " +
      colorize(`[${formatNumber(valueOf(l))}]`, theme.label, noColor)
    );
  }

  function buildLedgerRow(r: (typeof ranked)[number], i: number): string {
    const parts: string[] = [colorize("■ " + r.node, toneFor(i), noColor)];
    const tin = inflows.get(r.node)!;
    const tout = outflows.get(r.node)!;
    if (tin > 0) parts.push(colorize(`in:${formatNumber(tin)}`, theme.label, noColor));
    if (tout > 0) parts.push(colorize(`out:${formatNumber(tout)}`, theme.label, noColor));
    return "  " + parts.join("  ");
  }

  function buildSummary(): string {
    if (empty) return colorize(footPlain, theme.label, noColor);
    const head = colorize(
      `NODES ${nodes.length} · LINKS ${links.length} · PEAK ${nameOf(peak!.source)} → ${nameOf(
        peak!.target
      )} `,
      theme.label,
      noColor
    );
    return head + colorize(formatNumber(valueOf(peak!)), acc, noColor);
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    lines.push(
      frameTop(effectiveWidth, opts.title ?? "SANKEY", undefined, theme.axis, theme.title, noColor, true)
    );
    lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    lines.push(frameRow(effectiveWidth, colorize(eyebrow, theme.label, noColor), theme.axis, noColor));
    links.forEach((l, i) => lines.push(frameRow(effectiveWidth, buildFlowRow(l, i), theme.axis, noColor)));
    if (ranked.length > 0) {
      lines.push(frameRow(effectiveWidth, colorize("Nodes:", theme.title, noColor), theme.axis, noColor));
      ranked.forEach((r, i) => lines.push(frameRow(effectiveWidth, buildLedgerRow(r, i), theme.axis, noColor)));
    }
    lines.push(frameRule(effectiveWidth, theme.axis, noColor));
    lines.push(frameRow(effectiveWidth, buildSummary(), theme.axis, noColor));
    lines.push(frameBottom(effectiveWidth, theme.axis, noColor, true));
    return lines;
  }

  const output = buildLines().join("\n");

  return {
    render() {
      process.stdout.write(output + "\n");
    },
    toString() {
      return output;
    },
    toPlain() {
      return stripAnsi(output);
    },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
    toJSON() {
      return {
        type: "sankey",
        nodes: opts.nodes,
        links: opts.links,
        // Additive S26 fact: the peak flow (null when there is no data).
        peakFlow: empty
          ? null
          : {
              source: nameOf(peak!.source),
              target: nameOf(peak!.target),
              value: valueOf(peak!),
            },
        plain: stripAnsi(output),
      };
    },
  };
}
