import type { AreaChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, stripAnsi, truncateAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

/** Braille dot mapping: each cell is 2 dots wide × 4 dots tall. Dot (x,y)
 *  lights bit at position `x * 4 + y` of the braille char. */
const AREA_BITS = [
  [0x01, 0x08],
  [0x02, 0x10],
  [0x04, 0x20],
  [0x40, 0x80],
];

interface AreaCanvas {
  dotCols: number;
  dotRows: number;
  set(dc: number, dr: number): void;
  fillColumn(dc: number, from: number, to: number): void;
  toLines(): string[];
}

/** A braille dot canvas: rows × cols cells, each 2×4 dots. Empty cells are
 *  SPACES — never blank-braille (U+2800), which renders as faint dots. */
function areaCanvas(cols: number, rows: number): AreaCanvas {
  const dots = new Uint8Array(rows * cols);
  const dotCols = cols * 2;
  const dotRows = rows * 4;
  return {
    dotCols,
    dotRows,
    set(dc, dr) {
      if (dc < 0 || dc >= dotCols || dr < 0 || dr >= dotRows) return;
      dots[Math.floor(dr / 4) * cols + Math.floor(dc / 2)] |= AREA_BITS[dr % 4]![dc % 2]!;
    },
    fillColumn(dc, from, to) {
      const lo = Math.min(from, to);
      const hi = Math.max(from, to);
      for (let r = lo; r <= hi; r++) this.set(dc, r);
    },
    toLines() {
      const out: string[] = [];
      for (let r = 0; r < rows; r++) {
        let line = "";
        for (let c = 0; c < cols; c++) {
          const b = dots[r * cols + c];
          line += b === 0 ? " " : String.fromCodePoint(0x2800 + b);
        }
        out.push(line);
      }
      return out;
    },
  };
}

/** The line IS the fill's interpolated top edge: every column is filled down to
 *  the baseline, and the top dot of each column is the line. One clean edge. */
function buildArea(
  data: number[],
  cols: number,
  rows: number,
  yMin: number,
  yMax: number
): { fill: AreaCanvas; lineTop: Int16Array } {
  const fill = areaCanvas(cols, rows);
  const lineTop = new Int16Array(cols * 2).fill(-1);
  const fillRows = rows * 4;
  const span = yMax - yMin;
  for (let x = 0; x < cols * 2; x++) {
    const fx = (x / (cols * 2 - 1)) * (data.length - 1);
    const i0 = Math.floor(fx);
    const i1 = Math.min(Math.ceil(fx), data.length - 1);
    const t = fx - i0;
    const v = i0 === i1 ? data[i0]! : data[i0]! * (1 - t) + data[i1]! * t;
    const norm = span === 0 ? 0.5 : (v - yMin) / span;
    const y = fillRows - 1 - Math.round(norm * (fillRows - 1));
    lineTop[x] = y;
    fill.fillColumn(x, y, fillRows - 1);
  }
  return { fill, lineTop };
}

export function area(opts: AreaChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 15;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti
    ? (rawData as number[][])
    : [rawData as number[]];
  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);

  const allValues = series.flat();
  const dataMin = Math.min(...allValues);
  const dataMax = Math.max(...allValues);
  // y-range auto-scales to the data so the area fills the panel height —
  // no dead space hugging the bottom.
  const yMin = opts.yMin ?? dataMin;
  const yMax = opts.yMax ?? dataMax;

  const yAxisW = Math.max(formatNumber(yMax).length, formatNumber(yMin).length) + 1;
  const plotCols = width - yAxisW - 6;
  const plotRows = height - 2;
  const acc = theme.accent!;
  const tones = theme.tones!;
  const lineColor = tones[2] ?? tones[1];
  const fillColor = tones[1] ?? tones[0];

  // primary series: one accent marks the peak (like the pie's largest slice)
  const areas = series.map((s) => buildArea(s, plotCols, plotRows, yMin, yMax));
  const primary = areas[0]!;
  const maxIdx = primarySeriesMaxIndex(series[0]!);
  const peakDotX = Math.round((maxIdx / Math.max(1, series[0]!.length - 1)) * (primary.fill.dotCols - 1));
  const peakCap = new Set([peakDotX - 1, peakDotX, peakDotX + 1]);

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    const eyebrow = (opts.eyebrow ?? "TREND").toUpperCase();
    if (useFrame && !useCompact) {
      lines.push(frameTop(width, opts.title ?? "AREA", opts.timestamp, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(width, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(width, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
    }

    const yStep = Math.max(1, Math.floor(plotRows / 5));
    for (let row = 0; row < plotRows; row++) {
      const yVal = yMax - (row / Math.max(1, plotRows - 1)) * (yMax - yMin);
      const yLabel =
        row % yStep === 0 || row === plotRows - 1
          ? padStart(formatNumber(yVal), yAxisW - 1)
          : " ".repeat(yAxisW - 1);
      let rowStr = colorize(yLabel + "│", theme.axis, noColor);

      for (let c = 0; c < plotCols; c++) {
        // gather the cell char per series (layered, later series on top)
        let cell: string | null = null;
        let cellColor = "";
        for (let s = series.length - 1; s >= 0; s--) {
          const { fill, lineTop } = areas[s]!;
          const fLine = fill.toLines()[row] ?? "";
          const fCh = fLine[c] ?? " ";
          if (fCh === " ") continue;
          let hasTop = false;
          for (let dc = 0; dc < 2; dc++) {
            const topY = lineTop[c * 2 + dc];
            if (topY >= row * 4 && topY <= row * 4 + 3) hasTop = true;
          }
          let isPeak = false;
          if (s === 0) {
            for (let dc = 0; dc < 2; dc++) {
              const x = c * 2 + dc;
              if (!peakCap.has(x)) continue;
              const topY = lineTop[x];
              if (topY >= row * 4 && topY <= row * 4 + 3) isPeak = true;
            }
          }
          cell = fCh;
          if (s === 0) {
            cellColor = isPeak ? acc : hasTop ? lineColor : fillColor;
          } else {
            const sColor = theme.colors[s % theme.colors.length];
            cellColor = hasTop ? sColor : theme.colors[(s + 1) % theme.colors.length];
          }
          break;
        }
        rowStr += cell ? colorize(cell, cellColor, noColor) : " ";
      }

      lines.push(useFrame && !useCompact ? frameRow(width, rowStr, theme.axis, noColor) : rowStr);
    }

    if (useFrame && !useCompact) lines.push(frameRule(width, theme.axis, noColor));
    if (!useCompact) {
      const last = series[0]![series[0]!.length - 1];
      const foot =
        (isMulti ? `${seriesLabels[0]} · ` : "series · ") +
        colorize(`max ${formatNumber(dataMax)}`, acc, noColor) +
        ` · min ${formatNumber(dataMin)} · last ${formatNumber(last)}`;
      lines.push(useFrame ? frameRow(width, foot, theme.axis, noColor) : foot);
    }
    if (useFrame && !useCompact) lines.push(frameBottom(width, theme.axis, noColor, true));
    return lines;
  }

  const rawLines = buildLines();
  const clippedLines = opts.maxWidth === undefined ? rawLines : rawLines.map((l) => truncateAnsi(l, opts.maxWidth!));
  const output = clippedLines.join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toContent() { return area({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "area",
        data: opts.data,
        title: opts.title,
        plain: stripAnsi(output),
      };
    },
  };
}

function primarySeriesMaxIndex(data: number[]): number {
  let idx = 0;
  let max = data[0] ?? 0;
  for (let i = 1; i < data.length; i++) {
    if ((data[i] ?? 0) > max) {
      max = data[i]!;
      idx = i;
    }
  }
  return idx;
}
