# Session 37 — Summary

**Type:** CODE — publish the S36-deferred npm package under a scope the account owns.
**Branch:** `session-37-publish-v0.1.0` · **Date:** 2026-09-24.
Founder in-chat direction: close the deferred npm publish ("Rename to my personal
scope"). Branch/PR rules kept; the rename is a founder decision recorded here.

## What shipped

| # | Requirement (contract) | Result |
|---|---|---|
| 1 | Publish `@ifelse.codes/core@0.1.0` to npm | **SHIPPED** — but the package name had to change first: `@chitra/core` → `@ifelse.codes/core` (the `@chitra` npm org is not owned by the account). Published: 38 files / 94.2 kB, `latest`; consumer install verified |
| 2 | Set repo secret `NODE_AUTH_TOKEN` | **NOT-BUILT** — npm is **deprecating bypass-2FA tokens** for direct publishing; a usable token cannot be minted. CI publishing now needs npm **Trusted Publishing (OIDC)**. The release publish job skips (version exists), so it stays green without the secret |
| 3 | Verify `npm view @ifelse.codes/core@0.1.0` → `0.1.0` | **SHIPPED** — `0.1.0`; packument `200`, tarball `200`, dist-tag `latest` |
| 4 | Re-cut + push `v0.1.0`; release workflow green | **PENDING** — must be cut on the **post-merge `main` HEAD** (tagging the branch would run the old workflow); flow verified idempotent |
| 5 | README install line real; bump hero pill | **SHIPPED** — README install section is now a real `pnpm add @ifelse.codes/core`; hero pill `v0.1.0 · npm` |
| 6 | Ledger row 2 → DONE; sync `.ai/` → 37 | **SHIPPED** — `.ai/GT-REMEDIATIONS.md` row 2 `DONE`; SESSION 37 + boot/task/state/roadmap/knowledge synced |
| 7 | Fix the two S36-review weaknesses | **SHIPPED** — `check_gt_remediations` now requires a `DEFERRED` row's Evidence to carry a reason **and** expiry; `verify-closeout.sh --gt-no-code-only N` exercises the GT no-code **offender path** (proven blocking) |
| 8 | S37 verify/demo/summary/cold review/closeout | **SHIPPED** — `verify-session-37.sh` 20/20, `demo-session-37.sh` exit 0; this summary; cold review; closeout |

**Extra (founder-directed, required for req 1):** renamed the package across **26 live
files** (identity, workspace deps + lockfile, docs imports/scripts, CI workflows, README/
CONTRIBUTING/replit, tooling, `.ai/`). Frozen `sessions/` + old `prompts/` left as
history. Post-rename: core **452/452**, typecheck, build, docs typecheck, chart-drift green.

## Root cause of the S36 stall (two layers, both found here)

1. **npm's web/passkey 2FA only runs on a TTY.** `npm/lib/utils/auth.js#otplease`
   bails early unless `stdin.isTTY && stdout.isTTY`; a normal non-TTY shell gets
   `EOTP` with a masked URL. Fixed by publishing inside **tmux** and approving the
   passkey. (Passkey 2FA cannot produce a 6-digit OTP.)
2. **`@chitra` is an npm org the account does not own** (`npm org ls chitra` → 403;
   unscoped `chitra` taken at v0.1.14). The S36 diagnosis ("needs a Classic Automation
   token") was one layer short — no token type fixes scope ownership.

## Limits (disclosed)

- Req 2 NOT-BUILT (token deprecation) — a **future version** cannot be tag-published
  with a long-lived token; it needs Trusted Publishing (OIDC). Not falsely marked green.
- Req 4 PENDING — the `v0.1.0` tag is cut on post-merge `main`; until then the release
  workflow has not run for S37.
- Frozen `sessions/`, old `prompts/`, and old `scripts/verify-session-*.sh` still name
  `@chitra/core` (history, not re-run). The live build surface is clean.
- `scripts/workflows/15-qacheck.sh` was renamed cosmetically but is a **frozen session-15
  artifact** (hardcodes `session-15-*`, `163 passed`, "core unchanged from main") — it is
  not a live gate and cannot pass against the current suite; disclosed, not rewritten.
- Publish propagation lag (~6 min): the `PUT` returned 200 and the tarball was live
  immediately, but the packument 404'd briefly — no re-publish was needed.

## Evidence

| Item | Value |
|---|---|
| npm | `@ifelse.codes/core@0.1.0`, 38 files / 94.2 kB, `latest`; consumer install OK |
| Publish log | `PUT 200 registry.npmjs.org/@ifelse.codes%2fcore` (web-auth via tmux) |
| Rename | 26 live files; 10 atomic commits `bd9a41b`…`230e90c` |
| Gate hardening | `0555a23` — DEFERRED reason+expiry; `--gt-no-code-only` offender path |
| `.ai` sync | `5c9688b` (SESSION/Boot/Task), `e7c2857` (State/Roadmap/Knowledge) |
| Verify | `scripts/verify-session-37.sh` — **20/20 ALL GREEN** |
| Demo | `scripts/demo-session-37.sh` — exit 0 |

## Cost

One opencode session: a 26-file rename (10 commits), one real npm publish (web/passkey
via tmux), docs honesty, ledger + two gate hardenings, S37 artifacts. Token/`$` cost
unmeasured (founder's opencode plan). npm publish cost $0 (public package).
