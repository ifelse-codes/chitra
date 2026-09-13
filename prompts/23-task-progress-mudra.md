# Session 23 — lock the `progress` chart to the mudra reference/panel design language

> **Type: CODE.** Branch `session-23-progress-mudra`. One story: apply the locked panel
> language to the single-value progress bar — the last chart of the founder-named trio
> (`timeline` → `gauge` → `progress`), carrying the founder's 2026-09-11 shade-texture
> ruling (░▒▓ texture on the fill; the accent is the solid `█`). Keep it tight.

## Goal

`progress` is NOT locked to chitra's reference design language: it picks a raw
`theme.colors[2/3/1]` hue by value band (a traffic-light rainbow), renders a naked
`[████░░░] 87.0%` bar with sub-block `▁▂▃` texture and `=`/`.` ascii fallback glyphs
(all outside the locked vocabulary), has no frame, no eyebrow, no guide, no scale row,
no summary footer — and it **silently clamps and lies**: `value` is clamped into
`0..max` before anything is computed, so a `value` past `max` reports the clamped
number and a `percent` that never exceeds 100, and `toJSON()` repeats the lie. Its
locked sibling `gauge` (S22) is the exact reference — the single-value panel language,
already carrying the shade-texture ruling. Apply that locked language to `progress`.

## Named references (read ONLY these — do not scan the repo)

- `packages/core/src/charts/gauge.ts` — the S22 locked reference (tone-bucket method,
  shade glyph ramp, accent-once edge, panel chrome, guide + scale rows, auto-width,
  honest out-of-range footer).
- `packages/core/tests/gauge.test.ts` — the raw-ANSI accent-census test pattern and the
  degenerate-input suite to mirror.
- `packages/core/README.md` → `### LOCKED: gauge chart — session 22 design` — the
  written contract style to mirror.
- `packages/core/src/renderers/panel.ts` — `frameTop` / `frameRow` / `frameRule` /
  `frameBottom`.

## Acceptance (testable, EARS-style)

1. WHEN `progress` renders, THEN the fill is the grey tone ramp WITH its matching
   plain-text shade glyph (`░ ▒ ▓ █`, one per tone bucket, light → dark by level — the
   heatmap/gauge texture language, per the founder's shade-texture ruling, so the
   intensity survives `stripAnsi` / `noColor`), and the theme's accent hue is spent
   EXACTLY once on the bar: a solid `█` on the fill's leading edge (the same
   reading-edge element as the locked gauge — it marks exactly where the fill stops).
   No `theme.colors[i % n]` band rainbow, ever. Verified at raw-ANSI level (one accent
   bar segment, zero non-ramp / non-accent bar segments). The `style` option stays
   accepted (public API unchanged) but the locked design supersedes it: every style
   renders the same shade-ramp panel — no `▁▂▃` sub-block texture, no `=`/`.` ascii
   glyphs, no naked `[`…`]` bracket bar.
2. WHEN `progress` renders, THEN it carries the same panel language as the locked
   families: dashed frame (`┌╌…╌┐` / `└╌…╌┘`), an uppercase eyebrow row (`PROGRESS`,
   or `opts.label` uppercased when given), a `+╌…╌+` value-axis guide and a `0..max`
   scale row under the bar, and two `│ ╌…╌ │` rule separators. The `─` track (axis
   colour) remains behind the fill as the shared scale. Panel width auto-expands so
   the eyebrow and summary are never clipped (an explicit `width` is a floor, not a
   cap).
3. WHEN the reading renders, THEN the fill length is the level clamped to the track
   (a `value` past `max` clips at full width — never a negative `repeat`), while the
   footer and `toJSON()` report the TRUE value and a TRUE percent (may exceed 100% or
   sit below 0%). The old silently-clamped-and-lying `value` is gone.
4. WHEN the range is collapsed (`max === min`, i.e. `max === 0` since the progress
   range is `0..max`), THEN the chart renders honestly with no division by zero: the
   level reads full when `value ≥ max`, empty otherwise. A non-finite `value` renders
   a framed `value n/a` panel — never `NaN`/`Infinity`.
5. WHEN the summary renders, THEN the footer reports `value <v> · 0..<max> · <pct>%`
   with the `value <v>` fact in the accent hue — facts true for arbitrary input, never
   fabricated. WHEN `showPercent` is `false`, the `· <pct>%` fact is dropped from the
   footer (the option keeps its meaning).
6. WHEN `toJSON()` is called, THEN it returns the additive agent surface: `type:
   "progress"`, `value` (TRUE, unclamped), `max`, `percent` (TRUE percent, `null` when
   n/a), `bucket` (the 0–3 shade index, `null` when n/a), `plain`. No key that exists
   today is removed. The public `ProgressOptions` shape is unchanged.
7. `packages/core/README.md` carries a `### LOCKED: progress chart — session 23 design`
   block stating the rules above (mirroring the gauge block's style).
8. `scripts/verify-session-23.sh` exits 0 (raw-ANSI accent census, panel chrome, footer
   format, retired-glyph check, ramp-survives-noColor, degenerate-safe incl. out-of-range
   honest footer + collapsed range + n/a, no-rainbow / no-sub-block / no-ascii-bar source
   check, core tests + typecheck, README block, docs chart-drift gate, branch check) and
   `scripts/demo-session-23.sh` exits 0 with live renders + falsifiable checks.
9. The docs catalog preview regenerates in sync (`gen:charts:check` green) with the
   locked render and an updated description; the full core suite stays green (the
   outdated `charts.test.ts` assertion that blesses the clamped-and-lying `toJSON`
   value is updated to the honest contract); zero runtime deps.

## Session constraints (constitution)

- One story. Max 3 files per atomic commit. No autonomous commits (founder runs them with
  `VAJRA_ALLOW_COMMIT=23`). Verify exit 0 required. Independent cold fidelity review owed
  post-commit (`sessions/session-23-review.md`, per `reviewer/SKILL.md`) before ACCEPT.
