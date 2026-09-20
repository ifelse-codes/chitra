# @chitra/core

A production-grade TypeScript terminal charting library. Beautiful visualizations for terminals, agents, and modern developer workflows.

## Features

- **20 Chart Types:** Line, bar, area, sparkline, histogram, scatter, pie, donut, heatmap, progress, gauge, timeline, radar, boxplot, waterfall, funnel, candlestick, treemap, sankey, horizontal bar.
- **AI-Agent Native:** Exposes `toPlain()` and `toJSON()` so LLMs and MCP tools get clean data without ANSI escape code noise.
- **Zero Dependencies:** All ANSI colors, braille math, and layout logic are self-contained.
- **TypeScript First:** Complete type definitions.
- **Three Renderers:** Braille (for high-resolution curves), Blocks (for robust terminal support), and ASCII (for SSH/fallback environments).
- **Fluent API:** Shared configuration using a chainable `plot(data)` builder.

## Installation

```bash
npm install @chitra/core
# or
pnpm add @chitra/core
# or
yarn add @chitra/core
```

## Quickstart

```typescript
import { bar, line, sparkline, plot } from "@chitra/core";

// 1. Simple Bar Chart
bar({
  data: [42, 67, 38, 55, 72],
  labels: ["Jan", "Feb", "Mar", "Apr", "May"],
  title: "Monthly Deployments",
  theme: "tokyo-night"
}).render(); // prints to stdout

// 2. Line Chart (braille renderer by default — smooth continuous curves)
line({
  data: [10, 20, 15, 35, 28, 45, 38, 52],
  title: "Revenue"
}).render();

// 3. Fluent API Builder
plot([42, 67, 38, 55, 72])
  .labels(["Jan", "Feb", "Mar", "Apr", "May"])
  .title("Deploys")
  .theme("dracula")
  .bar()
  .render();
```

## AI Agent Integration

When writing MCP (Model Context Protocol) tools or building AI agents, you don't want to feed the LLM a string full of `\x1b[31m` ANSI escape codes.

Every chart returns a `ChartResult` object with safe export methods:

```typescript
import { bar } from "@chitra/core";

const chart = bar({
  data: [42, 67, 38],
  labels: ["Q1", "Q2", "Q3"],
  title: "Quarterly Revenue",
  noColor: true // strips formatting
});

// For LLM context (clean text):
const plainText = chart.toPlain();

// For structured data extraction:
const json = chart.toJSON(); 
// { type: "bar", title: "Quarterly Revenue", data: [42, 67, 38], plain: "..." }
```

## Renderers

Chitra supports three rendering modes:
- **`block` (default for line):** A glyph-only chain — each series is drawn as its own `* ○ +` marker
  at every 2nd data point (exactly like the reference), with no `●` filler. Clean and airy: crossing
  curves stay traceable by shape, and the plot keeps generous whitespace. Best for multi-series line charts.
- **`braille`:** Uses Unicode Braille patterns (⠀–⣿) to achieve 4× resolution over standard characters. Best for area, scatter, and high-resolution single-series line plots.
- **`blocks` (default for discrete data):** Uses Unicode Block elements (▁▂▃▄▅▆▇█). Best for bar, progress, and histograms.
- **`ascii`:** Pure ASCII characters. Best for restrictive environments, legacy SSH sessions, or basic log files.

## Themes

Chitra includes 7 built-in themes that automatically map series data to colors:
`"default"`, `"nord"`, `"dracula"`, `"github-dark"`, `"tokyo-night"`, `"solarized"`, and `"monochrome"`.

## Design Style

Chitra's look is built on the `design-reference/` language — tui-chart (terminal-native),
mudra-chart (one-hue refinement), and mudra-dashboard (terminal translation). The target
look for terminal output:

- **Dashed panel frame**, mono-first typography, sharp corners. Floating `panel-tag`
  labels (`- SUMMARY -`) sit on the frame line.
- **Series identity = tone + dash + glyph**, never rainbow color alone. Each series is
  separated by a tone from the theme's ramp, a dash pattern (solid / dashed / dotted /
  dash-dot), and a glyph marker (`* o + x`).
- **One accent hue per theme**, reserved for the primary or active series; other series
  stay muted so the accent lands where the eye is pointing.
- **Thin dashed gridlines** with a solid baseline axis, and `+` tick marks on both axes.
- **Eyebrow captions** — uppercase, letter-spaced, mono — label the x/y axes.
- **Metric summary cells** — LAST value prominent, MIN / MAX / AVG beneath, per series.
- **SVG output mirrors the terminal model**: the web renderer draws the same tones,
  dashes, glyphs, grid, and captions as the terminal renderer, from the same model.

### LOCKED: circular charts (pie / donut) — session 09 design

The pie and donut look is **the locked reference for every future circular chart**. Rules
that must not change:

- **The circle is drawn as braille sub-pixels** (2 dots wide × 4 dots tall per cell) at
  dot-space resolution, so the curve reads as a genuinely round circle — matching the
  reference HTML's stroked SVG circles. **No** fill patterns (`█▓▒░▚▞`), **no** density
  stripes, **no** radial seams, **no** in-wedge labels. Clean solid disc, round rim.
