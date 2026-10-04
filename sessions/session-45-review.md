# Session 45 — Fidelity Review (cold)

> **Verdict: REJECT, on a diff that has since been corrected.** This artifact is the canonical review
> for S45 and it records a **REJECT**, not an ACCEPT. Two things are true at once and both belong on
> the record: **every finding below was fixed in the delivery**, and **no pass has re-judged the
> corrected diff.**
>
> **A second cold pass was launched and interrupted.** The builder did not substitute its own
> judgement for it, because `.ai/AGENTS.md` forbids self-certification and a self-appeal is the exact
> move that rule exists to stop. So the REJECT stands, the fixes are listed with their evidence, and
> `verify-closeout.sh` runs under `VAJRA_CLOSEOUT_WAIVER=45` — **the same treatment S44 received on
> the same grounds.**
>
> **What that costs, stated plainly:** `check_review_attestation` reads *"N/A: attestation only gates
> an ACCEPT"*, so it passes **vacuously** and S45 has **no DECISION-003 input attestation** — the very
> gap this session reported as finding 🔴 **F1** about S44. **S45 is now the second session in a row
> whose fidelity verdict is not an ACCEPT.** That is a real cost of an interrupted review, and it is
> better disclosed than waived away quietly.

**Method controls.** A fresh subagent with its own context, fed **only**
`prompts/45-task-public-flip.md` and `git diff $(git merge-base main HEAD) HEAD`. Withheld:
`sessions/session-45-summary.md`, `.ai/STATE.md`, `.ai/SESSION-BOOT.md`, and
`sessions/session-45-ground-truth.md` — the last treated purely as an artifact of claims to attack,
never as a source. Adversarial framing: *assume the builder silently re-scoped to whatever yields a
green checkmark; find the fakest checkmark.* No expected score disclosed. Nothing was modified by the
reviewer. 40+ independent shell re-derivations, including a full `pnpm vitest run`, live npm and GitHub
API probes, a 443-commit history walk, and a byte-faithful re-implementation of `canonical_inputs_sha`
evaluated at each of the six then-current commits.

**Full pass-1 output, with all 12 findings verbatim:** `sessions/session-45-review-pass-1.md`.

## Requirements — as ruled at the time of the pass

| Requirement | Verdict | Evidence |
|---|---|---|
| A.1 seven audits × six axes, 3+3+3 questions | PARTIAL | All 7 audits and all 6 axes present, but only **4 of 9** questions answered; `CONSTRAINTS.yaml:69–71` lists **two** constitution questions, not three, and the third was marked `(implied)` rather than amended |
| A.2 both drift directions | SHIPPED | §A/§B vision+roadmap; §C–§H rules+state+constitution. No axis omitted, none reported clean |
| A.3 every finding is a probe with command + falsifier | PARTIAL | "27 probes" has **no population** (8 labels, 2 retired); §C row 8's citations carry no command |
| A.4 meta-check answered; NO-CODE evidence is the diff | SHIPPED | Blind spot stated before any finding; the diff probe re-run verbatim → empty. Correctly declined to lean on the vacuous gate |
| B.5 ledger S45 section, newest first, DEFERRED carries reason+expiry | PARTIAL | Section and all 9 rows correct; **ordering false of the file** (S45 → S35 → S40) |
| B.6 no S40 row re-dispositioned by assertion | PARTIAL | 6 of 7 re-probed; **row 1 asserted, not run — and both halves false** |
| C.7 flip carried with numbers + done-conditions intact | PARTIAL | F1–F6, P1–P2 all intact and F3 strengthened — but the new file's own commit count was typed and wrong |
| C.8 STATE and ROADMAP name S46 | SHIPPED | Both quote S46 with F1–F6 and both gates |
| D.9 `.ai/` re-synced, every count derived | PARTIAL | All six files re-synced, but three counts were typed and did not reproduce, and one `1b6c17d` site was left stale |
| D.10 fidelity map + independent cold review | PARTIAL | Review did not exist; summary untracked, so absent from the delivery |
| D.11 closeout runs; known-red named | PARTIAL | Rationale delivered; `verify-closeout.sh` **never run for N=45** |
| F1 · F2 · F4 · F5 · P2 (carried) | SHIPPED | Done-conditions intact; F3's "editing either field is a FAILURE" preserved; P2 re-probed live (404 / `unknown`) |
| F6 (carried) | PARTIAL | Handed on with a **stale 304** and a falsified "zero" premise |
| P1 (carried) | PARTIAL | Done-condition verbatim, tool choice and 5-step order genuinely added — but the derived count **443** was wrong |
| `canonical_inputs_sha` computable | PARTIAL | Computable — and the published value was stale, which is the fakest green below |
| Summary as part of the delivery | NOT-BUILT | Untracked |
| Three next options | NOT-BUILT | Existed only in the untracked summary |

**10 of 23 SHIPPED · 11 PARTIAL · 2 NOT-BUILT.** On the 11 numbered scope requirements alone:
**3 SHIPPED / 8 PARTIAL / 0 NOT-BUILT.**

## Independent re-derivations

Reproduced **exactly**: `main = 5a39c43`; 443 commits; 44 merge commits; **17/60** on the 3-file cap;
the **S37** ceiling on `check_session_coverage`; `S40 has NO summary`; **1001** home-path pairs;
**453/453 in 23 files**; 23 chart modules; all three tag SHAs; `App.tsx:927 = 453`; S44's single
`REJECT` at L37; **14 `DEFERRED` / 18 `DONE`**; **36** numbered scripts; the NO-CODE diff probe;
`check_verify_demo_scripts`'s `N % 5` exemption at `verify-closeout.sh:216`; `ci.yml:41`;
`release.yml:100–103`; `maturity: L3`; `ground_truth_commit_exempt_branch_suffixes`; `.session-owner`
at `.gitignore:2`.

