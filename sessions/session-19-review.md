# Session 19 — Independent Fidelity Review

**Reviewer:** fidelity-reviewer (cold, adversarial pass — dispatched as a governed crew role,
fed only the contract prompt + the delivery diff; did not build the code).
**Contract:** `prompts/19-task-horizontalbar-lock.md` (8 EARS acceptance criteria).
**Method:** every verdict verified against committed source (`horizontalBar.ts`,
`horizontalBar.test.ts`, `README.md`, `verify-session-19.sh`, `demo-session-19.sh`, regenerated
docs artifacts); verify + tests re-run. Verify, don't trust.

## Per-requirement verdict

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | Exactly one accent bar (global max), all others grey ramp, no `theme.colors[i%n]` rainbow; raw-RGB accent count == 1 | SHIPPED | `horizontalBar.ts:33-40` computes `accentIdx` via strict `>` (first-max wins); `buildBarRows` colors `isPeak ? acc : grey` (`grey = tones[2]`). No `theme.colors[` in the file. `GREY_TONES` = exact ramp `#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`. Real raw-RGB test counts `\x1b[..m(?=█)` codes == 1 and rejects rainbow across all 7 themes; accent ∉ tones for every theme, so isolation is valid. |
| 2 | Same panel language rotated to horizontal: dashed frame, uppercase eyebrow, `+`-tick value-axis guide, rule separators | SHIPPED | `buildLines` uses `frameTop/frameRule/frameRow/frameBottom` (same helpers as `bar.ts`); eyebrow `(xLabel ?? "VALUES").toUpperCase()`; `buildAxisGuide` emits `+╌…╌+`; two `frameRule` separators. Prose "letter-spaced" is not literally letter-spaced in code, but matches the S12 reference behaviour the criterion demands parity with. |
| 3 | Empty cell = SPACE, never `░` phantom filler | SHIPPED | Both blocks and ascii paths pass explicit `" "`, overriding the renderer's `░` default. Tests assert no `░` in either renderer; demo greps the live AFTER render (data includes a 0 cell). |
| 4 | Each value label rendered; peak value in accent hue | SHIPPED | `buildBarRows` renders `padStart(formatNumber(v))` per item, `colorize(..., isPeak ? acc : label)`. Test asserts `accent + "47"`; summary `max` also accented + `peak <label>`. |
| 5 | Auto-scale `min(0,dataMin)` baseline + auto-width so longest label/value never clipped | SHIPPED | `yMin = opts.yMin ?? Math.min(0, dataMin)`; `effectiveWidth` Math.max includes label+bar+value, eyebrow, and `summaryPlain.length + 4`. Test asserts a long label survives and the row ends with `│`; baseline `│ 0 … 30 │` asserted. |
| 6 | Degenerate input (empty / all-equal / single) safe, no NaN; tie-break = first max | SHIPPED | `hasData` guards; `minMax` skipped when empty. Tests cover empty (`n 0`, no NaN), single, all-equal, and a two-maxima tie asserting `peak b` + accent count 1. Verify + demo render all three live. |
| 7 | README `### LOCKED: horizontalBar chart — session 19 design` block | SHIPPED | Heading present verbatim with a full rules block; verify greps the exact heading. |
| 8 | verify-session-19.sh exit 0 (raw-RGB accent + no-`░`), demo before/after, core test green | SHIPPED | verify runs core tests, typecheck, a rendered raw-RGB accent==1 check, a rendered no-`░` check, degenerate, drift gate, and the demo (11/11 GREEN). Demo shows an honest reconstructed BEFORE vs a live AFTER with falsifiable checks. Core 217/217. |

**Count: 8 of 8 SHIPPED.**

## Fakest green

Criterion 5's auto-width clause ("longest label/value never clipped"). The auto-width test
proves only the *label* row ends at the frame border — it never asserts the *summary/value*
edge fits. The `effectiveWidth` guard does include `summaryPlain.length + 4`, so the auto path
is genuinely safe, but the committed docs preview originally pinned `width: 52` and its summary
row overran the right border — a blind spot the test would not catch. The builder addressed
this (dropped the explicit width; the regenerated preview now sits cleanly inside the frame),
so the visible defect is gone, but the *test* still asserts only the label edge. Non-blocking
(explicit width is out of criterion-5 scope), recorded as a follow-up.

The verify script's `source-locked` grep (`theme.colors[` absence) is a proxy, but it is backed
by the real rendered `raw-rgb-accent-count-1` check, so it is not load-bearing on its own.

## Attestation

Review-Inputs-SHA: 28172d8a92e4b57f71b8ef3ec1cb554e0412f8daf03fbc988ca5e7caa4b69657

**Verdict:** ACCEPT
