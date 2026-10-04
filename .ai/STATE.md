# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S44 — cleanup Batch 4,
**complete**, closed 2026-10-03.)

## Active Branch
`session-44-oss-polish`, branched from `main` `1b6c17d` (the S43 merge, == `origin/main` at
branch time). S43 is **merged**. The package is **`@ifelse.codes/chitra@0.3.0`**, live on npm;
the repo around it now carries everything a public OSS project is expected to carry, and is one
session from going public.

## What Currently Works (observed, not claimed)
- **The OSS surface exists and every part of it can be checked.** `SECURITY.md` (supported
  versions, private disclosure route, explicit no-SLA / no-bounty / latest-only policy, release
  pipeline in scope), `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1 + enforcement ladder),
  two issue forms plus `config.yml` (blank issues off, three contact links that resolve), a PR
  template, and a **CI badge whose URL is read out of the README and matched against a file that
  must exist** — the same assertion run against `main` fails, which is the counterfactual.
- **No invented contact address anywhere.** The project publishes no mailbox, so the CoC says
  so and points at GitHub's private reporting **as the route, not as a promise it makes** —
  whether that route is switched on is a repository setting recorded (with the command that
  re-derives it) in `.github/REPO-SETTINGS.md`, and the docs say what to do when it is not. A
  `conduct@` nobody reads would be worse than none, and a placeholder would be a lie.
- **Coverage is enforced, not merely configured.** `vitest.config.ts` has carried four
  thresholds since S41 (statements 90 / branches 85 / functions 85 / lines 90 — the *measured*
  floor) that **nothing ran**; `ci.yml`'s `core` job now runs `test:coverage` **instead of** the
  plain `Test` step, so the suite still runs once and the thresholds can fail the build. No
  coverage service was wired up — that would be new recurring infrastructure.
- **`engines` are derived, not chosen.** Repo floor `>=26` / pnpm `>=9.12.3` come from the
  versions `ci.yml` pins. Package floor `>=22` is stated in `CONTRIBUTING.md` **as a support
  policy and not a test result**, with the derivation (zero `node:` builtins, zero runtime
  deps, newest syntax optional chaining) — no suite has ever run on 22.
- **All 81 `overrides` entries are gone and the lockfile did not move.** `pnpm install
  --lockfile-only` after the removal produced an **empty diff**; a full install,
  `--frozen-lockfile`, root typecheck and **453/453** all exit 0. Amendment **A1** records why
  the removal set is 81 rather than the 11 the requirement's literal wording named: the right
  test is *does the override change resolution*, and for every entry the answer was no.
- **The founder's home path is out of the tracked tree.** 15 files, one mechanical commit:
  `/Users/<name>` → `~`, and the path-encoded spelling → `-home`. `numstat` is N/N on every
  file — no line added, none removed, nothing created or deleted. The gate's check runs the same
  pattern against the newest pre-scrub commit, so a pattern that matched nothing would fail
  rather than pass.
- **N1 (the contract-rewrite hole) is closed with a rule and a gate.** `reviewer/SKILL.md`
  freezes `prompts/NN-*.md` for the duration of a review cycle — corrections are **appended**
  under `## Contract amendments`, never written into the requirement they failed. The gate is
  `contract-freshness` in `verify-closeout.sh`, with a **pure** core that the session gate
  extracts and runs against two real sessions: green on S43's untouched contract, red on S42's
  (rewritten by this session's own D4 scrub), naming the offending commit.
- **§4.9 — the gate prices itself.** `VAJRA_GATE_SCOPE=fast|full` (default **full**, closeout
  runs full) drops only the inherited checks that cost wall clock, and marks them `SKIP`. Every
  check now writes its own seconds, so the claim "fast is faster" is arithmetic over measured
  timings instead of a number copied out of a review.
- **Product, re-observed:** **453/453** tests in 23 files; root typecheck exit 0;
  `pnpm example` runs; `gen:charts:check` green. 20 charts / 3 renderers / 7 themes /
  0 runtime deps. **No file under `packages/core/src/` changed in this session.**
- **The gate is a PORT of `verify-session-43.sh`** and its counterfactual is discoverable, not
  asserted: `s43-gate-verbatim-goes-red` extracts S43's real `ai-files-describe-s43` body and
  asserts it exits non-zero here, because that check hard-codes S43's session number and branch.

## What Is In Progress
- **S44 is the in-progress item, and it is complete.** 14 requirements across the OSS surface,
  the founder decisions, the two carried findings, and the proof. The port re-expresses what
  this session's own changes break: `ai-files-describe-s43` → `-s44`, `contract-at-head` →
  `prompts/44` + requirements 1…14 + the amendments section, `s42-gate-verbatim-goes-red` →
  `s43-gate-verbatim-goes-red`. `charts-format-only` is unchanged — this session never touches
  the LOCKED dirs.
- **The founder decisions are answered and recorded where the next session will find them**
  (contract requirement 7, `sessions/session-44-summary.md`, and here), not left in a transcript.

## What Is Broken / Incomplete
- 🔴 **D4b — the git history still carries the home path.** `main` still matches
  `(/|-)Users[-/][a-z]+`, earliest carrier S10 (the scrub is branch-side only). **Derive, never
  type:** `git rev-list --count HEAD` is how many commits a rewrite moves. **The tree is clean;
  history is not.** A rewrite changes every commit SHA: `.ai/` and `prompts/` cite `main`
  by SHA in several records (S42's merge `49e1ee2` among them), PR merge history and every
  recorded ref move with it — derive the current one with `git rev-parse main` rather than
  trusting any of those citations — so this is a pre-flip operation for **S45**, not a
  cleanup commit. **Irreversible once published.**
- 🔴 **The public flip still has no date.** S45 resolves the README `git clone` URL, npm
  `repository.url` / `homepage`, and **npm provenance** (a private repo cannot generate it) in
  one move — and the cheapest close on the trusted-publisher claim is a real **`0.4.0`**.
- 🔴 **Pre-flip task from the cold review: private vulnerability reporting is not established.**
  `SECURITY.md` and `CODE_OF_CONDUCT.md` both route confidential reports to GitHub's private
  reporting, and the settings live outside this repo: no mailbox is published, Discussions are
  **off** (`has_discussions: false`), and `gh api repos/ifelse-codes/chitra/private-vulnerability-reporting`
  returns 404 — which is also what a caller without admin access gets, so it cannot distinguish
  "off" from "not permitted to ask". **Both docs say plainly that the private channel may not
  exist**, and the settings are recorded with re-derive commands in `.github/REPO-SETTINGS.md`.
  Enabling it is a repository setting only the founder can change, so it belongs to **S45**
  beside D4b, not to a cleanup commit.
- 🟠 **A contract rewrite now has a consequence, including for history.** The D4 scrub edited
  `prompts/10-…` and `prompts/42-…`, which sit in the *prompt half* of `canonical_inputs_sha`,
  so **S10's and S42's recorded `Review-Inputs-SHA` no longer match their contracts' current
  bytes.** Those reviews are frozen historical records that no live gate recomputes; the edit is
  mechanical and D4-mandated. Disclosed in the contract (req 8) rather than discovered later —
  and `contract-freshness` now makes that class of change visible instead of silent.
- 🟠 **Seven pre-existing dead docs deps remain**, named, not fixed: `framer-motion`,
  `react-icons`, `@tanstack/react-query`, `zod`, `date-fns`, `@tailwindcss/typography`,
  `tw-animate-css`. Out of scope here (a weight session, not a governance one).
- 🟠 **`minimumReleaseAgeExclude: stripe-replit-sync`** is the same species of Replit-scaffold
  cruft D5 removed, but it is not an `overrides` entry, so requirement 11 did not reach it.
  Named in amendment A1 rather than smuggled in.
- 🟠 **Still open from S40, untouched:** `required-crew` (now **three** founder waivers — S38,
  S39, S42), `check_ground_truth_no_code` passing **vacuously** on a GT session, the cost gate
  that greps a heading, and **S16** invisible to every ledger.
- 🟠 **The adoption baseline is zero, and that is the correct pre-launch reading.** The 304
  lifetime downloads on `@ifelse.codes/core` are all inside a 5-day window starting on the
  publish day and are release-runner and founder shaped — **never cite them as traction**.
  A GTM proof pack must record this zero as its `t0`.
- 🟠 **`gate-scope-switch` needs a full run's timings** (it reads the gate's own per-check
  seconds). It fails closed with an instruction if none exist — local state, like every
  `latest` symlink in `.ai/verify/`, and deliberately not a green that can be typed.
- **MCP server: founder-DEFERRED, not built, not stubbed.**
- **Historical verify scripts are already unrunnable** (01, 02, 03, 07, 31, 34, 36, 37, 38),
  and the S41/S42 gates hard-code deleted paths by design. The live set is **39 / 42 / 43 / 44**.

## Milestones done
- **S01–S04** docs/examples/polish/README · **S05** NO-CODE ground-truth · **S06** publishable
  dist · **S07** CI · **S08** release.yml + line/SVG · **S09** circular+area LOCKED · **S10**
  line · **S11** catalog two-panel · **S12** bar · **S13** Darpan-parity chrome · **S14** URL
  routes+persistence · **S15** scripted browser QA · **S17** scatter · **S18** heatmap · **S19**
  horizontalBar · **S20** treemap · **S21** timeline · **S22** gauge · **S23** progress · **S24**
  grouped nav · **S25** histogram · **S26** waterfall+funnel+sankey+radar · **S27**
  candlestick+boxplot · **S28** sparkline · **S29** family-wide footer B-diet+ · **S30** docs live
  · **S31** antra atoms + hero rotation + wall fix · **S32** wall playbook · **S33** release
  readiness · **S34** GTM README + MIT LICENSE · **S35** NO-CODE ground-truth · **S36** S35 gaps
  closed + deploy unfrozen · **S37** package published · **S38** OIDC release runway, `0.2.0`
  unattended · **S39** renamed to `@ifelse.codes/chitra`, `0.3.0` live · **S40** NO-CODE
  ground-truth audit, 🔴, 11 remediations · **S41** cleanup Batch 1 — the public face is honest
  · **S42** cleanup Batch 2 — dead weight: `artifacts/mockup-sandbox/`, `lib/`,
  `artifacts/api-server/`, `attached_assets/` and 6 dead scripts deleted (110 files), the 9-file
  chain cut · **S43** cleanup Batch 3 — docs weight: 43 unused components, 30 deps, 3 replit
  plugins, the dead lint script, and Prettier adopted + enforced · **S44** cleanup Batch 4 —
  OSS polish (security, CoC, templates, badge, coverage, engines) and the six founder decisions
  answered, with N1 and §4.9 closed.

## Cost Tracking
- S44 measured: one opencode session; **6** founder decisions in-chat (D1, D4, D4b, the
  D2/D3/D5/D6 bundle, and the N1 + §4.9 scope — five ballots) plus the plan approval, which
  carried the blanket commit approval; **14 requirements** across a delivery whose size is derived,
  never typed (`git diff --shortstat main...HEAD`, `git rev-list --count main..HEAD`); **0** product-code changes under `packages/core/src/`; **0** new product tests
  (453 stays 453); **0** lockfile changes — the D5 regen produced an empty diff, recorded as
  amendment A1; **0** releases; **0** npm secrets touched; **0** new recurring infrastructure
  (the coverage bar rides inside the existing `core` CI job; no coverage service). One
  `--no-verify` commit for the 15-file D4 scrub, authorised by the contract because the 3-file
  atomic cap cannot express one mechanical substitution. Token/`$` cost **unmeasured** (billed
  to the founder's plan). npm cost: $0.
- S43: one opencode session, 1 founder decision + plan approval, 10 requirements, ~80 files,
  ~10 commits, 0 product-code changes, 1 lockfile regen, 0 releases. S42: 4 founder decisions,
  10 requirements, 130 files, 13 commits. S41: 6 cold-review passes, 34 files, 32 commits.
  S40: 49 audit probes + 41 re-verifications, 0 code changes.
