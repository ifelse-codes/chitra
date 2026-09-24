# Ground-Truth Remediation Ledger

> The teeth the S35 audit found missing: ground-truth findings used to be written and
> forgotten (S05's remediation debt sat open 30 sessions). Every ground-truth session's
> remediations are copied here and **must be dispositioned `DONE`, `WAIVED`, or
> `DEFERRED`** (founder-deferred, with the reason in Evidence) before the next closeout
> passes — `scripts/verify-closeout.sh#check_gt_remediations` fails on any other status.
> One row per remediation, newest ground-truth first.

## S35 (`sessions/session-35-ground-truth.md`) → folded into S36

| # | Finding (S35) | Status | Evidence |
|---|---|---|---|
| 1 | Stale local `v0.1.0` tag on the 2026-07-29 commit; push would publish July code | DONE | stale tag deleted (`git tag -d v0.1.0`); `release.yml` made idempotent. Re-cut of `v0.1.0` travels with the publish (item 2) |
| 2 | `@ifelse.codes/core` not on npm (E404); distribution stalled | DEFERRED | founder deferred the publish to S37 (needs a **Classic Automation token** or Granular-with-Bypass-2FA; the Publish token given returns npm E403 "2FA … required"). Package is publish-ready: dry-run green, 38 files / 94.2 kB |
| 3 | Docs-hero pills stale (`v0.1.0 — stable`, `134`) | DONE | `App.tsx` → `v0.1.0` / `452`; site redeployed and verified in the live bundle |
| 4 | KNOWLEDGE.md false facts (142/163/442, 7 files, dist, CI, main range) | DONE | `.ai/KNOWLEDGE.md` corrected; one canonical count (452) |
| 5 | STATE/SESSION-BOOT/TASK a merge behind (S34 PR #40) | DONE | `.ai/` synced to S36 |
| 6 | S05 closeout-integrity debt (S17/S32 artifact-less) + no CI gate | DONE | S17/S32 backfilled; `verify-closeout.sh#check_session_coverage` added |
| 7 | GT findings have no closure mechanism | DONE | this ledger + `check_gt_remediations` gate |
| 8 | "No code in Ground Truth" declared hook-enforced but no hook | DONE | `.ai/hooks/hook-ground-truth-guard.sh` + `check_ground_truth_no_code` |
| 9 | Cost tracking has no number | DONE | `STATE.md#Cost Tracking` carries a measured line |
| 10 | Vision (AI-first) demands an MCP item the roadmap lacks | DONE | MCP-server item added to `.ai/ROADMAP.md` |
| 11 | README `/ai-data` link points at an undeployed page | DONE | site redeployed with the S33 AI-data page live (verified HTTP 200) |

## Template for the next ground truth

| # | Finding | Status | Evidence |
|---|---|---|---|
| 0 | _(none yet)_ | DONE | — |
