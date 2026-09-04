# Session 19 — lock the `horizontalBar` chart to the reference/panel design language

> **Type: CODE.** Branch `session-19-horizontalbar-lock` (already created). This session is the
> governed BUILD half of Vajra's S144 full-loop dogfood: a native chitra session, driven by chitra's
> OWN fleet + hooks, run to a green `verify-closeout.sh`. Keep it tight.

## Goal

`horizontalBar` is the last chart family NOT locked to chitra's reference design language (the mudra
review flagged it: "NOT locked (pre-mudra)" — no frame, no eyebrow, `░` phantom filler, rainbow
`theme.colors[i % n]`). Its sibling `bar` was locked in S12 and is the exact reference. Rotate that
locked language to the horizontal orientation.

## Named references (read ONLY these — do not scan the repo)

- `packages/core/src/charts/bar.ts` — the S12 locked reference implementation (accent-once, grey ramp,
  panel chrome, `+` guide/ticks, summary rows, auto-scale, space-fill).
- `packages/core/README.md` → `### LOCKED: bar chart — session 12 design` — the written contract.
- `packages/core/src/charts/horizontalBar.ts` — the target to rewrite (currently rainbow + `░` fill).
- `packages/core/src/renderers/blocks.ts` — `buildHorizontalBlockBar` (the horizontal bar renderer).

## Acceptance (testable, EARS-style)

1. WHEN `horizontalBar` renders, THEN exactly ONE bar — the one with the globally highest value — is
   drawn in the theme's accent hue, and EVERY other bar uses the grey tone ramp
   (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`). No `theme.colors[i % n]` rainbow, ever. Verified at
   raw-RGB level (accent count == 1, no other accent-hued cells).
2. WHEN `horizontalBar` renders, THEN it carries the same panel language as the locked families:
   dashed frame, uppercase letter-spaced eyebrow, a value-axis guide with the `+` tick language, and
   the rule separators — matching `bar`'s chrome rotated to horizontal.
3. WHEN a bar cell is empty, THEN it is a SPACE — the plot never writes the `░` phantom filler.
4. WHEN values are shown, THEN each item's value label is rendered, and the peak item's value is in the
   accent hue (mirroring bar's summary accent).
5. WHEN no explicit range is given, THEN the value axis auto-scales (`min(0, dataMin)` baseline) and the
   panel width auto-expands so the longest label/value is never clipped.
6. WHEN degenerate input is given (empty data, all-equal values, single item), THEN it renders safely
   (no crash, no NaN, deterministic accent tie-break = first max in data order).
7. `packages/core/README.md` carries a `### LOCKED: horizontalBar chart — session 19 design` block.
8. `scripts/verify-session-19.sh` exits 0 (with a raw-RGB accent-count assertion + a no-`░` assertion),
   `scripts/demo-session-19.sh` shows the before/after, and `pnpm --filter @chitra/core run test` is green.

## Guardrails

- **Dispatch the tech-lead FIRST** (mandatory) and let its `required` verdict bind the crew; every role
  it marks `required` must produce a real governed handoff (`vajra next --role <name> --from <file>`) or
  the close cannot go green (the S139 gate — restored to chitra's `verify-closeout.sh` for this run).
- **Budget every subagent dispatch TIGHT: named files only, never "read the repo"** (Vajra S134).
- Max 3 files per atomic commit (hook-enforced); commit only with the founder marker in the launch env.
- Do NOT touch `sparkline`/`histogram` or any other chart — this is the one story.
- Public API stays stable (`toPlain()`/`toJSON()` output preserved); zero runtime deps.

## Delta (vs ROADMAP)

- `+` `horizontalBar` joins the locked family (circular S09 · area S09 · line S10 · bar S12 · scatter S17
  · heatmap S18) — the last unlocked chart, closing the reference-language migration for the core set.
