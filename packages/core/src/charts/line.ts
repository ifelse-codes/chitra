import type { LineChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, stripAnsi } from "../ansi.js";
import { minMax, formatNumber, niceTicks } from "../utils.js";
import { BrailleCanvas, plotLineOnBrailleCanvas } from "../renderers/braille.js";

export function line(opts: LineChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 15;
  const renderer = opts.renderer ?? "braille";
  const showAxes = opts.showAxes !== false;

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti
    ? (rawData as number[][])
    : [rawData as number[]];

  const allValues = series.flat();
  const { min: dataMin, max: dataMax } = minMax(allValues);
  
  // Apply nice ticks for cleaner Y-axis bounds
  const plotRows = height;
  // Apply nice ticks for cleaner Y-axis bounds, but don't force a 0 baseline if data starts high
  const yTicks = showAxes ? niceTicks(opts.yMin ?? dataMin, opts.yMax ?? dataMax, Math.max(2, Math.floor(plotRows / 3))) : null;
  const yMin = yTicks ? yTicks.min : (opts.yMin ?? dataMin);
  const yMax = yTicks ? yTicks.max : (opts.yMax ?? dataMax);
  const tickLabels = yTicks ? yTicks.ticks : [];

  const yAxisWidth = Math.max(
    formatNumber(yMax).length,
    formatNumber(yMin).length,
    ...tickLabels.map(t => formatNumber(t).length)
  ) + 1;
  const plotCols = width - yAxisWidth - 2;

  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);

  function renderBraille(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const canvases = series.map(() => new BrailleCanvas(plotCols, plotRows));
    series.forEach((s, si) => {
      plotLineOnBrailleCanvas(canvases[si], s, yMin, yMax);
    });

    for (let row = 0; row < plotRows; row++) {
      let isTick = false;
      let yLabel = " ".repeat(yAxisWidth);
      
      if (showAxes && yTicks) {
        // Find if this row is close to a nice tick
        const closestTick = tickLabels.find(t => {
          const rowNorm = 1 - (row / (plotRows - 1));
          const tNorm = (t - yMin) / (yMax - yMin);
          return Math.abs(rowNorm - tNorm) < 0.5 / (plotRows - 1);
        });
        
        if (closestTick !== undefined) {
          yLabel = padStart(formatNumber(closestTick), yAxisWidth);
          isTick = true;
        }
      } else if (!showAxes) {
        yLabel = "";
      }

      const axisChar = showAxes ? colorize(isTick ? "├" : "│", theme.axis, noColor) : " ";
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      const rowChars = canvases.map((c) => c.toLines()[row] ?? "");
      let mergedData = "";
      
      if (series.length === 1) {
        mergedData = colorize(rowChars[0], theme.colors[0], noColor);
      } else {
        mergedData = mergeCanvasRows(rowChars, series.length, theme.colors, noColor);
      }
      
      // Inject faint horizontal gridlines behind the braille cleanly
      if (showAxes && isTick) {
        mergedData = injectGridline(mergedData, plotCols, theme.axis, noColor);
      }
      
      lines.push(rowStr + mergedData);
    }

    if (showAxes) {
      lines.push(
        " ".repeat(yAxisWidth) + colorize("└" + "─".repeat(plotCols), theme.axis, noColor)
      );

      if (opts.labels) {
        const labelStr = buildXLabels(opts.labels, plotCols);
        lines.push(" ".repeat(yAxisWidth + 1) + colorize(labelStr, theme.label, noColor));
      }
    }

    if (opts.legend !== false && series.length > 1) {
      lines.push("");
      lines.push(
        seriesLabels
          .map((sl, i) => colorize("─ " + sl, theme.colors[i % theme.colors.length], noColor))
          .join("  ")
      );
    }

    return lines;
  }

  function renderBlocks(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    for (let row = 0; row < plotRows; row++) {
      let isTick = false;
      let yLabel = " ".repeat(yAxisWidth);
      
      if (showAxes && yTicks) {
        const yVal = yMax - (row / (plotRows - 1)) * (yMax - yMin);
        const closestTick = tickLabels.find(t => {
          const rowNorm = 1 - (row / (plotRows - 1));
          const tNorm = (t - yMin) / (yMax - yMin);
          return Math.abs(rowNorm - tNorm) < 0.5 / (plotRows - 1);
        });
        
        if (closestTick !== undefined) {
          yLabel = padStart(formatNumber(closestTick), yAxisWidth);
          isTick = true;
        }
      }

      const axisChar = showAxes ? colorize(isTick ? "├" : "│", theme.axis, noColor) : " ";
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      for (let col = 0; col < plotCols; col++) {
        let ch = isTick && showAxes ? colorize("·", theme.axis, noColor) : " ";
        for (let si = series.length - 1; si >= 0; si--) {
          const s = series[si];
          const xIdx = Math.round((col / (plotCols - 1)) * (s.length - 1));
          const yNorm = (yMax === yMin) ? 0.5 : (s[xIdx] - yMin) / (yMax - yMin);
          const yRow = Math.round((1 - yNorm) * (plotRows - 1));
          if (row === yRow) {
            const color = theme.colors[si % theme.colors.length];
            ch = colorize("●", color, noColor);
            break;
          }
        }
        rowStr += ch;
      }
      lines.push(rowStr);
    }

    if (showAxes) {
      lines.push(
        " ".repeat(yAxisWidth) + colorize("└" + "─".repeat(plotCols), theme.axis, noColor)
      );
      if (opts.labels) {
        const labelStr = buildXLabels(opts.labels, plotCols);
        lines.push(" ".repeat(yAxisWidth + 1) + colorize(labelStr, theme.label, noColor));
      }
    }

    return lines;
  }

  function buildLines(): string[] {
    if (renderer === "braille") return renderBraille();
    return renderBlocks();
  }

  const output = buildLines().join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "line",
        data: opts.data,
        labels: opts.labels,
        title: opts.title,
        plain: stripAnsi(output),
      };
    },
  };
}

