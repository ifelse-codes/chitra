import type { CandlestickOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padStart, padEnd, stripAnsi } from "../ansi.js";
import { minMax, formatNumber } from "../utils.js";

export function candlestick(opts: CandlestickOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const height = opts.height ?? 15;

  const data = opts.data;
  const allVals = data.flatMap((d) => [d.open, d.high, d.low, d.close]);
  const { min: dataMin, max: dataMax } = minMax(allVals);
  const yMin = opts.yMin ?? dataMin;
  const yMax = opts.yMax ?? dataMax;
  const yRange = yMax - yMin;

  // Pre-compute all y-axis tick labels so yAxisWidth accounts for decimal labels
  // (intermediate values like "162.55" can be wider than the min/max labels)
  const yLabelStepCalc = Math.max(1, Math.floor(height / 5));
  const allTickLabels: string[] = [];
  for (let row = 0; row < height; row++) {
    if (row % yLabelStepCalc === 0 || row === height - 1) {
      const yVal = yMax - (row / (height - 1)) * yRange;
      allTickLabels.push(formatNumber(yVal));
    }
  }
  const yAxisWidth = Math.max(...allTickLabels.map((l) => l.length)) + 1;
  const candleAreaWidth = width - yAxisWidth - 2;
  const candleWidth = Math.max(1, Math.floor(candleAreaWidth / data.length) - 1);
  const numCandles = data.length;

  function toRow(v: number): number {
    return Math.round(((yMax - v) / yRange) * (height - 1));
  }

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    for (let row = 0; row < height; row++) {
      const yVal = yMax - (row / (height - 1)) * yRange;
      const yLabel =
        row % yLabelStepCalc === 0 || row === height - 1
          ? padStart(formatNumber(yVal), yAxisWidth)
          : " ".repeat(yAxisWidth);

      const axisChar = colorize("│", theme.axis, noColor);
      let rowStr = colorize(yLabel, theme.label, noColor) + axisChar;

      data.forEach((candle) => {
        const isUp = candle.close >= candle.open;
        const bodyColor = isUp
          ? (theme.colors[2] ?? theme.colors[0])
          : (theme.colors[5] ?? theme.colors[0]);
        const wickColor = bodyColor;

        const highRow = toRow(candle.high);
        const lowRow = toRow(candle.low);
        const openRow = toRow(candle.open);
        const closeRow = toRow(candle.close);
        // Ensure body is at least 1 row tall even for doji candles
        const bodyTop = Math.min(openRow, closeRow);
        const bodyBot = Math.max(openRow, closeRow);

        // All characters rendered at midCol so wick and body are always aligned
        const midCol = Math.floor(candleWidth / 2);
        const segArr = " ".repeat(candleWidth).split("");

        if (row >= bodyTop && row <= bodyBot) {
          // Body: full block (bullish) or medium block (bearish)
          segArr[midCol] = isUp ? "█" : "▓";
          rowStr += colorize(segArr.join(""), bodyColor, noColor) + " ";
        } else if ((row >= highRow && row < bodyTop) || (row > bodyBot && row <= lowRow)) {
          // Wick above or below the body
          segArr[midCol] = "│";
          rowStr += colorize(segArr.join(""), wickColor, noColor) + " ";
        } else {
          rowStr += " ".repeat(candleWidth) + " ";
        }
      });

      lines.push(rowStr);
    }

    lines.push(
      " ".repeat(yAxisWidth) +
        colorize("└" + "─".repeat(numCandles * (candleWidth + 1)), theme.axis, noColor)
    );

    const labelLine =
      " ".repeat(yAxisWidth + 1) +
      data
        .map((d) => padEnd((d.label ?? "").slice(0, candleWidth), candleWidth + 1))
        .join("");
    lines.push(colorize(labelLine, theme.label, noColor));

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
        type: "candlestick",
        data: opts.data,
        plain: stripAnsi(output),
      };
    },
  };
}
