import type { SparklineOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";
import { sparklineBlocks } from "../renderers/blocks.js";
import { sparklineAscii } from "../renderers/ascii.js";
import { BrailleCanvas, plotLineOnBrailleCanvas } from "../renderers/braille.js";
import { minMax, formatNumber } from "../utils.js";

export function sparkline(opts: SparklineOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const renderer = opts.renderer ?? "blocks";
  const width = opts.width ?? opts.data.length;

  function buildOutput(): string {
    const { data } = opts;
    if (data.length === 0) return "";

    const { min, max } = minMax(data);

    let spark: string;
    if (renderer === "braille") {
      const canvas = new BrailleCanvas(Math.ceil(width / 2), 1);
      plotLineOnBrailleCanvas(canvas, data, min, max);
      spark = canvas.toLines()[0];
    } else if (renderer === "ascii") {
      spark = sparklineAscii(data, width);
    } else {
      spark = sparklineBlocks(data, width);
    }

    spark = colorize(spark, theme.colors[0], noColor);

    const parts: string[] = [];
    if (opts.label) {
      parts.push(colorize(opts.label + " ", theme.label, noColor));
    }
    parts.push(spark);
    if (opts.showValue) {
      const last = data[data.length - 1];
      parts.push(colorize(" " + formatNumber(last), theme.label, noColor));
    }

    return parts.join("");
  }

  const output = buildOutput();

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "`" + stripAnsi(output) + "`"; },
    toJSON() {
      return {
        type: "sparkline",
        data: opts.data,
        label: opts.label,
        plain: stripAnsi(output),
      };
    },
  };
}