- **Slice separation is tone ramp + one accent**, never per-slice fill patterns: the
  largest slice gets the theme's single accent hue, the rest get the grey tone ramp
  (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`). In color output the slices read apart;
  in plain mode the legend is the separator.
- **Edge quality**: each braille dot is supersampled at 2×2 sub-points and lit only when
  the majority fall inside the ring — keeps the rim smooth and vertically symmetric.
- **Right-aligned legend** beside the ring: solid swatch + label, value and percent
  right-aligned. Ring on the left, legend vertically centred.
- **Panel**: dashed frame (`┌╌…╌┐`), eyebrow row (uppercase, letter-spaced) under the
  top rule, optional status row before the bottom rule. Donut centre shows the total.
- **Braille rendering requires a glyph-complete mono font** (Cascadia Mono, Fira Code,
  Menlo). Web/editor output must load one or the circle columns misalign.

### LOCKED: area chart — session 09 design

The area chart follows the same locked language. Rules that must not change:

- **The line IS the fill's top edge.** No separate stroke pass: every column of the plot
  is filled down to the baseline with interpolated sub-pixel braille, and the top dot of
  each column is the line. This gives one clean continuous curve with no gap or jitter
  between the stroke and the fill.
- **Auto-scale the y-range to the data** (`yMin`/`yMax` default to the data min/max, not
  0) so the area fills the panel height — no dead space hugging the bottom.
- **Empty cells are spaces, never blank-braille (`⠀` U+2800).** Blank braille renders as
  faint dots in browsers; plain spaces keep the panel clean.
- **One accent, used only for what's relevant.** The peak (series max) gets a small 3-dot
  accent cap on the line; the rest of the line is the tone ramp (`#A4A4AE`), the fill is
  a lighter tone (`#C6C6CE`), and the footer's `max N` value is accent too. The whole
  curve must never be painted accent.
- **Same panel language**: dashed frame, eyebrow row, y-axis labels with `│` guide on the
  left, footer `series · max · min · last`.

### LOCKED: line chart — session 10 design

The line chart carries the same locked language as the area chart. Rules that must not change:

- **Default renderer is `braille`: smooth continuous curves**, the faithful terminal analog of
  the reference's SVG polylines — every series is a high-resolution braille line resampled
  through a Catmull-Rom spline (one point per dot-column, so the curve bends smoothly instead
  of jointing between raw points) with its glyph marker (`* ○ + × □`, every 2nd data point)
  dropped on top. `renderer: "block"` (a glyph-only marker chain, no `●` filler — airy and
  traceable) and `renderer: "ascii"` (`- / \` connectors) remain plain-terminal fallbacks.
  Spline smoothing can be turned off with `smooth: false`.
- **One hue + tone ramp, like the LOCKED pie/donut/area charts.** A lone line keeps the grey
  body with the accent spent once on its peak (series max). With several series the primary
  becomes the accent hero and every extra series recedes onto the shared grey tone ramp —
  series identity comes from the glyph markers (`* ○ + × □`), never from separate bright hues.
- **In monochrome the marker density is texture-coded** so crossing chains stay separable:
  the primary (`*`) is DENSEST, the first extra series sparser, and later series sparsest.
  The legend shows each series' texture + marker identity (`──*── Up  ╌╌○╌╌ Down  ··+·· Base`),
  with solid `──` dashes for every series in colour mode.
- **The dotted `·` grid backdrop is off by default** — the y labels and `│` guide already carry
  the scale, so the plot reads clean. Opt back in with `grid: true` (dotted guide every 2nd
  column on the y-step rows, dim so series cells and markers always outrank it).
- **`+` axis ticks, like the reference**: a `+` x-tick row sits between the plot and the X
  labels (axis colour, aligned to the label slots), and the y-guide starts with a `+` at the
  top of the axis.
- **Auto-scale the y-range to the data** (`yMin`/`yMax` default to the data min/max) so the
  line fills the panel height — no dead space hugging the bottom. The shared `LineChartModel`
  feeds the same range to the SVG web renderer.
- **Empty cells are spaces** — the block plot never paints phantom fill or blank glyphs.
- **One accent, spent once**: the primary's peak (series max) gets a 3-dot accent cap; the rest
  of the curve stays on its tone ramp, and the primary's `max N` in the summary is accent too.
- **Per-series summary rows** under the chart: `* Up · min N · max N · avg N · last N` for every
  series (MIN / MAX / AVG / LAST), each right-anchored with a compact spark bar (`▁▂▃▄▅▆▇█`)
  echoing the reference's sparkline panel.
- **Same panel language**: dashed frame (`┌╌…╌┐`), eyebrow row, `│` y-guide on the left,
  series legend (`──*── name`), `+` X-axis ticks with clean labels.

### LOCKED: bar chart — session 12 design

The bar chart now carries the same locked design language as the circular, area, and line
chart families. Rules that must not change:

- **One accent hue, spent once on the peak bar.** The single bar with the globally highest
  value gets the theme's accent hue; every other bar uses the grey tone ramp
  (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`). No raw `theme.colors[s % n]` rainbow
  assignment. Series identity in multi-series charts comes from position and the summary
  legend, not from separate bright hues — exactly like the circular and line locked charts.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), eyebrow row
  (uppercase, letter-spaced), `│` y-guide with a `+` at the topmost row (matching the
  `+` axis-tick language from the locked line chart), and two `│ ╌…╌ │` rule separators
  (one below the eyebrow/legend, one above the summary).
- **`+` x-axis ticks**: a dedicated tick row between the bar plot and the x-labels, with
  a `+` mark centred under each bar group — directly mirroring the locked line chart's
  x-tick row.
- **Per-series summary rows** (MIN / MAX / AVG / LAST) under the chart, echoing the
  line/area summary panel. The series that holds the global peak bar has its `max N`
  value rendered in the accent colour.
- **Auto-scale y-range**: `yMin` defaults to `min(0, dataMin)` so the baseline is always
  at or below zero, and `yMax` defaults to the data maximum. Override with `yMin`/`yMax`.
- **Empty cells are spaces** — the bar plot never writes phantom fill characters.
- **Panel width auto-expands** to fit the widest summary row so the footer is never
  clipped by the frame.

### LOCKED: scatter chart — session 17 design

The scatter plot now carries the same locked design language as the circular, area, line,
and bar chart families. Rules that must not change:

