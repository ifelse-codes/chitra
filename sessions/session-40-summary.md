# Session 40 — summary · mandatory ground-truth audit (BACKFILLED in S47)

> **Backfilled 2026-10-05 in S47 (R1/G1).** S40 merged with no
> `session-40-summary.md`; the S36 coverage gate could not see it (blind for
> squash merges) and S45's audit proved the gap. This file is the record the gate
> exists to require — derived from the two artifacts S40 did leave, not from
> memory. Nothing here re-judges S40; it only makes the merged session visible.

**Contract:** `prompts/40-task-ground-truth.md` — NO-CODE audit (`40 % 5 == 0`),
vision + roadmap + state + knowledge + constraints + constitution + cost.
**Artifacts S40 left:** `sessions/session-40-ground-truth.md` (audit, 🔴 overall)
+ `sessions/session-40-review.md` (cold, `ACCEPT-with-conditions`, 41 probes).
**Branch:** `session-40-ground-truth` (from `main` `ba6cf6f`).

---

## What S40 found (from its own artifacts)

| # | Finding class | Disposition |
|---|---|---|
| 1 | Adoption baseline never read (304 downloads, release-runner shaped) | DEFERRED → ledger (GT-REMEDIATIONS S40 row 1) |
| 2 | Flip gated on cleanup with no scope/owner | DONE in S41 (cleanup plan + contract) |
| 3 | KNOWLEDGE stale facts | DONE in S40 |
| 4 | S16 vanished, no gate sees it | DEFERRED (S40 row 4) |
| 5 | `required-crew` structurally wrong (3rd failure) | DEFERRED (S40 row 5) |
| 6 | GT cadence on no board | DONE in S40 (ROADMAP entry) |
| 7 | GT artifact self-certified, not durable | DONE (review) + closeout-suffix path |
| 8–11 | Cost gate greps heading; hook claims false; no-code backstop blind; closeout unsatisfiable in NO-CODE | DEFERRED (S40 rows 8–11) |

**Overall:** 🔴 (direction sound, governance gaps open). Closeout RED 13/3
(`required-crew`, `review-inputs-attested` structurally unsatisfiable in NO-CODE,
founder-waived) — disclosed in the audit, not green.

## Cost (from the audit)

- One session, 49 audit probes + 41 re-verifications, 0 code changes.

## 3 next options (as S40 left them)

1. S41 cleanup Batches + S42/S43/S44 (owned, scheduled).
2. GTM proof pack with `t0` (S40 row 1 → S45 F6 → S46).
3. Crew-gate structural fix (S40 row 5 → S47 R7).
