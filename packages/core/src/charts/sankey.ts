import type { SankeyOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";

export function sankey(opts: SankeyOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 70;

  const { nodes, links } = opts;

  const outflows: Record<string, Array<{ target: string; value: number }>> = {};
  const inflows: Record<string, Array<{ source: string; value: number }>> = {};
  for (const node of nodes) {
    outflows[node] = [];
    inflows[node] = [];
  }
  for (const link of links) {
    const srcName = typeof link.source === "number" ? nodes[link.source] : link.source;
    const tgtName = typeof link.target === "number" ? nodes[link.target] : link.target;
    outflows[srcName]?.push({ target: tgtName, value: link.value });
    inflows[tgtName]?.push({ source: srcName, value: link.value });
  }

  const maxNodeLen = Math.max(...nodes.map((n) => n.length));
  const maxValue = Math.max(...links.map((l) => l.value));

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
      lines.push("");
    }

    links.forEach((link, i) => {
      const srcName = typeof link.source === "number" ? nodes[link.source] : link.source;
      const tgtName = typeof link.target === "number" ? nodes[link.target] : link.target;
      const color = theme.colors[i % theme.colors.length];
      const barWidth = Math.max(
        1,
        Math.round((link.value / maxValue) * (width - maxNodeLen * 2 - 10))
      );
      const valueStr = formatNumber(link.value);
      const bar = "─".repeat(barWidth);
      const arrow = "▶";

      const sourcePad = padEnd(srcName, maxNodeLen);
      const targetPad = padEnd(tgtName, maxNodeLen);

      lines.push(
        colorize(sourcePad, theme.label, noColor) +
          " " +
          colorize(bar + arrow, color, noColor) +
          " " +
          colorize(targetPad, theme.label, noColor) +
          " " +
          colorize("[" + valueStr + "]", theme.label, noColor)
      );
    });

    lines.push("");

    const nodeStats = nodes.map((node) => {
      const totalOut = outflows[node].reduce((s, l) => s + l.value, 0);
      const totalIn = inflows[node].reduce((s, l) => s + l.value, 0);
      return { node, totalIn, totalOut };
    });

    lines.push(colorize("Nodes:", theme.title, noColor));
    nodeStats.forEach(({ node, totalIn, totalOut }, i) => {
      const color = theme.colors[i % theme.colors.length];
      const parts: string[] = [colorize("■ " + node, color, noColor)];
      if (totalIn > 0) parts.push(colorize(`in:${formatNumber(totalIn)}`, theme.label, noColor));
      if (totalOut > 0) parts.push(colorize(`out:${formatNumber(totalOut)}`, theme.label, noColor));
      lines.push("  " + parts.join("  "));
    });

    return lines;
  }

  const output = buildLines().join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "sankey",
        nodes: opts.nodes,
        links: opts.links,
        plain: stripAnsi(output),
      };
    },
  };
}