- **One accent hue, and what it lands on depends on how many series there are.** No raw
  `theme.colors[i % n]` rainbow assignment, ever; everything not accented uses the grey tone
  ramp (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`).
  - **Single series → one point.** The point with the highest `y` gets the accent, spent once.
    On the braille renderer it is applied to the point's own 2×4 CELL, so it survives even when
    other points share that cell. Ties resolve to the first such point in data order
    (deterministic). An explicit `highlight` index overrides which point spends the accent.
  - **Multiple series → the whole primary GROUP.** With more than one series, spending the
    accent on a single dot is meaningless, so **series 0 as a whole becomes the accent hero** —
    every one of its points is drawn in the accent hue, on top (it wins a shared cell / is
    painted last), while the other groups recede onto the grey ramp. This mirrors the locked
    line chart's "primary series is the hero" rule. A future interactive renderer may re-accent
    a different group on hover.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), eyebrow row
  (uppercase, letter-spaced — `CORRELATION` by default, overridable via `eyebrow`), `│`
  y-guide with a `+` at the topmost row (matching the locked line/bar y-tick language), and
  two `│ ╌…╌ │` rule separators (one below the eyebrow/legend, one above the summary).
- **Summary footer** reporting `n <count> · x <min>..<max> · y <min>..<max>`, followed by the
  accented tail: for a single series the peak point `peak (<x>, <y>)`; for multiple series the
  name of the highlighted primary group (`● <label>`). No Pearson r by default — a correlation
  coefficient is dishonest for non-linear, multi-series, or zero-variance clouds, so the footer
  reports only facts true for arbitrary point data.
- **Multi-series identity** comes from glyph shape (`● ○ ◆ ◇ ▲ △`) and position, plus the
  legend — never from separate bright hues. The primary group is the accent hero; the extras
  recede onto the shared grey ramp, exactly like the locked line chart.
- **Empty / degenerate data is safe**: empty data renders a framed panel with an `n 0` footer
  and no `Infinity`/`NaN`; a single point or an all-equal-y cloud renders honestly with a
  collapsed `min..max` range.

### LOCKED: heatmap chart — session 18 design

The heatmap now carries the same locked design language as the circular, area, line, bar,
and scatter chart families. Rules that must not change:

- **Intensity IS the grey tone ramp.** Cell magnitude is encoded on the documented grey tone
  ramp (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, light → dark by magnitude), with a matching
  plain-text shade glyph (`░ ▒ ▓ █`) so the ordering survives `stripAnsi` / `noColor`. The old
  10-colour blue→orange→red rainbow (`HEAT_COLORS_DARK`) is gone — no `theme.colors[i % n]`
  rainbow, ever.
- **One accent hue, spent EXACTLY once, on the peak cell.** The single maximum-value cell gets
  the theme's accent hue; ties resolve to the first such cell in row-major order (deterministic).
  Everything else stays on the grey ramp. The accent marks the peak — it is not a second scale.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an uppercase
  letter-spaced eyebrow row (`DENSITY`), a `│` y-guide with a `+` at the topmost grid row
  (matching the locked scatter/line/bar y-tick language), and two `│ ╌…╌ │` rule separators
  (one below the eyebrow, one above the summary).
- **Summary footer** reporting `<rows>×<cols> · <min>..<max>`, followed by the accented tail
  `peak (<r>, <c>)` — the peak coordinates in the accent hue. Facts true for arbitrary matrix
  data, never a fabricated statistic.
- **Empty / degenerate data is safe**: an empty grid renders a framed panel with an `n 0` footer
  and no `Infinity`/`NaN`; an all-equal grid renders honestly with a collapsed `min..max` range
  and the accent still spent exactly once (on the first cell).

### LOCKED: horizontalBar chart — session 19 design

`horizontalBar` now carries the same locked design language as the circular, area, line, bar,
scatter, and heatmap families — the S12 `bar` language rotated to the horizontal orientation.
This closes the reference-language migration for the core chart set. Rules that must not change:

- **One accent hue, spent once on the peak bar.** The single bar with the globally highest
  value gets the theme's accent hue; every other bar uses the grey tone ramp
  (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`). No raw `theme.colors[i % n]` rainbow assignment,
  ever. Verified at raw-RGB level (accent count == 1). Ties resolve to the **first** maximum in
  data order (deterministic).
- **Same panel language as all locked charts, rotated to horizontal**: dashed frame (`┌╌…╌┐`),
  an uppercase letter-spaced eyebrow row (`VALUES` by default, or the uppercased `xLabel`), a
  rotated value-axis guide carrying the `+` tick vocabulary (`+╌…╌+` under the bars, `+` at the
  baseline and max columns) with a `min .. max` scale row, and two `│ ╌…╌ │` rule separators
  (one below the eyebrow, one above the summary).
- **Empty cells are spaces** — the plot never writes the `░` phantom filler (both the blocks
  and ascii renderers pass an explicit space empty-char).
