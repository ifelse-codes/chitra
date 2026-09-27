# chitra — Continuation Handoff (after S38)

**Resume in a NEW chat (S39).** `main` = S00–S38 (`3835c1f`); `.ai/SESSION` = 38;
`v0.2.0` tag on `main` HEAD; **`@ifelse.codes/core@0.2.0` is LIVE on npm** (`latest`).

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

## S39 candidates (founder picks the goal + writes the contract)

1. **GTM proof pack** — benchmarks / token-savings / before-after. **Unblocked:** there is
   a real `0.2.0` with an installable tarball to measure. Also the one item that both
   produces evidence *and* gives people a surface to find.
2. **Adoption watching** — decide a *trigger* (first real install, first external issue)
   rather than a date, so "nobody is asking" stays a measurement. When it fires: set
   *Publishing access → require 2FA and disallow tokens*.
3. **Fix the `required-crew` gate at the root** — it demands a tech-lead handoff that
   `.ai/AGENTS.md`'s Session Loop never asks for, and **S37 failed it too**. It is
   currently a tax that only ever fires red. Either surface the crew step in the
   constitution or drop the gate.

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
