// Shared terminal "panel" primitives — dashed-border frame, rule, padded
// rows — modeled on the tui-chart.html reference design language. Any chart
// renderer (line, bar, area, ...) can compose these into a consistent
// terminal-native look that mirrors the SVG/web output.
import { colorize, visibleLength } from "../ansi.js";

export function frameTop(
  width: number,
  title: string,
  meta: string | undefined,
  frameColor: string,
  textColor: string,
  noColor: boolean
): string {
  const inner = width - 2;
  const left = title ? ` ${title} ` : "";
  const right = meta ? ` ${meta} ` : "";
  const dashCount = Math.max(1, inner - 2 - visibleLength(left) - visibleLength(right));
  return (
    colorize("┌─", frameColor, noColor) +
    colorize(left, textColor, noColor) +
    colorize("─".repeat(dashCount), frameColor, noColor) +
    colorize(right, textColor, noColor) +
    colorize("─┐", frameColor, noColor)
  );
}

export function frameBottom(width: number, frameColor: string, noColor: boolean): string {
  return colorize("└" + "─".repeat(width - 2) + "┘", frameColor, noColor);
}

export function frameRow(width: number, content: string, frameColor: string, noColor: boolean): string {
  const inner = width - 4;
  const len = visibleLength(content);
  const padded = len >= inner ? content : content + " ".repeat(inner - len);
  return colorize("│ ", frameColor, noColor) + padded + colorize(" │", frameColor, noColor);
}

export function frameRule(width: number, frameColor: string, noColor: boolean, dashChar = "╌"): string {
  const inner = width - 4;
  return colorize("│ " + dashChar.repeat(inner) + " │", frameColor, noColor);
}

export function padVisible(str: string, width: number): string {
  const len = visibleLength(str);
  return len >= width ? str : str + " ".repeat(width - len);
}
