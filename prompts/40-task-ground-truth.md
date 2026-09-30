# Session 40 — Ground-Truth Audit (NO-CODE)

**Type:** mandatory 5th-session ground truth (`40 % 5 == 0`).
**Branch:** `session-40-ground-truth` (from `main` `ba6cf6f`).
**Contract:** audit S36–S39 for direction drift **and** discipline drift.

## Why this session exists as a surprise

S39's handoff (`sessions/session-39-summary.md` §"Next three options") offered three
**code-shaped** candidates — GTM proof pack, a real `0.4.0` through CI, fix the
`required-crew` gate. **None of them is legal in S40.** `CONSTRAINTS.yaml` sets
`ground_truth_every_n_sessions: 5`, `40 % 5 == 0`, so:

- `.ai/hooks/hook-ground-truth-guard.sh` **BLOCKS** most non-markdown writes (L3 = enforce) —
  its allowlist is `sessions/*`, `.ai/*`, `prompts/*`, plus `*.md` / `*.txt` repo-wide, so
  `.ai/` bookkeeping stays legal even in a NO-CODE session;
- `verify-closeout.sh` structurally **requires** `sessions/session-40-ground-truth.md`
  and dispositions every row in `.ai/GT-REMEDIATIONS.md`.

Founder decision at boot: **run the audit**; the three candidates slide to S41. The
5-session cadence holds; the handoffs had simply stopped naming the ground-truth slot.

## Mandate

Catch **both** directions. Auditing rule-following without auditing the vision is the
trap this session is built to avoid — rules exist to serve the north-star.

| # | Audit | Question |
|---|---|---|
| 1 | `vision_alignment` | Is the north-star still the destination? Shortest path, or scope creep? What evidence forces a pivot? |
| 2 | `roadmap_alignment` | Does each item still map? Is the next one the highest-leverage? Anything obsolete, or demanded and missing? |
| 3 | `state_drift` | Does `.ai/` describe the repo that actually exists? |
| 4 | `knowledge_staleness` | Does `KNOWLEDGE.md` — reloaded every session — state falsehoods? |
| 5 | `constraint_violation_review` | Walk `CONSTRAINTS.yaml` rule by rule against evidence. |
| 6 | `constitution_review` | Is any rule blocking the vision? Did this audit's own mechanism have a blind spot? |
| 7 | `cost_review` | Is cost tracked with a number, or with prose? |

## Guardrails

- **Every finding carries a run probe and its raw result.** Nothing asserted from memory.
- **No code. No commits. No PRs.** Markdown only.
- Artifacts land uncommitted on this branch — the S35 precedent, folded in by `c2cbcec`.
  That round-trip is itself a finding, recorded not fixed.
- A check that cannot evaluate **FAILS**; it never passes silently.
- Counterfactual discipline: a green that would have lied is worse than a red. If a probe
  is inconclusive, say **INCONCLUSIVE**, not green.

## Required outputs

1. `sessions/session-40-ground-truth.md` — the audit.
2. `.ai/GT-REMEDIATIONS.md` — S40 rows, one per finding. *(Deviation, disclosed by the cold
   review: this names status `OPEN`, but `check_gt_remediations` accepts only
   `DONE`/`WAIVED`/`DEFERRED` (`verify-closeout.sh:694`), so rows carry `DEFERRED` with a
   reason and an expiry. Also: audit remediations 7 and 9 share one ledger row, so "one row
   per finding" is not literal.)*
3. `.ai/SESSION` / `SESSION-BOOT.md` / `TASK.md` / `STATE.md` / `ROADMAP.md` — synced, so this
   session's own `state_drift` finding does not recur at S41.

## Two facts the audit did not have (supplied by the founder, 2026-09-30)

1. **Nothing has been released-and-marketed.** No launch, no announcement, no promotion — so
   a zero download count is the **correct pre-launch baseline**, not a verdict on the product.
2. **The repo goes public after a code cleanup.** Today's private-repo 404s are a known,
   sequenced, temporary state; the finding is the *prerequisite* (an unscoped, unowned
   cleanup), not the decision.

Both were applied as **re-reads against the evidence, never as acceptances on authority**: the
download numbers and the anonymous-404 evidence stand unchanged in the audit, and neither
correction bought a green — the overall verdict stayed 🔴 on two untouched sections.
