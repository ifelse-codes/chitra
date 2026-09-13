# Current Task Pointer

## Session 22 — lock the `gauge` chart to the mudra reference/panel design language — COMPLETE (closeout gate + PR)

- **Branch:** `session-22-gauge-mudra` (close on branch; main untouched)
- **Shipped:** `gauge()` re-rendered in the locked panel language — the S18/S19/S21
  language on the single-value chart. Rainbow `theme.colors[1/3/2]` value bands removed:
  the fill is the grey tone ramp (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`) WITH its matching
  plain-text shade glyph (`░ ▒ ▓ █`, one per tone bucket, light → dark by level — the
  heatmap texture language per the founder's 2026-09-11 shade-texture ruling, so intensity
  survives noColor); ONE accent hue spent EXACTLY once as a solid `█` on the fill's
  leading edge (marks where the reading stops). Explicit `thresholds` stay a user override.
  Panel chrome: dashed frame, uppercase `LEVEL` eyebrow (or `opts.label` uppercased),
  `+╌…╌+` guide + `min..max` scale row, two rule separators; the dim `─` track (axis
  colour) remains the shared scale; `┤`/`├` endcaps retired. Fill length clamps to the
  track (out-of-range never crashes — the old `RangeError` is gone) while the footer
  reports the TRUE value and TRUE percent; non-finite → framed `value n/a` panel;
  collapsed range renders honestly. Footer `value <v> · <min>..<max> · <pct>%` with the
  value fact in accent. `toJSON()` gains additive `bucket` (0–3, `null` when n/a) and
  `percent`. Public API unchanged, zero runtime deps, dead `labelLine` removed. README
  `### LOCKED: gauge chart — session 22 design` block added.
- Verify: `scripts/verify-session-22.sh` — 13/13 ALL GREEN (core 284/284, +25 gauge).
  Demo exit 0, 7/7 PASS. Summary: `sessions/session-22-summary.md`. Review:
  `sessions/session-22-review.md` — independent cold pass ACCEPT, attested (9/9 SHIPPED).

**Next session (S23 candidates):** `progress` — the last chart of the founder-named trio
(`timeline` → `gauge` → `progress`), carrying the shade-texture ruling; the
founder-deferred family-wide plain-English footer pass (A trim / B plain words / B-diet);
plan-review bug-first queue (histogram, waterfall, funnel); `lineModelToSvg` parity; real
`v0.1.0` release; Playwright QA into CI. Open in a **new chat**.
