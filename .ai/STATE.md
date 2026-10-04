# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S45 — the mandatory ground-truth audit
(`45 % 5 == 0`), **NO-CODE**, complete, closed 2026-10-04.)

## Active Branch
`session-45-ground-truth-closeout`, branched from `main` `5a39c43` (the S44 merge — PR #65, then
follow-up #66; derive with `git rev-parse main`). The package is **`@ifelse.codes/chitra@0.3.0`**,
live on npm, and the repo around it is still **private**.

> The `-closeout` suffix is not decoration: `CONSTRAINTS.yaml`'s
> `ground_truth_commit_exempt_branch_suffixes: [-closeout, -enforcement]` is what makes the contract
> and the audit artifact committable in a NO-CODE session — and a contract **not** at `HEAD` makes
> `canonical_inputs_sha` uncomputable, so `review-inputs-attested` can only pass on such a branch.

## What Currently Works (observed, not claimed)
- **The ground-truth audit ran, and its findings are reproducible.** `sessions/session-45-ground-truth.md`
  — **27 probes, 3 retired** (the retired three are listed in the artifact; a retired probe quietly
  dropped is how a count becomes a fiction). Every finding carries the command that re-derives it.
  Overall **🔴** — not for the direction, which is sound, but because the material findings are
  *checks that report green while doing nothing*.
- **`check_session_coverage` cannot see sessions 38–44, and says green.** It reads its population from
  `git log --merges` plus `sed -nE 's#.*session-([0-9]+)-[a-z0-9-]+.*#\1#p'`. Every session from **S38**
  on was **squash-merged**, so those subjects read `S44: …` and match nothing. `git log --merges
  --oneline main | wc -l` → 44 merge commits exist; the check's newest belief is **S37**. **It has
  already cost a record:** `sessions/session-40-summary.md` is absent for a merged session, and the
  gate built to catch exactly that cannot see it. **This is the S16 failure re-occurring inside the S16
  remediation** — which proposed backfilling S16's records and never proposed checking that the
  detector still detects.
- **The GT cadence exists in a config key and in no file an agent is told to read.** Mentions of the
  cadence or `N % 5`: `.ai/AGENTS.md` **0**, `SESSION-BOOT.md` **0**, `TASK.md` **0**,
  `CONSTRAINTS.yaml` **1**. `grep -rlE '45 % 5' .ai/ prompts/` returns exactly one file —
  `prompts/45-task-public-flip.md`, written by this session. Five tracked documents named S45 "the
  public flip" and none computed `45 % 5`.
- **The flip's two gates now have an owner.** `prompts/46-task-public-flip.md` carries **P1** (D4b) and
  **P2** (private vulnerability reporting) as preconditions with done-conditions, plus P1's tool
  choice and a **5-step re-verify order** S46 must record *before* the push.
- **One closeout blocker is closed by this session.** Committing the contract on a `-closeout` branch
  made `canonical_inputs_sha` computable: `bash scripts/verify-closeout.sh --inputs-sha 45` →
  `2d95c863…3e401` (*canonical input hash uncomputable* at S40). That was the precondition for
  `review-inputs-attested`.
- **`check_verify_demo_scripts` is the counter-example to the vacuity finding**: it reads
  `[ "$((N % 5))" -eq 0 ]` and returns `N/A — no session scripts expected`, so S45 owes no gate and
  no waiver for one. **A check that knows its own scope is the shape the other four should take.**
- **Product, re-observed this session:** **453/453** tests in **23** files
  (`packages/core/tests/`). No file under `packages/core/` changed. Repo **private**
  (`gh repo view --json isPrivate` → `true`); npm `latest` → `0.3.0`.
- **The NO-CODE claim rests on the diff, read directly** — never on `check_ground_truth_no_code`,
  which diffs an empty range and returns `OK`:
  `git diff --name-only main...HEAD` → every changed file is inside `sessions/`, `.ai/`, `prompts/`
  or is `*.md`; the non-`.md` filter returns **nothing**. *(The first draft of this line read "four
  files" — derived at the third of six commits and never re-derived, which is the defect this
  session's own audit is about. Count it, do not carry it forward.)*

## What Is In Progress
- **S45 is complete** (the audit, the ledger, the carry-forward, the `.ai/` re-sync, the fidelity map,
  the cold review). Nothing is half-done; S46 is a fresh start.

## What Is Broken / Incomplete
- 🔴 **`check_session_coverage` is blind for S38–S44** — and the first casualty is already on disk
  (`sessions/session-40-summary.md`, absent). **Falsifier:** squash-merge one session PR and the
  check's "scanned N merged session branch(es)" line is unchanged. A check whose population a workflow
  change can empty is not a check.
- 🔴 **The 5-session cadence has no line in the constitution**, so it survives only in a config key.
  S40's fix (naming S40 on the board) was reactive and did not generalise; the collision recurred five
  sessions later. Fixing it properly means `AGENTS.md`, which is **vajra-owned** — so it is a
  vajra-side change, disclosed not smuggled.
- 🔴 **S44's canonical fidelity verdict is `REJECT`** — `sessions/session-44-review.md` holds exactly
  one verdict line (`L37`) across eight passes. So `check_fidelity_review` blocks (waived: the 4th
  `required-crew`-class waiver) and `check_review_attestation` reads *"N/A: attestation only gates an
  ACCEPT"* and **passes vacuously** — **S44, the most recent session, carries no DECISION-003 input
  attestation.** `STATE.md` and `ROADMAP.md` recorded it COMPLETE with "13 SHIPPED · 1 PARTIAL"; the
  PARTIAL and the REJECT are disclosed nowhere.
- 🔴 **The 3-file atomic cap is breached by 17 of the last 60 commits on `main`** — up from **8** when
  S40 measured it — and `AGENTS.md` states the rule as **"Hook-enforced"**. It cannot be: PRs are
  squash-merged, so no local hook runs. The breach count grew across exactly the four multi-file
  cleanup sessions, i.e. **the rule degrades in proportion to how much legitimate work a session does.**
- 🔴 **Eight stale facts across `.ai/`**, four of them one recurring class: `main` = `1b6c17d` in
  **six** files (`STATE.md`, `SESSION-BOOT.md` ×2, `TASK.md`, `CONTINUATION-PROMPT.md`, and S44's
  contract) — **all six corrected in this session**; S44 still "in-progress" (merged); the D4b red
  claims `main` matches
  `(/|-)Users[-/][a-z]+` when the **tree** has **0** and only **history** has carriers; "live set
  39/42/43/44" against **36** numbered scripts; `KNOWLEDGE.md` "452 tests" (live **453**) and its pill
  citation `App.tsx` L550/L570 (live **L927**); "main hosts S00–S39" (live **S44**); and **2 of 3**
  tag SHAs wrong. `KNOWLEDGE.md:111` diagnosed this class as "wrong twice … **no guard protects it**"
  and shipped no cure. **S45 makes it four.**
- 🔴 **`ROADMAP.md:56` schedules `check_required_crew` to S44** inside the table headed *"recorded,
  deliberately NOT scheduled"* — and S44 completed without touching it. `STATE.md` listed it open, one
  closeout from a **fourth** waiver, while the same row writes the epitaph: *"Three waivers is a
  decision, four is a burial."*
- 🔴 **The public flip still has no date — but it now has a session.** **S46**,
  `prompts/46-task-public-flip.md`, requirements **F1–F6**, gated on **P1** and **P2**.
- 🔴 **P1 — D4b, the git history rewrite.** `git rev-list --count HEAD` → the count a rewrite moves;
  `(/|-)Users[-/][a-z]+` matches **0** files in the tree at `main` and at `HEAD`, and **1001**
  (commit, file) pairs across history; earliest carrier S10. **Derive, never type.** **Irreversible
  once public** — which is why it gates F1 instead of following it. *(The S44 handoff's "`main` still
  carries the home path" is stale: after PR #65 the tree does not, only the history does.)*
- 🔴 **P2 — private vulnerability reporting is not established.** 404, recorded `unknown` in
  `.github/REPO-SETTINGS.md`, hedged in both `SECURITY.md` and `CODE_OF_CONDUCT.md`. A **closed door
  with honest signage**, not a lie — but a repository setting only the founder can change.
- 🟠 **The vision has had no new product surface for ~16 sessions.** The newest commit that *added* a
  chart module is `c72cc14` (2026-08-03, the S09 ring renderer); 23 chart modules exist. Defensible
  sequencing — the cleanup was load-bearing — but the flip it cleared the path for has now slipped a
  session to an audit, and sequencing without an owner is how a detour becomes the destination.
- 🟠 **Six ledger rows re-confirmed, not closed:** the adoption baseline (`t0`), S16, `required-crew`,
  the cost gate that greps a heading, the false `true` claims (**worsened**), and the vacuous GT
  no-code backstop. Every remedy is a `verify-closeout.sh` or `AGENTS.md` change — **code**, so
  illegal in a NO-CODE session. The ledger now reads **14 `DEFERRED` / 18 `DONE`**.
- 🟠 **The cost gate greps a heading** and the S44 cost line is demonstrably incomplete: it records one
  clean delivery and **0** mentions of the follow-up PR #66, the eight cold-review passes, or the
  REJECT.
- 🟠 **`.ai/.session-owner` is gitignored** (`.gitignore:2`) and pinned at chat `12` (session 36), so
  `one_session_per_chat` cannot bind across chats. `verify.clean_room.enabled: false` — an S119 gap
  disclosed in the config and never closed.
- **MCP server: founder-DEFERRED, not built, not stubbed.** Its gate (a release exists **and** someone
  demands it) is honestly unmet.
- **Historical verify scripts** are unrunnable by design (01, 02, 03, 07, 31, 34, 36, 37, 38); **36**
  numbered scripts exist and the state names 4 as live, leaving **32** unclassified.

## Milestones done
- **S01–S04** docs/examples/polish/README · **S05** NO-CODE ground-truth · **S06** publishable
  dist · **S07** CI · **S08** release.yml + line/SVG · **S09** circular+area LOCKED · **S10**
  line · **S11** catalog two-panel · **S12** bar · **S13** Darpan-parity chrome · **S14** URL
  routes+persistence · **S15** scripted browser QA · **S17** scatter · **S18** heatmap · **S19**
  horizontalBar · **S20** treemap · **S21** timeline · **S22** gauge · **S23** progress · **S24**
  grouped nav · **S25** histogram · **S26** waterfall+funnel+sankey+radar · **S27**
  candlestick+boxplot · **S28** sparkline · **S31** antra atoms + hero rotation + wall fix · **S32**
  wall playbook · **S33** release readiness · **S34** GTM README + MIT LICENSE · **S35** NO-CODE
  ground-truth · **S36** S35 gaps closed + deploy unfrozen · **S37** package published · **S38** OIDC
  release runway, `0.2.0` unattended · **S39** renamed to `@ifelse.codes/chitra`, `0.3.0` live ·
  **S40** NO-CODE ground-truth audit, 🔴, 11 remediations · **S41** cleanup Batch 1 — the public face
  is honest · **S42** cleanup Batch 2 — dead weight: 110 files · **S43** cleanup Batch 3 — docs weight ·
  **S44** cleanup Batch 4 — OSS polish + the six founder decisions · **S45** NO-CODE ground-truth
  audit, 🔴 — **the cadence named nowhere in the constitution, a coverage check blind for 7 sessions,
  and S44's REJECT verdict recorded as COMPLETE.**

## Cost Tracking
- S45 measured: one opencode session; **1** founder decision in-chat (make S45 the review session and
  carry the flip forward) plus the plan approval, which carried the commit approval; **11
  requirements**; **27 probes, 3 retired**; **0** product-code changes under `packages/core/`; **0**
  new product tests (453 stays 453); **0** lockfile changes; **0** releases; **0** npm secrets; **0**
  new recurring infrastructure; **$0** npm cost. **16 commits, 14 files, every one inside the 3-file cap**
  (verified per commit, not asserted: `git rev-list main..HEAD | while read c; do git show --numstat
  --format='' "$c" | grep -c .; done` → max **3**) — which is worth stating plainly rather than hiding
  behind, since this session's own finding is that the cap is breached by **17 of the last 60**
  commits on `main`. **Six of the sixteen commits exist only because a gate or the cold review caught
  this session's own work**, which is the honest cost line: the finding was not free, and it was paid
  in the currency the audit is about. *(An earlier draft of this line read "Three commits", then "6";
  both were true at no instant. Derive it.)*
  cap. Token/`$` cost **unmeasured** (billed to the founder's plan) — the correct honest reading.
  Delivery size derived, never typed: `git diff --shortstat main...HEAD`, `git rev-list --count HEAD`.
- S44: one session, 6 founder decisions, 14 requirements, **plus a follow-up PR (#66) after eight
  cold-review passes and a REJECT verdict** — none of which its own cost line records. S43: 1 decision,
  10 requirements. S42: 4 decisions, 10 requirements. S41: 6 cold-review passes, 34 files. S40: 49
  audit probes + 41 re-verifications, 0 code changes.
