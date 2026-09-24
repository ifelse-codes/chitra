# Current Task Pointer

## Session 36 — close the S35 ground-truth gaps + unfreeze deploy — DONE (npm deferred)

- **Branch:** `session-36-close-audit-gaps` (close on branch; PR to `main` to go)
- **Contract:** `prompts/36-task-close-audit-gaps.md` (12 numbered requirements).
  Founder in-chat direction: "target session 36 and fill all the issues" from the
  S35 ground-truth audit; run the real release + unfreeze. Founder waived
  one-session-per-chat (S36 runs in the S35 chat).
- **Delivery:** docs-hero pills honest (`v0.1.0` / `452`); KNOWLEDGE facts fixed;
  ROADMAP S35/S36 + MCP item + S05 debt closed; GT ledger + 3 closeout gates +
  no-code-in-GT hook; S17/S32 records backfilled; `release.yml` idempotent; live
  deploy **unfrozen** and verified (`chitra.iifelse.com` 200, `/ai-data` 200).
- **Deferred:** npm publish of `@ifelse.codes/core@0.1.0` → **S37** (needs a Classic
  Automation token; the Publish token returns E403 2FA). Stale `v0.1.0` tag
  deleted; re-cut with the publish.
- Verify: `scripts/verify-session-36.sh`. Demo: `scripts/demo-session-36.sh`.
  Summary: `sessions/session-36-summary.md`; review: `sessions/session-36-review.md`.
- **To go:** commit + PR to `main`; then S37 release.

**Next session (S37):** publish `@ifelse.codes/core@0.1.0` (Classic Automation token),
re-cut + push `v0.1.0`; then MCP server / GTM proof pack / api-server. Open in a
**new chat**.
