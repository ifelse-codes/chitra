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

      // Use a faint dot "·" for gridlines if this is a tick row, otherwise standard braille empty "\u2800"
      const emptyChar = isTick ? colorize("·", theme.axis, noColor) : "\u2800";
      
      const rowChars = canvases.map((c) => c.toLines(emptyChar)[row] ?? "");
      let mergedData = "";
      
      if (series.length === 1) {
        mergedData = mergeCanvasRows([rowChars[0]], 1, theme.colors, noColor, emptyChar);
      } else {
        mergedData = mergeCanvasRows(rowChars, series.length, theme.colors, noColor, emptyChar);
      }
      
      lines.push(rowStr + mergedData);
    }

    if (showAxes) {
      lines.push(
        " ".repeat(yAxisWidth) + colorize("└" + "─".repeat(plotCols), theme.axis, noColor)
      );

      if (opts.labels) {
        const n = opts.labels.length;
        if (n > 0) {
            const positions = opts.labels.map((_, i) => Math.round((i / (n - 1)) * (plotCols - 1)));
            let tickRow = " ".repeat(plotCols).split("");
            positions.forEach(p => { if (p < plotCols) tickRow[p] = "┼"; });
            if (tickRow[0] === "┼") tickRow[0] = "┬";
            
            lines.pop();
            lines.push(" ".repeat(yAxisWidth) + colorize("└" + tickRow.join("").replace(/ /g, "─"), theme.axis, noColor));
            
            const labelStr = buildXLabels(opts.labels, plotCols, positions);
            lines.push(" ".repeat(yAxisWidth + 1) + colorize(labelStr, theme.label, noColor));
        }
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

    const gridLines = Array.from({ length: plotRows }, () =>
      Array<string>(plotCols).fill(" ")
    );

    series.forEach((s, si) => {
      const color = theme.colors[si % theme.colors.length];
      for (let col = 0; col < plotCols; col++) {
        // Find left and right data bounds for this column to interpolate
        const exactX = (col / (plotCols - 1)) * (s.length - 1);
        const idxL = Math.floor(exactX);
        const idxR = Math.ceil(exactX);
        const frac = exactX - idxL;
        
        const valL = s[idxL];
        const valR = s[idxR] ?? valL;
        const val = valL + frac * (valR - valL);

        const yNorm = yMax === yMin ? 0.5 : (val - yMin) / (yMax - yMin);
        const yRow = Math.round((1 - yNorm) * (plotRows - 1));
        
        let ch = renderer === "ascii" ? "o" : "●";
        
        // Very basic slope check to choose character
        if (col > 0 && renderer === "ascii") {
            const prevExactX = ((col - 1) / (plotCols - 1)) * (s.length - 1);
            const prevVal = s[Math.floor(prevExactX)];
            if (val > prevVal) ch = "/";
            else if (val < prevVal) ch = "\\";
            else ch = "-";
        }

        if (yRow >= 0 && yRow < plotRows) {
          gridLines[yRow][col] = colorize(ch, color, noColor);
        }
      }
    });

    for (let row = 0; row < plotRows; row++) {
      let isTick = false;
      let yLabel = " ".repeat(yAxisWidth);
      
      if (showAxes && yTicks) {
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
        let ch = gridLines[row][col];
        if (ch === " " && isTick && showAxes) {
          ch = colorize("·", theme.axis, noColor);
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
        const n = opts.labels.length;
        if (n > 0) {
            const positions = opts.labels.map((_, i) => Math.round((i / (n - 1)) * (plotCols - 1)));
            let tickRow = " ".repeat(plotCols).split("");
            positions.forEach(p => { if (p < plotCols) tickRow[p] = "┼"; });
            if (tickRow[0] === "┼") tickRow[0] = "┬";
            
            lines.pop();
            lines.push(" ".repeat(yAxisWidth) + colorize("└" + tickRow.join("").replace(/ /g, "─"), theme.axis, noColor));
            
            const labelStr = buildXLabels(opts.labels, plotCols, positions);
            lines.push(" ".repeat(yAxisWidth + 1) + colorize(labelStr, theme.label, noColor));
        }
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
  return rowStr;
}

function mergeCanvasRows(
  rows: string[],
  _numSeries: number,
  colors: string[],
  noColor: boolean,
  emptyChar: string = "\u2800"
): string {
  if (rows.length === 0) return "";
  const len = stripAnsi(rows[0]).length; 
  
  const visualRows = rows.map(extractVisualChars);
  let result = "";
  
  for (let i = 0; i < len; i++) {
    let found = false;
    for (let si = 0; si < visualRows.length; si++) {
      const ch = visualRows[si][i];
      if (ch && ch !== stripAnsi(emptyChar) && ch !== "\u2800" && ch !== " ") {
        result += colorize(ch, colors[si % colors.length], noColor);
        found = true;
        break;
      }
    }
    if (!found) {
      result += emptyChar;
    }
  }
  return result;
}

function extractVisualChars(row: string): string[] {
  const chars: string[] = [];
  let inEscape = false;
  for (let i = 0; i < row.length; i++) {
    const ch = row[i];
    if (ch === "\x1b") { inEscape = true; continue; }
    if (inEscape) { if (ch === "m") inEscape = false; continue; }
    chars.push(ch);
  }
  return chars;
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
