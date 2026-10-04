# chitra — Continuation Handoff (after S45)

**Resume in a NEW chat (S46).** `.ai/SESSION` = 45; **`@ifelse.codes/chitra@0.3.0` is LIVE on npm**
(`latest`); the repo is still **private**. `main` = the S44 merge `5a39c43` (**derive with
`git rev-parse main`** — the `1b6c17d` this file carried for two sessions was S43's merge, and its own
audit flagged it). **S45 was the mandatory 5-session ground-truth audit**, NO-CODE, and it **moved the
public flip off this session** because `45 % 5 == 0` makes the audit mandatory and the guard blocks
the one file `0.4.0` needs.

> **The one thing to carry forward:** the flip now has a **contract, a session, and two named gates**.
> `prompts/46-task-public-flip.md` carries **F1–F6** with their done-conditions, gated on **P1** (the
> D4b history rewrite — `(/|-)Users[-/][a-z]+` in **1001** commit-file pairs across history and **0** in
> the tree; **irreversible once the repo is public**) and **P2** (private vulnerability reporting,
> 404, recorded `unknown`). **Decide P1's rewrite tool (`git filter-repo`) and its 5-step re-verify
> order before the push** — that decision is the whole point of carrying it forward rather than
> improvising it under time pressure.

## Where we are

Detail: `sessions/session-45-ground-truth.md` (the audit, **overall 🔴**) +
`sessions/session-45-summary.md` (fidelity map) + `sessions/session-45-review.md` (cold, **REJECT**)
+ `.ai/STATE.md`.

| S45 delivered | State |
|---|---|
| the audit | **shipped** — 6 numbered probes + 2 retired, ~19 unlabelled; 🔴 overall |
| `check_session_coverage` blindness | **found, 🔴** — sees only up to **S37**; every session since **S38** was squash-merged, and it has already missed `sessions/session-40-summary.md` being absent |
| the cadence's absence from `AGENTS.md` | **found, 🔴** — `0` mentions in the three files every agent must read, which is *why* five documents mis-scheduled S45 |
| S44's `REJECT` verdict | **found, 🔴** — the only canonical verdict line, so `check_review_attestation` reads `N/A` and **S44 carries no DECISION-003 attestation** |
| the 3-file cap | **found, 🔴** — **17 of the last 60** commits breach it (S40 measured 8) and it is declared "Hook-enforced" |
| 8 stale `.ai/` facts | **4 fixed in-session**, the rest carried; `KNOWLEDGE.md` was wrong about `main`'s range, the suite count, the pill's line number, and 2 of 3 tag SHAs |
| the ledger | **9 rows added**, now **14 `DEFERRED` / 18 `DONE`**, reordered newest-first |
| the flip's gates | **given an owner** — P1 and P2 are S46 preconditions |
| `canonical_inputs_sha` | **computable** (it was *uncomputable* at S40) — but the value S45 published was **stale**; see below |

## S46 — the public flip

`prompts/46-task-public-flip.md`, requirements **F1–F6**, **gated on P1 and P2**. Full text, with
done-conditions, in that file. In one line: *the repo stops being private and every claim it makes
becomes checkable, with each remote fact proven by a recorded before **and** after.*

Three things S46 must not get wrong, all of which this handoff used to get wrong:

1. **F3 is satisfied by NOT editing.** `repository.url` and `homepage` already hold correct values —
   they were unreachable, not wrong. **Editing either field fails F3.**
2. **Every remote fact needs a `before` row.** A visibility change leaves no trace in the tree, so a
   flip with no recorded `before` fails: anyone can type `private: false` into a markdown table and
   every gate here will agree.
3. **`t0` is not zero.** `@ifelse.codes/chitra` has **119** lifetime downloads, all inside a 6-day
   window starting on its publish day. The number is real; its *shape* disqualifies it as traction.

## The bug worth inheriting

**A derived figure published inside the session that keeps changing its population is stale by
construction.** S45 computed `canonical_inputs_sha` once — when the attested diff was still empty —
and pasted `40bd7929…` into six files; the real value from the next commit on was different, and
`check_review_attestation` compares with **exact string equality**, so an ACCEPT carrying the pasted
figure reads `MISMATCH`. Amendment **A3** states the rule. **Compute it after the last commit that can
move it.** Corollary the cold review found: `.ai/GT-REMEDIATIONS.md` is the *only* one of the ten S45
changed files inside the attestation, so **the ledger cannot contain the hash at all** — a file cannot
be part of its own preimage. The authoritative value lives in the review artifact.

## Also still open — the S47 candidate

`sessions/session-45-ground-truth.md` § *Findings, ranked* is the specification. Chiefly:
`check_session_coverage`'s blindness; the cadence's absence from `AGENTS.md` (**vajra-owned** — that
half is a vajra-side change, disclosed not smuggled); S44's undisclosed `REJECT`; the unenforced
3-file cap. Plus seven dead docs deps, `minimumReleaseAgeExclude: stripe-replit-sync`, S40's
`required-crew` (now **five** waivers), the vacuous `check_ground_truth_no_code`, the cost gate that
greps a heading, and **S16**.

## Two process facts

- **The cadence appeared in `0` of `AGENTS.md` / `SESSION-BOOT.md` / `TASK.md`.** If you add it, add
  it to **`AGENTS.md`** — and note the probe must name its ref: the same grep reads `0` at `main` and
  `0 / 5 / 4 / 1` at `HEAD`, because the finding gets copied into the files it measures (amendment A3-2).
- **A contract rewrite now fails closeout.** If S46 edits `prompts/46-*.md` after
  `sessions/session-46-review.md` exists, `contract-freshness` turns red — append an amendment instead.

Historical verify scripts stay frozen (01, 02, 03, 07, 31, 34, 36, 37, 38). The live set is
**39 / 42 / 43 / 44** — and note **36** numbered scripts exist, so that 4-item list is curation, not a
derivation.