Did **not** reproduce, at the time: `canonical_inputs_sha` `40bd7929…` (real value `5b5664d2…`);
commits "3" (real 6); files "4" (real 10); the five-`1b6c17d` claim (six sites, one still stale);
"28 scripts unclassified" (32); `chitra` "unindexed" (**119** lifetime); `core` "304" (**318**);
"27 probes" (underivable); closeout run for N=45 (never run).

## The fakest green

> **`.ai/GT-REMEDIATIONS.md` S45 row 8 — `DONE`, evidence `canonical_inputs_sha` → `40bd7929…`.**

The **only** row in the session claiming to have **closed** anything rather than deferred it, carrying
the strongest disposition the vocabulary allows, repeated as settled fact in **five** other delivered
files — and trivially checkable, with the command printed beside the claim.

It failed. `40bd7929…` was the hash from the moment the attested diff was still **empty**. The moment
`.ai/GT-REMEDIATIONS.md` was committed the value changed, and `check_review_attestation` compares with
**exact string equality** — so any ACCEPT embedding the published figure reads `BLOCK: attestation
MISMATCH`. It asserted *that a number is computable*, which was true, while the number it published was
not the number any gate computes. **This was the one requirement the whole `-closeout` branch strategy
exists to serve.**

**Fixed:** re-derived **after** the last attested-set commit → `898b65c3…a43060`, propagated to all six
sites; the rule recorded as amendment **A3**; and the ledger's cell **unpinned**, because the ledger is
the only one of the ten changed files inside the attested preimage — **a file cannot contain its own
hash.**

## What could not be broken

The core audit is genuinely strong, and this is the reviewer's own conclusion: the 3-file-cap count,
the home-path pair count, the coverage-check population, the tag SHAs, the pill citation, the test
count, the script count, the ledger tallies, the precondition states, the workflow pins, the maturity
level and the hook exemption **all reproduced exactly**, several to the digit. The NO-CODE claim
survives the strongest attack the contract demands. The `-closeout` reasoning is correct and
non-obvious. And the builder **declined** to lean on `check_ground_truth_no_code` when that gate would
have been *informative* here — over-caution, not evasion.

**The failure mode was not fabrication. It was stale emit-time numbers in the one session whose thesis
is that stale numbers are the disease.**

## Fixes applied after this verdict

| Finding | Fix | Evidence |
|---|---|---|
| Stale hash in 6 files | re-derived after the last attested-set commit | `bash scripts/verify-closeout.sh --inputs-sha 45` → `898b65c3…a43060`, re-run after the citing commits and **unchanged** |
| Ledger cannot hold the hash | cell unpinned; command + rule instead | `GT-REMEDIATIONS.md` row 8 |
| Cadence probe falsifies itself | probe now names its ref (`git show main:…`) | amendment **A3-2**; `0` at `main`, disclosed as `0/5/4/1` at `HEAD` |
| Adoption baseline asserted, not run | re-run with commands | **119** lifetime, first non-zero **2026-09-29 = 89** = the `0.3.0` publish day; `core` **318**. Amendment **A2**; **F6** rewritten — `t0` is *119 downloads, none organic* |
| "27 probes" underivable | withdrawn | **6 numbered + 2 retired**, ~19 unlabelled, under-labelling named as the finding |
| 28 vs 32 scripts | reconciled | **32** (36 − 4) |
| `CONTINUATION-PROMPT.md` left stale | rewritten for S46 | `git grep -n 1b6c17d HEAD -- .ai` → **nothing** |
| `prompts/46` typed count | replaced | "derive it, never trust that figure" |
| Summary + review untracked | committed | `sessions/session-45-{summary,review,review-pass-1,ground-truth}.md` |
| Closeout never run | run | see below |
| Two constitution questions, not three | amendment **A1** | requirement text left standing per N1 |
| No trailing newlines | fixed | four `.ai` files |

## Closeout result

`VAJRA_CLOSEOUT_WAIVER=45 bash scripts/verify-closeout.sh 45` → **16 pass / 1 fail**, the failure being
`gt-remediations-dispositioned`: **an unescaped `|` inside a table cell** — `(/|-)Users[-/][a-z]+` —
broke `check_gt_remediations`' field splitting, so the status cell parsed as mid-text. **A bug this
session introduced, caught by a gate, fixed in place.** After the fix, re-run below.

## Two things this review does not excuse

1. **No ACCEPT exists for S45.** The verdict stands at REJECT and the closeout runs on a founder
   waiver. A session that ends with its builder's own fixes unreviewed has not closed its loop — it has
   documented where the loop was interrupted.
2. **The finding this session made about S44 now applies to itself.** S45 reported 🔴 **F1**: *S44's
   only canonical verdict is REJECT, so `check_review_attestation` reads `N/A` and the session carries
   no DECISION-003 attestation.* S45 has reproduced that exactly. **The audit's subject and its author
   are in the same state**, and that is worth more than a green closeout.

**Overall verdict:** Not "one narrow slice presented as the whole" — a broad, near-complete build of all
11 numbered requirements that failed its own evidentiary standard on three load-bearing numbers, left
two required artifacts out of the delivery, and never ran the closeout it certified. **All of that was
corrected in the delivery; none of it was re-reviewed.**

**Verdict:** REJECT