- **Per-item value labels**, each rendered to the right of its bar; the peak item's value is
  rendered in the accent hue (mirroring bar's accented summary), and the summary footer names
  the peak item (`n <count> · min · max · avg · peak <label>`, with `max` in the accent hue).
- **Auto-scale value axis**: `yMin` defaults to `min(0, dataMin)` so the baseline is always at
  or below zero, and `yMax` defaults to the data maximum. Override with `yMin`/`yMax`.
- **Panel width auto-expands** to fit the longest label + bar + value and the eyebrow, so no
  label or value is ever clipped by the frame.
- **Empty / degenerate data is safe**: empty data renders a framed panel with an `n 0` footer
  and no `NaN`; all-equal and single-item inputs render honestly with the accent spent exactly
  once (on the first maximum). Public API (`toPlain()` / `toJSON()` type `"horizontalBar"`) is
  unchanged, zero runtime deps.

### LOCKED: treemap chart — session 20 design

`treemap` now carries the same locked design language as the circular, area, line, bar,
scatter, and heatmap families — the S18 panel language applied to a hierarchical area chart.
Rules that must not change:

- **Intensity IS the grey tone ramp.** Each node's magnitude is encoded on the documented grey
  tone ramp (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, light → dark by magnitude), with a
  matching plain-text shade glyph (`░ ▒ ▓ █`) so the ordering survives `stripAnsi` / `noColor`.
  The old `theme.colors[i % n]` rainbow assignment is gone — never a raw rainbow hue, ever.
- **One accent hue, spent EXACTLY once, on the peak node.** The single maximum-value node gets
  the theme's accent hue; ties resolve to the first such node in flatten/data order
  (deterministic). Everything else stays on the grey ramp. The accent marks the peak — it is
  not a second scale.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an uppercase
  letter-spaced eyebrow row (`AREA`), a `│` y-guide with a `+` at the topmost plot row
  (matching the locked scatter/line/bar y-tick language), and two `│ ╌…╌ │` rule separators
  (one below the eyebrow, one above the summary).
- **Summary footer** reporting `<n> · <min>..<max>`, followed by the accented tail
  `peak <label>` — the peak node's label in the accent hue. Facts true for arbitrary
  hierarchical data, never a fabricated statistic.
- **Hierarchy flattens honestly**: a node with `children` contributes its leaves to the layout
  (no parent node is drawn); the peak is the max leaf, first in flatten order on ties.
- **Slivers stay clean blocks**: a region stamps its label + value only when the whole text
  fits inside it — narrow slivers keep their ramp shade with no truncated `…` noise.
- **Empty / degenerate data is safe**: an empty input renders a framed panel with an `n 0`
  footer and no `Infinity`/`NaN`; an all-equal or single-node set renders honestly with a
  collapsed `min..max` range and the accent still spent exactly once.

### LOCKED: timeline chart — session 21 design

`timeline` now carries the same locked design language as the circular, area, line, bar,
scatter, heatmap, horizontalBar, and treemap families — the S18/S19 panel language applied
to the Gantt/timeline. Rules that must not change:

- **One accent hue, spent EXACTLY once, on the longest-span event.** The event whose span
  (`end − start`) is the largest gets the theme's accent hue as a solid `█` run; ties resolve
  to the first such event in event order (deterministic, the same strict-`>` rule as
  bar/heatmap/treemap). Every other event is one tone from the documented grey ramp
  (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, light → dark by span length). The old
  `theme.colors[i % n]` rainbow is gone — never a raw rainbow hue, ever. An explicit
  `event.color` stays a user override, not a theme rainbow.
- **Intensity IS the shade ramp** — the heatmap texture language. Each bar's shade glyph
  (`░ ▒ ▓ █`, one per tone bucket, light → dark by span length) carries the ordering through
  `stripAnsi` / `noColor`, so a plain-text render still reads longest-to-shortest at a
  glance. The peak leaves the ramp for its solid accent block, exactly like the LOCKED
  heatmap's peak cell.
- **The `─` track IS the shared time scale** (axis colour), kept behind every event so spans
  read against the full range — the v2 rule: keep the visible scale when exact reading
  matters. It is scale furniture, not bar fill; it must never be mistaken for data.
- **Point events render one lightest-shade glyph.** An event with no `end` (or an `end`
  before its `start`) is honestly zero-length: exactly one `░` — the lightest ramp step.
  The old `▶`/`◀` markers are retired glyphs, outside the locked vocabulary.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an uppercase eyebrow
  row (`SPAN`), a `+╌…╌+` value-axis guide with a `min..max` scale row under the events
  (matching the locked horizontalBar axis), and two `│ ╌…╌ │` rule separators.
- **Summary footer** reporting `n · <min>..<max>`, followed by the accented tail
  `span <label>` — the longest event's label in the accent hue. Facts true for arbitrary
  event data, never a fabricated statistic.
- **Empty / degenerate data is safe**: an empty input renders a framed panel with an
  `n 0 · (no data)` footer and no `Infinity`/`NaN`; a collapsed range (every event at one
  instant) renders honestly with the accent still spent exactly once.

### LOCKED: gauge chart — session 22 design

`gauge` now carries the same locked design language as the area, line, bar, scatter,
heatmap, horizontalBar, treemap, and timeline families — the S18–S21 panel language
applied to the single-value gauge, completing the founder-named trio (`timeline` →
`gauge` → `progress`). Rules that must not change:

- **Intensity IS the grey tone ramp.** The fill is encoded on the documented grey tone
  ramp (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, light → dark by level), with the
  matching plain-text shade glyph (`░ ▒ ▓ █`, one per tone bucket) so the level survives
  `stripAnsi` / `noColor` — the heatmap/timeline texture language. The old
  `theme.colors[1/3/2]` value-band rainbow is gone — no `theme.colors[i % n]` band
  rainbow, ever.
- **One accent hue, spent EXACTLY once, on the reading's leading edge.** The theme's
  accent hue is carried by a single solid `█` at the end of the fill run — the
  single-value analog of the locked peak element; it marks exactly where the reading
  stops. Everything else stays on the grey ramp. Explicit `thresholds` stay a user
  override: the matched threshold colour replaces the ramp tone on the whole fill (glyph
  texture unchanged) and the accent edge yields to it.
- **The `─` track IS the shared value scale** (axis colour), kept behind the fill so
  the reading reads against the full range. The `┤` / `├` endcaps are retired glyphs,
  outside the locked vocabulary.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an uppercase
  eyebrow row (`LEVEL`, or the uppercased `opts.label`), a `+╌…╌+` value-axis guide with
  a `min..max` scale row under the bar, and two `│ ╌…╌ │` rule separators. Panel width
  auto-expands so the eyebrow and summary are never clipped (an explicit `width` is a
  floor, not a cap).
- **Summary footer** reporting `value <v> · <min>..<max> · <pct>%`, with the `value <v>`
  fact in the accent hue. Facts true for arbitrary input, never fabricated.
- **Out-of-range and degenerate data are safe**: a `value` past `max` clips the fill at
  full track width while the footer reports the TRUE value and percent (may exceed 100%
  or sit below 0%) — never a negative-`repeat` `RangeError`; a reading below `min`
  renders an empty track, honestly reported; a collapsed range (`max === min`) never
  divides by zero (full when `value ≥ max`, empty otherwise); a non-finite `value`
  renders a framed `value n/a` panel — no `NaN`/`Infinity` anywhere.
- **Agent surface is additive**: `toJSON()` returns `type: "gauge"`, `value`, `min`,
  `max`, `percent` (null when n/a), `bucket` (the 0–3 shade index, null when n/a), and
  `plain`. No existing key is removed; the public `GaugeOptions` shape is unchanged.

### LOCKED: progress chart — session 23 design

`progress` now carries the same locked design language as the area, line, bar, scatter,
heatmap, horizontalBar, treemap, timeline, and gauge families — the S18–S22 panel
language applied to the single-value progress bar, completing the founder-named trio
(`timeline` → `gauge` → `progress`). Rules that must not change:

- **Intensity IS the grey tone ramp.** The fill is encoded on the documented grey tone
  ramp (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, light → dark by level), with the
  matching plain-text shade glyph (`░ ▒ ▓ █`, one per tone bucket) so the level survives
  `stripAnsi` / `noColor` — the heatmap/gauge texture language. The old
  `theme.colors[2/3/1]` traffic-light band rainbow is gone — no `theme.colors[i % n]`
  band rainbow, ever.
- **One accent hue, spent EXACTLY once, on the fill's leading edge.** The theme's
  accent hue is carried by a single solid `█` at the end of the fill run — the same
  reading-edge element as the locked gauge; it marks exactly where the fill stops.
  Everything else stays on the grey ramp.
- **The `style` option stays accepted, the locked design supersedes it.** The public
  `ProgressOptions` shape is unchanged — `style` (`"bar" | "blocks" | "braille" |
  "ascii"`) is honoured as accepted input, but every style renders the same
  shade-ramp panel. The retired glyphs — the `▁▂▃` sub-block texture, the `=`/`.`
  ascii bar, and the naked `[`…`]` bracket bar with its trailing pct — are outside
  the locked vocabulary and never render.
- **The `─` track IS the shared value scale** (axis colour), kept behind the fill so
  the level reads against the full `0..max` range.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an uppercase
  eyebrow row (`PROGRESS`, or the uppercased `opts.label`), a `+╌…╌+` value-axis guide
  with a `0..max` scale row under the bar, and two `│ ╌…╌ │` rule separators. Panel
  width auto-expands so the eyebrow and summary are never clipped (an explicit `width`
  is a floor, not a cap).
- **Summary footer** reporting `value <v> · 0..<max> · <pct>%`, with the `value <v>`
  fact in the accent hue. `showPercent: false` drops the `· <pct>%` fact from the
  footer (the option keeps its meaning; the agent surface still carries `percent`).
  Facts true for arbitrary input, never fabricated.
- **Out-of-range and degenerate data are safe — and honest.** A `value` past `max`
  clips the fill at full track width while the footer and `toJSON()` report the TRUE
  value and TRUE percent (may exceed 100% or sit below 0%) — the old silent clamp
  (which reported a clamped value and a percent that could never exceed 100) is
  retired as a lie; a negative value renders an empty track, honestly reported; a
  collapsed range (`max === 0`) never divides by zero (full when `value ≥ max`, empty
  otherwise); a non-finite `value` renders a framed `value n/a` panel — no
  `NaN`/`Infinity` anywhere.
- **Agent surface is additive**: `toJSON()` returns `type: "progress"`, `value`
  (TRUE, unclamped), `max`, `percent` (TRUE percent, null when n/a), `bucket` (the
  0–3 shade index, null when n/a), and `plain`. No existing key is removed; the
  public `ProgressOptions` shape is unchanged.

### LOCKED: histogram chart — session 25 design

`histogram` now carries the same locked design language as the area, line, bar,
scatter, heatmap, horizontalBar, treemap, timeline, gauge, and progress families —
the S12 `bar` orientation applied to binned distribution data. Rules that must not
change:

- **One accent hue, spent EXACTLY once, on the mode bin.** The bin with the highest
  count (ties → first bin in bin order, deterministic) renders a solid `█` column in
  the theme's accent hue — the same peak rule as bar/timeline/horizontalBar. Every
  other bin sits on the grey tone ramp. The old `theme.colors[0]` wall (the only
  chart in the core set that ignored the tone system entirely) is retired — no
  `theme.colors[i % n]` flood, ever.
- **Density IS the grey tone ramp — and the texture.** Each non-mode bin's shade
  glyph (`░ ▒ ▓ █`, light → dark by its share of the modal count) carries the
  density through `stripAnsi` / `noColor` — the heatmap/timeline/progress texture
  language. Bars stay thin (width ≥ 3 where the panel allows) with real 1-col gaps.
- **Y-axis labels are INTEGER counts.** Counts are integers — the old decimal
  y-labels (`36.56` on a count axis) were a bug the axis told and are retired.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an uppercase
  eyebrow row (`DISTRIBUTION`, or the uppercased `opts.xLabel`), a dashed `└╌…╌`
  baseline, bin-start labels under their columns in the label tone, and two
  `│ ╌…╌ │` rule separators. Panel width auto-expands so the eyebrow, bin labels,
  and summary are never clipped (an explicit `width` is a floor, not a cap).
- **Summary foot** reporting `n <count> · mode <value> · p50 <value> · p99 <value>`
  (nearest-rank percentiles over the sample), with the `mode` fact in the accent
  hue. Facts true for the given sample, never fabricated.
- **Degenerate input is safe.** Empty / all-non-finite data renders a framed
  `n 0 · (no data)` panel (no fabricated bin labels); a collapsed range (every
  value equal) lands every sample in the first bin; non-finite samples are
  excluded from the distribution — no `NaN`/`Infinity` anywhere.
- **Agent surface is additive**: `toJSON()` returns the original keys (`type`,
  `data`, `bins`, `binCounts`, `title`, `plain`) plus `mode`, `p50`, `p99` (null
  when there is no data) and `count` (the number of samples actually binned). The
  public `HistogramOptions` shape is unchanged.

### LOCKED: waterfall chart — session 26 design

`waterfall` now carries the same locked design language as the area, line, bar,
scatter, heatmap, horizontalBar, treemap, timeline, gauge, progress, and histogram
families — the audit's mudra waterfall card in the S18–S25 panel vocabulary.
Rules that must not change:

- **Down-deltas are visible by design.** Every negative step renders a dashed
  outline box (`┌╌╌┐` top / `│  │` sides / `└╌╌┘` bottom); a sub-row delta
  still renders a minimum one `┌╌╌┐` row. The old flat `─` dash on the baseline
  (indistinguishable from zero — the chart could not tell its story) is retired.
- **Tonal kinds, never rainbow.** Start and Total are solid `█` anchors (Start
  on the darkest grey tone, Total in the theme's accent hue, spent EXACTLY
  once); up-steps are solid `▓` on a mid grey tone; down-steps are the dashed
  outline on a light grey tone. The old `theme.colors[i]`
  positive/negative/total rainbow is retired — no `theme.colors[i % n]` flood,
  ever. Kind reads through `stripAnsi` / `noColor`: `█` anchors vs `▓` ups vs
  outlined downs (Start and Total share `█` as fellow level-anchors, told apart
  by position, step labels, and the foot facts).
- **Explicit color options stay user overrides** (like gauge thresholds):
  `positiveColor` / `negativeColor` / `totalColor` replace the locked tone for
  their kind when given; the glyph vocabulary never changes.
- **Y-axis labels are integers**, with the locked `│`/`+` guide. Zero deltas
  render an empty column (no mass, no outline) with the connector passing
  through — never a dash, never a fill.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an
  uppercase eyebrow row carrying the `NET <signed>` metric, a signed-delta
  label row above the plot (`+80` / `−120`), dashed `┄` connectors at each
  running level in the 1-col gaps, a dashed `└╌…╌` baseline, truncated step
  labels under their columns, and two `│ ╌…╌ │` rule separators. Panel width
  auto-expands so facts are never clipped (an explicit `width` is a floor, not
  a cap; bar width fits the longest delta fact, min 4 so outlines stay
  legible).
- **Summary foot** reporting `START <v> · Δ <signed…> · TOTAL <v>`, with the
  `TOTAL` fact in the accent hue. Facts true for the given data, never
  fabricated.
- **Degenerate input is safe.** Empty data renders a framed
  `TOTAL 0 · (no data)` panel with empty step facts; all-zero deltas render
  empty columns — no `NaN`/`Infinity` anywhere.
- **Agent surface is additive**: `toJSON()` returns the original keys (`type`,
  `data`, `labels`, `total`, `plain`) plus `steps` (per-step
  `{ label, delta, start, end, kind }`, `kind` in `start|up|down|total`, empty
  when there is no data). The public `WaterfallOptions` shape is unchanged.

### LOCKED: funnel chart — session 26 design

`funnel` now carries the same locked design language as the waterfall family
above — the audit's mudra funnel card (§3.4) in the panel vocabulary. Rules
that must not change:

- **Arrows deleted, rows CENTERED.** The `▼` connectors exist nowhere in mudra.
  Rows are centered boxes, top-wide → bottom-narrow — the symmetric silhouette
  that IS the funnel identity across every major chart library (ECharts,
  PowerBI, Highcharts, Evidence, Atlassian, Wikipedia). This deliberately
  REVERSES the audit's §3.4 item 2 (left-anchored rows), which rendered a
  horizontal bar chart and lost the chart's reason to exist — reversed by
  founder order with industry research on record, not silently. Centered boxes,
  never tapered slopes (slopes distort comparison and stairstep in a
  terminal). Labels stay in a fixed left column so row scanning survives.
- **One accent hue, spent EXACTLY once, on the peak stage.** The highest-value
  stage (ties → first in stage order, the family peak rule) renders a solid `█`
  run in the theme's accent hue. Every other stage sits on the descending grey
  tone ramp (`t1 → t2 → t2 → t3 …` down the stages — mudra's `.66 − i·.09`
  descent) with its matching shade glyph (`░ ▒ ▓` by share of the peak) plus
  one `▓` rounded-cap stand-in closing each non-peak bar. The old
  `theme.colors[i % n]` rainbow is retired — no flood, ever.
- **Percentages are integers** (`68%`, never `68.0%`) in the label tone.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an
  uppercase `CONVERSION <pct>%` metric eyebrow, two `│ ╌…╌ │` rule separators,
  and a foot row reporting `IN <v> · OUT <v> · CONVERSION <pct>% · DROP <label>
  −<pct>%` with the `CONVERSION` fact in the accent hue. Panel width
  auto-expands (explicit `width` is a floor, not a cap).
- **Degenerate input is safe.** Empty data renders a framed
  `STAGES 0 · (no data)` panel with null facts; a zero first stage reports
  `n/a` conversion (never div-by-zero `NaN`).
- **Agent surface is additive**: `toJSON()` returns the original keys (`type`,
  `data`, `labels`, `conversionRates`, `plain`) plus `conversion` (end-to-end,
  null when unmeasurable) and `biggestDrop` (`{ label, pct }`, null when none).
  The public `FunnelOptions` shape is unchanged.

### LOCKED: sankey chart — session 26 design

`sankey` now carries the same locked design language — the family language
applied by analogy (no audit mockup exists for sankey). Rules that must not
change:

- **One accent hue, spent EXACTLY once, on the peak flow.** The highest-value
  link (ties → first in link order) renders a solid `█` run in the theme's
  accent hue. Every other flow sits on the grey tone ramp with its matching
  shade glyph (`░ ▒ ▓` by share of the peak flow), widths proportional to
  value. The old `theme.colors[i % n]` per-link and per-node rainbow is
  retired — no flood, ever.
- **The `▶` arrow is deleted.** Direction reads left-to-right (`source` flows
  to `target`); the arrow is decoration — the same ruling that retired
  funnel's `▼`.
- **The node ledger stays, toned.** `Nodes:` keeps the `in:`/`out:` facts with
  each `■` on the grey ramp, nodes ordered by total flow (loudest first).
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an
  uppercase `FLOW <total>` metric eyebrow, two `│ ╌…╌ │` rule separators, and a
  foot row reporting `NODES <n> · LINKS <m> · PEAK <src> → <tgt> <v>` with the
  peak value in the accent hue. Panel width auto-expands (explicit `width` is
  a floor, not a cap).
- **Degenerate input is safe.** Empty links render a framed
  `NODES 0 · (no data)` panel with a null peak fact — no `NaN` anywhere.
- **Agent surface is additive**: `toJSON()` returns the original keys (`type`,
  `nodes`, `links`, `plain`) plus `peakFlow` (`{ source, target, value }`, null
  when there is no data). The public `SankeyOptions` shape is unchanged.

### LOCKED: radar chart — session 26 design

`radar` now carries the same locked design language — the family language
applied by analogy (no audit mockup exists for radar; the S09 circular geometry
and the S10/S17 multi-series language are the playbooks). Rules that must not
change:

- **One accent hue, spent EXACTLY once, on the primary series.** Series 0 draws
  a thickened sub-pixel braille rim with halo-ringed `●` vertices — all in
  the theme's accent hue — over a sparse wash haze one tone dimmer (the
  target's translucency: thin rim vanished beside neon; full tint buried the
  grid). Every other series draws a DASHED braille polygon in its grey tone
  with hollow `○` vertices. The old `theme.colors[si % n]` rainbow across
  edges, vertices, and legend is retired — no flood, ever. Mass and kind
  survive `stripAnsi` / `noColor` (shape, not hue).
