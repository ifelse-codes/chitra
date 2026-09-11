# Session 21 — lock the `timeline` chart to the mudra reference/panel design language

> **Type: CODE.** Branch `session-21-timeline-mudra`. One story: apply the locked panel
> language to the Gantt/timeline chart — the next chart in the founder-named trio
> (`timeline` → `gauge` → `progress`), cross-checked against the plan-review recommendation
> (`design-reference/plan-review.html`). Keep it tight.

## Goal

`timeline` is NOT locked to chitra's reference design language: it renders a rainbow
(`theme.colors[i % n]`), carries the retired `▶`/`◀` markers, and has no frame, no eyebrow,
no guide, and no summary footer. Its siblings `heatmap` (S18), `horizontalBar` (S19), and
`treemap` (S20) are the exact references for a rows-panel chart. Apply that locked language
to the timeline. Per the plan-review recommendation: keep the dim `─` track as the visible
scale (v2 rule — keep the scale when exact reading matters), and introduce NO new glyphs
beyond the locked vocabulary (retire `▶`/`◀`).

## Named references (read ONLY these — do not scan the repo)

- `packages/core/src/charts/horizontalBar.ts` — the S19 locked rows-panel reference
  (accent-once on the peak bar, grey ramp, panel chrome, auto-width, footer).
- `packages/core/src/charts/heatmap.ts` — the S18 locked reference (tone-bucket method).
- `packages/core/README.md` → `### LOCKED: treemap chart — session 20 design` — the written
  contract style to mirror.
- `packages/core/src/charts/timeline.ts` — the target to rewrite (currently rainbow).
- `packages/core/src/renderers/panel.ts` — `frameTop` / `frameRow` / `frameRule` / `frameBottom`.
- `packages/core/tests/heatmap.test.ts` — the raw-ANSI accent-census test pattern to mirror.

## Acceptance (testable, EARS-style)

1. WHEN `timeline` renders, THEN the single longest-span event (`end − start`) is drawn in
   the theme's accent hue as a solid `█` run, and EVERY other event uses the grey tone ramp
   (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, light → dark by span length) WITH its matching
   plain-text shade glyph (`░ ▒ ▓ █`, one per tone bucket — the heatmap texture language, so
   the ordering survives `stripAnsi` / `noColor`). No `theme.colors[i % n]` rainbow, ever.
   Verified at raw-RGB level (accent spent EXACTLY once — one bar segment — zero
   non-ramp/non-accent bar segments). Ties resolve to the first such event in event order
   (deterministic strict-`>` rule, same as bar/heatmap/treemap). An explicit `event.color`
   stays a user override, not a theme rainbow.
2. WHEN `timeline` renders, THEN it carries the same panel language as the locked families:
   dashed frame (`┌╌…╌┐` / `└╌…╌┘`), an uppercase eyebrow row (`SPAN`), a `+╌…╌+` value-axis
   guide with a `min..max` scale row under the events, and two `│ ╌…╌ │` rule separators.
3. WHEN an event row renders, THEN the dim `─` track (axis colour) remains behind the event
   as the shared time scale, and the bar fill is the shade-ramp run — no `▶`, `◀`, or any
   glyph outside the locked vocabulary (`░ ▒ ▓ █` bars, `─` scale, `╌` frame, `+` guide).
4. WHEN an event has no `end` (or an `end` before its `start`), THEN it renders exactly ONE
   lightest-shade glyph (`░` — honestly zero-length), never a crash and never a
   NaN-derived position.
5. WHEN the summary renders, THEN the footer reports `n <count> · <min>..<max> · span <label>`
   with the longest event's label in the accent hue — facts true for arbitrary event data.
6. WHEN degenerate input is given (empty events, single event, collapsed range where all
   events share one instant), THEN it renders safely: no crash, no `NaN`/`Infinity`, framed
   panel, empty → `n 0 · (no data)`, collapsed range → honest render with the accent still
   spent exactly once.
7. WHEN `toJSON()` is called, THEN it returns the additive agent surface: `type: "timeline"`,
   `events`, `min`, `max`, `peak` (`{ index, label, span }` or `null`), `plain`.
8. `packages/core/README.md` carries a `### LOCKED: timeline chart — session 21 design` block
   stating the rules above.
9. `scripts/verify-session-21.sh` exits 0 (raw-RGB accent census, panel chrome, footer
   format, retired-glyph + point-event check, degenerate-safe, no-rainbow source check,
   core tests + typecheck, README block, docs chart-drift gate, branch check) and
   `scripts/demo-session-21.sh` exits 0 with live renders + falsifiable checks.
10. The docs catalog preview regenerates in sync (`gen:charts:check` green) with the locked
    render and an updated description; the public API (`TimelineOptions` shape) is unchanged;
    zero runtime deps; the full core suite stays green.

## Session constraints (constitution)

- One story. Max 3 files per atomic commit. No autonomous commits (founder runs them with
  `VAJRA_ALLOW_COMMIT=21`). Verify exit 0 required. Independent cold fidelity review owed
  post-commit (`sessions/session-21-review.md`, per `reviewer/SKILL.md`) before ACCEPT.
