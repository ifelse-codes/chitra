import type { ThemeName, Theme, RendererType, BaseChartOptions, ChartResult } from "./types.js";
import {
  bar,
  line,
  area,
  sparkline,
  histogram,
  scatter,
  pie,
  donut,
  heatmap,
  progress,
  gauge,
  horizontalBar,
  timeline,
  radar,
  boxplot,
  waterfall,
  funnel,
  candlestick,
  treemap,
  sankey,
} from "./charts/index.js";

type SingleOrMulti = number[] | number[][];

export class PlotBuilder {
  private _data: SingleOrMulti;
  private _title?: string;
  private _theme: ThemeName | Theme = "default";
  private _renderer: RendererType = "braille";
  private _width?: number;
  private _height?: number;
  private _labels?: string[];
  private _seriesLabels?: string[];
  private _noColor = false;
  private _showAxes = true;
  private _yMin?: number;
  private _yMax?: number;

  constructor(data: SingleOrMulti) {
    this._data = data;
  }

  title(t: string): this {
    this._title = t;
    return this;
  }

  theme(t: ThemeName | Theme): this {
    this._theme = t;
    return this;
  }

  renderer(r: RendererType): this {
    this._renderer = r;
    return this;
  }

  size(width: number, height: number): this {
    this._width = width;
    this._height = height;
    return this;
  }

  width(w: number): this {
    this._width = w;
    return this;
  }

  height(h: number): this {
    this._height = h;
    return this;
  }

  labels(l: string[]): this {
    this._labels = l;
    return this;
  }

  seriesLabels(l: string[]): this {
    this._seriesLabels = l;
    return this;
  }

  noColor(v = true): this {
    this._noColor = v;
    return this;
  }

  axes(show = true): this {
    this._showAxes = show;
    return this;
  }

  yRange(min: number, max: number): this {
    this._yMin = min;
    this._yMax = max;
    return this;
  }

  private get baseOpts(): BaseChartOptions {
    return {
      title: this._title,
      theme: this._theme,
      renderer: this._renderer,
      width: this._width,
      height: this._height,
      labels: this._labels,
      noColor: this._noColor,
      showAxes: this._showAxes,
    };
  }

  line(): ChartResult {
    return line({
      ...this.baseOpts,
      data: this._data,
      seriesLabels: this._seriesLabels,
      yMin: this._yMin,
      yMax: this._yMax,
    });
  }

  area(): ChartResult {
    return area({
      ...this.baseOpts,
      data: this._data,
      seriesLabels: this._seriesLabels,
      yMin: this._yMin,
      yMax: this._yMax,
    });
  }

  bar(): ChartResult {
    return bar({
      ...this.baseOpts,
      data: this._data,
      seriesLabels: this._seriesLabels,
      yMin: this._yMin,
      yMax: this._yMax,
    });
  }

  horizontalBar(): ChartResult {
    const flat = this._data.flat() as number[];
    return horizontalBar({
      ...this.baseOpts,
      data: flat,
      yMin: this._yMin,
      yMax: this._yMax,
    });
  }

  sparkline(): ChartResult {
    const flat = this._data.flat() as number[];
    return sparkline({
      data: flat,
      theme: this._theme,
      renderer: this._renderer,
      noColor: this._noColor,
      width: this._width,
    });
  }

  histogram(bins?: number): ChartResult {
    const flat = this._data.flat() as number[];
    return histogram({
      ...this.baseOpts,
      data: flat,
      bins,
      yMin: this._yMin,
      yMax: this._yMax,
    });
  }

  pie(): ChartResult {
    const flat = this._data.flat() as number[];
    return pie({
      ...this.baseOpts,
      data: flat,
      labels: this._labels,
    });
  }

  donut(): ChartResult {
    const flat = this._data.flat() as number[];
    return donut({
      ...this.baseOpts,
      data: flat,
      labels: this._labels,
    });
  }

  render(): void {
    this.line().render();
  }

  toString(): string {
    return this.line().toString();
  }
}

export function plot(data: SingleOrMulti): PlotBuilder {
  return new PlotBuilder(data);
}
