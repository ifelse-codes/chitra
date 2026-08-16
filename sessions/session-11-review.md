# Session 11 — Independent cold fidelity review

## What this file is, and what it is not

Cold passes by `subagent_type: "fidelity-reviewer"` subagents, none of them the agent that
wrote the code. **Nine passes rendered a verdict; all nine REJECTED.** The tenth is the
verdict of record.

**A structural note this ledger owes the reader.** This file is written *before* the pass
that judges it, so its own count can never include that pass — and three consecutive passes
correctly flagged the resulting off-by-one as a false claim. The count below is therefore
stated as *verdicts rendered so far*, and the closing verdict line is transcribed from the
pass that follows it. Reading this table as a complete history of its own review is a
category error the ledger cannot fix from the inside.

**Passes 1 and 2** were fed only the session prompt plus the branch diff. **Passes 3–10**
were *targeted re-checks*: each was given the prior pass's findings by name and, from
pass 4 onward, a diff that included this file. That is weaker independence than passes 1–2
and is stated here rather than implied away.

The original in-session "cold fidelity review" is **not** part of this record. It was a code
read by the same session that wrote the code, and it certified a page broken on 19 of 20
charts. It is retained, unedited and banner-warned, as
`sessions/session-11-review-INVALID-self-read.md`.

**An earlier version of this file recorded two REJECTs, logged the third pass as "see
below", and then ended with a self-authored ACCEPT verdict line — written by me, the side doing
the remediation.** Pass 4 named that as the fakest green in the whole delivery, and it was
right: a verdict line contradicting the verdicts on its own page is precisely the failure
this session exists to document. **No verdict in this file is authored by me.** Each row
below is the verdict a cold pass actually rendered, and the closing verdict line is the
final pass's own, transcribed.

## Verdict of every pass

| Pass | Independence | Verdict | Grade |
|---|---|---|---|
| 1 | prompt + diff only | **REJECT** | 6 of 8 SHIPPED, 2 PARTIAL |
| 2 | prompt + diff only | **REJECT** | 6 of 8 SHIPPED, 2 PARTIAL — code accepted, record rejected |
| 3 | targeted re-check | **REJECT** | 3 of 7 remediation items done; record still false |
| 4 | targeted re-check | **REJECT** | 7 of 8 SHIPPED, 1 PARTIAL — code accepted, review artifact rejected |
| 5 | targeted re-check | **REJECT** | 7 of 8 SHIPPED, 1 PARTIAL — code accepted; caught a fabricated evaluation count in this file |
| 6 | targeted re-check | **REJECT** | 7 of 8 SHIPPED, 1 PARTIAL — code accepted; found a live undisclosed defect (the footer mislabelling its own run), an anti-shrink pin that could not detect a shrunken input set, and a pass count rounded down in `.ai/TASK.md` |
| 7 | targeted re-check | **REJECT** | 7 of 8 SHIPPED, 1 PARTIAL — found a second panel mislabelling its own run (`output.txt` after a failed run) |
| 8 | targeted re-check | **REJECT** | 7 of 8 SHIPPED, 1 PARTIAL — found two more instances of the same class (unlabelled terminal placeholder; empty copy/download payloads) and diagnosed the pattern: *fixes keep landing on the named instance, not the class* |
| 9 | targeted re-check | **REJECT** | 6 of 8 SHIPPED, 2 PARTIAL — confirmed the diagnosis: `resolveOutput()` consolidated three surfaces and left the footer, the pill, `runMs` and an unawaited clipboard promise outside it |
| 10 | targeted re-check | see the closing verdict line | verdict of record |

## Per-criterion grades (pass 4, the most complete grading pass)

| # | Criterion | Verdict | Evidence the reviewer relied on |
|---|---|---|---|
| 1 | Two-panel view for every chart, resizable split | SHIPPED | `PanelGroup` / `Panel defaultSize={50} minSize={20}` / `PanelResizeHandle`; `ChartPage` reduced to `return <CatalogPage chart={chart} />`, so every chart routes through it |
| 2 | Vim buffer: gutter, current-line hl, `~`, block cursor, TS syntax, tabs, modeline | SHIPPED | `.vim-block-cursor` 1ch overlay with `data-mode` + `caret-color: transparent`; stripe at `VIM_PAD + (curLine-1)*LINE_H - scrollTop`; gutter scroll-synced; single-pass `TOKEN_RE` tokenizer; 3 tabs; full modeline |
| 3 | Terminal preview: title bar + pill, `$` prompt, ANSI output, exit/timing footer | SHIPPED | `term-titlebar` + `term-pill-*`, `$ tsx example.ts`, `ansiToHtml`, `term-footer`. Ships without the brief's literal `[ ]` brackets — cosmetic |
| 4 | Run executes chitra in-browser; edits change output; errors caught | SHIPPED | `evalCode` → `new Function(...keys, buildFnBody(...))(...vals)`, exercised by the check suite; broken buffer asserted to yield `exitCode !== 0` with a message |
| 5 | Toolbar: Run, Copy ×2, Download ×2, Renderer, Theme, Reset | SHIPPED | All nine controls wired to real handlers. **Verification-thin: zero automated coverage; the `Reset` repair has none at all** |
| 6 | Core tests, both typechecks, drift gate green; core byte-identical | SHIPPED | Zero `packages/core` hunks in the entire branch diff; `core-output-locked` asserts it mechanically |
| 7 | verify exits 0, demo exits 0 | SHIPPED | Demo is falsifiable: `fail()` sets `DEMO_FAILED=1`, terminal `exit 1`, all three previously-unconditional `ok`s given `else fail` branches, summary rows derived from the executable check |
| 8 | Summary maps each criterion; review is an independent cold fidelity review | PARTIAL | Summary half done. Review half was rejected at pass 4 for the self-authored ACCEPT; this rewrite is the response |

