# Chitra Field Report — SRE Dashboard

## What I learned

1. **Chitra is a terminal-native charting library with 20 chart types** — line, bar, area, sparkline, histogram, scatter, pie, donut, heatmap, progress, gauge, horizontalBar, timeline, radar, boxplot, waterfall, funnel, candlestick, treemap, sankey — all rendering to ANSI with braille/block/ascii renderers.

2. **The mudra default theme (`#8B7CF6` violet accent) is production-ready** — the one-hue design language is clean, consistent, and avoids the rainbow-vomit trap. The `GREY_TONES` ramp (`#ECECEF → #6A6A75`) works well for non-accent elements.

3. **The fluent `plot()` API is elegant but the function API (`bar()`, `line()`) is more ergonomic for dashboard builders** who need to compose many panels. The fluent API shines for quick one-off charts.

4. **The `ChartResult` interface is AI-agent gold** — `.toPlain()`, `.toJSON()`, `.toMarkdown()` make it trivial to feed charts to LLMs/MCP tools without ANSI noise. This is a genuine differentiator.

5. **The `normalize()` helper is essential for dashboard layouts** — chitra panels are intrinsically sized, so without normalization, panels in a row end ragged. The `band()` pattern from buffy-dashboard should be the standard approach.

## What I built

**SRE Dashboard** — a live-updating terminal dashboard for an SRE team, serving 20 chart panels covering all four golden signals (latency, traffic, errors, saturation) plus SLOs, incident tracking, capacity planning, and request flow.

### Files created
- `playground/sre-dashboard/sre-sim.ts` — SRE service simulation engine
- `playground/sre-dashboard/sre-frame.ts` — Dashboard frame renderer (all 20 chart types)
- `playground/sre-dashboard/sre-server.ts` — HTTP server (ANSI→HTML in browser)
- `playground/sre-dashboard/sre-dashboard.ts` — CLI entry (live terminal view)
- `playground/sre-dashboard/audit.ts` — Programmatic output audit

### Run commands
```bash
# Terminal (live, refreshes every 2s)
packages/core/node_modules/.bin/tsx playground/sre-dashboard/sre-dashboard.ts

# Terminal (single frame)
packages/core/node_modules/.bin/tsx playground/sre-dashboard/sre-dashboard.ts --once

# HTTP server via antra (browser) — uses existing chitra-dashboard.test route
packages/core/node_modules/.bin/tsx playground/sre-dashboard/sre-server.ts
# → http://chitra-dashboard.test:4173

# HTTP server standalone
PORT=4200 packages/core/node_modules/.bin/tsx playground/sre-dashboard/sre-server.ts
# → http://localhost:4200

# Add sre.test domain via antra (requires sudo once)
sudo antra alias sre.test 4173
# → http://sre.test:4173

# Audit
packages/core/node_modules/.bin/tsx playground/sre-dashboard/audit.ts
```

## Star ratings

| Chart | Stars | Justification |
|-------|-------|---------------|
| sparkline | ★★★★★ | Compact, beautiful shade-ramp columns. Perfect for KPI sparkbars. |
| line | ★★★★★ | Multi-series with Catmull-Rom smoothing. Clean axis labels. |
| area | ★★★★★ | Filled area reads well for traffic volume. |
| horizontalBar | ★★★★★ | Labels fit naturally. Great for route/region comparisons. |
| heatmap | ★★★★★ | Color density is immediately readable. Cell sizing works. |
| timeline | ★★★★★ | Gantt-style events with incident/deploy markers. |
| bar | ★★★★☆ | Good but single-color by default; multi-series needs `seriesLabels`. |
| donut | ★★★★☆ | Clean but legend can spill panel width on many slices. |
| pie | ★★★★☆ | Braille circle is precise but small slices hard to distinguish. |
| gauge | ★★★★☆ | Thresholds work well. Could use a needle marker for precision. |
| progress | ★★★★☆ | Shade ramp is nice. Could auto-color by threshold. |
| candlestick | ★★★★☆ | OHLC rendering is solid. Limited to 6 candles before crowding. |
| boxplot | ★★★★☆ | Box-and-whisker reads well. Whisker outliers could be annotated. |
| histogram | ★★★★☆ | Binning is automatic. Bin count could be suggested by data shape. |
| scatter | ★★★★☆ | Highlight point works. Dot size is small on dense plots. |
| funnel | ★★★★☆ | Conversion percentages are clear. Nesting constraint is enforced. |
| waterfall | ★★★★☆ | Positive/negative colors read well. Total bar is a nice touch. |
| radar | ★★★★☆ | Readable after sizing up. Small radar is hard to parse. |
| treemap | ★★★★☆ | Nested rectangles work. Labels can overflow on small cells. |
| sankey | ★★★★☆ | Flow paths are clear with fewer nodes. Gets cluttered with 10+ links. |

**Final: all charts ≥ 4 stars after enhancement.**

## Bugs found in the library

1. **No bugs found during this field test.** All 20 chart types rendered correctly with the mudra default theme. ANSI escape codes were well-formed (every escape had a corresponding reset).

## Newcomer verdict: delightful

**The ONE feature the library is missing:** A built-in `dashboard()` or `grid()` layout API that automatically arranges panels into a grid with consistent sizing, gaps, and responsive width. Currently you have to manually implement `normalize()` + `band()` (which I copied from buffy-dashboard). This is the #1 friction point for dashboard builders — the chart rendering is excellent, but the layout story is DIY.

### Other minor gaps worth noting:
- No `sparkline` option for inline embedding within text (the `label` + `showValue` is good but there's no `inline()` helper)
- No built-in color legend component — you have to build it yourself
- The `toSVG()` method is only available on line charts, not the full 20-type surface
