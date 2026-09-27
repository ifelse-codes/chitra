# Session 38 — task: release runway (npm Trusted Publishing / OIDC)

**Resume point.** S37 (PR #43) published `@ifelse.codes/core@0.1.0` and PR #45 landed
the handoff. Founder in-chat direction: **MCP server is deferred** until a release
exists *and* someone demands it. Releases must be **fully automated — no manual step**.

## Context (do not re-derive)

- `release.yml#publish` authenticates with a long-lived `NODE_AUTH_TOKEN` secret.
  npm is **deprecating bypass-2FA tokens** for direct publishing, so the *next* tag
  push would fail. S37 recorded this as honestly NOT-BUILT.
- The token from the S37 chat (`npm_xToANF…`) was pasted in plaintext and is still
  valid. It is unowned security debt.
- `packages/core` version is `0.1.0`; `v0.1.0` tag sits on `main` HEAD
  (`fd8a96e`); Release workflow is green (publish job skips — idempotent).
- Prereqs verified this session, all green:
  - `repository.url` = `https://github.com/ifelse-codes/chitra.git` — matches the repo
    exactly (npm requires this for OIDC from a public repo).
  - Node 26 / npm 11.12.1 locally; CI pins Node `26` (npm floor for OIDC is 11.5.1,
    Node floor 22.14.0). Both satisfied.

## ⚠ The trap that silently breaks this (Sep 3 2026 rule change)

npm trusted-publisher configs **created after 2026-09-03 default to `npm stage publish`
only** — direct `npm publish` is *not* allowed unless explicitly opted in. Our workflow
publishes with `pnpm … publish` (i.e. `npm publish`). So the founder **must tick
"allow `npm publish`"** when creating the publisher, or the first automated release
fails with an auth error that looks like a config typo.

npm does **not** validate the trusted publisher on save. Errors surface only on publish.

## Findings this session (all verified, not assumed)

1. **🔴 `pnpm publish` cannot do OIDC — the release would have failed.** pnpm is
   pinned at **9.12.3**, which predates npm Trusted Publishing entirely; pnpm's auth
   surface is token-only (`_authToken` / `_auth` / `tokenHelper`) and it has no OIDC
   exchange. The publish step now runs `npm publish` (npm ≥ 11.5.1 is OIDC-capable).
   pnpm still does install/build/test — only the publish step moved. Guarded by the
   `publish-not-pnpm` verify check.
2. **🟠 The repo is PRIVATE, so `0.2.0` ships WITHOUT npm provenance.** npm does not
   generate provenance attestations for private repositories even under trusted
   publishing (documented npm limitation). OIDC *publishing* itself is unaffected.
   Making the repo public would enable provenance and arguably suits an MIT-licensed
   package — surfaced to the founder, not decided here.
3. **🟢 S37 never actually set the CI secret.** `gh secret list` returns **zero**
   secrets; S37's own contract logs step 2 as "deferred". So there was never a
   `NODE_AUTH_TOKEN` secret to revoke — the earlier claim that it was "revoked" was
   wrong and is corrected here. What *does* still exist is the npm **account** token
   pasted in the S37 chat; only the founder can revoke that, and it is not
   observable from CI, so no verify check asserts it.
4. **Release-job cache removed.** npm's own Trusted Publishing example says never use
   caching in release builds; the pnpm store is restored into the very tree we
   publish from, so the publish job now installs uncached.

## Requirements

1. **Founder: create the trusted publisher on npmjs.com** for
   `@ifelse.codes/core` → Settings → Trusted Publisher → GitHub Actions, with:
   - Organization or user: `ifelse-codes`
   - Repository: `chitra`
   - Workflow filename: `release.yml`  ← filename only, not the path; case-sensitive
   - Environment name: *(leave empty — we use no GitHub environments)*
   - **Allowed actions: `npm publish` explicitly enabled** (see the trap above)
2. **Rewrite `release.yml#publish` for OIDC:**
   - `permissions:` → `id-token: write` + `contents: read`
   - remove the `env: NODE_AUTH_TOKEN` step entirely
   - keep `registry-url` (npm's own example keeps it)
   - keep the existing "skip if version exists" idempotency guard
3. **Bump `packages/core` to `0.2.0`** and cut the release **from `main` after merge**,
   so the tag carries post-merge code. Push `v0.2.0`; the publish must run with
   **no human, no tmux, no passkey**.
4. **Verify, independently of CI logs:**
   `npm view @ifelse.codes/core version` → `0.2.0`, and a clean
   `npm install @ifelse.codes/core@0.2.0` in a temp dir resolves.
5. **Then revoke the exposed npm account token** at npmjs.com → Access Tokens (the
   `npm_xToANF…` token pasted in the S37 chat). Ordering per npm's migration tip:
   publisher first → verify it works → then restrict token access. **There is no CI
   secret to remove** (finding 3) — this is the founder's npm account, and it is not
   assertable from CI.
6. **Rider (hygiene, ≤1 line):** the README's `server.tool("render_chart", …)` snippet
   advertises an MCP handler that does not ship and now will not until demand. Mark it
   as roadmap so the deferral leaves no dangling promise.
7. **Verify script + demo + summary + independent cold review + closeout.**
   `scripts/verify-session-38.sh` exits 0; sync `.ai/` and `.ai/SESSION` → 38.

## Out of scope

- **MCP server** — founder-deferred, demand-led (do not build, do not stub).
- GTM proof pack, `artifacts/api-server` (S39+ candidates; the proof pack wants a real
  `0.2.0` to point at, so it comes after this session).

## Guardrails

Atomic commits ≤3 files; branch `session-38-*`; PR to `main`; founder approval token
before commits. Tag only from merged `main`. Do not claim the npm account token is
revoked until the founder confirms it (it is not observable from this repo).

## Execution

- step 1 — **PENDING (founder, browser)**: trusted publisher not yet confirmed created
- step 2 — done: `release.yml` OIDC rewrite (id-token: write, token env deleted,
  `pnpm publish` → `npm publish`, release-job cache dropped)
- step 3 — done: core `0.1.0` → `0.2.0`; lockfile unaffected (`workspace:*`, verified
  with `pnpm install --frozen-lockfile`); tag still to be cut from merged `main`
- step 4 — pending: needs the tag (3 verify checks legitimately red until then)
- step 5 — pending: founder-only, npmjs.com Access Tokens
- step 6 — done: README `render_chart` handler marked **not shipped yet** → ROADMAP
- step 7 — in progress: verify `26 pass / 3 fail` (all 3 = the un-cut tag), demo runs,
  summary + cold review + closeout to follow
