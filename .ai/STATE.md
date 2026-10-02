# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S41 — cleanup Batch 1,
**complete**, 2026-10-02.)

## Active Branch
`session-41-repo-cleanup`, branched from `main` `ece61fc` (== `origin/main` at branch
time). S40 is **merged** — PR #60 carried the audit, PR #61 carried a fix for a line of
mine that had broken S39's own gate. The package is **`@ifelse.codes/chitra@0.3.0`**, live
on npm, and the repo around it is being made fit to publish.

## What Currently Works (observed, not claimed)
- **A fresh clone builds, with no environment variables set.** `git clone` →
  `pnpm install --frozen-lockfile` → `pnpm run build` is **exit 0** with `PORT` and
  `BASE_PATH` unset. This has never been true before: the root `build` script typechecked
  the docs app before `@ifelse.codes/chitra`'s gitignored `dist/` existed, so any machine
  that had ever run a build reported green and every other machine got `TS2307`. The gate
  is `scripts/verify-session-41.sh#fresh-clone-build-no-env`, and it runs the clone.
- **`VERSION` can no longer lie.** It is exported public API; it shipped to npm as
  `0.1.0` while the manifest said `0.3.0`. It is now generated from the manifest
  (`scripts/sync-version.mjs` → `src/version.ts`), asserted by the suite, and gated twice
  in CI — once before the build, once by executing the built bundle.
- **The live docs site tells the truth.** `chitra.iifelse.com` was serving the Replit
  scaffold placeholder — *"Chitra Docs — built on Replit. Update this description to
  reflect the app."* — as its `description`, `og:description` and `twitter:description`.
- **The npm README is a README.** `packages/core/README.md` is in `files`, so all 785
  lines published: 19 `### LOCKED: … session NN design` sections and a renderer list
  naming a `block` renderer that does not exist. Now 122 lines, three real renderers with
  the per-chart defaults read from source.
- **CONTRIBUTING can be followed.** Wrong clone org, a run command using a Node flag that
  no longer exists, a chart template that omitted a required `ChartResult` member, a test
  path that no longer matches the layout, and a coverage promise the repo did not satisfy.
  All five corrected, and `pnpm example` now works.
- **The release path is automated — from `0.4.0`, not from `0.3.0`.** `release.yml#publish`
  holds `id-token: write` + `contents: read`, references **no npm secret**, and runs
  `npm publish`. Its provenance comment is now true whether or not the repo is public.
- **Product, re-observed:** **453/453** tests in 23 files (452 plus S41's version-drift
  test); root typecheck exit 0; `test:coverage` exit 0; `verify-session-39.sh` 43/43;
  `verify-session-41.sh` 23/23; 20 charts / 3 renderers / 7 themes / 0 runtime deps.

## What Is Broken / Incomplete
- 🔴 **The public flip has no date and two unanswered founder decisions.** The repo is
  still private: `README.md`'s `git clone` line, npm `repository.url` and npm `homepage`
  all 404 anonymously. **D1** — how much internal process (`.ai/`, `sessions/`,
  `prompts/`, `.claude/`, `reviewer/`, `darshan/`; ~146 files) goes public — and **D4** —
  whether to scrub the `/Users/REDACTED/…` paths in 5 tracked files. **D4 is irreversible
  once published.** Options B and C for D1 break `check_session_coverage` /
  `check_task_ref` unless the closeout gates are rewritten first.
- 🟠 **Unattended publishing is configured but unproven.** No release has traversed CI
  since the trusted publisher was created. The cheapest close is a real `0.4.0` through
  the pipeline.
- 🟠 **No npm provenance.** npm does not generate it for a private repo, even under
  trusted publishing (verified on `0.2.0`/`0.3.0`: `dist.signatures` present,
  `attestations: null`). Publishing is unaffected. The flip fixes it; the workflow comment
  no longer has to be rewritten when it does.
- 🟠 **Three cleanup batches are scoped and unowned by a session.** S42 (dead weight:
  `mockup-sandbox`, `lib/`, `api-server`, `attached_assets`, 5 dead scripts), S43 (43
  unused shadcn components, Prettier, the `lint` script that points at an eslint nobody
  installed), S44 (OSS polish + decisions D1–D6). All in `.ai/ROADMAP.md` with gates.
