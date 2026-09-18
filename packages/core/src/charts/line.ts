import type { LineChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { ansi, colorize, padStart, stripAnsi, truncateAnsi, visibleLength } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { createLineChartModel, lineModelToPlain, lineModelToSvg, type LineSeriesModel } from "./line-model.js";
import { BrailleCanvas, plotLineOnBrailleCanvas } from "../renderers/braille.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

function terminalWidth(explicit?: number): number {
  if (explicit) return explicit;
  const cols = typeof process !== "undefined" ? process.stdout?.columns : undefined;
  return Math.max(60, Math.min(cols || 76, 100));
}

/** The 3 dot-columns around the primary series max get the single accent —
 *  the rest of the curve stays on the tone ramp (LOCKED: accent spent once). */
function primaryPeakCap(series: LineSeriesModel | undefined, dotCols: number): Set<number> {
  const cap = new Set<number>();
  if (!series || series.values.length < 2) return cap;
  let maxIdx = 0;
  let maxVal = series.values[0] ?? Number.NEGATIVE_INFINITY;
  series.values.forEach((v, i) => {
    if (v > maxVal) {
      maxVal = v;
      maxIdx = i;
    }
  });
  const peakDotX = Math.round((maxIdx / (series.values.length - 1)) * (dotCols - 1));
  cap.add(peakDotX - 1);
  cap.add(peakDotX);
  cap.add(peakDotX + 1);
  return cap;
}

/** Texture-coded strokes, matching the reference's legend dash language: the
 *  primary is SOLID (step 1), the first extra series is DASHED (step 2 — cell
 *  on / cell off), and every later series is DOTTED (step 3). Keeps crossing
 *  curves distinguishable in plain monochrome. */
function lineTextureStep(seriesIndex: number): number {
  if (seriesIndex === 0) return 1;
  return seriesIndex === 1 ? 2 : 3;
}

/** Texture is a MONOCHROME fallback only — in colour mode every series draws
 *  as a solid line exactly like the reference (the dash language lives on the
 *  gridlines, not the series). */
function seriesStrokeStep(seriesIndex: number, noColor: boolean): number {
  return noColor ? lineTextureStep(seriesIndex) : 1;
}

/** Legend style hint text — in colour mode every legend is a solid `──glyph──`
 *  dash pair (identity via colour, like the reference); in monochrome each
 *  series keeps its own dash character so the texture survives without colour. */
const DASH_CHARS = ["──", "╌╌", "··", "─╌"];

function dashCharsFor(seriesIndex: number, noColor: boolean): string {
  if (!noColor) return DASH_CHARS[0]!;
  if (seriesIndex === 0) return DASH_CHARS[0]!;
  return DASH_CHARS[((seriesIndex - 1) % (DASH_CHARS.length - 1)) + 1]!;
}

/** Every series drops its glyph marker (○ + × □) at every 2nd data point, so
 *  crossing curves are identifiable by shape even in monochrome — matching the
 *  SVG (index % 2 === 0). Markers beat lower-priority braille but the accent
 *  cap on the primary peak outranks them. */
function markerCells(
  series: LineSeriesModel[],
  colors: string[],
  plotCols: number,
  plotRows: number,
  yMin: number,
  yMax: number,
  noColor: boolean
): Map<number, string> {
  const markers = new Map<number, string>();
  if (series.length === 0) return markers;
  const dotCols = plotCols * 2;
  const dotRows = plotRows * 4;
  series.forEach((s, si) => {
    if (s.values.length < 2) return;
    for (let i = 0; i < s.values.length; i += 2) {
      const dotX = Math.round((i / (s.values.length - 1)) * (dotCols - 1));
      const cell = Math.floor(dotX / 2);
      const v = s.values[i] ?? 0;
      const norm = yMax === yMin ? 0.5 : (v - yMin) / (yMax - yMin);
      const dotY = dotRows - 1 - Math.round(norm * (dotRows - 1));
      const row = Math.floor(dotY / 4);
      const key = row * plotCols + cell;
      if (!markers.has(key)) markers.set(key, colorize(s.marker, colors[si]!, noColor));
    }
  });
  return markers;
}

/** Merge per-series braille rows into one row; empty cells are SPACES — never
 *  blank-braille (U+2800), which renders as faint dots. Priority per cell:
 *  primary accent cap > glyph marker > series line > grid guide. */
function mergeLineCells(
  lines: string[],
  markers: Map<number, string>,
  row: number,
  colors: string[],
  accent: string,
  cap: Set<number>,
  noColor: boolean
): string {
  if (lines.length === 0) return "";
  const len = Math.max(...lines.map((l) => l.length));
  let out = "";
  for (let i = 0; i < len; i++) {
    let ch = " ";
    let si = -1;
    for (let k = 0; k < lines.length; k++) {
      const c = lines[k]?.[i] ?? " ";
      if (c !== " ") {
        ch = c;
        si = k;
        break;
      }
    }
    if (si === -1) {
      out += " ";
      continue;
    }
    const inCap = si === 0 && (cap.has(i * 2) || cap.has(i * 2 + 1));
    if (inCap) {
      out += colorize(ch, accent, noColor);
      continue;
    }
    const marker = markers.get(row * len + i);
    if (marker) {
      out += marker;
      continue;
    }
    out += colorize(ch, colors[si]!, noColor);
  }
  return out;
}

/** Renders a chitra-standard TUI panel carrying the LOCKED S09 design
 *  language: dashed frame, eyebrow row, `│` y-guide, braille line on the tone
 *  ramp with the accent spent once on the peak, `+` x-tick marks, and footer
 *  stats per series. In colour mode every series draws solid like the
 *  reference; in monochrome strokes are texture-coded (primary solid, extras
 *  dashed/dotted) so crossing curves stay separable. */
export function line(opts: LineChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = terminalWidth(opts.width);
  const height = opts.height ?? 14;
  const renderer = opts.renderer ?? "braille";
  const showAxes = opts.showAxes !== false;

  const model = createLineChartModel(opts);
  const innerWidth = width - 4; // minus "│ " ... " │"
  const acc = theme.accent!;
  const tones = theme.tones!;
  // Same "one hue + tone ramp" language as the LOCKED pie/donut/area charts.
  // A lone line keeps the LOCKED grey body with the accent spent once on its
  // peak. With several series the primary becomes the accent hero (like the
  // pie's largest slice) and the extras recede onto the shared grey ramp —
  // identity among the greys comes from the glyph markers (`* ○ + × □`), never
  // from separate bright hues.
  const multiSeries = model.series.length > 1;
  const toneOrder = [tones[2], tones[0], tones[3] ?? tones[1], tones[1]].filter(Boolean) as string[];
  const seriesColors = model.series.map((_, i) =>
    i === 0 && multiSeries ? acc : toneOrder[i % toneOrder.length]!
  );

  const yAxisW =
    Math.max(
      formatNumber(Math.round(model.yMax)).length,
      formatNumber(Math.round(model.yMin)).length
    ) + 1;
  const plotCols = Math.max(8, innerWidth - yAxisW - 2);
  const plotRows = Math.max(3, height - 2);

  const yStep = Math.max(1, Math.floor(plotRows / 5));
  /** Gridline rows (every yStep) get a dotted guide that never hides a curve —
   *  series cells and markers outrank it, and it skips the top/base rows. Rendered
   *  dim (one dot every 2nd column, like the reference's `9 9` dash) so it reads
   *  as a faint backdrop, never a competing stroke. */
  const showGrid = opts.grid ?? false;
  function isGridRow(row: number): boolean {
    return showGrid && row > 0 && row < plotRows - 1 && row % yStep === 0;
  }

  function dashedGrid(cols: number): string {
    let out = "";
    for (let col = 0; col < cols; col++) out += col % 2 === 0 ? "·" : " ";
    return out;
  }

  function plotRowLabel(row: number): string {
    if (!showAxes) return "";
    const yVal = model.yMax - (row / Math.max(1, plotRows - 1)) * (model.yMax - model.yMin);
    return (row % yStep === 0 || row === plotRows - 1)
      ? padStart(formatNumber(Math.round(yVal)), yAxisW - 1)
      : " ".repeat(yAxisW - 1);
  }

  const smooth = opts.smooth ?? true;
  function renderBrailleRows(): string[] {
    const canvases = model.series.map(() => new BrailleCanvas(plotCols, plotRows));
    model.series.forEach((s, si) => {
      if (s.values.length >= 2) {
        plotLineOnBrailleCanvas(canvases[si]!, s.values, model.yMin, model.yMax, smooth);
        canvases[si]!.thin(seriesStrokeStep(si, noColor));
      }
    });
    const cap = primaryPeakCap(model.series[0], plotCols * 2);
    const markers = markerCells(model.series, seriesColors, plotCols, plotRows, model.yMin, model.yMax, noColor);
    const gridColor = [...seriesColors, ansi.dim + (theme.grid ?? theme.axis)];
    const rows: string[] = [];
    for (let row = 0; row < plotRows; row++) {
      const lines = canvases.map((c) => c.toLines(" ")[row] ?? "");
      lines.push(isGridRow(row) ? dashedGrid(plotCols) : " ".repeat(plotCols));
      const cells = mergeLineCells(lines, markers, row, gridColor, acc, cap, noColor);
      const guide = row === 0 ? "+" : "│";
      const prefix = showAxes ? colorize(plotRowLabel(row) + guide, theme.axis, noColor) : "";
      rows.push(prefix + cells);
    }
    return rows;
  }

  function renderBlockRows(): string[] {
    const grid = Array.from({ length: plotRows }, () => Array<string>(plotCols).fill(""));
    const cellCap = new Set<number>();
    const primary = model.series[0];

    function setCell(col: number, yRow: number, ch: string, color: string): void {
      if (yRow < 0 || yRow >= plotRows || col < 0 || col >= plotCols) return;
      if (grid[yRow]![col]) return;
      grid[yRow]![col] = colorize(ch, color, noColor);
    }

    if (primary && primary.values.length >= 2) {
      let maxIdx = 0;
      let maxVal = primary.values[0] ?? Number.NEGATIVE_INFINITY;
      primary.values.forEach((v, i) => {
        if (v > maxVal) {
          maxVal = v;
          maxIdx = i;
        }
      });
      const peakCell = Math.round((maxIdx / (primary.values.length - 1)) * (plotCols - 1));
      cellCap.add(peakCell - 1);
      cellCap.add(peakCell);
      cellCap.add(peakCell + 1);
    }

    const yRowFor = (v: number): number => {
      const yNorm = model.yMax === model.yMin ? 0.5 : (v - model.yMin) / (model.yMax - model.yMin);
      return Math.round((1 - yNorm) * (plotRows - 1));
    };

    /** Glyph-chain pass: every series drops its marker at every 2nd data point
     *  (i += 2, matching the reference), and that's ALL the block renderer
     *  draws — no `●` filler. The curve reads by following the marker chain,
     *  so the plot stays airy and traceable with several crossing series. */
    model.series.forEach((s, si) => {
      if (s.values.length < 2) return;
      const color = seriesColors[si]!;
      for (let i = 0; i < s.values.length; i += 2) {
        const col = Math.round((i / (s.values.length - 1)) * (plotCols - 1));
        const isCap = si === 0 && cellCap.has(col);
        setCell(col, yRowFor(s.values[i] ?? 0), s.marker, isCap ? acc : color);
      }
    });

    /** The ascii renderer is the one exception: it needs a connecting line too,
     *  because bare markers don't read in pure ASCII. So it paints an
     *  interpolated `●`/slope line under its markers. The block renderer never
     *  reaches this pass. */
    if (renderer === "ascii") {
      model.series.forEach((s, si) => {
        if (s.values.length < 2) return;
        const color = seriesColors[si]!;
        const step = noColor ? 2 + Math.min(si, 2) : 2;
        for (let col = 0; col < plotCols; col++) {
          if (col % step !== 0) continue;
          const exactX = (col / Math.max(1, plotCols - 1)) * (s.values.length - 1);
          const idxL = Math.floor(exactX);
          const idxR = Math.min(s.values.length - 1, Math.ceil(exactX));
          const frac = exactX - idxL;
          const val = idxL === idxR ? s.values[idxL]! : s.values[idxL]! * (1 - frac) + s.values[idxR]! * frac;
          const yRow = yRowFor(val);

          let ch: string;
          if (col > 0) {
            const isExactPoint = frac < 0.1 || frac > 0.9;
            if (!isExactPoint) {
              const prevX = ((col - 1) / Math.max(1, plotCols - 1)) * (s.values.length - 1);
              const prevVal = s.values[Math.floor(prevX)]!;
              ch = val > prevVal + 1e-9 ? "/" : val < prevVal - 1e-9 ? "\\" : "-";
            } else {
              ch = s.marker;
            }
          } else {
            ch = s.marker;
          }
          const isCap = si === 0 && cellCap.has(col);
          setCell(col, yRow, ch, isCap ? acc : color);
        }
      });
    }

    for (let row = 0; row < plotRows; row++) {
      if (!isGridRow(row)) continue;
      for (let col = 0; col < plotCols; col++) {
        if (col % 2 === 0 && !grid[row]![col]) grid[row]![col] = colorize("·", ansi.dim + (theme.grid ?? theme.axis), noColor);
      }
    }

    const rows: string[] = [];
    for (let row = 0; row < plotRows; row++) {
      const guide = row === 0 ? "+" : "│";
      const prefix = showAxes ? colorize(plotRowLabel(row) + guide, theme.axis, noColor) : "";
      rows.push(prefix + grid[row]!.join(""));
    }
    return rows;
  }

  function renderXAxisLabels(): string[] {
    if (!showAxes || model.labels.length === 0) return [];
    const n = model.labels.length;
    const slotW = Math.max(1, Math.floor(plotCols / n));
    const labelChars = Array<string>(plotCols).fill(" ");
    model.labels.forEach((label, i) => {
      const truncated = label.slice(0, slotW);
      const slotStart = Math.round((i * plotCols) / n);
      const slotEnd = Math.min(plotCols, Math.round(((i + 1) * plotCols) / n));
      let startCol = slotStart + Math.floor((slotEnd - slotStart - truncated.length) / 2);
      if (startCol < 0) startCol = 0;
      for (let j = 0; j < truncated.length && startCol + j < plotCols; j++) {
        labelChars[startCol + j] = truncated[j]!;
      }
    });
    return [" ".repeat(yAxisW) + colorize(labelChars.join(""), theme.label, noColor)];
  }

  /** The reference puts a `+` on the x-axis at every tick. In the terminal that
   *  becomes a dedicated axis-colour tick row between the plot and the label
   *  row, with a `+` aligned to each label slot. */
  function renderXTickMarks(): string[] {
    if (!showAxes || model.labels.length === 0) return [];
    const n = model.labels.length;
    const cells = Array<string>(plotCols).fill(" ");
    model.labels.forEach((_, i) => {
      const slotStart = Math.round((i * plotCols) / n);
      const slotEnd = Math.min(plotCols, Math.round(((i + 1) * plotCols) / n));
      const mid = slotStart + Math.floor((slotEnd - slotStart) / 2);
      cells[mid] = "+";
    });
    return [" ".repeat(yAxisW) + colorize(cells.join(""), theme.axis, noColor)];
  }

  function renderLegend(): string[] {
    if (!model.showLegend || model.series.length === 0) return [];
    const items = model.series.map((s, i) =>
      colorize(`${dashCharsFor(i, noColor)}${s.marker}${dashCharsFor(i, noColor)} ${s.name}`, seriesColors[i]!, noColor)
    );
    return wrapItems(items, innerWidth);
  }

  /** Compact block spark bar (`▁▂▃▄▅▆▇█`) — the terminal echo of the reference's
   *  per-series sparkline in the summary panel. */
  const SPARK_CHARS = "▁▂▃▄▅▆▇█";

  function sparkline(values: number[], color: string, width = 14): string {
    if (values.length === 0) return "";
    const lo = Math.min(...values);
    const hi = Math.max(...values);
    const range = hi - lo || 1;
    let out = "";
    for (let i = 0; i < width; i++) {
      const idx = Math.min(values.length - 1, Math.floor(((i + 0.5) / width) * values.length));
      const t = ((values[idx] ?? lo) - lo) / range;
      out += SPARK_CHARS[Math.min(7, Math.round(t * 7))]!;
    }
    return colorize(out, color, noColor);
  }

  function renderSummary(): string[] {
    if (model.series.length === 0) return [];
    const nameW = Math.max(...model.series.map((s) => visibleLength(s.name) + 2));
    const rows = model.series.map((s, si) => {
      const stats = s.stats;
      const name = colorize(`${s.marker} ${s.name}`.padEnd(nameW), seriesColors[si]!, noColor);
      const maxPart = si === 0
        ? colorize(`max ${formatNumber(stats.max)}`, acc, noColor)
        : `max ${formatNumber(stats.max)}`;
      const left = `${name} · min ${formatNumber(stats.min)} · ${maxPart} · avg ${formatNumber(stats.avg)} · last ${formatNumber(stats.last)}`;
      const leftLen = visibleLength(left);
      if (leftLen >= innerWidth) return left.slice(0, innerWidth);
      const room = innerWidth - leftLen - 3;
      const sparkW = room < 4 ? 0 : Math.min(14, room);
      const spark = sparkline(s.values, seriesColors[si]!, sparkW);
      const pad = Math.max(0, innerWidth - leftLen - visibleLength(spark) - 1);
      return left + " ".repeat(pad) + spark;
    });
    return wrapItems(rows, innerWidth);
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    const eyebrow = (opts.eyebrow ?? "TREND").toUpperCase();

    if (useFrame && !useCompact) {
      lines.push(frameTop(width, opts.title ?? "LINE", opts.timestamp, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(width, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(width, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
      for (const item of renderLegend()) lines.push(useFrame ? frameRow(width, item, theme.axis, noColor) : item);
    }

    const plotRowsOut = renderer === "braille" ? renderBrailleRows() : renderBlockRows();
    for (const row of plotRowsOut) lines.push(useFrame && !useCompact ? frameRow(width, row, theme.axis, noColor) : row);
    for (const row of renderXTickMarks()) lines.push(useFrame && !useCompact ? frameRow(width, row, theme.axis, noColor) : row);
    for (const row of renderXAxisLabels()) lines.push(useFrame && !useCompact ? frameRow(width, row, theme.axis, noColor) : row);

    if (model.showSummary && !useCompact) {
      if (useFrame) lines.push(frameRule(width, theme.axis, noColor));
      for (const row of renderSummary()) lines.push(useFrame ? frameRow(width, row, theme.axis, noColor) : row);
    }

    if (opts.status && !useCompact) {
      if (useFrame) lines.push(frameRule(width, theme.axis, noColor));
      lines.push(useFrame ? frameRow(width, colorize(`Status: ${opts.status}`, theme.title, noColor), theme.axis, noColor) : colorize(`Status: ${opts.status}`, theme.title, noColor));
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
    toContent() { return line({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "line",
        data: opts.data,
        labels: opts.labels,
        title: opts.title,
        plain: stripAnsi(output),
        model: lineModelToPlain(model),
      };
    },
    toSVG() { return lineModelToSvg(model); },
  };
}

function wrapItems(items: string[], maxWidth: number): string[] {
  const rows: string[] = [];
  let current = "";
  for (const item of items) {
    const candidate = current ? current + "  " + item : item;
    if (visibleLength(candidate) > maxWidth && current) {
      rows.push(current);
      current = item;
    } else {
      current = candidate;
    }
  }
  if (current) rows.push(current);
  return rows;
}
