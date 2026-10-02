import type { TreemapOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi, truncateAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

interface Rect {
  x: number;
  y: number;
  w: number;
  h: number;
}

interface TreemapNode {
  label: string;
  value: number;
  order: number;
}

// Plain-text shade ramp, one glyph per grey tone bucket (light → dark by
// magnitude). Kept in lock-step with the theme's grey tone ramp so the
// intensity reads even after stripAnsi (noColor / toPlain / toMarkdown).
const AREA_SHADES = ["░", "▒", "▓", "█"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S20 design language:
 *  dashed frame, uppercase eyebrow row (`AREA`), a `+`/`│` left guide on the
 *  plot, and a squarified treemap whose intensity IS the grey tone ramp
 *  (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, light → dark by magnitude). The
 *  single accent hue is spent EXACTLY once, on the maximum-value node (ties →
 *  first in flatten/data order, deterministic). A `N leaves · peak <label>`
 *  summary footer carries the peak label in the accent hue. No
 *  `theme.colors[i % n]` rainbow — exactly like the LOCKED heatmap. */
export function treemap(opts: TreemapOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 12;

  const acc = theme.accent!;
  const tones = theme.tones!;

  const data = opts.data ?? [];
  const flatNodes: TreemapNode[] = [];
  data.forEach((item) => {
    if (item.children && item.children.length > 0) {
      item.children.forEach((child) => {
        flatNodes.push({ label: child.label, value: child.value, order: flatNodes.length });
      });
    } else {
      flatNodes.push({ label: item.label, value: item.value, order: flatNodes.length });
    }
  });

  const empty = flatNodes.length === 0;
  const minVal = empty ? 0 : Math.min(...flatNodes.map((n) => n.value));
  const maxVal = empty ? 0 : Math.max(...flatNodes.map((n) => n.value));
  const span = maxVal === minVal ? 1 : maxVal - minVal;

  // The one accent: the maximum-value node, first in flatten/data order on ties.
  let peakIdx = -1;
  if (!empty) {
    let best = -Infinity;
    for (let i = 0; i < flatNodes.length; i++) {
      if (flatNodes[i]!.value > best) {
        best = flatNodes[i]!.value;
        peakIdx = i;
      }
    }
  }
  const peakNode = peakIdx >= 0 ? flatNodes[peakIdx]! : null;

  function toneIdx(value: number): number {
    const normalized = (value - minVal) / span;
    return Math.min(Math.floor(normalized * tones.length), tones.length - 1);
  }

  // Recursive slice-and-dice: every node gets a rect of at least 1×1 as long as
  // the canvas can hold it. Local totals (not a stale remainTotal) keep small
  // leaves from collapsing to zero. Split always leaves ≥1 node on each side.
  function squarify(nodes: TreemapNode[], rect: Rect): Array<{ node: TreemapNode; rect: Rect }> {
    if (nodes.length === 0) return [];
    const usable: Rect = {
      x: rect.x,
      y: rect.y,
      w: Math.max(1, rect.w),
      h: Math.max(1, rect.h),
    };
    if (nodes.length === 1) return [{ node: nodes[0]!, rect: usable }];

    const sorted = [...nodes].sort((a, b) => b.value - a.value);
    const total = sorted.reduce((s, n) => s + n.value, 0) || 1;

    let acc = 0;
    let split = 1;
    for (let i = 0; i < sorted.length; i++) {
      acc += sorted[i]!.value;
      if (acc >= total / 2) {
        split = Math.min(Math.max(i + 1, 1), sorted.length - 1);
        break;
      }
    }

    const left = sorted.slice(0, split);
    const right = sorted.slice(split);
    const leftFrac = (left.reduce((s, n) => s + n.value, 0) || 1) / total;
    const canH = usable.h >= 2;
    const canW = usable.w >= 2;
    if (!canH && !canW) {
      // 1×1 leftover — paint the largest remaining node; smaller ones have no cell.
      return [{ node: sorted[0]!, rect: usable }];
    }
    const horiz = canH && (usable.h >= usable.w || !canW);

    if (horiz) {
      let hLeft = Math.round(usable.h * leftFrac);
      hLeft = Math.min(Math.max(hLeft, 1), usable.h - 1);
      return [
        ...squarify(left, { x: usable.x, y: usable.y, w: usable.w, h: hLeft }),
        ...squarify(right, { x: usable.x, y: usable.y + hLeft, w: usable.w, h: usable.h - hLeft }),
      ];
    }
    let wLeft = Math.round(usable.w * leftFrac);
    wLeft = Math.min(Math.max(wLeft, 1), usable.w - 1);
    return [
      ...squarify(left, { x: usable.x, y: usable.y, w: wLeft, h: usable.h }),
      ...squarify(right, { x: usable.x + wLeft, y: usable.y, w: usable.w - wLeft, h: usable.h }),
    ];
  }

  function buildPlotRows(): string[] {
    const inner = width - 4;
    const plotW = Math.max(1, inner - 1); // 1 col reserved for the +/│ guide
    const plotH = Math.max(1, height);
    const grid: string[][] = Array.from({ length: plotH }, () => Array(plotW).fill(" "));

    const layout = squarify(flatNodes, { x: 0, y: 0, w: plotW, h: plotH });

    layout.forEach(({ node, rect }) => {
      const isPeak = peakNode !== null && node.order === peakNode.order;
      const idx = toneIdx(node.value);
      const glyph = isPeak ? "█" : AREA_SHADES[Math.min(idx, AREA_SHADES.length - 1)]!;
      const color = isPeak ? acc : tones[idx]!;
      const { x, y, w, h } = rect;

      for (let row = y; row < y + h && row < plotH; row++) {
        for (let col = x; col < x + w && col < plotW; col++) {
          if (row < 0 || col < 0) continue;
          grid[row]![col] = colorize(glyph, color, noColor);
        }
      }

      if (w > 2 && h >= 1) {
        const maxLabelWidth = Math.max(0, w - 2);
        // Slivers stay clean blocks: stamp text only when it fits whole — a
        // truncated "R…" in a 1-col region is noise, not information.
        if (maxLabelWidth < node.label.length) return;
        const labelText = node.label;
        const valueText = formatNumber(node.value);
        const labelY = Math.max(0, Math.min(plotH - 1, y));
        for (let i = 0; i < labelText.length && i < maxLabelWidth; i++) {
          const col = x + 1 + i;
          if (col >= 0 && col < plotW) {
            grid[labelY]![col] = colorize(labelText[i]!, color, noColor);
          }
        }
        if (h > 2 && y + 1 < plotH && y + 1 >= 0 && maxLabelWidth >= valueText.length) {
          for (let i = 0; i < valueText.length && i < maxLabelWidth; i++) {
            const col = x + 1 + i;
            if (col >= 0 && col < plotW) {
              grid[y + 1]![col] = colorize(valueText[i]!, color, noColor);
            }
          }
        }
      }
    });

    return grid.map((row, r) => {
      const guide = colorize(r === 0 ? "+" : "│", theme.axis, noColor);
      return guide + row.join("");
    });
  }

  function buildFooter(): string {
    if (empty) return colorize("0 leaves · (no data)", theme.label, noColor);
    const head = colorize(`${flatNodes.length} leaves`, theme.label, noColor);
    const peakTail = colorize(`peak ${peakNode!.label}`, acc, noColor);
    return head + colorize(" · ", theme.label, noColor) + peakTail;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    const eyebrow = "AREA";
    if (useFrame && !useCompact) {
      lines.push(
        frameTop(width, opts.title ?? "TREEMAP", undefined, theme.axis, theme.title, noColor, true)
      );
      lines.push(frameRule(width, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(
        useFrame
          ? frameRow(width, colorize(eyebrow, theme.label, noColor), theme.axis, noColor)
          : colorize(eyebrow, theme.label, noColor)
      );
    }

    if (!empty) {
      for (const row of buildPlotRows())
        lines.push(useFrame && !useCompact ? frameRow(width, row, theme.axis, noColor) : row);
    }

    if (!useCompact) {
      lines.push(useFrame ? frameRow(width, buildFooter(), theme.axis, noColor) : buildFooter());
    }
    if (useFrame && !useCompact) lines.push(frameBottom(width, theme.axis, noColor, true));
    return lines;
  }

  const rawLines = buildLines();
  const clippedLines =
    opts.maxWidth === undefined ? rawLines : rawLines.map((l) => truncateAnsi(l, opts.maxWidth!));
  const output = clippedLines.join("\n");

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
    toContent() {
      return treemap({ ...opts, frame: false, compact: true }).toPlain();
    },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
    toJSON() {
      return {
        type: "treemap",
        data: opts.data,
        n: flatNodes.length,
        min: minVal,
        max: maxVal,
        peak: peakNode ? { label: peakNode.label, value: peakNode.value } : null,
        plain: stripAnsi(output),
      };
    },
  };
}
