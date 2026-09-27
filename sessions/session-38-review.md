# Session 38 — cold fidelity review

Cold pass over S38 ("release runway — npm Trusted Publishing (OIDC)"), run as an
independent subagent against two inputs only.

## Method controls

- **Cold inputs:** (1) the contract `prompts/38-task-release-runway.md`; (2) the delivery
  diff, which the reviewer rebuilt as `git diff 802ffc7..76d21f3` (422 lines, 6 files)
  because the expected inputs file was absent. It additionally read the *uncommitted*
  working-tree delta to `scripts/verify-session-38.sh`, on the grounds that this is the
  version that will gate the closeout, and flagged that the change was unreviewed.
- **Not read:** `sessions/session-38-summary.md`, `.ai/STATE.md`, `.ai/SESSION-BOOT.md`,
  `.ai/TASK.md`. The contract's `## Execution` conclusions were not used as evidence.
- **No expected score was supplied.** The green verify result was not treated as proof.
- **Method, not inference:** the reviewer re-implemented the verify script's workflow-text
  checks verbatim and ran them against six deliberately broken copies of `release.yml`;
  stubbed `gh` to construct counterfactuals; and re-verified requirement 4 against the npm
  registry directly. Reproduced: `npm view` → `0.2.0`; dist-tags `latest: 0.2.0`; clean
  temp-dir `npm install` → exit 0 with 51 exports; `gh secret list` length `0`; visibility
  `PRIVATE`; `v0.2.0^{}` = `76d21f3` = `origin/main` HEAD; PR #46 `MERGED` from
  `session-38-release-runway`; npm `time["0.2.0"]` = `13:11:11Z` vs run created `13:09:02Z`.

## Per-requirement verdicts

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | Founder creates the npm trusted publisher (`ifelse-codes`/`chitra`/`release.yml`, no environment, `npm publish` allowed) | SHIPPED | No diff artifact (browser action). Corroborated by outcome: zero secrets + publish job success + npm publish time inside the run window ⇒ no token path existed, so the OIDC exchange worked. **Not asserted by any check** — inferred from outcome. |
| 2 | Rewrite `release.yml#publish` for OIDC: `id-token: write` + `contents: read`; delete the token `env:`; keep `registry-url` and the idempotency guard | SHIPPED | `release.yml` `id-token: write`; `contents: read`; `registry-url` kept; the `skipping publish (idempotent tag push)` guard intact; the `env: NODE_AUTH_TOKEN` block gone. Plus `cd packages/core` + `npm publish`, and `cache: pnpm` dropped. |
| 3 | Bump to `0.2.0`; cut the release **from `main` after merge**; **no human, no tmux, no passkey** | SHIPPED | `v0.2.0^{}` = `76d21f3` = `origin/main` HEAD = the PR #46 squash. Run `36321392874` on that push, 4/4 jobs success. Decisive: npm records `0.2.0` at `13:11:11Z`, ~2 min **after** the run began. |
| 4 | Verify **independently of CI logs**: `npm view` + a clean `npm install` in a temp dir | SHIPPED | Both checks query the registry, not CI logs. Reproduced independently. **Gate gap:** the clean install existed only in the demo, which prints `✗ clean install FAILED` and still exits 0 — a warning where the contract said verify. |
| 5 | Revoke the exposed npm account token `npm_xToANF…` | **NOT-BUILT** | No assertion, script, artifact, or recorded confirmation anywhere. The token is still valid. The delivery reduced this debt by nothing. (Labeling was honest — no false revocation claim.) |
| 6 | README rider: mark `render_chart` as roadmap, no dangling promise | PARTIAL | The honest marker shipped, but it points at `.ai/ROADMAP.md` — which was **not touched** and still lists the MCP server as the *next* S38 deliverable while repeating the stale "README already advertises" claim. The rider created a fresh dangling cross-reference. |
| 7 | Verify + demo + summary + independent cold review + closeout; `verify-session-38.sh` exits 0; **sync `.ai/` and `.ai/SESSION` → 38** | PARTIAL | Scripts exist and run. Zero `.ai/` files in the diff; `.ai/SESSION` was `37`; the summary was untracked. `verify-closeout.sh:21-22` blocks on a missing/invalid SESSION, so closeout could not pass. Also: the committed script's `branch-is-s38` (`HEAD == session-38-*`) is **unsatisfiable** at the release commit, where `HEAD` is `main`. |

**Binding non-numbered clauses — all satisfied.** "Tag only from merged `main`" ✓.
"Do not claim the npm account token is revoked until the founder confirms it" ✓.
"MCP server — do not build, do not stub" ✓ (`mcp-not-built` green; the README change is
prose). Findings 2–4 are true in substance, not just narrated. Not auditable from a squash
diff: the ≤3-files-per-commit guardrail.

**4 of 7 SHIPPED · 2 PARTIAL · 1 NOT-BUILT**

## Fakest green

`publish-not-pnpm`, with `publish-uses-npm` as accomplice — hollow precisely because the
contract promoted it to a guard.

```
publish-not-pnpm  ! publish_code | grep -qE 'pnpm .*publish'
publish-uses-npm   publish_code | grep -q 'npm publish --access public'
```

Both are comment-stripped substring greps over the publish **job**'s text, not assertions
about the command that executes. The reviewer built the counterfactual and ran it: the real
command becomes `pnpm -F @ifelse.codes/core pub --access public` with a dead
`npm publish` in an unreachable `if [ "${DRY_RUN:-0}" = 1 ]` branch. Result: **8 of 8
green with the release path fully reverted to the exact bug the check exists to catch** —
and pnpm 9.12.3 cannot exchange an OIDC token, so the next tag push dies at auth.

