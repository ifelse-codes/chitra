# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S46 — **the public flip**, complete,
closed 2026-10-04: P1, P2, F1–F6 all discharged, contract never amended.)

## Active Branch
`session-46-public-flip`. Delivery = **4 commits / 9 files** on top of the post-rewrite base
`8a083c8`, squash-merged to `main` = **`86bc909`** (PR **#68**; derive with `git rev-parse main`).
The working branch is kept at the delivery commits so `merge-base(main, HEAD)..HEAD` is the real diff
`canonical_inputs_sha` hashes — after a squash merge, resetting the branch to `main` would leave that
diff **empty** and the attestation would bind to nothing.

## What Currently Works (observed, not claimed)
- **The repository is public.** `gh api repos/ifelse-codes/chitra --jq .private` → **`false`**,
  `.visibility` → **`public`**, the clone URL returns **200** (before: `true` / `private` / `404`),
  and an anonymous `--depth=1` clone succeeds. Both `before` rows are in `sessions/session-46-flip.md`
  with the commands that re-derive them.
- **P1 — the home path is out of every commit reachable from `HEAD`.** `git filter-repo` **2.47.0**
  (two literal rules: the macOS home path → `/Users/REDACTED`, and its dash-encoded form →
  `-Users-REDACTED`; **the patterns are written out nowhere in this tree, because the tree is what
  P1 scans**): **1001 → 0**
  (commit, file) pairs across **444** commits, **0** commit messages. The rewrite tip `8a083c8` kept
  the tree (`8167462a8f21ca400f051635cd6032e233771dbe`), the commit count and the **367** tracked
  files; tags kept their names and moved SHAs. **One** force-push, `--no-verify` disclosed (the
  tracked `.githooks/pre-push` blocks *any* push to `refs/heads/main`; an approved rewrite cannot
  open a PR against itself).
- **P2 — private vulnerability reporting is on:** `{"enabled":true}`. It was **impossible** before
  F1: `GET`/`PUT` 404 for private repos while a public control (`octocat/Hello-World`) reads
  `{"enabled":false}` — with `admin: true` on our side, so the 404 meant "private", not "off".
  Founder reordered to **F1 → P2** (**D-REORDER**) rather than waive.
- **F3 was satisfied by not editing.** `homepage` and `repository.url` bytes are unchanged — the only
  line differing from `main` in `packages/core/package.json` is `version` — and both now resolve.
  The npm packument agrees with the manifest (npm prefixes `git+`).
- **F5 — `0.4.0` released by CI unattended, with provenance.** Tag `v0.4.0` on merged `main`; run
  `37217761468` green; `+ @ifelse.codes/chitra@0.4.0` and a signed provenance statement (sigstore
  log `3078088104`). **`0.4.0` carries attestations, `0.3.0` does not** — and **no file under
  `.github/workflows/` changed**; npm attaches provenance automatically once the repo is public.
  No human, no tmux, no passkey, no `NODE_AUTH_TOKEN`.
- **F6 — `t0` = 119 lifetime downloads, none organic**, derived from
  `curl -s "https://api.npmjs.org/downloads/point/2020-01-01:$(date +%F)/@ifelse.codes/chitra"`.
  First non-zero day **2026-09-29 = 89**, the `0.3.0` publish day; the whole figure sits inside a
  6-day window opening on that day. **Never cite it as traction; never write "zero."**
- **A live gate was fixed instead of left red.** P1 made S44's `home-path-scrubbed` counterfactual
  permanently unsatisfiable (it *demands* a commit that still carries the path). Proof moved to
  samples **assembled at runtime** — a literal sample inside the gate's own source made the tree
  scan flag the gate — plus the history walk inverted to assert **zero** matches.
- **The session's own gate:** `scripts/verify-session-46.sh` — **16 checks**, full scope by default,
  each naming its counterfactual (P1 walked over every reachable commit with an assembled
  true-positive; D-F1 invariants compared at the *rewrite tip*, not HEAD; before-rows read out of the
  evidence file; F1/F2/P2 against their pre-flip values; F5's provenance asymmetry; F6's live count;
  the 3-file cap derived per commit). Recorded run: `.ai/verify/session-46/latest/summary.txt`.
- **Product, re-observed:** **453/453** tests in **23** files; typecheck, chart drift and prettier
  clean. No file under `packages/core/src/` changed except the generated `version.ts`; lockfile
  untouched. Repo **public**; npm `latest` → **`0.4.0`**.

## What Is In Progress
- **S46 is complete.** Cold review, summary, `.ai/` sync and closeout are the closing steps; S47 is
  a fresh start.

## What Is Broken / Incomplete
- 🔴 **The P1 residual is disclosed, not closed.** `refs/pull/*` is read-only
  (`DELETE …/git/refs/pull/67/head` → **`422 refs/pull/* is read-only`**) and **56 of 67** PR heads
  (PRs #9–#64) still expose the pre-rewrite home path to anyone who fetches them deliberately. Only
  a **GitHub support ticket** (delete the PR refs + GC unreachable objects) closes it — **owed,
  riding on S47**. P1's written done-condition is scoped to *reachable from `HEAD`*, so it is met;
  the scope is stated rather than assumed.
- 🔴 **The crew gate needs a founder waiver under OpenCode.**
  `.ai/handoffs/session-46-tech-lead.md` exists and validates structurally, but Vajra confirms helper
  provenance only from a Claude Code record, so `vajra next --check-crew 46` reads
  `unverifiable … gitBranch "session-18-heatmap-lock"` → **NOT READY**. The gate's own message
  prescribes the path for non-Claude-Code sessions: `VAJRA_CLOSEOUT_WAIVER=46` with a reason, in the
  close log. *(This is now the standing condition for every session run outside Claude Code — not a
  one-off.)*
- 🔴 **The S45 audit's 11 findings are untouched — by design.** `check_session_coverage` blind for
  S38–S44 (newest belief **S37**; already missed `sessions/session-40-summary.md` being absent), the
  GT cadence absent from `AGENTS.md` (**vajra-owned**), **S44's canonical verdict is `REJECT` while
  `STATE.md` recorded it COMPLETE** (so `check_review_attestation` read `N/A`), the **3-file cap
  breached by 17 of 60**, the stale-fact class, `ROADMAP.md:56`'s `check_required_crew` row. Spec:
  `sessions/session-45-ground-truth.md` § *Findings, ranked*. Fixing `verify-closeout.sh` in the
  session that made the repo public would have put the public surface and its gates in one
  unreviewable commit.
- 🟠 **`required-crew` has now waived five times** (S38, S39, S40-era, S44, S46) and its root cause is
  unchanged: a Vajra mechanism `.ai/AGENTS.md` never asked for, in an environment the binary cannot
  verify. S45's epitaph still stands: *three waivers is a decision, four is a burial* — the fifth is
  a structural gap, and it belongs to S47's gate work.
- 🟠 **The vision has had no new product surface for ~16 sessions.** Newest commit that *added* a
  chart module: `c72cc14` (S09); 23 modules exist. Defensible sequencing — but the flip it cleared
  the path for is now done, so the next session is the first with no flip to blame.
- 🟠 **Six ledger rows re-confirmed, not closed** (S16, the cost gate that greps a heading, the false
  `true` claims, the vacuous GT no-code backstop, `required-crew`, the adoption baseline — the last
  now **recorded** as `t0`, which closes the *reading* and leaves the *measurement* work).
  Ledger: **14 `DEFERRED` / 18 `DONE`** at S45; `t0` moves one row's reading.
- 🟠 **`.ai/.session-owner` is gitignored** and pinned at chat `12` (S36), so `one_session_per_chat`
  cannot bind across chats; `verify.clean_room.enabled: false` — an S119 gap disclosed and unclosed.
- **MCP server: founder-DEFERRED, not built, not stubbed.** Its gate (a release exists **and** someone
  demands it) is honestly unmet — and there is now a public repo to demand it against.
- **Historical verify scripts** are unrunnable by design (01, 02, 03, 07, 31, 34, 36, 37, 38) and
  **44** is only green from its own branch's perspective: 8 of its 9 failures on any later branch are
  the `proves nothing on main` counterfactuals plus stale-`.ai` assertions, pre-existing before S46.

## Milestones done
- **S01–S04** docs/examples/polish/README · **S05** NO-CODE ground-truth · **S06** publishable
  dist · **S07** CI · **S08** release.yml + line/SVG · **S09** circular+area LOCKED · **S10** line ·
  **S11** catalog two-panel · **S12** bar · **S13** Darpan-parity chrome · **S14** URL
  routes+persistence · **S15** scripted browser QA · **S17** scatter · **S18** heatmap · **S19**
  horizontalBar · **S20** treemap · **S21** timeline · **S22** gauge · **S23** progress · **S24**
  grouped nav · **S25** histogram · **S26** waterfall+funnel+sankey+radar · **S27** candlestick+boxplot
  · **S28** sparkline · **S31** antra atoms + hero rotation + wall fix · **S32** wall playbook ·
  **S33** release readiness · **S34** GTM README + MIT LICENSE · **S35** NO-CODE ground-truth ·
  **S36** S35 gaps closed + deploy unfrozen · **S37** package published · **S38** OIDC release runway,
  `0.2.0` unattended · **S39** renamed to `@ifelse.codes/chitra`, `0.3.0` live · **S40** NO-CODE
  ground-truth audit, 🔴, 11 remediations · **S41** cleanup Batch 1 — the public face is honest ·
  **S42** cleanup Batch 2 — dead weight: 110 files · **S43** cleanup Batch 3 — docs weight · **S44**
  cleanup Batch 4 — OSS polish + the six founder decisions · **S45** NO-CODE ground-truth audit, 🔴 —
  the cadence named nowhere, a coverage check blind for 7 sessions, S44's REJECT recorded COMPLETE ·
  **S46** **the public flip** — repo public, history scrubbed (`1001 → 0`), private reporting on,
  `0.4.0` published by CI **with provenance where `0.3.0` has none**, `t0` recorded, and S44's
  home-path gate repaired rather than left red.

## Cost Tracking
- S46 measured: one opencode session; **3** founder decisions in-chat (the plan approval, the
  **P2 reorder**, the **`home-path-scrubbed` fix**) + **1** implicit commit approval in the plan
  token; **8** requirements (P1, P2, F1–F6) + **2** assumptions, both held; **4 delivery commits, 9
  files, max 3 files per commit** (derived per commit with `git show --numstat`, not asserted);
  **1** pre-push `--no-verify`, disclosed; **1** release, **0** npm secrets, **0** new recurring
  infrastructure, **$0** npm cost; **0** product tests added (453 stays 453); **0** lockfile changes.
  The two off-plan changes — the P1 side-effect gate fix and the crew handoff — were both put to the
  founder before execution. Token/`$` cost **unmeasured** (billed to the founder's plan): the correct
  honest reading.
- S45: one session, 1 founder decision + plan approval, 11 requirements, 27 probes (3 retired), 0
  code changes, 16 commits / 14 files within cap. S44: 6 founder decisions, 14 requirements, plus
  follow-up PR #66 after eight cold-review passes and a REJECT verdict. S43: 1 decision, 10
  requirements. S42: 4 decisions, 10 requirements. S41: 6 cold-review passes, 34 files. S40: 49 audit
  probes + 41 re-verifications, 0 code changes.
