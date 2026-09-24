# Session 37 — independent fidelity review (cold pass)

> Produced by a fresh subagent fed ONLY the contract, the delivery diff, and an
> evidence appendix for ops actions (npm publish, tag, CI run) — no repo, no summary,
> no state. Adversarial framing.
>
> Round 1 returned **REJECT**: the diff alone could not show the npm publish, and the
> paired `v0.1.0` tag (req 4) was not yet cut. Before round 2 the tag was cut, the
> release workflow was run to green (a latent `release.yml` docs-job bug fixed), and
> the ops evidence appendix was supplied. Round 2 below.

## Method controls

- Inputs: `prompts/37-task-publish-v0.1.0.md` (contract) + the delivery diff
  (base`085425f`..HEAD, excluding `sessions/`, `prompts/`, and the closeout-synced
  `.ai/` state files) + an evidence appendix for external actions.
- Deliberately did not read the on-disk tree, `.ai/`, any summary, or the verify
  artifacts. Session-loop gates (this review, the closeout) are excluded from req 8.

## Per-requirement verdicts

| Requirement | Verdict | Evidence |
|---|---|---|
| 1. Publish the package | **SHIPPED** | `@chitra/core` → `@ifelse.codes/core` (founder-directed); appendix: `PUT 200 registry.npmjs.org/@ifelse.codes%2fcore`, tarball 38 files / 94.2 kB, clean consumer install → `0.1.0`. Token path differed (web/passkey 2FA in tmux, not Classic Automation) — intent met. |
| 2. Set `NODE_AUTH_TOKEN` secret | **NOT-BUILT** (disclosed) | Appendix states plainly it is NOT set. Acceptable non-delivery: npm is deprecating bypass-2FA tokens so a usable long-lived secret is unobtainable; OIDC Trusted Publishing is the real path. A future fresh-version tag push would need it. |
| 3. Verify `npm view` → `0.1.0` | **SHIPPED** | Appendix + `verify-session-37.sh`: version `0.1.0`, `dist-tags {latest: 0.1.0}`. |
| 4. Re-cut + push `v0.1.0`; release green | **PARTIAL** | Appendix: tag at `348ba44`, release run `36030452823` core/docs/drift/publish green with the idempotent skip notice; latent docs-job bug fixed. PARTIAL because the tag sits on the branch commit, not yet merged `main` HEAD (the PR merge is the follow-through). |
| 5. README install + hero pill | **SHIPPED** | README "not on npm yet" removed, real `pnpm add @ifelse.codes/core`; `App.tsx` pill → `v0.1.0 · npm`. |
| 6. Ledger row 2 DONE; `.ai/` → 37 | **PARTIAL** | Diff shows row 2 → `DONE` with root cause; the `.ai/` state files are excluded from the diff by construction (a cold-input control), so `SESSION`→37 and the STATE/ROADMAP/SESSION-BOOT/TASK sync are not visible here — unproven by this pass, not disproven. |
| 7. Harden closeout gates | **SHIPPED** | `check_gt_remediations` adds `has_reason`/`has_expiry`; `--gt-no-code-only` entry point; `verify-session-37.sh` runs it with `run_expect_block` (blocks → PASS). |
| 8. Verify/demo + summary + review + closeout | **PARTIAL** | `verify-session-37.sh` (21/21) + `demo-session-37.sh` (exit 0) present; summary/review/closeout are this loop's own artifacts, excluded from a cold pass. |

## Fakest green

The release `publish` job's green proves nothing about publishing — it only reaches
its `exit 0` skip branch (version already on npm) and is green while `NODE_AUTH_TOKEN`
is unset; a real next-version tag push would fail there (disclosed as req 2). Also
`scripts/workflows/15-qacheck.sh` (renamed cosmetically but a frozen session-15
artifact) still greps `163 passed` against today's 452-test suite, and pins the
`session-15-*` branch — it cannot pass and is not a live gate.

## Reviewer's verdict

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 2cca855a6ad8a5a40c17d72eff72aaf7fcc46ed1d92a4564327fef1c6c3c0ee9
