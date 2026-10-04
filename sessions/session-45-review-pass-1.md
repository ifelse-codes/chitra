# Session 45 — Fidelity Review, pass 1 (cold)

> **Superseded by `sessions/session-45-review.md` (pass 2).** Kept on record, not deleted: pass 1
> returned **REJECT** against the diff as it stood at `249cded`, and every finding below was fixed in
> the delivery rather than argued with. The path `sessions/session-45-review-pass-1-…` is this file;
> `check_fidelity_review` reads only `session-45-review.md`, so this artifact is deliberately **not** at
> that path — a REJECT parked at the canonical filename would force a founder waiver on every future
> closeout.

**Method controls.** A fresh subagent, own context, fed **only** `prompts/45-task-public-flip.md` and
`git diff $(git merge-base main HEAD) HEAD`. Withheld: `sessions/session-45-summary.md`,
`.ai/STATE.md`, `.ai/SESSION-BOOT.md` (claims sources), and `sessions/session-45-ground-truth.md`
(treated as the artifact under attack — every number in it an unverified claim). Adversarial framing:
*find the fakest checkmark*. No expected score disclosed. Nothing modified by the reviewer.

**Re-derivations run:** 40+ shell invocations, including a full `pnpm vitest run`, live npm/GitHub API
probes, a 443-commit history walk, and a byte-faithful re-implementation of `canonical_inputs_sha`
evaluated at **each** of the six branch commits.

## Verdict

**10 of 23 SHIPPED · 11 PARTIAL · 2 NOT-BUILT.** On the 11 numbered scope requirements alone:
**3 SHIPPED / 8 PARTIAL / 0 NOT-BUILT** (A.2, A.4, C.8).

**What reproduced exactly** — and deserves the credit: `main = 5a39c43`; 443 commits; 44 merge
commits; **17/60** on the 3-file cap; the **S37** ceiling on `check_session_coverage`'s extraction;
`S40 has NO summary`; **1001** home-path pairs; **453/453 in 23 files**; 23 chart modules; all three
tag SHAs; `App.tsx:927 = 453`; S44's single `REJECT` at L37; **14/18** ledger; **36** numbered scripts;
the NO-CODE diff probe; `check_verify_demo_scripts`'s real `N % 5` exemption at
`verify-closeout.sh:216`; `ci.yml:41`; `release.yml:100–103`; `maturity: L3`;
`ground_truth_commit_exempt_branch_suffixes`; `.ai/.session-owner` at `.gitignore:2`.

## The fakest green

> **`.ai/GT-REMEDIATIONS.md` S45 row 8 — `DONE`, evidence `canonical_inputs_sha` → `40bd7929…`.**

The *only* row in the session claiming to have **closed** anything rather than deferred it, marked
`DONE` with "reason closed, not deferred" — the strongest disposition available — and repeated as
settled fact in **five** other delivered files. Trivially checkable: one command, printed beside the
claim.

It fails. `40bd7929…` is the hash from the moment the attested diff was **empty** — two commits after
the contract landed, before the ledger commit. The moment `.ai/GT-REMEDIATIONS.md` was committed the
hash changed, and has been different ever since. `check_review_attestation` compares with exact
string equality, so any ACCEPT embedding the published figure reads `BLOCK: attestation MISMATCH`.

The checkmark is hollow because it asserts *that a number is computable* — true — while the number it
published is not the number any gate will compute. This is the single requirement the whole
`-closeout` strategy exists to serve, and it is the one that does not hold.

## Findings

| # | Finding | Sev |
|---|---|---|
| 1 | `canonical_inputs_sha` stale in **six** files → `review-inputs-attested` would read `MISMATCH` | 🔴 |
| 2 | The headline cadence finding **falsifies its own probe**: reads `0` at `main`, `0/5/4/1` at `HEAD`, because it was copied into the files it measures | 🔴 |
| 3 | The adoption-baseline re-probe was **asserted, not run**, and both halves are false — `chitra` **is** indexed (**119** lifetime, first non-zero 2026-09-29 = 89, the `0.3.0` publish day); `core` is **318**, not 304. Hands S46's F6 a falsified "baseline is zero" | 🔴 |
| 4 | "27 probes" has **no population** — 8 labels exist, 2 retired. §I's own thesis, committed in the same file | 🟠 |
| 5 | §I says **28** scripts unclassified, §C says **32**. 36 − 4 = 32 | 🟠 |
| 6 | `.ai/CONTINUATION-PROMPT.md` left stale **after** a pass claimed it fixed | 🔴 |
| 7 | `verify-closeout.sh` **never run for N=45** — newest `session-file-valid.log` reads N=44 | 🔴 |
| 8 | `CONSTRAINTS.yaml` lists **two** constitution questions, not three; the contract's "three" was never derived, and the audit resolved it silently instead of by amendment | 🟠 |
| 9 | `prompts/46-task-public-flip.md` ships a typed commit count (**443** vs 445 at write time) inside the artifact whose purpose is that numbers keep their identity | 🟠 |
| 10 | The attested diff **excludes nearly the whole delivery** — only `.ai/GT-REMEDIATIONS.md` of ten changed files is inside it. Worth disclosing rather than leaving implied | 🟠 |
| 11 | The summary and the review were **untracked**, so absent from the delivery — and the contract's "three next options" existed only in that untracked file | 🔴 |
| 12 | Minor: `.ai/STATE.md`, `SESSION-BOOT.md`, `TASK.md` lacked a trailing newline | ⚪ |

## What could not be broken

The core audit is genuinely strong. Attacked: the 3-file-cap count, the home-path pair count, the
coverage-check population, the tag SHAs, the pill citation, the test count, the script count, the
ledger tallies, the precondition states, `ci.yml:41`, `release.yml:100–103`, the maturity level, the
hook exemption, the 17-commit cap — **all reproduced exactly**, several to the digit. The NO-CODE
claim survives the strongest attack the contract demands. The `-closeout` reasoning is correct and
non-obvious. And the builder **declined** to lean on `check_ground_truth_no_code` when that gate would
in fact have been *informative* for this session — over-caution, not evasion.

**The failure mode is not fabrication. It is stale emit-time numbers in a session whose entire thesis
is that stale numbers are the disease.**

## Overall verdict

Not "one narrow slice presented as the whole" — a broad, near-complete build of all 11 numbered
requirements that fails its own evidentiary standard on three load-bearing numbers, leaves the summary
and review out of the delivery, and never ran the closeout it certifies.

**Verdict:** REJECT