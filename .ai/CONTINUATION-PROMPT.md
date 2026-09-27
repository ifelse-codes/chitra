# chitra — Continuation Handoff (after S38)

**Resume in a NEW chat (S39).** `main` = S00–S38 (`0405efc`); `.ai/SESSION` = 38;
`v0.2.0` tag on `main` HEAD; **`@ifelse.codes/core@0.2.0` is LIVE on npm** (`latest`).

> **S39's goal is already decided: rename the package to `@ifelse.codes/chitra`.**
> Founder-approved 2026-09-27. Read the S39 section below first — the name is verified
> free, the scope was never the problem, and the work is roughly one session.

## Where we are

S38 (PRs **#46** release + **#47** closeout + **#49**/**#50** records) turned the release
path fully automated. Full detail: `sessions/session-38-summary.md` +
`sessions/session-38-review.md` (cold **ACCEPT**) + `.ai/STATE.md`.

| Delivered in S38 | State |
|---|---|
| OIDC release path | `release.yml#publish` uses `id-token: write`; **no npm secret in CI at all** |
| `0.2.0` | **published by CI, unattended** — no human, no tmux, no passkey |
| The real blocker | **pnpm 9.12.3 cannot do OIDC** — publish step moved to `npm publish` |
| Proof of "unattended" | npm `time["0.2.0"]` 13:11:11Z ≥ Release run start 13:09:02Z |
| npm token | `npm_xToANF…` **revoked** on npmjs.com (founder-confirmed 2026-09-27) |
| MCP server | **founder-DEFERRED** — README labelled "not shipped yet"; ROADMAP records it |
| Verify hardening | 4 hollow checks the cold review proved hollow, rebuilt + counterfactuals |

## S39 goal (founder-approved 2026-09-27) — rename to `@ifelse.codes/chitra`

The npm page currently reads `@ifelse.codes/core`, which buries the product name in
every install command. **The scope was never the problem — the part after the slash is.**
`@ifelse.codes` is a namespace the account owns; the package name inside it is a free
choice. Founder decision: **`@ifelse.codes/chitra`**.

Availability re-verified on 2026-09-27:

| Name | Status |
|---|---|
| `chitra` (bare) | taken — `chitranga123`, an unrelated Angular sample lib, v0.1.14 |
| `@chitra/core` | 404 — the `@chitra` npm org exists but is not ours (S37: `npm org ls` → 403) |
| **`@ifelse.codes/chitra`** | **free (404)** |

Shape of the work (S39, one story):

1. Rename `@ifelse.codes/core` → `@ifelse.codes/chitra` across the live files. S37 already
   did exactly this rename (26 live files, 10 atomic commits) and left the frozen
   `sessions/` + old `prompts/` as history — repeat that boundary.
2. Publish **`@ifelse.codes/chitra@0.1.0`** through the OIDC path S38 built. This is also
   the first real test of that pipeline on a **brand-new package name**, so the
   trusted-publisher config must match the new name on npmjs.com (one trusted publisher
   per package; `0.2.0`'s config does not carry over).
3. `npm deprecate @ifelse.codes/core "renamed to @ifelse.codes/chitra"`. npm cannot rename,
   so the old package stays on the registry — deprecating makes its page read *"use
   @ifelse.codes/chitra instead"*, which beats a silent 404. Note `0.1.0`/`0.2.0` were
   published >72h / today respectively, so only today's version is unpublishable, and
   deprecation is the better move anyway.
4. Two one-line honesty fixes while in `package.json`: **drop `mcp` from the keywords**
   (nothing ships it — it is founder-deferred, and a keyword is a promise in a search
   index) and lead the `description` with the name.
5. Update every live reference: workspace deps + lockfile, docs imports/scripts, CI
   workflows, README/CONTRIBUTING/replit, tooling scripts, `.ai/`.

**Adoption is ~104 downloads, all within the last week** — essentially the founder's own
verification installs. There is nothing to break, which is why this is worth doing now
rather than after real users exist.

## Later candidates (founder ranks after S39)

1. **GTM proof pack** — benchmarks / token-savings / before-after. Unblocked: a real
   installable tarball now exists to measure. Best done *after* the rename, so the
   measured install command is the final name.
2. **Adoption watching** — decide a *trigger* (first real install, first external issue)
   rather than a date, so "nobody is asking" stays a measurement. When it fires: set
   *Publishing access → require 2FA and disallow tokens*.
3. **Fix the `required-crew` gate at the root** — it demands a tech-lead handoff that
   `.ai/AGENTS.md`'s Session Loop never asks for, and **S37 failed it too**. Either surface
   the crew step in the constitution or drop the gate. **This is why S38 needed a founder
   waiver, and S39 will need one too unless it is fixed first.**
4. **MCP server stays deferred** — until a release exists *and* someone demands it.
   `@ifelse.codes/core@0.2.0` counts as a release; demand is the missing half.

## Notes / gotchas

- **pnpm cannot do npm Trusted Publishing.** pnpm 9.12.3 predates the feature; its auth is
  token-only (`_authToken` / `_auth` / `tokenHelper`). `pnpm publish` under OIDC fails with
  an error that looks like a config typo, not a missing capability. Use `npm publish`
  (npm ≥ 11.5.1, Node ≥ 22.14.0) for the publish step only. **Reusable constraint.**
- **npm trusted-publisher configs created after 2026-09-03 default to `npm stage publish`
  only.** Direct `npm publish` is denied unless explicitly opted in. npm does **not**
  validate on save — the failure surfaces only at publish time. The founder ticked it for
  `0.2.0`; anyone adding a package must too.
- **The repo is PRIVATE, so `0.2.0` has no npm provenance** (`attestations: null`;
  `dist.signatures` is present and is *not* evidence of provenance). OIDC publishing is
  unaffected. Making the repo public would fix it and suits an MIT package — deferred at
  the founder's direction. If visibility flips, `release.yml`'s comment must change too or
  it becomes a lie.
- **Verify-script traps that cost real time this session:** an `awk` range
  `/^  publish:/,/^  [a-z-]+:$/` collapses to ONE line (the start line also matches the end
  pattern) — use `sed -n '/start/,$p'`; and helpers shelled out via `bash -c` need both
  the function *and* every variable it reads `export -f`/`export`ed.
- **A check coupled to a string or a commit's position is not a guard.** Three versions of
  the same S38 check failed three different ways: green on a no-op, green on a `Revert`,
  then red on a perfectly good state. Assert the *fact* (`git show origin/main:<file>`),
  never a phrase or a tip commit.
- Frozen `sessions/`, old `prompts/`, and old `scripts/verify-session-*.sh` still name
  `@chitra/core` (history). `scripts/workflows/15-qacheck.sh` is a frozen session-15
  artifact and cannot pass — ignore it.

## Housekeeping

- `pnpm --filter @ifelse.codes/core run test` → **452 green**
- `scripts/verify-session-38.sh` → **34/34** (run from `main`)
- `scripts/verify-closeout.sh 38` → **16/16** with
  `VAJRA_CLOSEOUT_WAIVER=38` (`required-crew`, founder-waived, recorded in the close log)
- `scripts/demo-session-38.sh` → runs, reports pending states honestly
