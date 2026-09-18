import type { ScatterPlotOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, stripAnsi, truncateAnsi, visibleLength } from "../ansi.js";
import { formatNumber } from "../utils.js";
import { BrailleCanvas } from "../renderers/braille.js";
import { frameTop, frameBottom, frameRow, frameRule } from "../renderers/panel.js";

const GLYPHS = ["●", "○", "◆", "◇", "▲", "△"];

/** Renders a chitra-standard TUI panel carrying the LOCKED S17 design language:
 *  dashed frame, eyebrow row, `│` y-guide with a `+` at the top row, braille or
 *  glyph points on the grey tone ramp with the single accent hue spent ONCE on
 *  the primary series' max-y point (survives the braille cell it shares), and an
 *  `n · x-range · y-range · peak (x, y)` summary footer with the peak in accent.
 *  No raw `theme.colors[i % n]` rainbow — series identity comes from glyph shape
 *  and position, exactly like the LOCKED line/bar/area/circular charts. */
export function scatter(opts: ScatterPlotOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 15;
  const renderer = opts.renderer ?? "braille";
  const showAxes = opts.showAxes !== false;

  const acc = theme.accent!;
  const tones = theme.tones!;
  // Same "one hue + grey tone ramp" language as the LOCKED bar/line/area charts.
  const toneOrder = [tones[2], tones[0], tones[3] ?? tones[1], tones[1]].filter(Boolean) as string[];

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]) && !("x" in (rawData[0] as object));
  const series = isMulti
    ? (rawData as Array<Array<{ x: number; y: number }>>)
    : [rawData as Array<{ x: number; y: number }>];

  const allPoints = series.flat();
  const n = allPoints.length;
  const empty = n === 0;

  const innerWidth = width - 4; // frame consumes "│ " ... " │"

  // Ranges — guarded against empty data so the panel never emits Infinity/NaN.
  const allX = allPoints.map((p) => p.x);
  const allY = allPoints.map((p) => p.y);
  const xMinVal = opts.xMin ?? (empty ? 0 : Math.min(...allX));
  const xMaxVal = opts.xMax ?? (empty ? 0 : Math.max(...allX));
  const yMinVal = opts.yMin ?? (empty ? 0 : Math.min(...allY));
  const yMaxVal = opts.yMax ?? (empty ? 0 : Math.max(...allY));
  const xSpan = xMaxVal === xMinVal ? 1 : xMaxVal - xMinVal;
  const ySpan = yMaxVal === yMinVal ? 1 : yMaxVal - yMinVal;

  // The one accent: the primary series' max-y point (first on ties, deterministic),
  // or an explicit opts.highlight override into the primary series.
  const primary = series[0] ?? [];
  let peak: { x: number; y: number } | null = null;
  if (primary.length > 0) {
    if (opts.highlight != null && primary[opts.highlight]) {
      peak = primary[opts.highlight]!;
    } else {
      let maxVal = -Infinity;
      for (const pt of primary) {
        if (pt.y > maxVal) {
          maxVal = pt.y;
          peak = pt;
        }
      }
    }
  }

  const yRange = Math.abs(yMaxVal - yMinVal);
  const yDecimals = yRange >= 10 ? 0 : yRange >= 1 ? 1 : 2;
  const fmtY = (v: number): string => v.toFixed(yDecimals);
  const yAxisWidth = Math.max(fmtY(yMaxVal).length, fmtY(yMinVal).length) + 1;
  const plotCols = Math.max(8, innerWidth - yAxisWidth);
  const plotRows = Math.max(3, height);
  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);
  const multiSeries = series.length > 1;
  const seriesColors = series.map((_, i) => (i === 0 && multiSeries ? acc : toneOrder[i % toneOrder.length]!));

  function yLabelFor(row: number): string {
    const yLabelStep = Math.max(1, Math.floor(plotRows / 5));
    const yVal = yMaxVal - (row / Math.max(1, plotRows - 1)) * (yMaxVal - yMinVal);
    const label =
      row % yLabelStep === 0 || row === plotRows - 1
        ? padStart(fmtY(yVal), yAxisWidth - 1)
        : " ".repeat(yAxisWidth - 1);
    return colorize(label, theme.label, noColor);
  }

  function guideFor(row: number): string {
    if (!showAxes) return "";
    // `+` on the top row mirrors the LOCKED line/bar y-axis tick language.
    return colorize(row === 0 ? "+" : "│", theme.axis, noColor);
  }

  function buildBrailleRows(): string[] {
    const canvases = series.map((s) => {
      const canvas = new BrailleCanvas(plotCols, plotRows);
      for (const pt of s) {
        const dotX = Math.round(((pt.x - xMinVal) / xSpan) * (canvas.dotCols - 1));
        const dotY = canvas.dotRows - 1 - Math.round(((pt.y - yMinVal) / ySpan) * (canvas.dotRows - 1));
        canvas.set(dotX, dotY);
      }
      return canvas;
    });
    const canvasLines = canvases.map((c) => c.toLines(" "));

    // The accent point's CELL (col AND row), so it survives a shared 2x4 cell.
    let peakKey = -1;
    if (peak) {
      const dotCols = plotCols * 2;
      const dotRows = plotRows * 4;
      const dotX = Math.round(((peak.x - xMinVal) / xSpan) * (dotCols - 1));
      const dotY = dotRows - 1 - Math.round(((peak.y - yMinVal) / ySpan) * (dotRows - 1));
      peakKey = Math.floor(dotY / 4) * plotCols + Math.floor(dotX / 2);
    }

    const rows: string[] = [];
    for (let row = 0; row < plotRows; row++) {
      let rowStr = yLabelFor(row) + guideFor(row);
      for (let col = 0; col < plotCols; col++) {
        let ch = " ";
        let si = -1;
        // Multi-series: the PRIMARY group (series 0) is the accent hero and wins the cell, so its
        // colour survives an overlap. Single series: the topmost dot wins and the accent is spent
        // once on the peak cell.
        if (multiSeries) {
          const c0 = canvasLines[0]![row]?.[col] ?? " ";
          if (c0 !== " " && c0 !== "⠀") {
            ch = c0;
            si = 0;
          } else {
            for (let k = series.length - 1; k >= 1; k--) {
              const c = canvasLines[k]![row]?.[col] ?? " ";
              if (c !== " " && c !== "⠀") {
                ch = c;
                si = k;
                break;
              }
            }
          }
        } else {
          const c = canvasLines[0]![row]?.[col] ?? " ";
          if (c !== " " && c !== "⠀") {
            ch = c;
            si = 0;
          }
        }
        if (si === -1) {
          rowStr += " ";
          continue;
        }
        const color = multiSeries
          ? (si === 0 ? acc : toneOrder[si % toneOrder.length]!)
          : (row * plotCols + col === peakKey ? acc : toneOrder[0]!);
        rowStr += colorize(ch, color, noColor);
      }
      rows.push(rowStr);
    }
    return rows;
  }

  function buildGridRows(): string[] {
    const grid: string[][] = Array.from({ length: plotRows }, () => Array(plotCols).fill(" "));

    let peakRow = -1;
    let peakCol = -1;
    if (peak) {
      peakCol = Math.round(((peak.x - xMinVal) / xSpan) * (plotCols - 1));
      peakRow = Math.round((1 - (peak.y - yMinVal) / ySpan) * (plotRows - 1));
    }

    const plotPoint = (pt: { x: number; y: number }): [number, number] | null => {
      const col = Math.round(((pt.x - xMinVal) / xSpan) * (plotCols - 1));
      const row = Math.round((1 - (pt.y - yMinVal) / ySpan) * (plotRows - 1));
      if (col < 0 || col >= plotCols || row < 0 || row >= plotRows) return null;
      return [row, col];
    };

    if (multiSeries) {
      // The non-primary groups render grey first; the PRIMARY group (series 0) is painted LAST,
      // in the accent hue, ON TOP — so the important group reads as one solid coloured cluster and
      // the rest recede. (A future interactive renderer can re-accent another group on hover.)
      for (let si = series.length - 1; si >= 1; si--) {
        const ch = GLYPHS[si % GLYPHS.length]!;
        for (const pt of series[si]!) {
          const rc = plotPoint(pt);
          if (rc && grid[rc[0]]![rc[1]] === " ") grid[rc[0]]![rc[1]] = colorize(ch, toneOrder[si % toneOrder.length]!, noColor);
        }
      }
      for (const pt of series[0]!) {
        const rc = plotPoint(pt);
        if (rc) grid[rc[0]]![rc[1]] = colorize(GLYPHS[0]!, acc, noColor);
      }
    } else {
      // Single series: every point on the tone ramp, the accent spent LAST on the peak cell so an
      // overlapping point can never stomp it.
      for (const pt of series[0]!) {
        const rc = plotPoint(pt);
        if (!rc || (rc[0] === peakRow && rc[1] === peakCol)) continue;
        if (grid[rc[0]]![rc[1]] === " ") grid[rc[0]]![rc[1]] = colorize(GLYPHS[0]!, toneOrder[0]!, noColor);
      }
      if (peak && peakRow >= 0 && peakRow < plotRows && peakCol >= 0 && peakCol < plotCols) {
        grid[peakRow]![peakCol] = colorize(GLYPHS[0]!, acc, noColor);
      }
    }

    const rows: string[] = [];
    for (let row = 0; row < plotRows; row++) {
      rows.push(yLabelFor(row) + guideFor(row) + grid[row]!.join(""));
    }
    return rows;
  }

  function buildLegend(): string[] {
    if (!multiSeries || opts.legend === false) return [];
    const items = seriesLabels.map((sl, i) =>
      colorize(`${GLYPHS[i % GLYPHS.length]} ${sl}`, seriesColors[i]!, noColor)
    );
    const rows: string[] = [];
    let cur = "";
    for (const item of items) {
      const candidate = cur ? cur + "  " + item : item;
      if (visibleLength(candidate) > innerWidth && cur) {
        rows.push(cur);
        cur = item;
      } else cur = candidate;
    }
    if (cur) rows.push(cur);
    return rows;
  }

  function buildFooter(): string {
    if (empty) return colorize("n 0", theme.label, noColor);
    const head = colorize(
      `n ${n} · x ${formatNumber(xMinVal)}..${formatNumber(xMaxVal)} · y ${formatNumber(yMinVal)}..${formatNumber(yMaxVal)}`,
      theme.label,
      noColor
    );
    // Multi-series: the footer names the accent GROUP (the highlighted primary series), not a
    // single point — the accent is a whole cluster now, not one peak.
    if (multiSeries) {
      const tail = colorize(`${GLYPHS[0]} ${seriesLabels[0]}`, acc, noColor);
      return head + colorize(" · ", theme.label, noColor) + tail;
    }
    if (!peak) return head;
    const peakCell = colorize(`peak (${formatNumber(peak.x)}, ${formatNumber(peak.y)})`, acc, noColor);
    return head + colorize(" · ", theme.label, noColor) + peakCell;
  }

  function buildLines(): string[] {
    const lines: string[] = [];
    const useFrame = opts.frame !== false;
    const useCompact = opts.compact === true;
    const eyebrow = (opts.eyebrow ?? "CORRELATION").toUpperCase();
    if (useFrame && !useCompact) {
      lines.push(frameTop(width, opts.title ?? "SCATTER", undefined, theme.axis, theme.title, noColor, true));
      lines.push(frameRule(width, theme.axis, noColor));
    }
    if (!useCompact) {
      lines.push(useFrame ? frameRow(width, colorize(eyebrow, theme.label, noColor), theme.axis, noColor) : colorize(eyebrow, theme.label, noColor));
      for (const item of buildLegend()) lines.push(useFrame ? frameRow(width, item, theme.axis, noColor) : item);
    }

    const plotRowsOut = empty ? [] : renderer === "braille" ? buildBrailleRows() : buildGridRows();
    for (const row of plotRowsOut) lines.push(useFrame && !useCompact ? frameRow(width, row, theme.axis, noColor) : row);

    if (useFrame && !useCompact) lines.push(frameRule(width, theme.axis, noColor));
    if (!useCompact) {
      lines.push(useFrame ? frameRow(width, buildFooter(), theme.axis, noColor) : buildFooter());
    }
    if (useFrame && !useCompact) lines.push(frameBottom(width, theme.axis, noColor, true));
    return lines;
  }

  const rawLines = buildLines();
  const clippedLines = opts.maxWidth === undefined ? rawLines : rawLines.map((l) => truncateAnsi(l, opts.maxWidth!));
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
    toContent() { return scatter({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() {
      return "```\n" + stripAnsi(output) + "\n```";
    },
    toJSON() {
      return {
        type: "scatter",
        data: opts.data,
        title: opts.title,
        plain: stripAnsi(output),
      };
    },
  };
}
