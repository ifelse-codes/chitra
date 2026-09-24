# Session 37 — task: publish `@chitra/core@0.1.0` + re-cut `v0.1.0`

**Resume point.** S36 (PR #41, `57a0b13`) closed the S35 ground-truth gaps and
unfroze the live deploy. The one deferred item is the npm publish. Start S37 in a
**new chat** (one session per chat).

## Context (do not re-derive)

- `@chitra/core@0.1.0` is **publish-ready but NOT on npm** — S36's publish attempt
  returned `E403 … 2FA or granular token with bypass 2fa required`. The token used
  was a *Publish* token; npm requires a **Classic Automation token** (or a Granular
  token with **Bypass 2FA** ON).
- `.github/workflows/release.yml` is now **idempotent** (skips publish if the
  version exists) — a re-pushed `v*` tag stays green.
- The stale local `v0.1.0` tag was **deleted**; no `v*` tag exists.
- Live docs are **unfrozen and current** (`chitra.iifelse.com`, `/ai-data` live).
- Open remediation ledger: `.ai/GT-REMEDIATIONS.md` (row 2 = publish, `DEFERRED`).

## Requirements

1. Obtain a **Classic Automation token** (npmjs.com → Access Tokens → Classic →
   Automation) — founder-supplied. Publish from `packages/core`:
   `npm publish --access public --no-git-checks`.
2. Set the repo secret so tag-driven releases work:
   `gh secret set NODE_AUTH_TOKEN --repo ifelse-codes/chitra`.
3. Verify: `npm view @chitra/core@0.1.0 version` → `0.1.0`.
4. Re-cut `v0.1.0` on the current `main` HEAD and push the tag; confirm the
   Release workflow goes green (publish job skips as already-published).
5. Flip the S34 README install line from "not on npm yet" to a real install; bump
   the docs hero status pill if warranted.
6. Update `.ai/GT-REMEDIATIONS.md` row 2 → `DONE`; sync `.ai/` (STATE/ROADMAP/
   SESSION-BOOT/TASK) and `.ai/SESSION` → 37.
7. Fix the two S36-review weaknesses: exercise `check_ground_truth_no_code`'s
   offender path; require `DEFERRED` ledger rows to carry a reason/expiry.
8. S37 verify/demo + summary + cold review + closeout.

## Out of scope
- MCP server, GTM proof pack, api-server (S38 candidates).

## Guardrails
Atomic commits ≤3 files; branch `session-37-*`; PR to `main`; founder approval
token before commits. **Push the branch before merging the PR** (S36 miss).

## Execution
- step 1 — done: published `@ifelse.codes/core@0.1.0` (package renamed from `@chitra/core` at the founder's direction; see `sessions/session-37-summary.md`)
- step 2 — deferred: npm is deprecating bypass-2FA tokens for direct publishing; a future CI publish needs **Trusted Publishing (OIDC)**
- step 3 — done: `npm view @ifelse.codes/core@0.1.0` → `0.1.0`
- step 4 — pending: re-cut + push `v0.1.0` on the post-merge `main` HEAD
- step 5 — done: commit `230e90c` (README install + hero pill)
- step 6 — done: commit `e7c2857` (ledger row 2 DONE + `.ai/` sync → 37)
- step 7 — done: commit `0555a23` (DEFERRED reason+expiry; GT offender path exercised)
- step 8 — done: verify/demo/summary + cold review (this session)