- **The grid is hexagonal radar grammar.** Five dashed braille hex rings
  (20–100% of range) with `+` ticks at spoke crossings and dashed spokes —
  the founder-supplied reference image. The `0..<max>` scale rides the
  eyebrow (in-web numbers collide at terminal density).
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an
  `AXES <n> · SERIES <m>` structural eyebrow, a multi-series glyph legend,
  two `│ ╌…╌ │` rule separators, and a foot row reporting
  `AVG <v> · PEAK <axis> <v>` with the peak value in the accent hue. Panel
  width auto-expands with a label margin beside the web (explicit `width` is a
  floor, not a cap).
- **Degenerate input is safe.** Empty axes render a framed
  `AXES 0 · (no data)` panel with null facts; negatives and non-finite samples
  collapse to the center — no `NaN`/`Infinity` anywhere.
- **Agent surface is additive**: `toJSON()` returns the original keys (`type`,
  `data`, `labels`, `plain`) plus `max` (`{ value, axis }`, null when empty)
  and `avg` (null when empty). The public `RadarChartOptions` shape is
  unchanged.

### LOCKED: candlestick chart — session 27 design

`candlestick` now carries the same locked design language as the waterfall
family above — the S26 down-outline card applied to OHLC data. Rules that
must not change:

- **Tonal kinds, never rainbow.** Up candles are solid `▓` fills on a mid
  grey tone; down candles are the dashed outline (`┌╌╌┐` top / `│  │` sides
  / `└╌╌┘` bottom, the waterfall down language) on a light grey tone. The
  old `theme.colors[2]` green / `theme.colors[5]` red flood is retired —
  direction reads through `stripAnsi` / `noColor`. Doji candles (open ==
  close) count as up (a 1-row solid).
