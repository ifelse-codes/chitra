# Session Boot

## Current Session
- **Number:** 48 — **the GTM proof pack** (`48 % 5 == 3`, ordinary code session),
  **complete and closed 2026-10-06**; branch `session-48-gtm-proof-pack`.
- **Branch:** `session-48-gtm-proof-pack` from `main` (`2f3c089` at branch time —
  derive with `git rev-parse main`, never trust this citation).
- **Contract:** `prompts/48-task-gtm-proof-pack.md` — requirements **R1–R6**, spec
  `.ai/ROADMAP.md:219` + `.ai/GT-REMEDIATIONS.md` S40 row 1. **Not amended**
  (N1 freeze holds from the first cold feed).
- **Gate:** `scripts/verify-session-48.sh` (10 checks, full scope by default) +
  `scripts/demo-session-48.sh` (6 probed rows). Every requirement ships with the
  command that makes the old body green and the new body red on the same tree —
  11 counterfactuals were executed, all red with the right diagnosis.
- **Cadence note (`N % 5`):** ground-truth sessions run every 5th session
  (`CONSTRAINTS.yaml#ground_truth_every_n_sessions: 5`) — S45 was NO-CODE, S46/S47/
  S48/S49 are code, **S50 is the next ground truth**. Named here so no handoff
  mis-schedules a code session onto a ground-truth slot again (S45 H1).

## Repo State Snapshot
> Re-read from live facts at S48 close. Every figure below is derived.

- `.ai/SESSION` = 48. **`main` = `2f3c089`** (S47's post-merge sync #73 — derive it).
- **The repo is public**; npm `latest` → **`0.4.0`** with provenance.
- **Adoption, measured:** `node scripts/gtm-reads.mjs` → **t1 = 273** through
  2026-10-06 (243 on the two release days, **0 on 10-05 and 10-06**);
  **t0 = 119 reproduces exactly** with `--as-of 2026-10-03`. **No organic signal.**
  Never cite either as traction — STATE's guard says so and the gate enforces it.
- **One channel live:** LinkedIn post published **2026-10-06** (URL in
  `.ai/STATE.md`, re-checked 200 by `channel-recorded`), reader window opens that
  day. Read it after 7 days with the same command.
- **Benchmarks, measured:** `node scripts/gtm-bench.mjs` → 0 deps, 81.5 KB packed,
  398.4 KB / 39 files, ≤ 2 ms for a 100-point line — cited in the README with the
  reproduce command above them.
- **Front door locked:** every public claim (20 charts, 3 renderers, 7 themes,
  453 tests, 0 deps, MIT) derives from its source; the naive file count says 23,
  which is why the derivation is written down (`ring.ts` is never exported).
- **Product untouched:** 453/453 in 23 files (re-derived at verify time);
  `packages/core/src/` and the lockfile unchanged by this session.
- **P1 residual:** `refs/pull/*` still serve pre-rewrite blobs, DELETE → 422.
  Ticket text ready in `sessions/session-47-support-ticket.md` — **founder decision
  2026-10-05: do not file** (open on purpose, by decision).
- **Crew gate:** standing condition outside Claude Code — founder waiver with
  reason at closeout (`VAJRA_CLOSEOUT_WAIVER=NN`), never a silent green.

## Next Session
- **Number:** 49 (code). Candidates: **read the channel in 7 days**
  (`node scripts/gtm-reads.mjs` after 2026-10-13 — if the days after the post stay
  at zero, the channel was wrong, not the product), **new product surface** (none
  since `c72cc14`, S09 — a channel that answers is the trigger), or **S47's three
  disclosed residuals** (one small maintenance lane).
- **S50 (`50 % 5 == 0`) is the next ground truth** — no code session may be
  scheduled onto it.
- Open in a **new chat** (one session per chat), from `.ai/CONTINUATION-PROMPT.md`.
