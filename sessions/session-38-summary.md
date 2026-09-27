# Session 38 — summary: release runway (npm Trusted Publishing / OIDC)

**Date:** 2026-09-27 · **Branch:** `session-38-release-runway` → merged via **PR #46** (`76d21f3`)
**Contract:** `prompts/38-task-release-runway.md`

## The one-line story

The next release was one tag push away from failing, and the reason was not the one we
expected. Releases now run fully unattended, and `@ifelse.codes/core@0.2.0` was published
by CI with no long-lived token anywhere in the repo.

## What shipped

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | Trusted publisher on npmjs.com | SHIPPED (founder) | `ifelse-codes` / `chitra` / `release.yml`, `npm publish` allowed |
| 2 | `release.yml` publishes via OIDC | SHIPPED | `id-token: write` + `contents: read`; token `env:` block deleted |
| 3 | `0.2.0` published by CI, unattended | SHIPPED | tag `v0.2.0` → Release run `36321392874` → `+ @ifelse.codes/core@0.2.0` |
| 4 | Independently verified | SHIPPED | `npm view` → `0.2.0`; clean install in a temp dir renders a chart |
| 5 | Revoke the exposed npm token | **SHIPPED (founder-attested)** | `npm_xToANF…` deleted on npmjs.com, confirmed by the founder 2026-09-27 after the release proved out. Not repo-verifiable, and no check claims to. The cold review first ruled this NOT-BUILT; it is now genuinely done, and the *publish-policy* lockdown is deferred at the founder's direction |
| 6 | README honest about deferred MCP | SHIPPED *(after closeout fix)* | `render_chart` marked "not shipped yet" → `.ai/ROADMAP.md`; ROADMAP itself corrected — it had still listed the MCP server as the *next* deliverable and repeated the stale "README already advertises" claim, so the README was pointing at a doc that contradicted it |
| 7 | Verify / demo / review / closeout | SHIPPED | `verify-session-38.sh` **32/32**; `demo-session-38.sh` runs; cold review ACCEPT |

## Three findings — one of them would have shipped broken

### 1. 🔴 `pnpm publish` cannot do OIDC. The release would have failed.

pnpm is pinned at **9.12.3**, which predates npm Trusted Publishing entirely. Its auth
surface is token-only (`_authToken` / `_auth` / `tokenHelper`); it has no OIDC exchange.
Under OIDC with no token present, `pnpm publish` fails — and the error reads like a config
typo, not a missing capability. The obvious "add `id-token: write`" change would have
looked complete and shipped a red release.

Fixed by using `npm publish` for that one step (npm ≥ 11.5.1; local 11.12.1). pnpm still
does install/build/test.

**The first guard for this was hollow, and the cold review proved it.** The summary of
this session originally cited a `publish-not-pnpm` check as guarding the regression. It did
not. Both it and its companion were substring greps over the whole publish *job*, so a
`DRY_RUN` branch holding a dead `npm publish` satisfied "uses-npm" while the executed
command was `pnpm … pub` — 8 of 8 checks green with the exact bug reverted. Replaced with
`publish-uses-npm` / `publish-no-pnpm-at-all` / `publish-exactly-one-cmd`, scoped to the
publish step's `run:` block and anchored to line start, so `pnpx`, a `pub` abbreviation,
and unreachable-branch decoys are all caught. **Do not cite that check family as a guard
again without re-testing the counterfactual.**

### 2. 🟠 The repo is private → `0.2.0` ships with no provenance. Confirmed empirically.

npm does not generate provenance attestations for private repositories, even under trusted
publishing. Predicted before the release; confirmed after it — `npm view @ifelse.codes/core@0.2.0`
shows `dist.signatures` present (ECDSA) but `attestations: null`.

OIDC *publishing* is unaffected. Making the repo public would enable provenance and let
consumers read the source of an MIT-licensed package. **Founder's call, deliberately not
decided here** — the repo remains private and the workflow says so, so nobody re-discovers
this by reading a comment that lies.

### 3. 🟢 S37 never set the CI secret, so "the token was revoked" was false.

`gh secret list` returns **zero** secrets; no org secrets; no GitHub environments. S37's
own contract logs its `gh secret set NODE_AUTH_TOKEN` step as "deferred". There was never
a CI secret to revoke.

This session initially wrote a check named `token-revoked` and a demo line claiming the
token "is revoked". Both were **overclaims** — the check passed for the wrong reason and
the demo asserted something unobserved. Both were rewritten. The verify script now asserts
that `gh secret list` *actually answered* before concluding no secret exists, so an
unavailable `gh` cannot manufacture a false green.

What still exists is the npm **account** token pasted in the S37 chat (`npm_xToANF…`).
It is founder-owned, not observable from CI, so no check asserts it. **Open.**

## Proof the release was unattended

- No repo secret (`gh secret list` → `[]`), no org secret (404), no environment secret.
- A credential-less publish would fail `ENEEDAUTH`. It succeeded.
- Release run `36321392874`: 4/4 jobs green, `publish` included.
- Local npm 11.12.1 / Node 26.0.0, both above npm's 11.5.1 / 22.14.0 OIDC floor.
- `package.json` `repository.url` matches the GitHub repo exactly (npm requires this).

## Corrections to the record

