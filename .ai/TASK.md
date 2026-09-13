# Current Task Pointer

## Session 23 — lock the `progress` chart to the mudra reference/panel design language — COMPLETE (closeout gate + PR)

- **Branch:** `session-23-progress-mudra` (close on branch; main untouched)
- **Shipped:** `progress()` re-rendered in the locked panel language — completing the
  founder-named trio (`timeline` → `gauge` → `progress`). The `theme.colors[2/3/1]`
  traffic-light band rainbow is gone: the fill is the grey tone ramp WITH its matching
  plain-text shade glyph (`░ ▒ ▓ █`, one per tone bucket, light → dark — the
  heatmap/gauge texture language per the founder's shade-texture ruling, so intensity
  survives noColor); ONE accent hue spent EXACTLY once as a solid `█` on the fill's
  leading edge. The `style` option stays accepted but the locked design supersedes it —
  `▁▂▃` sub-blocks, `=`/`.` ascii, and the naked `[bar] pct` line are retired. **The
  silent clamp is retired as a lie:** the fill clamps to the track while the footer AND
  `toJSON()` report the TRUE value and TRUE percent; non-finite → framed `value n/a`
  panel; collapsed range (`max === 0`) safe. Panel chrome: dashed frame, uppercase
  `PROGRESS` eyebrow (or `opts.label` uppercased), `+╌…╌+` guide + `0..max` scale row,
  two rule separators; the dim `─` track remains the shared scale. Footer
  `value <v> · 0..<max> · <pct>%` with the `value <v>` fact in accent; `showPercent:
  false` drops the pct fact. `toJSON()` gains additive `bucket` (0–3, `null` when n/a)
  and a true `percent`. Public API unchanged, zero runtime deps. README
  `### LOCKED: progress chart — session 23 design` block added; docs previews
  regenerated; the outdated clamped-value assertion in `charts.test.ts` updated to the
  honest contract.
- Verify: `scripts/verify-session-23.sh` — 13/13 ALL GREEN (core 309/309, +25 progress).
  Demo exit 0, 7/7 PASS. Summary: `sessions/session-23-summary.md`. Review:
  `sessions/session-23-review.md` — independent cold pass ACCEPT, attested (11/14
  SHIPPED; 3 PARTIAL = process facts not observable from a diff).

**Next session (S24 candidates):** the founder-deferred family-wide plain-English
footer pass (A trim / B plain words / B-diet); plan-review bug-first queue (histogram,
waterfall, funnel); `lineModelToSvg` parity; real `v0.1.0` release; Playwright QA into
CI. Open in a **new chat**.
