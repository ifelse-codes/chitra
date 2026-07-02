import type { TimelineOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, padEnd, padStart, stripAnsi } from "../ansi.js";
import { formatNumber } from "../utils.js";

export function timeline(opts: TimelineOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const width = opts.width ?? 60;
  const events = opts.events;

  const allStarts = events.map((e) => e.start);
  const allEnds = events.map((e) => e.end ?? e.start);
  const rangeMin = opts.min ?? Math.min(...allStarts);
  const rangeMax = opts.max ?? Math.max(...allEnds);
  const range = rangeMax - rangeMin;

  const labelWidth = Math.max(...events.map((e) => e.label.length)) + 1;
  const barWidth = width - labelWidth - 2;

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
      lines.push("");
    }

    events.forEach((event, i) => {
      const label = padEnd(event.label, labelWidth);
      const startPos = Math.round(((event.start - rangeMin) / range) * barWidth);
      const endPos = event.end
        ? Math.round(((event.end - rangeMin) / range) * barWidth)
        : startPos + 1;

      const barArr = new Array(barWidth).fill("─");
      for (let p = startPos; p < endPos && p < barWidth; p++) {
        barArr[p] = "█";
      }
      if (startPos < barWidth) barArr[startPos] = "▶";
      if (event.end && endPos - 1 < barWidth && endPos > startPos) {
        barArr[endPos - 1] = "◀";
      }

      const color = event.color
        ? colorize("", event.color, noColor).replace("\x1b[0m", "")
        : theme.colors[i % theme.colors.length];

      const barStr = barArr
        .map((ch, idx) => {
          if (idx >= startPos && idx < endPos) {
            return colorize(ch, color, noColor);
          }
          return colorize(ch, theme.axis, noColor);
        })
        .join("");

      lines.push(colorize(label, theme.label, noColor) + " " + barStr);
    });

    lines.push("");
    const xMin = padStart(formatNumber(rangeMin), 0);
    const xMax = formatNumber(rangeMax);
    const xMid = formatNumber((rangeMin + rangeMax) / 2);
    const midPos = Math.floor(barWidth / 2) - Math.floor(xMid.length / 2);
    let axisLabels = " ".repeat(labelWidth + 1) + xMin;
    axisLabels +=
      " ".repeat(Math.max(0, midPos - xMin.length)) +
      xMid +
      " ".repeat(Math.max(0, barWidth - midPos - xMid.length - xMax.length)) +
      xMax;
    lines.push(colorize(axisLabels, theme.label, noColor));

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
        type: "timeline",
        events: opts.events,
        min: rangeMin,
        max: rangeMax,
        plain: stripAnsi(output),
      };
    },
  };
}
