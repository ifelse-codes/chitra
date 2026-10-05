# Session 47 — make the governance gates able to fail

**Status:** contract drafted at plan time from `sessions/session-45-ground-truth.md`
§ *Findings, ranked* + `.ai/GT-REMEDIATIONS.md` S45 section. **Not yet reviewed** —
`reviewer/SKILL.md` N1 freeze has not attached.

**Why this contract exists where it does.** S45 (NO-CODE audit, `45 % 5 == 0`)
found 11 findings, 4 of them checks that report green while doing nothing.
S46 deliberately did NOT fix them — fixing `verify-closeout.sh` in the session
that made the repo public would put the public surface and its gates in one
unreviewable commit (S46 contract § *Out of scope*). **47 % 5 == 2** — S47 is an
ordinary code session. The flip is done; this is the gate work it deferred.

---

## The one story

> **Every governance check this repo runs can fail for the reason it claims —
> no vacuous green survives, and every stale fact it already shipped is
> disclosed with the command that re-derives it.**

---

## Scope — 9 requirements

**R1 — `check_session_coverage` sees squash-merged sessions (G1).**
Population today: `git log --merges --format='%s' main` + `session-([0-9]+)-`
regex → newest belief **S37**, blind for S38–S44, already missed
`sessions/session-40-summary.md` being absent. Done-condition: the check derives
its population from **both** merge subjects (`session-NN-slug`) **and** squash
subjects (`SNN:`), requires a summary for every merged session ≥ S17, asserts the
scanned count is non-zero and names its newest belief, and goes **red** on the
live tree (S40 has no summary today). *Counterfactual: the old body stays green
on the same tree.*

**R2 — `check_ground_truth_no_code` fails closed on an empty range (S40 row 10).**
Today it diffs `merge-base..HEAD`; a GT session that commits nothing yields an
empty range and `OK`. Done-condition: for `N % 5 == 0` the check requires the GT
artifact (`sessions/session-NN-ground-truth.md`) to exist and be non-empty,
requires a non-empty attested population (not just an empty diff), and its
offender path is exercised (a planted `packages/core/src/*.ts` under a synthetic
GT N goes red). *Counterfactual: plant a code file, the old body still reads OK.*

**R3 — `check_cost_tracking` verifies a measurement, not a heading (S40 row 8).**
Today it greps `Cost Tracking` — any text passes, including a lie; S44's cost
line omits the follow-up PR #66, eight cold-review passes and the REJECT.
Done-condition: the check requires the cost block to carry a derivation (session
count, decision count, requirement count, file/commit counts derived per commit,
release count) and fails on a heading-only block; `.ai/STATE.md`'s S44 cost line
discloses PR #66 + 8 passes + REJECT. *Counterfactual: a heading-only block goes
red.*