- `prompts/38-task-release-runway.md` originally framed requirement 5 as "revoke the CI
  secret and set publishing access to require-2FA-disallow-tokens". Both were wrong: there
  was no CI secret, and the npm account setting needs the interactive 2FA challenge. The
  contract now says what is actually true.
- The verify script's first version used an `awk` range for the publish job. `  publish:`
  matches *both* the start pattern and any `^  [a-z-]+:$` end pattern, collapsing the
  range to a single line — so `oidc-keeps-contents-read` and `no-node-auth-token` were
  false FAILs, and after the first fix several checks false PASSed because `$REL` and the
  helper functions were not exported into the `bash -c` subshell. Fixed with `sed` +
  `export -f`; the awk trap is commented in the script so it is not repeated.
- `branch-is-s38` asserted `HEAD == session-38-*`, which cannot pass when verify runs
  against merged `main` — and merged `main` is what proves the release. Replaced with
  `pr-from-session-branch` + `not-on-squashed-main` (squash-merge deliberately makes the
  branch tip a non-ancestor, so ancestry is the wrong test).

## Verification

`scripts/verify-session-38.sh` → **ALL GREEN (32 pass, 0 fail)**, including core 452/452,
typecheck, build, docs typecheck, chart-drift, and a clean-room install of the
CI-published `0.2.0` that actually renders a chart.

**The check that carries the session.** The cold review's sharpest finding was that
`npm-0.2.0-live`, `npm-latest-is-0.2.0` and `v0.2.0-tag-pushed` all pass *identically*
whether CI published `0.2.0` or a human ran `npm publish` locally two minutes earlier
with the S37 account token. So the proof of "unattended" was missing. Added
`published-after-run-start`, which compares npm's authoritative `time["0.2.0"]`
(**13:11:11Z**) against the Release run's `createdAt` (**13:09:02Z**) and requires the
publish to be *no earlier* than the run. That ordering is the discriminator, and it needs
no npm auth — packument `time` is public.

## Cold review — what it caught that I did not

Verdict **ACCEPT** (4 of 7 SHIPPED, 2 PARTIAL, 1 NOT-BUILT as it first read), scoped
honestly: *a release that works, not a verification layer that works.* Its findings were
not cosmetic:

- **The pnpm guard was hollow** (above) — fixed, with a standing warning not to re-cite it.
- **"Unattended" was unfalsifiable** (above) — `published-after-run-start` added.
- **Requirement 6 pointed at a doc that contradicted it.** The new README text said the
  deferral was tracked in `.ai/ROADMAP.md`, but ROADMAP still listed the MCP server as the
  *next* deliverable and still repeated the exact "README already advertises…" claim the
  README had just corrected. A fresh dangling cross-reference — the rider's stated purpose
  failed. ROADMAP now records the deferral, its gate, and S38.
- **Two more dressed-up greens.** `repo-visibility-known` matched `PUBLIC|PRIVATE`, which
  is every value a github.com repo can have — it could not fail on the value it named, and
  it never pinned the `PRIVATE` fact the whole provenance finding rests on. Replaced.
  `not-on-squashed-main` was green on any commit containing the phrase "S38: release
  runway", including an empty no-op or a `Revert`; replaced with a check that the squash
  commit actually *touched* `release.yml`.
- **A gate was swapped mid-closeout, after the release** — the most uncomfortable pattern
  in the file, because it is exactly when nobody is looking. Recorded here rather than
  quietly fixed.
- **Requirement 5 is NOT-BUILT, not PARTIAL.** Nothing was done, and nothing can be
  asserted from CI. The honest part is the *labeling*: the contract pre-authorized it as
  founder-only and the guardrail forbids claiming revocation, so the demo correctly prints
  `FOUNDER: revoke npm_xToANF… at npmjs` and never "revoked". The real risk the review
  names is sequencing: **the unblocking event has now occurred** and the delivery records
  it only as a `dim` line in a demo. Promoted to a next-options item below.
- **Two known limits, left standing rather than papered over.** The trusted publisher's
  existence is inferred from outcome (publish succeeded with zero tokens ⇒ OIDC worked),
  not asserted — npm's trusted-publisher API needs a session token. And `ci-no-auth-token-secret`
  covers *repo* secrets only, not org or environment secrets (there are none today, and
  no environments are configured).

## Cost

One opencode session. Token/`$` cost unmeasured (billed to the founder's opencode plan).
npm publish cost: $0 (public package). Release-runner minutes: ~2.

## Next options

The founder's direction on closing S38: **stop hardening, ship, and watch for adoption.**
The publish-policy lockdown and the provenance gap are both explicitly deferred on that
basis. So the ranked list is now about *demand*, not defence.

1. **GTM proof pack** — benchmarks / token-savings / before-after. Unblocked: there is a
   real `0.2.0` with an installable tarball to measure and point at. This is the one item
   that both produces evidence *and* creates the surface people can find.
2. **Watch adoption before hardening further** — the founder's stated plan. Decide on a
   trigger (first real install, first external issue) rather than a date, so "nobody is
   asking" stays a measurement instead of an assumption. When it fires: set *Publishing
   access → require 2FA and disallow tokens*, and decide repo visibility (public would
   turn on npm provenance and expose an MIT package's source).
3. **Fix the `required-crew` gate at the root** — it demands a tech-lead handoff that
   `.ai/AGENTS.md`'s Session Loop never asks for, and S37 failed it too. Either surface
   the crew step in the constitution or drop the gate. Right now it is a tax that only
   ever fires as red.