function injectGridline(rowStr: string, len: number, colorLabel: string, noColor: boolean): string {
  const out: string[] = [];
  let inEscape = false;
  let escapeSeq = "";
  let visualCount = 0;

  for (let i = 0; i < rowStr.length; i++) {
    const ch = rowStr[i];
    if (ch === "\x1b") {
      inEscape = true;
      escapeSeq = ch;
      continue;
    }
    if (inEscape) {
      escapeSeq += ch;
      if (ch === "m") {
        inEscape = false;
        out.push(escapeSeq);
      }
      continue;
    }
    
    // Only inject gridline if it's completely empty braille space, and use a dim, solid rule
    if (ch === "\u2800" || ch === " ") {
      out.push(colorize("┈", colorLabel, noColor));
    } else {
      out.push(ch);
    }
    visualCount++;
  }
  
  // Pad if the braille canvas didn't reach the edge
  while (visualCount < len) {
    out.push(colorize("┈", colorLabel, noColor));
    visualCount++;
  }
  
  return out.join("");
}

function mergeCanvasRows(
  rows: string[],
  _numSeries: number,
  colors: string[],
  noColor: boolean
): string {
  if (rows.length === 0) return "";
  const len = rows[0].length;
  let result = "";
  for (let i = 0; i < len; i++) {
    let found = false;
    for (let si = 0; si < rows.length; si++) {
      const ch = rows[si][i];
      if (ch && ch !== "\u2800") {
        result += colorize(ch, colors[si % colors.length], noColor);
        found = true;
        break;
      }
    }
    if (!found) result += rows[0][i] ?? " ";
  }
  return result;
}

function buildXLabels(labels: string[], totalWidth: number): string {
  const n = labels.length;
  if (n === 0) return "";
  const positions = labels.map((_, i) => Math.round((i / (n - 1)) * (totalWidth - 1)));
  let line = " ".repeat(totalWidth);
  const arr = line.split("");
  labels.forEach((label, i) => {
    const pos = positions[i];
    const truncated = label.slice(0, Math.max(1, Math.floor(totalWidth / n) - 1));
    for (let j = 0; j < truncated.length; j++) {
      if (pos + j < totalWidth) arr[pos + j] = truncated[j];
    }
  });
  return arr.join("");
}
