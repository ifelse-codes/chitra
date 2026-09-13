# Session 22 — lock the `gauge` chart to the mudra reference/panel design language

> **Type: CODE.** Branch `session-22-gauge-mudra`. One story: apply the locked panel
> language to the single-value gauge — the next chart in the founder-named trio
> (`timeline` → `gauge` → `progress`), carrying the founder's 2026-09-11 shade-texture
> ruling (░▒▓ texture on the fill; the accent is the solid `█`). Keep it tight.

## Goal

`gauge` is NOT locked to chitra's reference design language: it picks raw
`theme.colors[1/3/2]` hues by value band (a rainbow variant), renders a `▓`/`░` fill with
`┤`/`├` endcaps (glyphs outside the locked vocabulary), has no frame, no eyebrow, no
guide, no summary footer, computes a `labelLine` it never renders (dead code), and
crashes with a `RangeError` when `value > max` (`"░".repeat(negative)`). Its locked
siblings `timeline` (S21), `treemap` (S20), `horizontalBar` (S19), and `heatmap` (S18)
are the exact references. Apply that locked language to the gauge.

## Named references (read ONLY these — do not scan the repo)

- `packages/core/src/charts/timeline.ts` — the S21 locked reference (tone-bucket method,
  panel chrome, guide + scale rows, auto-width, footer).
- `packages/core/src/charts/heatmap.ts` — the S18 locked reference (grey tone ramp,
  accent-once, footer shape).
- `packages/core/README.md` → `### LOCKED: timeline chart — session 21 design` — the
  written contract style to mirror.
- `packages/core/src/charts/gauge.ts` — the target to rewrite.
- `packages/core/src/renderers/panel.ts` — `frameTop` / `frameRow` / `frameRule` /
  `frameBottom`.
- `packages/core/tests/timeline.test.ts` — the raw-ANSI accent-census test pattern.

## Acceptance (testable, EARS-style)

1. WHEN `gauge` renders, THEN the fill is the grey tone ramp WITH its matching plain-text
   shade glyph (`░ ▒ ▓ █`, one per tone bucket, light → dark by level — the heatmap
   texture language, per the founder's shade-texture ruling, so the intensity survives
   `stripAnsi` / `noColor`), and the theme's accent hue is spent EXACTLY once on the bar:
   a solid `█` on the fill's leading edge (the single-value analog of the locked peak
   element — it marks exactly where the reading stops). No `theme.colors[i % n]` band
   rainbow, ever. Verified at raw-RGB level (one accent bar segment, zero non-ramp /
   non-accent bar segments). Explicit `thresholds` stay a user override: the matched
   threshold colour replaces the ramp tone on the fill (glyph texture unchanged), and the
   accent edge yields to the override colour.
2. WHEN `gauge` renders, THEN it carries the same panel language as the locked families:
   dashed frame (`┌╌…╌┐` / `└╌…╌┘`), an uppercase eyebrow row (`LEVEL`, or `opts.label`
   uppercased when given), a `+╌…╌+` value-axis guide and a `min..max` scale row under
   the bar, and two `│ ╌…╌ │` rule separators. The `─` track (axis colour) remains
   behind the fill as the shared scale, and `┤` / `├` endcaps are retired glyphs.
3. WHEN the reading renders, THEN the fill length is the level clamped to the track
   (a `value` past `max` clips at full width — never a `RangeError`), while the footer
   reports the TRUE value and a TRUE percent (may exceed 100% / sit below 0%). A
   non-finite `value` renders a framed `value n/a` panel — never `NaN`/`Infinity`.
4. WHEN the range is collapsed (`max === min`), THEN the gauge renders honestly with no
   division by zero: the level reads full when `value ≥ max`, empty otherwise.
5. WHEN the summary renders, THEN the footer reports `value <v> · <min>..<max> · <pct>%`
   with the `value <v>` fact in the accent hue — facts true for arbitrary input, never
   fabricated.
6. WHEN `toJSON()` is called, THEN it returns the additive agent surface: `type: "gauge"`,
   `value`, `min`, `max`, `percent`, `bucket` (the 0–3 shade index, `null` when n/a),
   `plain`. No key that exists today is removed.
7. `packages/core/README.md` carries a `### LOCKED: gauge chart — session 22 design`
   block stating the rules above.
8. `scripts/verify-session-22.sh` exits 0 (raw-RGB accent census, panel chrome, footer
   format, retired-glyph check, ramp-survives-noColor, degenerate-safe incl. out-of-range
   clamp + collapsed range + n/a, no-rainbow source check, dead `labelLine` gone, core
   tests + typecheck, README block, docs chart-drift gate, branch check) and
   `scripts/demo-session-22.sh` exits 0 with live renders + falsifiable checks.
9. The docs catalog preview regenerates in sync (`gen:charts:check` green) with the locked
   render and an updated description; the public API (`GaugeOptions` shape) is unchanged;
   zero runtime deps; the full core suite stays green.

## Session constraints (constitution)

- One story. Max 3 files per atomic commit. No autonomous commits (founder runs them with
  `VAJRA_ALLOW_COMMIT=22`). Verify exit 0 required. Independent cold fidelity review owed
  post-commit (`sessions/session-22-review.md`, per `reviewer/SKILL.md`) before ACCEPT.