Runners-up, all executed by the reviewer:

- `repo-visibility-known` matched `PUBLIC|PRIVATE` — every value a github.com repo can
  take. It cannot fail on the value it names, and never pinned the `PRIVATE` fact the
  provenance finding depends on. A dressed-up "did the API answer" check.
- `not-on-squashed-main` was green on an empty no-op commit titled `S38: release runway`,
  and green on a commit titled `Revert "S38: release runway — OIDC (#46)"`.

## Adversarial findings

1. **Every `release.yml` check is a text grep, and all were breakable at once.** Beyond the
   counterfactual above, 8/8 stayed green under `if true; then` replacing the idempotency
   guard, `cache: 'pnpm'` re-inserted inside the publish job (valid YAML, defeats the
   literal regex), and a `NODE_AUTH_TOKEN` reintroduced at **workflow-level** `env:`
   (`no-node-auth-token` only scans from `^  publish:` to EOF, so anything above the job is
   invisible). The script proved the release job's *text* resembled the intended text.
2. **The committed `verify-session-38.sh` provably could not exit 0** at the release
   commit. The working tree's replacement was at the time a **net weakening**: it never
   inspected the local tree (green while `HEAD` was a branch that is not PR #46), hardcoded
   PR `46` so it would rot, and both members were green where the work was absent.
3. **A gate was swapped after the fact, mid-closeout** — the "warns where the contract said
   block" tell, at the moment nobody is looking.
4. **Requirement 4's independence was real, but the check set could not tell OIDC from a
   human.** Nothing asserted the trusted publisher exists, and nothing asserted that
   `0.2.0` *lacks* provenance — so if the repo were made public, the
   `release.yml:100-103` comment would silently become false with no check noticing.
5. **`ci-no-auth-token-secret` — one real credit, one real hole.** Credit: pairing it with
   `gh-secret-list-works` so a dead `gh` cannot fake a green (confirmed with a stub). Hole:
   `gh secret list --repo` covers repo secrets only — green with `NODE_AUTH_TOKEN` stubbed
   as an org or environment secret. Low practical risk (none exist, no environments
   configured), but the name overclaims.
6. **Requirement 5: PARTIAL would itself be a soft dodge — ruled NOT-BUILT.** Nothing was
   done. The review explicitly declined to hold this against the delivery, because the
   contract pre-authorized it as founder-only and the guardrail forbade claiming
   revocation. The live finding is sequencing: the contract's own order is *publisher →
   verify → restrict*, steps 1–4 are now done, and **nothing in the delivery records that
   the founder action is unblocked** — it is a `dim` line in a demo.
7. **Not auditable from the given inputs:** ≤3-files-per-commit (squash erases
   granularity), and whether the founder ticked "allow `npm publish`" (only inferable from
   the publish succeeding).
8. **Deliberately not counted as a defect:** the temp-dir install being demo-only. It
   passes; only the gate is soft.

## Disposition of these findings (builder, post-review)

Fixed in this closeout rather than argued away:

- Replaced the hollow publish-guard family with `publish-uses-npm` /
  `publish-no-pnpm-at-all` / `publish-exactly-one-cmd`, scoped to the publish step's `run:`
  block and anchored at line start, so `pnpx`, `pub` abbreviations, and unreachable-branch
  decoys are caught. `no-node-auth-token` now scans the **whole** workflow, not the job.
  `no-cache-in-publish` tolerates quoted values.
- Added `published-after-run-start`: npm's `time["0.2.0"]` (13:11:11Z) must be no earlier
  than the Release run's `createdAt` (13:09:02Z). This is the check that makes
  "unattended" falsifiable, and it needs no npm auth.
- Replaced `repo-visibility-known` (could not fail on its value) and
  `not-on-squashed-main` (green on a no-op or a revert) with `run-actually-succeeded` and
  `main-squash-touched-release`, which asserts the squash commit actually touched
  `release.yml`.
- `pr-from-session-branch` now derives the PR from the branch prefix instead of hardcoding
  `46`.
- Corrected `.ai/ROADMAP.md`, which still listed the MCP server as the next deliverable and
  repeated the stale README claim the rider had just corrected.
- Downgraded requirement 5 in the summary from PARTIAL to **NOT-BUILT**, and promoted the
  now-unblocked revocation to a top next-option. *(Post-review: the founder then revoked
  `npm_xToANF…` on npmjs.com, so requirement 5 is now genuinely done — recorded as
  founder-attested, since nothing observable from this repo can prove it. The review's
  NOT-BUILT verdict was correct as of the diff it audited.)*
- The founder's closing direction for S38 was to stop hardening and ship: the
  publish-policy lockdown and the provenance gap are both explicitly deferred on a
  "release, watch adoption, harden later" basis. Recorded rather than quietly dropped.

Accepted as standing limits, not fixed: the trusted publisher's existence is inferred from
outcome (npm's trusted-publisher API needs a session token), and
`ci-no-auth-token-secret` covers repo secrets only.

**Verdict:** ACCEPT

Scoped honestly, because the distinction matters more than the word: the **release runway
is real**. Requirements 1–4 are met and were confirmed against the npm registry and GitHub
APIs rather than the builder's account of them — `0.2.0` is live, was published by CI at
`13:11:11Z` inside the run window, with zero repo secrets, from a tag on merged `main`. The
pnpm→npm bug the contract flagged as a blocker was real and is genuinely fixed. Nothing
above disputes the shipped product. What was accepted is a release that works, not a
verification layer that worked — hence the counterfactual-driven hardening above.

**Review-Inputs-SHA:** 519bfeae3dfd527775435a8516464f4b447a3ef3c5429300655dcb192f2b57ab