- **One accent hue, spent EXACTLY once, on the peak candle.** The highest
  close (ties → first in data order) renders its body as solid `█` in the
  theme's accent hue. Wicks always stay in the candle's own kind tone (never
  accent): at raw-ANSI level the accent touches only solid `█` body mass
  plus non-block text (the `LAST` foot fact).
- **Adaptive price labels, never sprawl.** The S27 precision rule: integers
  once the range spans 100+, otherwise ≤1dp (range ≥ 10) or ≤2dp, trimmed —
  compact labels, never `162.55`-style float sprawl, and never silent integer
  rounding of real prices. Locked `│`/`+` guide, dashed `└╌…╌` baseline,
  full period labels under their candles.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`), an
  uppercase `OHLC` eyebrow (the frame top carries `opts.title` — never an
  uppercased title echo), two `│ ╌…╌ │` rule separators, and a foot row reporting
  `N <n> · HI <v> · LO <v> · LAST <v>`
  with the `LAST` fact in the accent hue. Panel width auto-expands so facts
  are never clipped (an explicit `width` is a floor; candles fit the longest
  period label in full — never `Jan`/`Jan1` mush — with a 4-wide floor so
  outlines stay legible).
- **Degenerate input is safe.** Empty / all-non-finite data renders a framed
  `N 0 · (no data)` panel with null JSON facts (the old code crashed:
  `Math.max(...[])` → `-Infinity` widths); a flat range (all OHLC equal)
  pads ±1 so candles stay visible (never `NaN` rows); non-finite candles are
  excluded, never plotted; narrow widths never `RangeError`.
- **Agent surface is additive**: `toJSON()` returns the original keys
  (`type`, `data`, `plain`) plus `count`, `high`, `low`, `last` (null when
  there is no data). The public `CandlestickOptions` shape is unchanged.

### LOCKED: boxplot chart — session 27 design

`boxplot` now carries the same locked design language as the candlestick
family above — the S18–S27 panel vocabulary on grouped spread data. Rules
that must not change:

- **Tonal groups, never rainbow.** The peak group (highest median, ties →
  first in group order) renders box + whiskers + caps + median in the
  theme's accent hue, spent EXACTLY once; every other group sits on the grey
  tone ramp with its matching shade fill (`░▒▓` by share of the peak median
  — the 2026-09-11 shade-texture ruling, so spread survives noColor). The
  old `theme.colors[si % n]` rainbow is retired — no rainbow, ever.
- **The median stays visually distinct from the box edges.** Box edges are
  vertical `│` with a shade/`█` fill between them; the median is a
  horizontal run (`───`, `═══` on the peak group) — direction tells them
  apart with or without colour. Whiskers are `│`, caps `┬`/`┴`.
- **Adaptive value labels** (`axisPriceFmt`, shared with candlestick):
  integers when the range is wide, ≤2dp when tight. Locked `│`/`+` guide,
  dashed `└╌…╌` baseline, truncated group labels, two rule separators.
  Width is a floor (auto-expand, never clip; groups stay 7 wide so the
  median marker never `RangeError`s on narrow widths — the old
  `" ".repeat(mid - 1)` crash).
- **Summary foot** reporting `GROUPS <n> · MED <v> · PEAK <label> <v>`, with
  the `PEAK` fact in the accent hue. Facts true for the given data, never
  fabricated.
- **Degenerate input is safe.** Empty / all-non-finite renders a framed
  `GROUPS 0 · (no data)` panel with null `stats`/`peakGroup` facts (the old
  code crashed on `rawData[0]`); single-value groups render via the
  flat-range guard (never `NaN`); non-finite samples are excluded before
  `quartiles()`, never plotted; groups left with no finite samples are
  dropped with their labels.
- **Agent surface is additive**: `toJSON()` returns the original keys
  (`type`, `data`, `labels`, `stats`, `plain`) plus `peakGroup`
  (`{ label, index, median }`, null when there is no data). The public
  `BoxPlotOptions` shape is unchanged.

### LOCKED: sparkline chart — session 28 design

`sparkline` now carries the same locked design language as the S18–S27
panel vocabulary — the heatmap strip grammar with a pulse, on inline time
data (the founder-approved v8 prototype). Rules that must not change:

- **Shape + shade, never a single-colour strip.** Every plotted reading is
  one 2-wide column, up to 4 rows tall by share of the data range (height
  reads the trend); each column takes its shade glyph (`░ ▒ ▓ █` by share)
  on the grey tone ramp (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`), so
  intensity survives `stripAnsi` / `noColor` — the 2026-09-11
  shade-texture ruling. The old single-teal `theme.colors[0]` strip is
  retired — no flood, ever. Columns stay 2 wide so the dither glyphs render
  as solid cells in browser fonts (1-wide `░▒▓` speckles outside the
  terminal).
