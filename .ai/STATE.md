# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S42 — cleanup Batch 2,
**in progress**, opened 2026-10-02.)

## Active Branch
`session-42-dead-weight`, branched from `main` `4893683` (the S41 merge, == `origin/main`
at branch time). S41 is **merged**. The package is **`@ifelse.codes/chitra@0.3.0`**, live
on npm, and the repo around it is being made fit to publish.

## What Currently Works (observed, not claimed)
- **A fresh clone builds, with no environment variables set** — and still does after this
  session deleted 103 tracked files. `git clone` → `pnpm install --frozen-lockfile` →
  `pnpm run build` is **exit 0** with `PORT` and `BASE_PATH` unset. Re-run at S42, not
  inherited: this session removed a workspace glob, three project references and a
  workspace dependency, so the gate was worth re-proving rather than assuming.
- **`pnpm install --frozen-lockfile` is green**, with the lockfile regenerated: ten
  importers down to four (`.`, `artifacts/chitra-docs`, `packages/core`, `scripts`),
  **+67 / −3177** lines. Four CI jobs run `--frozen-lockfile`, so this is what keeps
  the deletion from being a red pipeline.
- **The repo no longer carries the app it was extracted from.** 110 tracked files
  deleted across the branch. The product was not touched: **0 files** changed under
  `packages/core/src/charts/`, `src/renderers/` or `src/themes/`.
- **Product, re-observed:** **453/453** tests in 23 files; root typecheck exit 0;
  `test:coverage` exit 0; `verify-session-39.sh` 43/43; `pnpm example` runs.
  20 charts / 3 renderers / 7 themes / 0 runtime deps.
- **`typecheck:libs` is gone end to end** — from the root script, from the `typecheck`
  chain, from **both** `ci.yml` steps, and from `release.yml`. That last one mattered:
  the release workflow ran it on the way to `npm publish`, and a build step removed
  without looking leaves a release that is green and wrong.

## What Is Broken / Incomplete
- 🔴 **The public flip has no date and two unanswered founder decisions.** The repo is
  still private: `README.md`'s `git clone` line, npm `repository.url` and npm `homepage`
  all 404 anonymously. **D1** — how much internal process (`.ai/`, `sessions/`,
  `prompts/`, `.claude/`, `reviewer/`, `darshan/`; ~146 files) goes public — and **D4** —
  whether to scrub the `/Users/suman/…` paths in tracked files. **D4 is irreversible
  once published.** Options B and C for D1 break `check_session_coverage` /
  `check_task_ref` unless the closeout gates are rewritten first.
- 🟠 **Unattended publishing is configured but unproven.** No release has traversed CI
  since the trusted publisher was created. The cheapest close is a real `0.4.0` through
  the pipeline.
- 🟠 **No npm provenance.** npm does not generate it for a private repo, even under
  trusted publishing (verified on `0.2.0`/`0.3.0`: `dist.signatures` present,
  `attestations: null`). Publishing is unaffected. The flip fixes it.
- 🟠 **Two cleanup batches are scoped and unowned by a session.** S43 (43 unused shadcn
  components, Prettier, the `lint` script that points at an eslint nobody installed),
  S44 (OSS polish + decisions D1–D6). Both in `.ai/ROADMAP.md` with gates.
- 🟠 **The adoption baseline is zero, and that is the correct pre-launch reading.** The
  304 lifetime downloads on `@ifelse.codes/core` are all inside a 5-day window starting
  on the publish day and are release-runner and founder shaped — **never cite them as
  traction**. `@ifelse.codes/chitra` is unindexed by the npm downloads API. A GTM proof
  pack must record this zero as its `t0`.
- 🟠 **Governance gates, from S40, still standing.** `required-crew` (third founder
  waiver; demands a handoff the Session Loop never asks for); `check_ground_truth_no_code`
  passing **vacuously** on a GT session because it diffs a range the session never commits
  into; the cost gate passing on the string "Cost Tracking"; S16 invisible to every ledger.
- 🟠 **Historical verify scripts are already unrunnable, and this session added one.**
  `verify-session-07.sh` (and 01, 02, 03, 34, 36, 37, 38) filter the pre-rename
  `@chitra/core` and assert old test counts; `verify-session-31.sh` now names a file S42
  deleted (`check-hero-dims.py`, by founder decision). The live pair is 39 and 42.
  Nothing re-runs the old ones.
- 🟠 **Two gates in this repo check a string in a file, and S42 found one.** The S41
  `test-count-propagated` asserted the demo "displays" the canonical count by grepping
  the demo *file* — which a **comment** satisfies. S41's demo passed on its comment
  alone. S42 adds `demo-displays-count-at-runtime`, which runs the demo and greps its
  output. The same shape likely survives elsewhere; not swept in this session.
- `pnpm-workspace.yaml` still carries ~140 lines of `overrides` for packages (expo,
  ngrok) that are not in the dependency graph — **D5, S44**, needs a lockfile regen in
  its own commit. S42 regenerated the lockfile and deliberately left `overrides` alone so
  the two regens stay separable.