## The measurements, re-run rather than carried

`scripts/check-catalog-examples.ts` is **103 checks**, backed by **121 real invocations** of
the shipped `evalCode` — counted from the five call sites in the file: 20 baseline + 60
renderer (3 × 20) + 40 theme-comparison (2 × 20) + 1 broken buffer. The other 22 checks are derived
assertions — 20 regexes on the rewritten source, and 2 comparing outputs the 121 invocations
already produced (so "derived", not "unexecuted").

**This paragraph has been wrong twice, and both errors are the session's own lesson landing
on its author.** Draft 1 said "102 real evaluations" (checks counted as evaluations). Draft 2
said "121 real invocations (20 + 60 + 40 theme-comparison + 1)" while the theme loop had been
DELETED — a number carried across the change that removed it, inside the section written to
prove numbers are measured. Cold pass 5 caught it by reading the code rather than the prose.
The theme loop was then restored with real teeth at pass 6, so 121 is now true — but it is
true because it was re-counted from the five call sites, not because the earlier draft was
right.

Falsifiability, **re-measured against the current code**, not carried forward:

| Mutation | Result |
|---|---|
| `injectOpt` returns `code` unchanged | **81 / 103** |
| `injectOpt`'s INSERT branch only made a no-op (the 19-of-20 shape) | **82 / 103** |
| unmutated | **103 / 103** |

An earlier draft claimed 83 for the second shape. That figure was measured before the
output-differs floor was pinned to 5, and was carried across the very tightening it
described — the same staleness class this review keeps catching. Pass 4 caught it by
arithmetic before the re-run confirmed it.

## What is still short, in the final state

- **No DOM or browser test exists.** Criteria 1, 2, 3 and 5 rest on source greps plus
  screenshots captured during the governing Vajra session (`sessions/session-118-artifacts/
  screenshots/` in the **vajra** repo — not committed here, so from this repo's diff alone
  those four criteria are backed by greps and prose).
- **Nine of the sixteen verify checks are source greps**, each suffixed `-SOURCE-GREP` so
  the suite stops presenting a read as a verification.
- **Theme coverage is 3 of 7 executed** (`default`, `nord`, `monochrome`); four themes are
  never run. The theme path now has an end-to-end assertion — it had none until pass 6
  named it the fakest green in the delivery.
- **`LINE_H` / `VIM_PAD` duplicate CSS custom properties**, bound only by a comment.
- **`catalog-repairs-present-SOURCE-GREP` is the only guard on criterion 2's repairs and it
  guards nothing that renders** — it would pass over a `CatalogPage` that returns `null`.
  Four of the eight criteria are backed by nothing that ever renders the component.
- **The signature defect class — a panel reporting a run it did not do — took four passes
  to close**, because each fix landed on the named instance: the footer (pass 6), the
  `output.txt` tab (pass 7), the terminal placeholder and copy/download payloads (pass 8),
  and finally the unawaited clipboard promise, the stale `runMs`, and a `data.ts` tab
  reading the pristine source instead of the edited buffer (pass 9). That progression is
  the most useful thing this session produced.
- **`resolveOutput()` itself has no executable coverage.** Replace its body with
  `return { text: plainOut, ok: true }` and all 103 catalog checks and 16 verify checks
  stay green. The headline class-fix is guarded by nothing — named by pass 9 as the fakest
  green, and it is.
- **`hlTs` is a pure `string → string` function with zero executable coverage**, guarded
  only by a grep for its identifier, despite being root cause #3.
- **CI caught what ten cold passes did not.** Pass 10 named the gap precisely — "proven in
  Node, never in a browser bundle" — and it landed as a real failure minutes later: the
  docs typecheck cannot resolve `@chitra/core` on a fresh clone, because core resolves
  through a gitignored `dist/`. Every local verify had passed on a stale build. A reviewer
  reading a diff cannot see this class; only a clean environment can. Closed by building
  core before any importer in both `ci.yml` and the verify script, plus a real
  `docs-build` check — verify is now 18/18 from a clean clone.

## One pass-1 finding that was wrong

`stripAnsi` was reported as missing the ESC byte. The source contains a literal `\x1b`,
invisible in a rendered diff. The regex is correct; no change was made.

## Verdict of record — cold pass 10

Transcribed verbatim from the pass that rendered it, not authored here.

> "This record now over-discloses rather than under-discloses… Every code item on pass 9's
> close list is closed in the shipped source, not merely in prose. The criterion that was
> actually broken on 19 of 20 pages is now the *best*-evidenced one in the delivery… The
> residual gaps are **not material to a reader deciding whether to trust this branch**…
> Rejecting a tenth time over one stale word in a narrative sentence would make this gate
> ceremony, which the contract names as its own failure mode."

Its grade: **7 of 8 SHIPPED, 1 PARTIAL, 0 NOT-BUILT.**

Its named fakest green, carried to S12 as debt: `catalog-examples-execute` tests
`evalCode` and `applyOverrides` — both *extracted out of* the component — and nothing
asserts the component still calls them. Gut `run()` to a no-op and all 103 catalog checks
and 16 verify checks stay green. **A single render-level test of `CatalogPage` would retire
that and the grep-only backing of four criteria at once.**

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 7bf1526856deb3e64c7a7acf7da0e7ac8cd92b92c54b3f634ca4faff494028f7
