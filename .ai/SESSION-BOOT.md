# Session Boot

## Current Session
- **Number:** 39 — DONE (package renamed to `@ifelse.codes/chitra`; `0.3.0` live)
- **Type:** CODE + one unavoidable founder publish
- **Branch:** `session-39-rename-chitra` → `-claims-fix` → `-publish-record` → `-closeout`
- **Date last updated:** 2026-09-29

## Repo State Snapshot
- `.ai/SESSION` = 39.
- Remote: `github.com/ifelse-codes/chitra` (**private**). `main` has S00–S39 (PR #55,
  `68d0b26`); only `v0.3.0` sits on `main` HEAD (`v0.1.0` is at `802ffc7`, `v0.2.0` at `76d21f3` — the old tags were never moved, which is why `0.3.0` was chosen), and the Release workflow
  is green.
- **S39 delivery:** the package is **`@ifelse.codes/chitra@0.3.0`**, live on npm (38 files /
  446,756 B, consumer-verified). 27 files, +1039/−360, 4 PRs, 15 atomic commits.
- **The finding that outlasts the rename:** **a brand-new package name can never be published
  by CI.** npm configures a trusted publisher *inside the package's own settings page*, and a
  package that does not exist has no settings page — so OIDC → publisher → package → a publish
  only a human can make. **Renaming always costs one human publish**, and the unattended
  property does not return until the *next* version.
- **The `v0.3.0` release went red, and that was the proof.** Attempt 1's `publish` job failed
  (`PUT …/@ifelse.codes%2fchitra` → 404 "could not be found or you do not have permission") at
  09:07:31Z. A human published at 13:30:46Z. Attempt 2 took the idempotency skip path → 4/4
  green. **CI published `0.3.0` zero times**, and that is asserted, not narrated.
- **A green check that would have lied:** S38's `published-after-run-start` compares npm's
  publish time to the run's start. For `0.3.0` it **passes** (13:30:46Z ≥ 09:06:11Z) and is
  false — it cannot tell "CI published two minutes in" from "CI died and a human published
  four hours later". Replaced by three attempt-level assertions: attempt 1 failed, attempt 2
  skipped, and npm's publish time **precedes** attempt 2's start.
- **The founder inverted requirement 7 mid-session:** *no* deprecation — no public release, no
  external user to redirect. The rename notices that had already shipped the claim "deprecated
  on npm" were removed, and a check now guards the **absence** of a deprecation claim.
- **Two more live lies fixed in passing:** the docs hero pill still read `v0.1.0 · npm` while
  the manifest said `0.2.0` (S38 bumped one and not the other); `packages/core/CHANGELOG.md`
  claimed "no public version has been published to npm yet".
- **The cold review REJECTED the first delivery** and named the fakest green: the honesty guard
  grepped three files, none of them the shipped docs app, so a migration banner would have
  shipped on a green board. Also caught a hardcoded version literal whose comment claimed it was
  "pinned to the manifest", and two fabricated `WORKS` rows in the demo's summary table. All
  three fixed and counterfactual-tested.

## Next Session
- **Number:** 40. Candidates, founder-ranked:
  1. **GTM proof pack** — benchmarks / token-savings / before-after. Unblocked, and it now
     measures the final install command.
  2. **A real `0.4.0` through CI** — the cheapest possible proof that the trusted publisher
     works, converting a founder attestation into a demonstrated fact. Nothing needs to change.
  3. **Fix the `required-crew` gate** — it has now cost two founder waivers (S38, S39).
- `artifacts/api-server` stays an undecided "if the hosted API is pursued" bet, not a task.
- **MCP server stays founder-deferred** until someone demands it. `@ifelse.codes/chitra@0.3.0`
  counts as a release; demand is the missing half.
- Open in a **new chat** (one session per chat).
