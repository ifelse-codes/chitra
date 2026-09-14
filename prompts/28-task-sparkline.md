# Session 28 — task: lock sparkline to the mudra panel language

Founder direction (in-chat, S28): the throwaway v8 prototype wins — lock it.
`sankey`/`funnel` use `░▒▓█` shade blocks, `pie`/`donut` use braille; the
founder-approved sparkline is the v8 shape+shade strip (height reads the
trend, shade reads the intensity), after rejecting the heatmap-flat-strip,
mini-area, and sensor-table variants with reasons on record.

## Numbered requirements

1. **Shape+shade columns.** Every reading is one 2-wide column, ≤4 rows tall
   by share of the data range; shade glyph (`░ ▒ ▓ █`) by share on the grey
   tone ramp, so intensity survives noColor.
2. **One accent, spent once.** Peak reading (ties → first) solid `█` accent;
   no `theme.colors[0]` teal flood.
3. **Panel chrome.** Dashed frame, label on the frame top, uppercase
   `SPARKLINE` eyebrow, two rule separators; bigger presence than the bare
   one-line strip.
4. **Facts foot.** `n · min · max · last · peak` with the peak accented
   (`showValue: false` drops `last`).
5. **Width keeps meaning.** Plotted data columns; longer input deterministically
   downsampled; panel auto-expands (floor, never cap).
6. **Renderer superseded.** Option stays accepted, one design renders.
7. **Degenerate-safe.** Empty/all-non-finite → framed `n 0 · (no data)` +
   null facts; flat range safe; non-finite excluded from plot, facts, count;
   narrow-safe.
8. **Additive agent surface.** `toJSON` keeps `type`/`data`/`label`/`plain`,
   adds facts incl. `peak {index, value}`.
9. **Gates.** New lock tests, full suite + typecheck green, verify script
   green, demo green, README `### LOCKED` block, docs previews in sync,
   `dist/` rebuilt.
