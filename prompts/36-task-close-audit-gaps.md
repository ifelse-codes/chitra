# Session 36 — task: close the S35 ground-truth gaps + ship v0.1.0

**Founder directive (in-chat):** "target session 36 and fill all the issues we
found" in `sessions/session-35-ground-truth.md`; run the real release + unfreeze.
Founder ruled: run the real release now, unfreeze now, and waive
one-session-per-chat (S36 runs in the S35 chat) — all three recorded here.

Founder-waived multi-story session (S26/S27/S33 precedent, disclosed).

## Requirements (numbered)

1. **Ship `@chitra/core` v0.1.0 to npm for real** — `npm publish --access public`,
   package contents verified (dist + README + LICENSE), no version bump (0.1.0).
2. **Resolve the stale `v0.1.0` tag** — delete the local tag on the 2026-07-29
   commit; re-cut `v0.1.0` on the current release commit; push it.
3. **Harden `release.yml`** — skip the publish when the version already exists on
   npm (idempotent tag push; a re-push stays green).
4. **Unfreeze + deploy the docs site** to `chitra.iifelse.com` (S31 freeze lifted
   by founder order) — this also makes the README's `/ai-data` link live.
5. **Fix the docs-hero pills** (`artifacts/chitra-docs/src/App.tsx`): honest
   version status; `134` → `452` tests.
6. **Correct `.ai/KNOWLEDGE.md`** stale facts: test count (one number = 452), test
   files (23), CI Node (26), `main` range (S00–S36), dist-built claim, dead
   `/tmp/ring-lab` path.
7. **Sync `.ai/` bookkeeping**: `STATE.md`, `SESSION-BOOT.md`, `TASK.md`,
   `ROADMAP.md`, `.ai/SESSION` → 36.
8. **Close the S05 closeout-integrity debt**: backfill S17/S32 session records and
   make `verify-closeout.sh` detect a merged `session-NN-*` branch with no summary.
9. **Bind ground-truth findings**: a tracked remediation ledger whose items the
   closeout gate requires to be dispositioned (DONE/WAIVED).
10. **Make "No code in Ground Truth" true** — an enforcing hook + a closeout check
    (the AGENTS.md claim was previously unbacked).
11. **Honest cost tracking** in `STATE.md` (a number or an explicit "unmeasured").
12. **S36 artifacts**: verify + demo scripts (exit 0), summary, cold fidelity
    review (ACCEPT), closeout.

## Out of scope
- No MCP server implementation (roadmap item only, requirement in roadmap).
- No `artifacts/api-server` work.
- No design/visual changes beyond the two stale pills.

## Guardrails
- Atomic commits, ≤3 files each; no `main` commits (branch + PR).
- Founder approval token required before any commit.
- Release/deploy are founder-authorized this session.

## Execution
- step 1 — deferred: npm publish → S37 (needs Classic Automation token)
- step 2 — done: tag deleted (git op); re-cut deferred with step 1
- step 3 — done: 71507f6
- step 4 — done: ops deploy (no sha; wrangler pages deploy)
- step 5 — done: 88be3fd
- step 6 — done: 90758e3
- step 7 — done: 3fd131f, 4abbd47
- step 8 — done: 442032a, 18be7e7
- step 9 — done: 4759cd2
- step 10 — done: 28277ad
- step 11 — done: 3fd131f
- step 12 — done: 31b1338, e9aee50