- **MCP server: founder-DEFERRED.** Not built, not stubbed, and the `mcp` keyword was
  dropped in S39 — a keyword is a promise in a search index, and nothing ships it.
- A **revoked** npm token still sits in the founder's global `~/.npmrc` (outside the repo).
- GTM proof pack (benchmarks / token-savings) still to build. Pricing story still open.
- Frozen `sessions/` + old `prompts/` + old verify scripts still name
  `@ifelse.codes/core` and the deleted `lib/` trees — history, on purpose.
- **`artifacts/api-server` is closed, not deferred.** STATE.md previously carried it as
  "the undecided if-the-hosted-API-is-pursued bet". S42 deleted it; git history keeps it.

## Milestones done
- **S01–S04** docs/examples/polish/README · **S05** NO-CODE ground-truth ·
  **S06** publishable dist · **S07** CI · **S08** release.yml + line/SVG ·
  **S09** circular+area LOCKED · **S10** line · **S11** catalog two-panel ·
  **S12** bar · **S13** Darpan-parity chrome · **S14** URL routes+persistence ·
  **S15** scripted browser QA · **S17** scatter · **S18** heatmap ·
  **S19** horizontalBar · **S20** treemap · **S21** timeline · **S22** gauge ·
  **S23** progress · **S24** grouped nav · **S25** histogram ·
  **S26** waterfall+funnel+sankey+radar · **S27** candlestick+boxplot ·
  **S28** sparkline · **S29** family-wide footer B-diet+ · **S30** docs live ·
  **S31** antra atoms + hero rotation + wall fix · **S32** wall playbook ·
  **S33** release readiness · **S34** GTM README + MIT LICENSE ·
  **S35** NO-CODE ground-truth · **S36** S35 gaps closed + deploy unfrozen ·
  **S37** package published · **S38** OIDC release runway, `0.2.0` unattended ·
  **S39** renamed to `@ifelse.codes/chitra`, `0.3.0` live ·
  **S40** NO-CODE ground-truth audit, 🔴, 11 remediations (3 done, 8 deferred) ·
  **S41** cleanup Batch 1 — the public face is honest and a fresh clone builds ·
  **S42** cleanup Batch 2 — dead weight: 110 tracked files deleted, 9-file chain cut.

## What Is In Progress
- **S42**, past its deletions: requirements 7 (the gate green end to end), 8 (browser
  QA + green CI), the rest of 9 (this snapshot), and 10 (fidelity map + **independent**
  cold review). Then the PR and closeout.
- 10 requirements, 10 commits so far, **110 deleted / 3 added / 11 modified**, 0 files
  under the LOCKED chart code. Contract: `prompts/42-task-dead-weight.md`, at HEAD.
- **Founder decision F42-1**, recorded in the contract: this session's agent is
  authorised to set `VAJRA_ALLOW_COMMIT` inline, because the L3 hook that would enforce
  its un-forgeability is Claude Code configuration and does not run here. A marker the
  agent typed is not un-forgeable evidence, and the contract says so rather than
  letting it pass silently. Whether `commit_guard: off` belongs in `CONSTRAINTS.yaml`,
  as in the vajra repo, is **S44's** question — this project ships no such line, so
  enforcement is deliberate.
- Next (S43): cleanup **Batch 3, docs weight** — 43 unused shadcn components (~5,000
  LOC), Prettier (31 core files fail `--check`), and the `lint` script. Then S44
  (OSS polish + D1–D6), then the public flip. See [[roadmap]].

## Cost Tracking
- S42 measured so far: one opencode session; **three** in-chat founder decisions (the
  three I asked at boot) and **one** authorising decision (**F42-1**); 10 requirements
  across 123 changed files and 10 commits; **0** product-code changes under
  `src/charts/`, `src/renderers/` or `src/themes/`; **0** new product tests (453 stays
  453 — this session does not touch the product); 1 lockfile regen; 0 releases; 0 npm
  secrets touched. One `pnpm install`, one `pnpm install --frozen-lockfile`.
  Four full-suite-ish gate runs so far, one of which runs S41's entire gate *inside* it
  to prove the counterfactual, plus a real `git clone` + install + build in
  `fresh-clone-build-no-env`. Two S42 gate checks were wrong before they were right
  (extracting S41's check body; asserting directory absence) and both are recorded in
  the script. Token/`$` cost **unmeasured** (billed to the founder's plan). npm cost:
  $0. No new recurring infrastructure.
- S41 measured: one opencode session, one in-chat founder decision, six independent
  cold-review passes by a separate subagent, 34 tracked files, 32 commits, 1 new test,
  2 new CI steps. S40: 49 audit probes + 41 independent re-verifications, 0 code
  changes. S39: a package rename across 27 files, one human bootstrap publish, a red
  release diagnosed rather than retried.