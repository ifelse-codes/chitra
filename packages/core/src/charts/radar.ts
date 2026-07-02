import type { RadarChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";

export function radar(opts: RadarChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;
  const size = Math.min(opts.width ?? 40, opts.height ?? 20);
  const radius = Math.floor(size / 2) - 2;
  const cx = Math.floor(size / 2);
  const cy = Math.floor((opts.height ?? size) / 2);

  const rawData = opts.data;
  const isMulti = Array.isArray(rawData[0]);
  const series: number[][] = isMulti
    ? (rawData as number[][])
    : [rawData as number[]];

  const axisLabels = opts.labels;
  const numAxes = axisLabels.length;
  const yMax = opts.yMax ?? Math.max(...series.flat());
  const seriesLabels = opts.seriesLabels ?? series.map((_, i) => `Series ${i + 1}`);

  const cols = size * 2;
  const rows = opts.height ?? size;

  function buildLines(): string[] {
    const lines: string[] = [];

    if (opts.title) {
      lines.push(colorize(opts.title, theme.title, noColor));
    }

    const grid: string[][] = Array.from({ length: rows }, () =>
      Array(cols).fill(" ")
    );

    const axisAngles = Array.from({ length: numAxes }, (_, i) =>
      (i * 2 * Math.PI) / numAxes - Math.PI / 2
    );

    for (let r = 1; r <= 3; r++) {
      const rr = (r / 3) * radius;
      const steps = Math.floor(2 * Math.PI * rr * 4);
      for (let s = 0; s < steps; s++) {
        const angle = (s / steps) * 2 * Math.PI;
        const x = Math.round(cx + rr * Math.cos(angle) * 2);
        const y = Math.round(cy + rr * Math.sin(angle));
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          if (grid[y][x] === " ") {
            grid[y][x] = colorize("·", theme.grid ?? theme.axis, noColor);
          }
        }
      }
    }

    axisAngles.forEach((angle, i) => {
      const ex = Math.round(cx + radius * Math.cos(angle) * 2);
      const ey = Math.round(cy + radius * Math.sin(angle));
      drawLine(grid, cx, cy, ex, ey, colorize("·", theme.axis, noColor), cols, rows);

      const lx = Math.round(cx + (radius + 2) * Math.cos(angle) * 2);
      const ly = Math.round(cy + (radius + 2) * Math.sin(angle));
      const label = axisLabels[i] ?? "";
      for (let j = 0; j < label.length; j++) {
        const lxj = lx + j - Math.floor(label.length / 2);
        if (lxj >= 0 && lxj < cols && ly >= 0 && ly < rows) {
          grid[ly][lxj] = colorize(label[j], theme.label, noColor);
        }
      }
    });

    series.forEach((s, si) => {
      const color = theme.colors[si % theme.colors.length];
      const points = s.map((v, i) => {
        const angle = axisAngles[i];
        const r = (yMax === 0 ? 0 : v / yMax) * radius;
        return {
          x: Math.round(cx + r * Math.cos(angle) * 2),
          y: Math.round(cy + r * Math.sin(angle)),
        };
      });

      for (let p = 0; p < points.length; p++) {
        const curr = points[p];
        const next = points[(p + 1) % points.length];
        drawLine(grid, curr.x, curr.y, next.x, next.y, colorize("*", color, noColor), cols, rows);
      }

      points.forEach((pt) => {
        if (pt.x >= 0 && pt.x < cols && pt.y >= 0 && pt.y < rows) {
          grid[pt.y][pt.x] = colorize("●", color, noColor);
        }
      });
    });

    for (const row of grid) {
      lines.push(row.join(""));
    }

    if (series.length > 1) {
      lines.push("");
      lines.push(
        seriesLabels
          .map((sl, i) => colorize("● " + sl, theme.colors[i % theme.colors.length], noColor))
          .join("  ")
      );
    }

    return lines;
  }

  function drawLine(
    grid: string[][],
    x0: number,
    y0: number,
    x1: number,
    y1: number,
    ch: string,
    maxCols: number,
    maxRows: number
  ): void {
    const dx = Math.abs(x1 - x0);
    const dy = Math.abs(y1 - y0);
    const sx = x0 < x1 ? 1 : -1;
    const sy = y0 < y1 ? 1 : -1;
    let err = dx - dy;
    let cx2 = x0;
    let cy2 = y0;
    while (true) {
      if (cx2 >= 0 && cx2 < maxCols && cy2 >= 0 && cy2 < maxRows) {
        if (grid[cy2][cx2] === " ") grid[cy2][cx2] = ch;
      }
      if (cx2 === x1 && cy2 === y1) break;
      const e2 = 2 * err;
      if (e2 > -dy) { err -= dy; cx2 += sx; }
      if (e2 < dx) { err += dx; cy2 += sy; }
    }
  }

  const output = buildLines().join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "radar",
        data: opts.data,
        labels: opts.labels,
        plain: stripAnsi(output),
      };
    },
  };
}
