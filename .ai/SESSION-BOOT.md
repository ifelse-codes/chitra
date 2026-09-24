# Session Boot

## Current Session
- **Number:** 37 — DONE (published `@ifelse.codes/core@0.1.0`; tag + PR to go)
- **Type:** CODE — publish the S36-deferred npm package under a scope the account owns
- **Branch:** `session-37-publish-v0.1.0` (close on branch; PR to `main` to go)
- **Date last updated:** 2026-09-24

## Repo State Snapshot
- `.ai/SESSION` = 37.
- Remote: `github.com/ifelse-codes/chitra`. `main` has S00–S36 (PR #42 merged,
  `085425f`).
- **S37 delivery**: renamed `@chitra/core` → `@ifelse.codes/core` across 26 live
  files (frozen `sessions/` + old `prompts/` left as history) and **published to
  npm**: `@ifelse.codes/core@0.1.0`, 38 files / 94.2 kB, dist-tag `latest`;
  consumer install verified. README install line + docs-hero pill made honest;
  `.ai/GT-REMEDIATIONS.md` row 2 (`DEFERRED`) → `DONE`; closeout gates hardened per
  the S36 review (a `DEFERRED` ledger row now needs a reason + expiry; the GT
  no-code offender path is exercised via `verify-closeout.sh --gt-no-code-only`).
- **Root cause of the S36 stall (two layers, both found in S37):**
  (a) npm's `otplease` only runs the web/passkey 2FA flow when stdin+stdout are
  TTYs — solved by publishing inside `tmux`; (b) `@chitra` is an npm **org the
  account does not own** (`npm org ls chitra` → 403; unscoped `chitra` was taken),
  so the package was renamed to the founder's `@ifelse.codes` scope (free).
- **npm publish is DONE** — the S36 `DEFERRED` item is closed.
- **CI publish caveat:** npm is **deprecating bypass-2FA tokens** for direct
  publishing; the tag-driven `release.yml` publish job skips (version already
  exists) so it stays green, but a *future* version needs npm **Trusted Publishing
  (OIDC)**, not a long-lived token.

## Next Session
- **Number:** 38 — MCP server / GTM proof pack / `artifacts/api-server`; and, if not
  closed here, the `v0.1.0` tag + PR follow-through.
- Open in a **new chat** (one session per chat).
