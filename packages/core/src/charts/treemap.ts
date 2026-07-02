import type { TreemapOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";
import { formatNumber, truncate } from "../utils.js";

interface Rect {
  x: number;
  y: number;
  w: number;
  h: number;
}

interface TreemapNode {
  label: string;
  value: number;
  colorIdx: number;
}

export function treemap(opts: TreemapOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 20;

  const flatNodes: TreemapNode[] = [];
  opts.data.forEach((item, i) => {
    if (item.children && item.children.length > 0) {
      item.children.forEach((child, j) => {
        flatNodes.push({ label: child.label, value: child.value, colorIdx: i });
      });
    } else {
      flatNodes.push({ label: item.label, value: item.value, colorIdx: i });
    }
  });

  const total = flatNodes.reduce((s, n) => s + n.value, 0);

  function squarify(nodes: TreemapNode[], rect: Rect): Array<{ node: TreemapNode; rect: Rect }> {
    if (nodes.length === 0) return [];
    if (nodes.length === 1) return [{ node: nodes[0], rect }];

    const result: Array<{ node: TreemapNode; rect: Rect }> = [];
    let remaining = [...nodes].sort((a, b) => b.value - a.value);
    let remainRect = { ...rect };
    const remainTotal = remaining.reduce((s, n) => s + n.value, 0);

    function layoutRow(row: TreemapNode[], isHoriz: boolean): void {
      const rowTotal = row.reduce((s, n) => s + n.value, 0);
      const rowFrac = rowTotal / remainTotal;
      let offset = 0;

      row.forEach((node) => {
        const nodeFrac = node.value / rowTotal;
        let nr: Rect;
        if (isHoriz) {
          const w = Math.round(remainRect.w * rowFrac);
          const h = Math.round(remainRect.h * nodeFrac);
          nr = { x: remainRect.x, y: remainRect.y + offset, w, h: Math.max(1, h) };
          offset += h;
        } else {
          const h = Math.round(remainRect.h * rowFrac);
          const w = Math.round(remainRect.w * nodeFrac);
          nr = { x: remainRect.x + offset, y: remainRect.y, w: Math.max(1, w), h };
          offset += w;
        }
        result.push({ node, rect: nr });
      });

      if (isHoriz) {
        const w = Math.round(remainRect.w * rowFrac);
        remainRect = { ...remainRect, x: remainRect.x + w, w: remainRect.w - w };
      } else {
        const h = Math.round(remainRect.h * rowFrac);
        remainRect = { ...remainRect, y: remainRect.y + h, h: remainRect.h - h };
      }
      remaining = remaining.slice(row.length);
    }

    const half = Math.ceil(remaining.length / 2);
    const isHoriz = remainRect.h >= remainRect.w;
    layoutRow(remaining.slice(0, half), isHoriz);
    if (remaining.length > 0) {
      layoutRow(remaining.slice(0, remaining.length), !isHoriz);
    }

    return result;
  }

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const grid: string[][] = Array.from({ length: height }, () =>
      Array(width).fill(" ")
    );

    const layout = squarify(flatNodes, { x: 0, y: 0, w: width, h: height });

    layout.forEach(({ node, rect }) => {
      const color = theme.colors[node.colorIdx % theme.colors.length];
      const { x, y, w, h } = rect;

      for (let row = y; row < y + h && row < height; row++) {
        for (let col = x; col < x + w && col < width; col++) {
          const isEdge = row === y || row === y + h - 1 || col === x || col === x + w - 1;
          grid[row][col] = colorize(isEdge ? "░" : "▓", color, noColor);
        }
      }

      if (w > 2 && h > 1) {
        const labelY = y + 0;
        const maxLabelWidth = Math.max(0, w - 2);
        const labelText = truncate(node.label, maxLabelWidth);
        const valueText = truncate(formatNumber(node.value), maxLabelWidth);
        for (let i = 0; i < labelText.length && i < maxLabelWidth; i++) {
          if (x + 1 + i < width) {
            grid[labelY][x + 1 + i] = colorize(labelText[i], color, noColor);
          }
        }
        if (h > 2 && y + 1 < height) {
          for (let i = 0; i < valueText.length && i < maxLabelWidth; i++) {
            if (x + 1 + i < width) {
              grid[y + 1][x + 1 + i] = colorize(valueText[i], color, noColor);
            }
          }
        }
      }
    });

    for (const row of grid) {
      lines.push(row.join(""));
    }

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
        type: "treemap",
        data: opts.data,
        plain: stripAnsi(output),
      };
    },
  };
}