- **One accent hue, spent EXACTLY once, on the peak reading.** The maximum
  value (ties → first in data order, the family peak rule) renders a solid
  `█` column in the theme's accent hue. Everything else stays on the ramp.
- **The `renderer` option stays accepted, the locked design supersedes
  it.** The public `SparklineOptions` shape is unchanged — `renderer`
  (`"blocks" | "braille" | "ascii"`) is honoured as accepted input, but
  every renderer draws the same shade-ramp panel. The retired glyphs — the
  `▁▂▃` sub-block strip, the braille line, and the ascii glyphs — are
  outside the locked vocabulary and never render.
- **Same panel language as all locked charts**: dashed frame (`┌╌…╌┐`),
  the label on the frame top (or `SPARKLINE`), an uppercase `SPARKLINE`
  eyebrow, and two `│ ╌…╌ │` rule separators. Panel width auto-expands so
  the strip and the summary are never clipped (an explicit `width` shaped
  the columns and stays a floor, never a cap).
- **Summary foot** reporting `n <count> · min <v> · max <v> · last <v> ·
  peak <v>`, with the `peak` fact in the accent hue (`showValue: false`
  drops the `last` fact). Every fact describes the PLOTTED points
  (post-downsample), so the foot can never disagree with the strip.
- **`width` keeps its meaning.** It counts plotted data columns; longer
  input is deterministically downsampled on evenly spaced indices (stable
  ties, stable re-renders).
