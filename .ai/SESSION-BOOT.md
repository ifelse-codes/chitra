# Session Boot

## Current Session
- **Number:** 47 — **make the governance gates able to fail** (`47 % 5 == 2`,
  ordinary code session), **complete and closed 2026-10-05** — 4 independent
  review passes ending **ACCEPT 13/13**; branch `session-47-gate-truth`.
- **Branch:** `session-47-gate-truth` from `main` (`a218ac5` at branch time —
  derive with `git rev-parse main`, never trust this citation).
- **Contract:** `prompts/47-task-gate-truth.md` — requirements **R1–R9**,
  spec `sessions/session-45-ground-truth.md` § *Findings, ranked*.
  **Not amended** (N1 freeze holds from the first cold feed).
- **Gate:** `scripts/verify-session-47.sh` (14 checks, full scope by default) +
  `scripts/demo-session-47.sh`. Every fix ships with the command that makes the
  old body green and the new body red on the same tree.
- **Cadence note (`N % 5`):** ground-truth sessions run every 5th session
  (`CONSTRAINTS.yaml#ground_truth_every_n_sessions: 5`) — so S45 was NO-CODE,
  S46/S47/S48/S49 are code, **S50 is the next ground truth**. Five tracked
  documents mis-scheduled S45 because none computed `45 % 5` (S45 H1); this line
  exists so the next handoff cannot repeat it. The vajra-owned `AGENTS.md` half
  is disclosed in the summary, not edited here.

## Repo State Snapshot
> Re-read from live facts at S47 branch time. Every figure below is derived.

- `.ai/SESSION` = 47. **`main` = `a218ac5`** (S46 closeout #70 — derive it).
- **The repo is public** (`private` → `false`, `visibility` → `public`).
  P1 holds (0 matches, re-derived by S46's gate); **residual:** `refs/pull/*` heads
  still serve pre-rewrite blobs, DELETE → 422 — count it, never trust it:
  `git ls-remote origin 'refs/pull/*/head' | wc -l` → **71** at S47 close (70 before
  PR #71). Ticket text in `sessions/session-47-support-ticket.md` (R8), **not filed**.
- **S40 now has a summary** (`sessions/session-40-summary.md`, backfilled in S47
  — the record `check_session_coverage` exists to require). New coverage newest
  belief **S46** (merge-only body still believes S37 — the blindness, measured).
- **Closeout gates fixed this session:** coverage sees squash merges (R1),
  no-code fails closed on empty range + requires the GT artifact (R2), cost
  tracking requires a measurement (R3).
- **Product untouched:** 453/453 in 23 files (re-derived at verify time);
  tags `v0.1.0`–`v0.4.0` present (SHAs post-rewrite — derive, never copy).
- **S44's canonical verdict is REJECT** (single verdict line, 8 passes, follow-up
  PR #66) — disclosed in STATE/ROADMAP this session (R4), no longer COMPLETE.
- **Crew gate:** 5 waivers standing; S47 records the 6th-or-green honestly (R7).
  Standing condition outside Claude Code: founder waiver with reason.

## Next Session
- **Number:** 48 — candidates: GTM proof pack beyond `t0`, or new product
  surface (none since `c72cc14`). S50 (`50 % 5 == 0`) is the next ground truth.
- Open in a **new chat** (one session per chat).
