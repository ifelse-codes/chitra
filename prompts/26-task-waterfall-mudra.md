# Session 26 — lock `waterfall` + `funnel` + `sankey` + `radar` to the mudra reference/panel design language

> **Type: CODE.** Branch `session-26-waterfall-mudra`. Five stories — founder-directed
> scope expansions in-session (funnel + sankey, then the centered-funnel
> reversal on research record, then radar): after each lock landed green, the
> next target was named in-chat. The 1-story/session rule is waived throughout
> by explicit founder direction (disclosed in the summary). Carry the 2026-09-11 shade-texture
> ruling throughout. Keep it tight.

## Goal

`waterfall` is NOT locked to chitra's reference design language and carries the
audit's last open P0 rendering bug plus the P1 language gaps (STATE.md bug queue,
audit §3.5): (1) **negative deltas render as flat dashes on the baseline**
(`COGS −120`, `OpEx −60` indistinguishable from zero — the chart cannot tell its
story); (2) **decimal y-labels** (`392.86` on a money axis the mockup prints as
integers); (3) a **`theme.colors[i]` rainbow** (positive/negative/total each a
different bright hue) instead of mudra's tonal semantics; (4) no panel, no step
connectors, no signed delta labels. Apply the locked S18–S25 language: dashed
panel + eyebrow + rules + foot, one accent spent exactly once, grey tone ramp
with shade texture so kind survives `stripAnsi` / `noColor`.

## Named references (read ONLY these — do not scan the repo)

- `packages/core/src/charts/histogram.ts` — the S25 locked playbook (panel
  composition, `width`-is-floor auto-expand, integer y-labels, `│`/`+` y-guide,
  dashed `└╌` baseline, accent-once census shape, degenerate-safe pattern).
- `packages/core/src/charts/timeline.ts` — the shade-ramp texture method and the
  raw-ANSI accent-census test pattern to mirror.
- `packages/core/README.md` → `### LOCKED: histogram chart — session 25 design`
  — the written contract style to mirror.
- `design-reference/mudra-audit.md` §3.5 — the directional mockup (outlined
  down-boxes, tonal kinds, `┄` connectors, signed labels, integer labels,
  `NET` metric, `┸` baseline, `●` foot). Where the mockup and the locked family
  vocabulary differ, the family vocabulary wins (`│`/`+` y-guide; facts in the
  foot row, not an eyebrow-right metric cell; 1-col gaps; accent spent exactly
  once — up-delta labels stay in the label tone, not accent).
- `design-reference/mudra-audit.md` §3.4 — the funnel directional mockup
  (arrows deleted, left-anchored rows, `▓` rounded-cap stand-in, tone descent,
  integer percents, `CONVERSION` metric cell, `BIGGEST DROP` foot). Same
  family-wins rule (accent exactly once — on the peak stage, per the
  bar/timeline peak rule; facts in the foot row).

## Acceptance A — waterfall (testable, EARS-style)

1. WHEN `waterfall` renders a negative delta, THEN it renders a visible dashed
   outline box (`┌╌╌┐` top / `│  │` sides / `└╌╌┘` bottom; a sub-row delta
   renders at minimum one `┌╌╌┐` row) — never a flat `─` dash on the baseline.
   The P0 flat-dash bug is retired by design.
2. WHEN `waterfall` renders, THEN kinds are tonal, never rainbow: Start and
   Total are solid `█` (Start on the darkest grey tone, Total in the theme's
   accent hue, spent EXACTLY once); up-steps are solid `▓` on a mid grey tone;
   down-steps are the dashed outline on a light grey tone. No `theme.colors[i]`
   flood, ever. Verified at raw-ANSI level (accent only on solid `█` segments
   plus non-block text; zero non-ramp/non-accent bar segments).
3. WHEN `waterfall` renders, THEN it carries the locked panel: dashed frame
   (`┌╌…╌┐` / `└╌…╌┘`), uppercase eyebrow (`WATERFALL`, or `opts.title`
   uppercased), a signed-delta label row above the plot (`+80` / `−120` per
   column), dashed `┄` connectors at each running level in the 1-col gaps,
   integer y-labels with the `│`/`+` guide, a dashed `└╌…╌` baseline, truncated
   step labels under their columns, and two `│ ╌…╌ │` rule separators. Panel
   width auto-expands (explicit `width` is a floor, min bar width 3 so outlines
   stay legible).
4. WHEN the summary renders, THEN the foot row reports
   `START <v> · Δ <signed…> · TOTAL <v>` with the `TOTAL` fact in the accent
   hue — facts true for the given data, never fabricated.
5. WHEN the input is degenerate, THEN it renders safely and honestly: empty
   data renders a framed `TOTAL 0 · (no data)` panel with null JSON step facts;
   all-zero deltas render empty columns (never outlines, never fills); no
   `NaN`/`Infinity` anywhere.
6. WHEN `toJSON()` is called, THEN it returns the original keys (`type`,
   `data`, `labels`, `total`, `plain`) plus additive `steps` (per-bar
   `{ label, delta, start, end, kind }`, `kind` in `start|up|down|total`, empty
   array when there is no data). No existing key is removed; the public
   `WaterfallOptions` shape is unchanged (`positiveColor` / `negativeColor` /
   `totalColor` stay accepted as user overrides of the locked tones).
