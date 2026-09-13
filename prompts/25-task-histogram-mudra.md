# Session 25 — lock the `histogram` chart to the mudra reference/panel design language

> **Type: CODE.** Branch `session-25-histogram-mudra`. One story: migrate the next
> un-migrated chart family to the locked panel language — per the audit's own P1
> queue (`design-reference/mudra-audit.md` §5), that is `histogram` (funnel and
> waterfall follow). Founder ask, 2026-09-13: "migrate the next available chart to
> mudra design system like you did previously." Carry the 2026-09-11 shade-texture
> ruling (░▒▓ texture on the bars; the accent is the solid `█`). Keep it tight.

## Goal

`histogram` is NOT locked to chitra's reference design language and carries two
live bugs the audit and STATE.md both flag: (1) **decimal y-labels on a count
axis** (`36.56`, `26.11` — counts are integers; the axis lies), and (2) a
**`theme.colors[0]` accent flood** — every bar in the same bright hue, the only
core chart that ignores the tone system entirely. It also predates the panel
language: no frame, no eyebrow, no summary, solid `─────` baseline. Apply the
locked S18–S23 language: the S12 `bar` orientation for a binned distribution,
with the heatmap/timeline shade-texture ramp.

## Named references (read ONLY these — do not scan the repo)

- `packages/core/src/charts/bar.ts` — the S12 locked orientation reference
  (integer-rounded y-labels, `│`/`+` y-guide, plot-row build, panel chrome).
- `packages/core/src/charts/timeline.ts` + `packages/core/src/charts/progress.ts`
  — the shade-ramp texture method (`░▒▓█` by bucket, accent spent exactly once).
- `packages/core/tests/timeline.test.ts` — the raw-ANSI accent-census test
  pattern and degenerate-input suite to mirror.
- `packages/core/README.md` → `### LOCKED: progress chart — session 23 design`
  — the written contract style to mirror.
- `design-reference/mudra-audit.md` §3.3 — the directional mockup (panel,
  tone semantics, integer labels, metric foot). Where the mockup and the locked
  family vocabulary differ, the family vocabulary wins (`│`/`+` y-guide, not
  `┈`; facts in the foot row, not an eyebrow-right metric cell; 1-col gaps).

## Acceptance (testable, EARS-style)

1. WHEN `histogram` renders, THEN the bin with the highest count (the MODE bin;
   ties → first bin in bin order, deterministic — the same rule as
   bar/timeline/horizontalBar) renders a solid `█` column in the theme's accent
   hue, spent EXACTLY once; every other bin sits on the grey tone ramp with its
   matching plain-text shade glyph (`░ ▒ ▓ █`, light → dark by the bin's share
   of the modal count — the heatmap/timeline texture language, so the density
   survives `stripAnsi` / `noColor`). No `theme.colors[i % n]` flood, ever.
   Verified at raw-ANSI level (accent only on solid `█` segments, zero
   non-ramp/non-accent bin segments).
2. WHEN `histogram` renders, THEN it carries the same panel language as the
   locked families: dashed frame (`┌╌…╌┐` / `└╌…╌┘`), an uppercase eyebrow row
   (`DISTRIBUTION`, or `opts.xLabel` uppercased when given), a dashed `└╌…╌`
   baseline, bin-start labels under their columns in the label tone, and two
   `│ ╌…╌ │` rule separators. Bars stay thin (width ≥ 3 where the panel allows)
   with real 1-col gaps. Panel width auto-expands so the eyebrow, bin labels,
   and summary are never clipped (an explicit `width` is a floor, not a cap).
3. WHEN the y-axis renders, THEN its labels are INTEGER counts (the decimal
   count-label bug is retired) and its guide uses the locked `│`/`+`
   vocabulary (a `+` tick on the top row).
4. WHEN the summary renders, THEN the foot row reports
   `n <count> · mode <value> · p50 <value> · p99 <value>` with the `mode` fact
   in the accent hue, the percentiles nearest-rank over the sample — facts true
   for the given sample, never fabricated.
5. WHEN the input is degenerate, THEN it renders safely and honestly: empty or
   all-non-finite data renders a framed `n 0 · (no data)` panel (no fabricated
   bin labels) with null JSON facts; a collapsed range (every value equal)
   lands every sample in the first bin; non-finite samples are excluded from
   the distribution — no `NaN`/`Infinity` anywhere.
6. WHEN `toJSON()` is called, THEN it returns the original keys (`type`,
   `data`, `bins`, `binCounts`, `title`, `plain`) plus the additive `mode`,
   `p50`, `p99` (null when there is no data) and `count` (the number of samples
   actually binned). No existing key is removed; the public
   `HistogramOptions` shape is unchanged.
7. `packages/core/README.md` carries a `### LOCKED: histogram chart — session
   25 design` block stating the rules above (mirroring the S23 block's style).
8. `scripts/verify-session-25.sh` exits 0 (raw-ANSI accent census, integer
   y-labels, panel chrome, ramp-survives-noColor, footer format incl.
   nearest-rank percentiles, degenerate-safe, no-`theme.colors` source check,
   core tests + typecheck, README block, docs chart-drift gate, branch check)
   and `scripts/demo-session-25.sh` exits 0 with live renders + falsifiable
   checks.
9. The docs catalog preview regenerates in sync (`gen:charts:check` green)
   with the locked render; the full core suite stays green (the two legacy
   histogram assertions keep passing against the honest contract); zero
   runtime deps.

## Session constraints (constitution)

- One story. Max 3 files per atomic commit. No autonomous commits (founder runs
  them with `VAJRA_ALLOW_COMMIT=25`, or gives an in-chat approval token per
  `CONSTRAINTS.yaml commit.approval_tokens`). Verify exit 0 required.
  Independent cold fidelity review owed post-commit
  (`sessions/session-25-review.md`, per `reviewer/SKILL.md`) before ACCEPT.
