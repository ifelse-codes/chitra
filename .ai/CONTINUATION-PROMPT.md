# chitra — Continuation Handoff (after S36)

**Resume S37 in a NEW chat from `prompts/37-task-publish-v0.1.0.md`.**
`main` = S00–S36 (`57a0b13`). `.ai/SESSION` = 36.

## Where we are

S36 (PR #41) closed every S35 ground-truth finding except one, and unfroze the
live deploy. Full detail: `sessions/session-36-summary.md` +
`sessions/session-36-review.md` (cold ACCEPT) + `.ai/STATE.md`.

| Done in S36 | State |
|---|---|
| Live docs deploy (S31 freeze lifted) | `chitra.iifelse.com` live, `/ai-data` 200 |
| Docs-hero pills honest | `v0.1.0` / `452` |
| KNOWLEDGE.md facts | corrected (452 / 23 files / Node 26 / main S00–S36) |
| S05 closeout debt | S17/S32 backfilled + `check_session_coverage` |
| GT teeth | `.ai/GT-REMEDIATIONS.md` + `check_gt_remediations` + hook |
| `release.yml` | idempotent (skip if version exists) |
| stale `v0.1.0` tag | deleted |

## The one open item (S37)

**Publish `@chitra/core@0.1.0` to npm.** S36's attempt failed with
`E403 … 2FA or granular token with bypass 2fa required` — the supplied token was a
*Publish* token. npm needs a **Classic Automation token** (or Granular with
**Bypass 2FA** ON). Then:

```bash
cd packages/core && npm publish --access public --no-git-checks
gh secret set NODE_AUTH_TOKEN --repo ifelse-codes/chitra   # for tag-driven releases
npm view @chitra/core@0.1.0 version                        # -> 0.1.0
# re-cut + push v0.1.0 on main; release.yml skips the already-published version
```

The package is publish-ready (dry-run: 38 files / 94.2 kB / public). Update
`.ai/GT-REMEDIATIONS.md` row 2 → `DONE` when done.

## S36 process miss (disclosed)

PR #41 was **merged before the branch was re-pushed**, so main initially landed
without the round-1/round-2 review fixes and the cold-review file. A follow-up PR
carries them. **Lesson: `git push` the branch before `gh pr merge`.** S37's
contract restates this.

## S37 follow-ups (from the S36 review)

- Exercise `check_ground_truth_no_code`'s offender path (S36 only hit its N/A branch).
- Require `DEFERRED` ledger rows to carry a reason/expiry.
- Then S38 candidates: MCP server, GTM proof pack, api-server beyond `/healthz`.

## Housekeeping

- Rotate the npm token pasted in the S36 chat.
- `pnpm --filter @chitra/core run test` → 452 green; `scripts/verify-session-36.sh`
  → ALL GREEN.