7. `packages/core/README.md` carries a `### LOCKED: waterfall chart — session
   26 design` block stating the rules above (mirroring the S25 block's style).
8. `scripts/verify-session-26.sh` exits 0 (P0 outline-box proof incl. sub-row
   minimum, raw-ANSI tonal census, integer y-labels, panel chrome, connectors +
   signed labels, footer format, degenerate-safe, no-`theme.colors` source
   check, core tests + typecheck, README block, docs chart-drift gate, branch
   check) and `scripts/demo-session-26.sh` exits 0 with live renders +
   falsifiable checks.
9. The docs catalog preview regenerates in sync (`gen:charts:check` green);
   the full core suite stays green (the two legacy waterfall assertions keep
   passing against the honest contract); zero runtime deps.

## Acceptance B — funnel (testable, EARS-style)

10. WHEN `funnel` renders, THEN no `▼` arrow connector appears anywhere; every
    stage row is CENTERED in a shared field, top-wide → bottom-narrow — the
    symmetric silhouette every major library (ECharts, PowerBI, Highcharts,
    Evidence, Atlassian, Wikipedia) defines as the funnel identity. This
    REVERSES audit §3.4 item 2 (left-anchored rows read as a horizontal bar
    chart) by founder order, on industry research record. Centered boxes, never
    tapered slopes; labels stay in a fixed left column. The stage with the
    highest value (ties → first, the family peak rule) renders a solid `█` run
    in the accent hue, spent EXACTLY once; every other stage sits on the
    descending grey tone ramp with its matching shade glyph (`░ ▒ ▓` by share
    of the peak) plus one `▓` rounded-cap stand-in at the bar end. No
    `theme.colors[i % n]` rainbow, ever (raw-ANSI census).
11. WHEN `funnel` renders, THEN it carries the locked panel: dashed frame, an
    uppercase `CONVERSION <pct>%` metric eyebrow, integer percent labels
    (`68%`, never `68.0%`), two rule separators, and a foot row reporting
    `IN <v> · OUT <v> · CONVERSION <pct>% · DROP <label> −<pct>%` with the
    `CONVERSION` fact accented. Width is a floor (auto-expand, never clip).
12. WHEN the input is degenerate, THEN empty renders a framed
    `STAGES 0 · (no data)` panel with null `conversion`/`biggestDrop`; a zero
    first stage reports `n/a` conversion (never div-by-zero `NaN`).
    `toJSON()` keeps `conversionRates` plus additive `conversion` and
    `biggestDrop`; `FunnelOptions` unchanged.

## Acceptance C — sankey (testable, EARS-style)

13. WHEN `sankey` renders, THEN no `▶` arrow decoration appears; the peak flow
    (highest value, ties → first) renders a solid `█` run in the accent hue,
    spent EXACTLY once; every other flow sits on the grey tone ramp with its
    matching shade glyph (`░ ▒ ▓` by share of peak). The node ledger keeps
    `in:`/`out:` facts with toned `■` marks ordered by total flow. No
    `theme.colors[i % n]` rainbow, ever (raw-ANSI census).
14. WHEN `sankey` renders, THEN it carries the locked panel: dashed frame, an
    uppercase `FLOW <total>` metric eyebrow, two rule separators, and a foot
    row reporting `NODES <n> · LINKS <m> · PEAK <src> → <tgt> <v>` with the
    peak value accented. Empty links render a framed `NODES 0 · (no data)`
    panel with null `peakFlow`. `toJSON()` keeps `nodes`/`links` plus additive
    `peakFlow`; `SankeyOptions` unchanged.

## Acceptance D — radar (testable, EARS-style)

15. WHEN `radar` renders, THEN the primary series (series 0) draws slope-aware
    thin edges (`─ │ ╲ ╱`), a `·` stipple fill, and solid `●` vertices in the
    accent hue, spent EXACTLY once; every other series draws a DASHED edge in
    its grey tone with hollow `○` vertices and no fill. No `theme.colors[si]`
    rainbow, ever (raw-ANSI census). The grid is five dashed hex rings with
    `+` ticks and dashed spokes; the `0..<max>` scale rides the eyebrow;
    every axis label prints unclipped beside the web.
16. WHEN `radar` renders, THEN it carries the locked panel: dashed frame, an
    `AXES <n> · SERIES <m>` eyebrow, a multi-series glyph legend, two rule
    separators, and a foot row reporting `AVG <v> · PEAK <axis> <v>` with the
    peak value accented. Empty axes render a framed `AXES 0 · (no data)` panel
    with null `max`/`avg`; negatives and non-finite samples collapse to the
    center. `toJSON()` keeps `data`/`labels` plus additive `max`/`avg`;
    `RadarChartOptions` unchanged.

## Acceptance E — gates

17. `packages/core/README.md` carries `### LOCKED` blocks for waterfall,
    funnel, sankey, and radar (S25 style).
18. `scripts/verify-session-26.sh` exits 0 (waterfall criteria 1–12 PLUS funnel
    chrome/no-arrows/tonal-census/integer-pcts/foot/degen, sankey
    chrome/no-arrows/tonal-census/ledger/foot/degen, radar
    chrome/tonal-census/markers/foot/degen, source-locked across all five,
    core tests + typecheck, all README blocks, docs drift gate, branch check)
    and `scripts/demo-session-26.sh` exits 0 with live funnel + sankey +
    radar renders and falsifiable checks.
19. Docs previews regenerate in sync (`gen:charts:check` green); the full core
    suite stays green (legacy assertions keep passing); the rebuilt `dist/`
    carries all five locks (the docs playground executes `dist`, not `src`);
    zero runtime deps.

## Session constraints (constitution)

- Five stories by founder direction (1-story rule waived, disclosed). Max 3
  them with `VAJRA_ALLOW_COMMIT=26`, or gives an in-chat approval token per
  `CONSTRAINTS.yaml commit.approval_tokens`). Verify exit 0 required.
  Independent cold fidelity review owed post-commit
  (`sessions/session-26-review.md`, per `reviewer/SKILL.md`) before ACCEPT.