- 🟠 **The adoption baseline is zero, and that is the correct pre-launch reading.** The
  304 lifetime downloads on `@ifelse.codes/core` are all inside a 5-day window starting on
  the publish day and are release-runner and founder shaped — **never cite them as
  traction**. `@ifelse.codes/chitra` is unindexed by the npm downloads API. A GTM proof
  pack must record this zero as its `t0`.
- 🟠 **Governance gates, from S40, still standing.** `required-crew` (third founder
  waiver; demands a handoff the Session Loop never asks for); `check_ground_truth_no_code`
  passing **vacuously** on a GT session because it diffs a range the session never commits
  into; the cost gate passing on the string "Cost Tracking"; S16 invisible to every ledger.
- 🟠 **Historical verify scripts are already unrunnable.** `verify-session-07.sh` (and 01,
  34, 36, 37, 38) filter the pre-rename `@chitra/core` and assert old test counts. The
  live pair is 39 and 41. Nothing re-runs the old ones.
- `pnpm-workspace.yaml` still carries ~140 lines of `overrides` for packages (expo, ngrok)
  that are not in the dependency graph — D5, needs a lockfile regen in its own commit.
- `artifacts/api-server` remains the undecided "if the hosted API is pursued" bet. S42
  deletes it; git history keeps it.
- **MCP server: founder-DEFERRED.** Not built, not stubbed, and the `mcp` keyword was
  dropped in S39 — a keyword is a promise in a search index, and nothing ships it.
- A **revoked** npm token still sits in the founder's global `~/.npmrc` (outside the repo).
- GTM proof pack (benchmarks / token-savings) still to build. Pricing story still open.
- Frozen `sessions/` + old `prompts/` + old verify scripts still name
  `@ifelse.codes/core` — history, on purpose.

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
  **S41** cleanup Batch 1 — the public face is honest and a fresh clone builds.

## What Is In Progress
- **Nothing.** S41 is **complete**: 13 requirements, 12 SHIPPED and 1 PARTIAL (req 8 —
  `AGENTS.md`/`CLAUDE.md` still point into `.ai/`, which is founder decision **D1** that the
  contract explicitly does not make). 32 commits, 34 tracked files, 0 files under the LOCKED
  chart code. `verify-session-39.sh` is 43/43. The S41 gate is 24 checks, all green, and
  the core suite is green at 453.
  Fidelity map: `sessions/session-41-summary.md`. Independent verdict over **six** passes,
  **ACCEPT**: `sessions/session-41-review.md` — it rejected the delivery twice, and the
  findings (a check that provably could not fail, a guard scoped to its author's habits,
  three fabricated numbers in the demo, a missing test the summary had called done) were all
  fixed in place.
- Next (S42): cleanup **Batch 2, dead weight** — `mockup-sandbox`, `lib/`, `api-server`,
  `attached_assets`, 5 dead scripts, and the 6-file chain that references them. Then S43
  (docs weight), then S44 (OSS polish + D1–D6), then the public flip. See [[roadmap]].

## Cost Tracking
- S41 measured: one opencode session; **one** in-chat founder decision (the session goal:
  cleanup Batch 1) and one unanswered (D1); **six** independent cold-review passes by a
  separate subagent, all against the committed diff; 13 requirements across 34 tracked
  files and 32 commits; **0** product-code changes under `src/charts/`, `src/renderers/` or
  `src/themes/`; **1** new test (453 from 452); 2 new CI steps; 0 releases. One `pnpm
  install` (adding `tsx` at the root) and one lockfile update. Roughly a dozen full
  `verify-session-41.sh` runs at ~40 s each — each one performs a **real** `git clone` +
  install + build — plus a fresh-clone build run three extra times, and ~15 targeted
  counterfactuals. Two new session gates written from scratch (24 checks).
  Token/`$` cost **unmeasured** (billed to the founder's plan). npm cost: $0. No new
  recurring infrastructure.
- The honest cost line: **the review was not overhead.** It rejected twice, and every
  rejection was a real defect a green gate had passed — including one check that could not
  fail at all.
- S40 measured: 49 audit probes + 41 independent re-verifications, 0 code changes.
  S39: a package rename across 27 files, one human bootstrap publish, a red release
  diagnosed rather than retried.
