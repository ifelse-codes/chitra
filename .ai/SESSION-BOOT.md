# Session Boot

## Current Session
- **Number:** 46 — **the public flip** (`46 % 5 == 1`, ordinary code session), **complete and
  closed 2026-10-04**; the closeout is what this file describes.
- **Branch:** `session-46-public-flip`. Delivery = **4 commits / 9 files** on top of the post-rewrite
  base `8a083c8`, squash-merged to `main` as **`86bc909`** (PR **#68**); derive with
  `git rev-parse main`. Working branch kept at the delivery commits so
  `merge-base(main, HEAD)..HEAD` is the real diff the attestation hashes.
- **Contract:** `prompts/46-task-public-flip.md` — preconditions **P1/P2**, requirements **F1–F6**.
  **Not amended** (the N1 freeze held: the contract was never edited after the cold review began).
- **Gate:** `scripts/verify-session-46.sh` (16 checks, full scope by default; `fast` skips only the
  suite, drift and the network probes) + `scripts/demo-session-46.sh`. The F5/F6 evidence cannot
  exist before the release, so the gate is run twice and the recorded run is the last one.
- **Three decisions were taken here, all recorded before the action they authorize:**
  1. **D-F1** — `git filter-repo` 2.47.0 + a 5-step re-verify order, written down **before** the push.
  2. **D-REORDER** — P2 was unsatisfiable before F1 (the endpoint is public-repo-only; proved against
     a public control), so the founder reordered to **F1 → P2** instead of waiving it.
  3. **the `home-path-scrubbed` fix** — P1 made S44's counterfactual permanently unsatisfiable, and
     the founder chose to fix that one check in-session rather than leave a live gate red.

## Repo State Snapshot
> Re-read from live facts at S46. Every figure below is derived.

- `.ai/SESSION` = 46. **`main` = `86bc909`** (the S46 squash merge, PR #68) — derive it, never type it.
- **The repo is public.** `gh api repos/ifelse-codes/chitra --jq .private` → `false`;
  `.visibility` → `public`; the clone URL returns **200** and an anonymous `--depth=1` clone works.
  Before the flip the same probes read `true` / `404` — both rows are recorded in
  `sessions/session-46-flip.md`.
- **P1 is done, with a disclosed residual.** `(/|-)Users[-/][a-z]+` matches **0** files in **0** of
  the **444** commits reachable from `HEAD` (was **1001** (commit, file) pairs); the rewrite tip
  `8a083c8` kept the tree (`8167462…`), the count and the **367** tracked files. Force-pushed once
  with `--no-verify` (the tracked pre-push hook blocks any `main` push) — disclosed, not hidden.
  **Residual:** GitHub's `refs/pull/*` is read-only, and **56 of 67** PR heads still expose the old
  blobs; a support ticket to delete them and GC is **owed, not done**.
- **P2 is established:** `{"enabled":true}`. It could not have been green before F1 — the endpoint
  404s for private repos while a public control returns `{"enabled":false}`.
- **`0.4.0` is live with provenance**; `0.3.0` has none — the asymmetry is the proof, and **no file
  under `.github/workflows/` changed**. npm `latest` → `0.4.0`.
- **Product untouched apart from the version triple:** **453/453** tests in **23** files; no file
  under `packages/core/src/` changed except the generated `version.ts`; lockfile untouched.
- **GTM `t0` = 119 lifetime downloads, none organic** — first non-zero day is the `0.3.0` publish
  day (89) and the whole figure sits inside a 6-day window opening on that day.
- **Crew gate:** `.ai/handoffs/session-46-tech-lead.md` exists (validated: frontmatter + body +
  Handoff Delta) with `fidelity-reviewer` the only `required` role. Its provenance string is
  **unverifiable under OpenCode** — Vajra only confirms helpers from a Claude Code record — so the
  gate needs the **founder waiver** (`VAJRA_CLOSEOUT_WAIVER=46`) with that reason, exactly as the
  gate's own message prescribes for non-Claude-Code sessions.

## Next Session
- **Number:** 47 — the leading candidate is the **S45 audit's 11 findings**, chiefly
  `check_session_coverage`'s blindness (newest belief **S37**, blind for 7 sessions, and it already
  missed `sessions/session-40-summary.md` being absent), the GT cadence's absence from
  `AGENTS.md` (vajra-owned — disclosed, not smuggled), S44's undisclosed `REJECT`, the 3-file cap
  breached by 17 of 60, and the stale-fact class. Spec: `sessions/session-45-ground-truth.md`
  § *Findings, ranked*. **The GitHub support ticket for the P1 residual rides along.**
- Alternatives on the table: the **GTM proof pack** (F6 recorded `t0` only), and **new product
  surface** (~16 sessions since `c72cc14` added a chart module).
- Open in a **new chat** (one session per chat).
