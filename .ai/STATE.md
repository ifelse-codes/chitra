# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S40 ground-truth audit in
progress, 2026-09-30.)

## Active Branch
`session-40-ground-truth`, branched from `main` `ba6cf6f` — which is **exactly** `origin/main`
(`0 0`), verified at boot, so no merge-lag can be hiding in this snapshot. S39 is merged
(PRs #53–#59); the package is **`@ifelse.codes/chitra@0.3.0`**, live on npm. S40 is a
**NO-CODE** session (`40 % 5 == 0`): markdown only, no commits, no PRs.

## What Currently Works (observed, not claimed)
- **The rename is complete and consumer-verified.** `@ifelse.codes/chitra@0.3.0` (38 files /
  446,756 B) installs clean into an empty dir, imports by package name (48 exported functions),
  and renders real `line()` / `horizontalBar()` / `plot().line()` charts with working
  `toJSON()` / ANSI-free `toPlain()`.
- **The release path is automated — from `0.4.0`, not from `0.3.0`.** `release.yml#publish` holds
  `id-token: write` + `contents: read`, references **no npm secret**, and runs `npm publish`
  (pnpm 9.12.3 predates Trusted Publishing and cannot exchange an OIDC token).
- **The trusted publisher for `@ifelse.codes/chitra` exists (founder-attested 2026-09-29).**
  Not repo-verifiable — npm's trusted-publisher API needs a session token. The evidence is the
  outcome, and **the outcome has not happened yet**: no release has gone through CI since it was
  created. Treat unattended publishing as *configured, not demonstrated*.
- **CI published `0.3.0` zero times — proven, not assumed.** The `v0.3.0` run's attempt 1
  `publish` job **failed** (09:07:01→09:07:31Z, `PUT …/@ifelse.codes%2fchitra` → 404 "could not
  be found or you do not have permission"). A human published at **13:30:46Z**. Attempt 2 took
  the idempotency **skip** path and the run went **4/4 green**. npm's publish time *precedes*
  attempt 2's start (13:40:18Z), so neither attempt could have produced the version.
- **Root cause of that failure is structural, not a misconfiguration:** npm configures a trusted
  publisher *per package, inside that package's settings page*, and a package that does not exist
  has no settings page. **A brand-new package name can never be OIDC-published — its first
  publish is necessarily human.** Renaming always costs one.
- **The idempotency guard is proven behaviourally, not by grep.** Attempt 2 emitted
  `@ifelse.codes/chitra@0.3.0 is already on npm — skipping publish`, which is only reachable from
  the live `npm view` branch against the *new* package name.
- **`@ifelse.codes/core` is NOT deprecated** (founder decision). No public release, no external
  user, so a deprecation notice is ceremony for an audience of one. The old package stays at
  `0.2.0` and still resolves.
- **Live docs site:** `chitra.iifelse.com` (`/ai-data` live). Hero pill reads `v0.3.0 · npm` — the
  S38 lie where it still read `v0.1.0` is fixed. The pill is still a JSX literal; what changed is
  that `hero-pill-matches-version` now *derives* the expected value from the manifest, so the next
  bump without a pill edit goes red instead of shipping. The pill itself is not generated.
- **`@ifelse.codes/chitra` library:** 20 charts, 3 renderers, 7 themes, `ChartResult`;
  LOCKED families S09–S28. `pnpm --filter @ifelse.codes/chitra run test` — **452/452**.

## What Is Broken / Incomplete

> **The 🔴 rows are S40 ground-truth findings, each traced to a run probe** in
> `sessions/session-40-ground-truth.md`; the 🟠 rows are inherited, still-true items, plus
> two S40 rows the founder's corrections moved off 🔴.

- 🟠 **The adoption baseline is zero, and that is the correct pre-launch reading** (founder:
  nothing has been released-and-marketed). The finding is not the number — it is that **the
  number had never been read before S40**: no trend, no comparison, no way to tell a
  marketing effect from a release artifact later. `@ifelse.codes/core`'s 304 lifetime
  downloads are **0 for the 9 days before its publish**, then 75 / 17 / 12 / 181 / 19 in the
  5 days it existed — release-runner and founder-verification shaped, so they must **never be
  cited as traction**. `@ifelse.codes/chitra` is **unindexed by the npm downloads API**
  (three endpoints, all `"not found"`) while `registry.npmjs.org` answers 200. A GTM proof
  pack must record this zero as its explicit `t0`.
- 🟠 **The repo goes public after a code cleanup** (founder decision, 2026-09-30). Today's
  404s — `README.md:75` `git clone`, npm `repository.url`, npm `homepage` — are a **known,
  sequenced, temporary** state, and `chitra.iifelse.com` is the only public surface that
  resolves. **The open item is the prerequisite, not the decision:** "clean up the code and
  make it good" gates the public flip and has **no roadmap item, no scope, no owner**. The
  flip then resolves all three links and adds npm provenance in one move.
- 🔴 **S16 vanished and no gate can see it.** No prompt / verify / demo / summary / review;
  its only commit is a parked WIP (`74b3c17`) and **nothing landed on `main`**. It is not in
  the ROADMAP's grandfather list (only S04/S06 are), not in the S35 ledger, and it sits
  **below** `check_session_coverage`'s S17 floor — so three ledgers all read complete.
- 🔴 **`KNOWLEDGE.md` L97–98 serves three falsehoods** — "main hosts S00–S37 (PR #43
  `fd8a96e`)" and "the `v0.1.0` tag is on `main` HEAD". Truth: `main` is `ba6cf6f` (#59);
  `v0.1.0` is at `802ffc7` and the newest tag is `v0.3.0` at `f4ff6ef9`. **This is S35
  ledger row 4's exact class, closed in S36 and drifted back — with no guard on the line.**
- 🟠 **Unattended publishing is configured but unproven.** No release has traversed CI since the
  trusted publisher was created. The cheapest close is a real `0.4.0` through the pipeline.
- 🟠 **No npm provenance.** The GitHub repo is **private**, and npm does not generate provenance
  for private repos even under trusted publishing. Confirmed on `0.2.0`: `dist.signatures` is
  present, `attestations: null`. Publishing is unaffected. Making the repo public would fix it and
  suits an MIT package — **founder's open decision**. If visibility flips, `release.yml`'s comment
  must change with it or it becomes a lie.
- **MCP server: founder-DEFERRED.** Not built, not stubbed. Gate: a release exists **and**
  someone demands it **and** it is worth building. The `mcp` **keyword was dropped** in S39 —
  a keyword is a promise in a search index, and nothing ships it.
- 🟠 **The `required-crew` closeout gate is structurally wrong** and has now failed **three**
  sessions: waived twice (S38, S39) and at S40 as `verdict: NOT READY` with **zero** `WAIVED`
  lines. It demands a tech-lead handoff that `.ai/AGENTS.md`'s Session Loop never asks for — and
  a **ground-truth session cannot dispatch one at all**, so it is unsatisfiable *by
  construction* there. S40 closed it under `VAJRA_CLOSEOUT_WAIVER=40`. Fix or drop it.
- 🟠 **The S40 closeout is RED and cannot be otherwise: 14 pass, 2 fail.** `required-crew`
  (above) plus **`review-inputs-attested`**, whose `Review-Inputs-SHA` is *uncomputable*
  because `canonical_inputs_sha` requires the contract **committed at HEAD** and a NO-CODE
  session commits nothing (`git cat-file -e HEAD:prompts/40-…` → *exists on disk, but not in
  HEAD*). Both waived by the founder at S40 close. **The trap:** the same no-commit condition
  makes `check_ground_truth_no_code` **fail-open** (empty diff range → `OK`) while the
  attestation gate fails closed — so "the gates passed" would have pointed a reader at the
  wrong one. See ledger rows 5, 10, 11.
- 🟠 **Two "Hook-enforced" / `true` declarations in `.ai/AGENTS.md` are false.** *Max 3 files
  per atomic commit* holds on the branch, but 8 of the last 60 `main` commits exceed it —
  every one a GitHub **squash merge**, which never runs a local hook. *`one_session_per_chat`*
  is wired but **unfireable**: `hook-session-guard.sh` blocks only on a same-chat `N→N+1`
  boundary, the repo's own convention is a new chat per session, and `.ai/.session-owner` is
  **untracked** and pinned at `12` (28 sessions stale).
- 🟠 **The GT artifact is self-certified and not durable.** No independent pass on the audit
  itself (S35's meta-remediation, still open), and the file round-trips through the *next*
  code session's commit (S35's arrived via S36's `c2cbcec`) instead of the `-closeout` branch
  suffix `CONSTRAINTS.yaml` already exempts.
- 🟠 **The GT no-code backstop is blind in the harness it exists for.** The write-time hook
  is real and L3, but opencode does not run it — and `verify-closeout.sh#check_ground_truth_no_code`,
  credited as the harness-agnostic substitute, diffs `merge-base..HEAD`, a range a GT session
  **never commits into**. Proved by counterfactual at S40: a planted `packages/core/src/*.ts`
  left it reading `OK: no code changes` / `INTEGRITY: PASS`. The honest NO-CODE evidence for
  S40 is `git status` — six `.ai/*` files and two new markdown artifacts, zero tracked source.
- 🟠 **The cost gate greps a heading.** `cost-tracking-present.log` passes on the string
  "Cost Tracking"; any text passes, including a lie. The prose is honest ("unmeasured") — the
  check verifies nothing. Unchanged from S35.
- `ci-no-auth-token-secret` covers **repo** secrets only — not org or environment secrets. None
  exist today and no environments are configured.
- A **revoked** `npm_xToANF…` token still sits in the founder's global `~/.npmrc` (outside the
  repo) and is sent to the registry on authenticated calls. S39's bootstrap publish used an
  isolated `npm_config_userconfig` instead, which was deleted afterwards.
- GTM proof pack (benchmarks / token-savings) still to build — now unblocked and now measuring
  the *final* install command. `artifacts/api-server` remains the undecided "if the hosted API is
  pursued" bet. Pricing story still open.
- Frozen `sessions/` + old `prompts/` + old `scripts/verify-session-*.sh` still name
  `@ifelse.codes/core` (history; not re-run).
- `pnpm run lint` unrunnable — eslint not installed (pre-existing).

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
  **S37** package renamed to `@ifelse.codes/core` + published ·
  **S38** OIDC release runway, `0.2.0` unattended ·
  **S39** renamed to `@ifelse.codes/chitra`, `0.3.0` live.

## What Is In Progress
- **S40 — NO-CODE ground-truth audit** (`40 % 5 == 0`), on `session-40-ground-truth`. Overall
  🔴, on `knowledge_staleness` and `constitution_review` — **not** on distribution, which is
  correctly at its pre-launch baseline. The product is excellent (452/452,
  `verify-session-39.sh` 43/43 on `main` HEAD); the governance carries mis-declared rules.
  Delivered: `sessions/session-40-ground-truth.md` (**49 probes**, 7 audits),
  `sessions/session-40-review.md` (cold, **ACCEPT-with-conditions**, 41 probes re-run, 0
  fabricated), and **11 rows** in `.ai/GT-REMEDIATIONS.md` — **3 `DONE` in-session** (rows 3,
  6, 7: the `KNOWLEDGE.md` falsehoods fixed, the GT cadence put on the roadmap, and the cold
  review delivered), 8 `DEFERRED` to S41 with reason + expiry. **Closeout: RED, 14 pass /
  2 fail** (`required-crew` + `review-inputs-attested`), both founder-waived at
  `VAJRA_CLOSEOUT_WAIVER=40` as structurally unsatisfiable in a NO-CODE session.
- S39 **complete** — merged (`ba6cf6f` via PRs #53–#59); `@ifelse.codes/chitra@0.3.0` live.
  **Next (S41):** scope the code cleanup that gates the public launch; then a real `0.4.0`
  through CI (cheapest close on the trusted-publisher claim), the GTM proof pack (first
  measurement — carry the zero as `t0`), `required-crew`, and **disposition S16**, which no
  gate can currently see. See [[roadmap]].

## Cost Tracking
- S40 measured: one opencode session, one in-chat founder decision (the GT/code goal
  conflict), 49 audit probes + 41 independent re-verifications by the cold review,
  0 code changes, 0 commits, 0 PRs, 0 release minutes.
  Token/`$` cost **unmeasured** (billed to the founder's plan). npm cost: $0. The audit added
  no new recurring infrastructure.
- S39 measured: one opencode session (interrupted once by a server restart) — a package rename
  across 27 files, the npm chicken-and-egg that makes a first publish necessarily human, one
  human bootstrap publish, a red release diagnosed rather than retried, **two hollow checks
  caught in my own verify script and one more caught by the cold review** (a narrowed honesty
  guard, a hardcoded version literal, and two fabricated `WORKS` rows in the demo), and S39
  artifacts. Token/`$` cost **unmeasured** (billed to the founder's plan). npm publish cost: $0.
  Release-runner minutes: ~4 (two attempts on `v0.3.0`).
- Prior: S20 founder $20/mo plan; S21–S28 single ZCode chats; S29 3 build + 2 cold reviews;
  S30 ops deploy + 2 cold reviews; S31 1 recon + 2 cold reviews; S32 knowledge-only; S33 four
  stories + 1 cold review; S34 one story + 4 cold reviews, approval-token gated; S35 NO-CODE
  audit; S36 docs/gates + live deploy; S37 rename + real npm publish via tmux; S38 OIDC runway.
