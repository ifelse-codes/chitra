# Session 11 — Independent cold fidelity review

Three cold passes, each `subagent_type: "fidelity-reviewer"`, each fed **only** the session
prompt plus the branch diff. None of them was the agent that wrote the code, and none was
shown this file or any conclusion drawn from it.

The original in-session "cold fidelity review" is **not** part of this record. It was a code
read written by the same session that wrote the code; it certified a page broken on 19 of 20
charts. It is retained, unedited and banner-warned, as
`sessions/session-11-review-INVALID-self-read.md` — the clearest specimen this repo owns of a
review that passes a broken delivery.

## Pass 1 — REJECT

Graded the repaired branch 6 of 8 SHIPPED, rejecting on criteria 2 and 8. Findings, all real:

| Finding | Class |
|---|---|
| No block cursor — the brief asked for one; `caret-color` on a native I-beam shipped | criterion 2 |
| Current-line stripe offset half a line: positioned without the 10px padding on the text layers | criterion 2, undisclosed |
| Gutter, `~` markers and stripe froze in place when the buffer scrolled | criterion 2, undisclosed |
| `check-catalog-examples.ts` would stay 81/81 green if `injectOpt` became `return code` | the flagship check |
| `demo-session-11.sh` **could not fail** — `fail()` printed and returned 0, above 11 hardcoded `SHIPS` rows | criterion 7 |
| The summary self-graded 8-of-8 with false evidence cells, corrected only by an appendix | criterion 8 |
| Three records described a `.render()` → `.toString()` transform that does not exist in the code | criterion 8 |

## Pass 2 — REJECT

A fresh pass on the responses. It confirmed the code repairs were substantive, not cosmetic,
and then rejected again — on the **record layer**, plus one real code hole:

- The renderer assertion passed on `differing.length > 0`, i.e. on **one** chart. Since `line`
  is precisely the chart taking `injectOpt`'s REPLACE branch rather than the INSERT branch that
  broke, that threshold **re-admits the exact 19-of-20 failure shape.**
- Three unconditional greens survived in the demo (`ok "All renderers verified…"` and two
  `if grep; then ok; fi` with no `else`) — in the script whose repair was that greens must be
  able to fail.
- The verify suite's vim grep matched strings **all present in the state pass 1 rejected**, so
  the three criterion-2 repairs were guarded by nothing.
- The `.render()` → `.toString()` claim was **still open**, untouched by an explicit REJECT.
- `14/14`, `81`, `5/81`, and the block-cursor description were all stale in the records.

## What changed in response

| Pass-2 finding | Response |
|---|---|
| Renderer threshold re-admits the 19-of-20 shape | Suite now asserts the **transform per chart** (`applyOverrides` output must carry the requested renderer and theme), with output-differs kept as corroboration. Tightening to "all charts must differ" was tried first and **rejected as asserting something false** — 15 of 20 charts legitimately render identically across renderers |
| A shrinking suite reports a cheerful `N/N` | Expected check count pinned; deleting an assertion now fails |
| Three unconditional greens in the demo | All three given failing branches |
| Criterion-2 repairs unguarded | Named individually in verify; both grep checks renamed `-SOURCE-GREP` so the suite stops presenting a read as a verification |
| `.render()` → `.toString()` in three records | Struck from all three |
| Stale counts and block-cursor description | Corrected; criterion table regraded **in place**, "Nothing was omitted" removed |

**Falsifiability, measured on both mutation shapes** — a wholly no-op `injectOpt` → **81/102**;
a no-op INSERT branch only, the exact shape that broke the page → **83/102** (19 failures, one
per chart lacking a renderer key).

**One pass-1 finding was wrong and was not acted on:** `stripAnsi` was reported as missing the
ESC byte. The source contains a literal `\x1b`, invisible in a rendered diff. The regex is
correct; no change made.

## Verdicts

| Pass | Verdict | Grade |
|---|---|---|
| 1 | REJECT | 6 of 8 SHIPPED, 2 PARTIAL |
| 2 | REJECT | 6 of 8 SHIPPED, 2 PARTIAL — code accepted, record rejected |
| 3 | see below | remediation-only re-check |

## What is still short, in the accepted state

- **No DOM or browser test exists.** Criteria 1, 2, 3 and 5 rest on source greps plus operator
  screenshots. Nine of sixteen verify checks are greps, now labelled as such.
- **Theme coverage is 2 of 7** in the executable suite.
- **`LINE_H` / `VIM_PAD` duplicate CSS custom properties**, bound only by a comment.
- The **`Reset` repair** has no automated coverage.

**Verdict:** ACCEPT
