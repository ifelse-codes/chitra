# chitra — Continuation Handoff (after S37)

**Resume in a NEW chat (S38).** `main` = S00–S37 (`9bfb0da`); `.ai/SESSION` = 37;
`v0.1.0` tag on `main` HEAD; **`@ifelse.codes/core@0.1.0` is LIVE on npm**.

## Where we are

S37 (PRs **#43** publish + **#44** sync) closed the S36-deferred npm publish. Full
detail: `sessions/session-37-summary.md` + `sessions/session-37-review.md` (cold
**ACCEPT**) + `.ai/STATE.md`.

| Delivered in S37 | State |
|---|---|
| npm publish | `@ifelse.codes/core@0.1.0` live (`latest`); clean install verified |
| Rename | `@chitra/core` → `@ifelse.codes/core` (the `@chitra` org isn't ours) |
| `v0.1.0` tag | on `main` HEAD; Release workflow **green** (publish skipped, idempotent) |
| Docs | README install real; hero pill `v0.1.0 · npm` |
| GT ledger | row 2 → `DONE`; gates hardened (DEFERRED reason+expiry; GT offender path) |
| `release.yml` | latent docs-job bug fixed (it had never run — no `v*` tag before) |

## S38 candidates (founder picks the goal + writes the contract)

1. **MCP server** — README advertises a `server.tool("render_chart", …)` handler;
   nothing ships it. Highest-leverage for the AI-first vision.
2. **GTM proof pack** — benchmarks / token-savings / before-after.
3. **`artifacts/api-server`** — flesh out beyond `/healthz`.

## Notes / gotchas

- **CI publishing:** npm is deprecating bypass-2FA tokens. A *future* version's
  tag-driven publish needs npm **Trusted Publishing (OIDC)**, not `NODE_AUTH_TOKEN`
  (req 2 of S37 was honestly NOT-BUILT).
- **Local publishing needs a TTY + passkey** — run `npm publish` inside `tmux`,
  press Enter, approve the passkey. A non-TTY shell only returns `EOTP`.
- Frozen `sessions/`, old `prompts/`, and old `scripts/verify-session-*.sh` still
  name `@chitra/core` (history). `scripts/workflows/15-qacheck.sh` is a frozen
  session-15 artifact and cannot pass — ignore it.
- **Rotate the npm token pasted in the S37 chat** (`npm_xToANF…`).

## Housekeeping

- `pnpm --filter @ifelse.codes/core run test` → 452 green;
  `scripts/verify-session-37.sh` → ALL GREEN; `scripts/verify-closeout.sh` → 16/16.