- **Degenerate input is safe.** Empty / all-non-finite renders a framed
  `n 0 · (no data)` panel with null `min`/`max`/`last`/`peak` facts (the old
  code returned a bare `""`); a flat range renders full columns (never
  `NaN`); non-finite samples are excluded from the plot, the facts, and
  the count — never plotted, never counted; narrow widths never crash.
- **Agent surface is additive**: `toJSON()` returns the original keys
  (`type`, `data`, `label`, `plain`) plus `count`, `min`, `max`, `last`
  (null when there is no data) and `peak` (`{ index, value }`, null when
  there is no data). The public `SparklineOptions` shape is unchanged.

### LOCKED: family-wide footer (B-diet+) — session 29 design

The S21-deferred footer pass is closed, founder-picked B-diet+ from
real-render ballots: **plain-words takeaway footers + one rule separator**,
family-wide. Where an S09–S28 block above quotes a footer line or two rule
separators, **this block supersedes those two lines** — the rest of each
block (geometry, tones, accent rule, degenerate safety, agent surface)
stands unchanged. Rules that must not change:

- **One `│ ╌…╌ │` rule separator per panel** (below the eyebrow/legend).
  The pre-footer rule is gone everywhere; panels read airier at a glance.
- **Footers speak plain nouns and name the takeaway.** No `n`, `min/max`,
  `span`, `MED`, `AVG`, `GROUPS`, `HI/LO` jargon; no range repeats (the
  scale row already owns the range):
  timeline `N events · longest L`; horizontalBar `N items · peak L (max)`;
  sparkline `N readings · peak P`; gauge/progress `V of A..B · P%`;
  histogram `N samples · peak M`; heatmap `R×C grid · peak (r, c)`; scatter
  `N points · peak (x, y)`; treemap `N leaves · peak L`; bar per-series
  `name · avg C · peak B`; line per-series `lowest/highest` (facts kept);
  area `highest/lowest`; radar `average A · peak L (V)`; candlestick
  `N candles · high H · low L · last X`; boxplot
  `G groups · median M · peak L (V)`; pie/donut/waterfall/funnel/sankey
  keep their already-plain text.
- **The takeaway keeps the single accent hue** (ties-first rules
  unchanged). Empty panels use the plain count noun
  (`0 events/readings/samples/candles/groups/axes/cells/leaves/points/items
  · (no data)`) with null JSON facts.
- **Display-only change.** `toJSON()` facts, `toContent()`/compact paths,
  and public option shapes are untouched.

## License

MIT