**R4 — S44's REJECT is disclosed, not recorded COMPLETE (S45-F1).**
`sessions/session-44-review.md` carries exactly one verdict line
(`**Verdict:** REJECT`, L37); `check_review_attestation` reads N/A for a REJECT,
so S44 carries no DECISION-003 attestation; `STATE.md`/`ROADMAP.md` record it
COMPLETE with "13 SHIPPED · 1 PARTIAL". Done-condition: `STATE.md` + `ROADMAP.md`
record the REJECT canonically (verdict + pass-8 + PR #66 follow-up), the ledger
row is dispositioned DONE or DEFERRED with reason + expiry, and no file claims
S44 ACCEPT. *Counterfactual: grep for COMPLETE-without-REJECT goes red.*

**R5 — the 3-file cap is honest (E1).** 17 of the last 60 `main` commits breach
it (S40 measured 8); `.ai/AGENTS.md` declares it "Hook-enforced" while squash
merges never run a local hook. Done-condition: the wording is corrected where
this repo owns it (`CONSTRAINTS.yaml` comment + session gate asserting the
**delivery** cap per commit on the branch), the vajra-owned `AGENTS.md` line is
**disclosed, not smuggled** (that file's governed body cannot be edited here),
and the session gate `commit_cap_respected` derives per-commit counts and fails
on a 4-file delivery commit. *Counterfactual: a 4-file delivery commit goes red.*

**R6 — stale facts carry guards, not just corrections (C1/C2/C3).**
Eight stale facts across `.ai/` (main SHA in 6 places, S44 in-progress, D4b tree
vs history, live-set 39/42/43/44 over 36 scripts, 452→453, pill L550/L570→L927,
main S00–S39→S44, 2 of 3 tag SHAs). Done-condition: every corrected fact in
`.ai/STATE.md` + `.ai/KNOWLEDGE.md` cites the deriving command beside it, and the
session gate adds `stale-facts-guarded` asserting test count, pill line, tag SHAs
and main range at run time. *Counterfactual: retype a stale number, the gate goes
red.*

**R7 — `check_required_crew` + `ROADMAP.md:56` (B1).** The roadmap schedules the
crew fix to completed S44 inside a table headed *deliberately NOT scheduled*;
the crew gate has waived 5 times (S38/S39/S42/S44/S46) for a tech-lead step
`AGENTS.md`'s 9-step loop never asks for. Done-condition: `ROADMAP.md:56`
no longer assigns open work to a completed session (re-pointed to S47 with a
done-condition), and the closeout log records the waiver-or-green honestly —
no file claims the gate is satisfied when it was waived. *Counterfactual: the old
ROADMAP line still names S44.*

**R8 — the P1 residual ticket rides along (owed from S46).** `refs/pull/*` is
read-only (`DELETE` → 422); 56 of 67 PR heads still expose pre-rewrite blobs.
Only GitHub support can delete them + GC. Done-condition: the session attempts
the DELETE (records 422), writes `sessions/session-47-support-ticket.md` with
the request text + evidence commands, and `STATE.md` records ticket filed vs
owed honestly (filed = issue/ticket reference, else still owed with reason).
*Counterfactual: no ticket file, no evidence — the requirement is NOT-BUILT.*

**R9 — GT cadence is named where agents must read (H1).** The cadence
(`ground_truth_every_n_sessions: 5`) lives only in `CONSTRAINTS.yaml` (1
mention); `AGENTS.md` / `SESSION-BOOT.md` / `TASK.md` carry 0. Five tracked
documents named S45 "the public flip" without computing `45 % 5`.
Done-condition: the cadence is named in `SESSION-BOOT.md` + `TASK.md` + `ROADMAP.md`
where this repo owns the bytes, each with the `N % 5` derivation; the
vajra-owned `AGENTS.md` half is **disclosed as a vajra-side change, not smuggled**
(a patch proposal recorded in the summary, no edit below the governed line).
*Counterfactual: grep for the cadence in the three owned files goes red.*

---

## Out of scope — named, so it cannot be smuggled in

| Item | Why |
|---|---|
| New product surface (no chart since `c72cc14`) | vision work, not gate work — ROADMAP alternative, not this story |
| GTM proof pack beyond `t0` | F6 recorded the reading; measurement work is separate |
| MCP server | founder-DEFERRED since S38, gate unmet |
| Vajra-side `AGENTS.md` governed body | disclosed in R5/R9, never edited here |

---

## Assumptions (2 — the cap)

- **AS-1 — the ranked list is the spec.** `sessions/session-45-ground-truth.md`
  § *Findings, ranked* (G1/H1/C1/F1/B1/E1/C2/C3/H2/B2/E2) + `.ai/GT-REMEDIATIONS.md`
  S45 rows are the requirement source; a finding closed without its named
  counterfactual going red is not closed.
- **AS-2 — one story: gates that can fail.** The support ticket rides along
  because S46 made it owed-to-S47, not because it is gate work; everything else
  is the same story (a check whose population is prose instead of derived).

## Founder decisions needed at plan approval

- **D-47-1 — S44's record:** disclose REJECT as canonical (R4) vs backfill a
  summary that never existed.
- **D-47-2 — the crew gate:** 6th waiver with reason vs structural fix this
  session can own.
- Commit approval.

---

## Closeout

`scripts/verify-session-47.sh` + `scripts/demo-session-47.sh` (code session) ·
`sessions/session-47-summary.md` · `sessions/session-47-review.md` (cold,
attested) · `sessions/session-47-support-ticket.md` (R8 evidence) · `.ai/` synced
(`SESSION` = 47) · `verify-closeout.sh` exit 0.

## The counterfactual this session demands

**A gate that cannot fail is not a gate.** Every fix ships with the command that
makes the old body go green and the new body go red on the same tree — stated in
the verify script beside the check, demonstrated in the demo. A fix proven only
by its own exit 0 FAILS.
