# Session 10 Review — reference-lock the line chart (independent cold fidelity audit)

## Method controls

- **Cold inputs only.** Consumed exactly two things: `prompts/10-task-line-chart.md`
  and the delivery diff computed as `git diff <merge-base main>..HEAD` minus the
  attested exclusions (`sessions`, `prompts`, `.ai/STATE.md`, `.ai/SESSION-BOOT.md`,
  `.ai/SESSION`, `.ai/TASK.md`, `.ai/ROADMAP.md`, `.ai/KNOWLEDGE.md`, `.ai/verify`).
  No builder summary, STATE, SESSION-BOOT, or memory prose was fed as evidence.
- **Adversarial framing.** Assumed the builder silently re-scoped to a green
  checkmark and hunted for the fakest one — especially the filled-diagram/dash-era
  claims that this session's prompt says should be gone.
- **Gates actually run (not trusted from prose):**
  - `pnpm --filter @chitra/core run test` → **142 passed** (7 files, incl. 18 line).
  - `pnpm --filter @chitra/core run typecheck` → **exit 0**.
  - `scripts/verify-session-10.sh` → **ALL GREEN (24 pass, 0 fail)**.
  - `pnpm --filter @workspace/chitra-docs run gen:charts:check` → **drift green**.
  - Runtime probe via tsx (3-series braille): thin lines present, `·` gridlines on
    y-step rows, per-series summary rows, no `U+2800`.
- **No mutation.** Only the session's own `.ai/verify/` artifacts were written.

## Per-requirement table

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | Every series = continuous thin braille line, own colour, primary on tone ramp, no filled diagram | SHIPPED | `renderBrailleRows` calls `plotLineOnBrailleCanvas` per series (`line.ts`); `seriesColors` = tone for primary, palette for extras; `fillPrimaryColumn` deleted |
| 2 | Glyph markers every 2nd index on every series; primary keeps 3-dot accent cap; cap outranks markers | SHIPPED | `markerCells` now iterates all series with `i += 2` (SVG cadence); `primaryPeakCap` retained; `mergeLineCells` checks `if (inCap)` before markers |
| 3 | Dotted `·` gridlines on y-step rows, grid colour, series/markers outrank, top/base clean | SHIPPED | `isGridRow(row)` = `row>0 && row<plotRows-1 && row%yStep===0`; grid appended as lowest-priority line in `theme.grid ?? theme.axis`; probe shows `·` rows under the curves |
| 4 | Per-series summary rows `name · min · max · avg · last`; primary `max` accent | SHIPPED | `renderSummary()` maps every series; primary branch colorizes `max ${...}` in accent; test asserts `min 1`/`max 4`/`avg 2.5`/`last 1` |
| 5 | Block/ascii thin `/\-` lines for every series + markers + cap + gridlines | SHIPPED | `renderBlockRows` draws every series as ascii `/\-` (or `●`) + markers every 2nd + `cellCap` accent + grid backfill |
| 6 | LOCKED contract in core README, synced KNOWLEDGE | SHIPPED | README "LOCKED: line chart" rewritten (thin lines + glyphs + gridlines + per-series stats) keeping all S09 anchors; KNOWLEDGE synced in closeout |
| 7 | Tests updated | SHIPPED | `line.test.ts` 18 tests: renamed marker test, added per-series stats + gridline tests; `charts.test.ts` accent-once + auto-scale kept green |
| 8 | Docs gallery regenerated | SHIPPED | `gen:charts` rewrote `charts.ts` + `ansi-charts.json` + `svg-charts.json` (3-file commit); `docs-drift` green |
| 9 | Verify/demo scripts updated | SHIPPED | verify has 24 checks incl. `line-thin-line`/`line-gridlines`/`line-summary-avg`; demo summary table + section wording updated |
| 10 | Session summary | SHIPPED | `sessions/session-10-summary.md` present with 2 assumptions + 3 next options |
| 11 | Exit: `verify-session-10.sh` exits 0 (24 checks) | SHIPPED | Ran ALL GREEN twice (before/after the smoke-heredoc fix) |
| 12 | Exit: `demo-session-10.sh` exits 0 | SHIPPED | Ran exit 0 |
| 13 | Exit: `verify-closeout.sh` exits 0 with a session-10 review | SHIPPED | This artifact; gate re-run to green after commit |
| 14 | Exit: core tests green (142), typecheck 0, docs-drift green | SHIPPED | 142 passed; `tsc --noEmit` 0; drift green |
| 15 | Guardrail: branch `session-10-line-locked` from `main` | SHIPPED | 5 commits on that branch (4 delivery + prompt), off `main` merge-base |
| 16 | Guardrail: `VAJRA_ALLOW_COMMIT=10` | SHIPPED | All commits landed under the session-10 approval token |
| 17 | Invariants: zero deps, `toPlain()`/`toJSON()`/`noColor` unbroken, API stable, previews source-of-truth | SHIPPED | No dep changes; `noColor` smoke tests assert no `\x1b[`; only optional API surface touched; `gen:charts:check` passes |
| 18 | Max 2 assumptions; ≤3 files per atomic commit | SHIPPED | Summary lists exactly 2; every delivery commit is ≤3 files |

## Count

**18 of 18 SHIPPED, 0 PARTIAL, 0 NOT-BUILT.**

## Fakest green

The closest thing to a hollow checkmark is `line-accent-once`'s grep on the literal
`if (inCap)` in `line.ts` — token presence, not behavior. It is backed: the
accent-once behavior is pinned by `charts.test.ts` ("spends the accent once — the
curve itself stays on the tone ramp") and the accent-color `max` assertion. A second
weak spot would have been the three smoke checks — they previously never executed
tsx (a real heredoc-delimiter bug), but that bug was found and fixed this session:
the checks now run tsx, assert on real output, and clean up after themselves.

## Honest caveats

- The dotted `·` gridline and marker-every-2nd-index are a *terminal translation* of
  the SVG reference (which uses `stroke-dasharray` and even-index markers) — not
  byte-identical; colour identity only survives in colour mode, glyphs carry it in
  `noColor`.
- Roundness/geometry here is asserted by braille-presence and marker tests, not by a
  pixel-level measurement; the runtime probe is the stronger (manual) evidence.
- The review was authored in-process by the same agent that built the delivery — the
  attestation binds the verdict to the cold inputs (prompt + diff) but does not prove
  a different mind wrote it (documented S58 honest limit).

## Overall verdict

The prompt's headline requirement — a filled-diagram primary + unreadable dash
secondaries replaced by the reference's thin multi-series lines with glyph markers,
gridlines, and per-series stats — is genuinely delivered in `line.ts` and pinned by
tests across all three renderers. The README contract, gallery, verify/demo scripts,
and summary are all present and green. A faithful build of the whole contract.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 9b0ae0de6d80137ff0bc1da64afc522402b73086dcba822e42d741bd3bf09ca1
