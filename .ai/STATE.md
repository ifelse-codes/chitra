# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S47 — **make the
governance gates able to fail**, in progress: R1–R9 from `sessions/session-45-ground-truth.md`
§ *Findings, ranked*. S46 closed 2026-10-04: P1, P2, F1–F6 discharged, repo public.)

## Active Branch
`session-47-gate-truth` from `main` (`a218ac5` at branch time — derive with
`git rev-parse main`). Delivery: `scripts/verify-closeout.sh` fail-closed fixes
(R1–R3) + `scripts/verify-session-47.sh` + `scripts/demo-session-47.sh` +
`prompts/47-task-gate-truth.md` + backfilled `sessions/session-40-summary.md` +
`sessions/session-47-support-ticket.md` (R8 evidence). No file under
`packages/core/src/`; lockfile untouched.

## What Currently Works (observed, not claimed)
- **The repository is public.** `gh api repos/ifelse-codes/chitra --jq .private` → **`false`**,
  `.visibility` → **`public`**, the clone URL returns **200**, anonymous `--depth=1`
  clone succeeds (before: `true` / `private` / `404`; rows in `sessions/session-46-flip.md`).
- **P1 holds.** Pattern `(/|-)Users[-/][a-z]+` matches nothing in any commit reachable
  from `HEAD` (re-derived by S46's `p1-history-and-tree-clean` over every reachable
  commit + tree scan with an assembled true-positive). Residual below, not here.
- **P2 on:** `{"enabled":true}` (public-repo-only endpoint, proved against control).
- **F5/F6 stand:** `0.4.0` with provenance (sigstore, `0.3.0` has none, no workflow
  edit); `t0` = 119 lifetime downloads, none organic (derive with the downloads API).
- **R1 — coverage sees squash merges.** `check_session_coverage` derives its population
  from merge subjects UNION squash subjects (`SNN:`), records newest belief (**S46**;
  the old merge-only body believed **S37** — run both commands beside each other),
  refuses an empty population, and requires a summary per merged session ≥ S17.
  **S40 backfilled** (`sessions/session-40-summary.md`, disclosed backfill) — the exact
  record the old blindness cost.
- **R2 — no-code fails closed.** `check_ground_truth_no_code` requires the GT artifact
  non-empty and BLOCKS on an empty/unresolvable range instead of passing; offender path
  exercised in `verify-session-47.sh` with a planted file under synthetic GT N.
- **R3 — cost tracking is a measurement.** The check requires decisions + commit/requirement
  counts + derivation words over a 200-char floor; a heading-only block goes red
  (demonstrated on a fixture in the session gate).
- **R4 — S44's canonical verdict is REJECT, disclosed.** `sessions/session-44-review.md`
  carries one verdict line (`**Verdict:** REJECT`, 8 passes, follow-up PR #66
  `79af323`); `check_review_attestation` reads N/A for a REJECT, so S44 carries no
  DECISION-003 attestation. STATE/ROADMAP no longer record it COMPLETE.
- **Product:** **453/453** tests in **23** files (derive: `pnpm --filter
  @ifelse.codes/chitra run test`); typecheck, chart drift, prettier clean.

## What Is In Progress
- **S47 is in progress** on `session-47-gate-truth` (R1–R9). Remaining in-session:
  session gate green, cold review with attestation, closeout green, PR.
- **S50 (`50 % 5 == 0`) is the next NO-CODE ground truth** (cadence:
  `CONSTRAINTS.yaml#ground_truth_every_n_sessions: 5`, named in BOOT + TASK +
  ROADMAP this session). S48/S49 are code sessions.

## What Is Broken / Incomplete
- 🔴 **The P1 residual is disclosed, ticket text ready, filing needs a human.**
  `refs/pull/*` is read-only (`DELETE …/git/refs/pull/67/head` → **`422
  refs/pull/* is read-only`**, re-derived 2026-10-05); **71** PR heads served
  (derive with `git ls-remote origin 'refs/pull/*/head' | wc -l` — this count moves
  with every PR: 70 before #71, 68 at the S46 audit). No API we own deletes them.
  Request text + evidence: `sessions/session-47-support-ticket.md`. Until support
  confirms deletion + GC, the status is DISCLOSED, not closed (same as S46 left it).
- 🔴 **The crew gate's standing condition.** 5 waivers (S38/S39/S42/S44/S46); S47
  records waiver-or-green honestly. Vajra confirms helper provenance only from a
  Claude Code record, so under OpenCode the gate needs `VAJRA_CLOSEOUT_WAIVER=47`
  with reason per its own message — the standing condition, not a one-off.
- 🟠 **S44's cost line is corrected, not just disclosed.** It recorded one clean
  delivery; the truth is delivery + **8 cold-review passes ending REJECT** +
  follow-up PR #66 (`79af323`, the honesty layer). Both the ledger row and the
  cost block below now say so.
- 🟠 **The 3-file cap is branch/delivery-scoped, not history-scoped (R5).** 17 of the
  last 60 `main` commits breach it (all squash merges, which never run a local hook).
  What this repo owns is corrected: the delivery cap is derived per commit in the
  session gate (`commit_cap_respected`); the vajra-owned `AGENTS.md` "Hook-enforced"
  line is **disclosed as a vajra-side change, not edited** (governed body).
- 🟠 **GT cadence in AGENTS.md (R9).** Named everywhere this repo owns
  (BOOT + TASK + ROADMAP + contract, each with the `N % 5` derivation); the
  constitution line itself is vajra-owned — patch proposed in the S47 summary,
  never smuggled as an edit.
- 🟠 **Vision has no new product surface since `c72cc14` (S09).** Sequencing was
  defensible (cleanup → flip → gates); the path is now clear.
- 🟠 **`.ai/.session-owner` gitignored at chat `12`; `clean_room.enabled: false`**
  (S45 E2, backlog 🟡 — untouched by design).
- **MCP server: founder-DEFERRED, not built.** Gate honestly unmet.

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
  ground-truth audit, 🔴, 11 remediations (summary backfilled in S47 — the gate-blindness
  record) · **S41** cleanup Batch 1 — the public face is honest ·
  **S42** cleanup Batch 2 — dead weight: 110 files · **S43** cleanup Batch 3 — docs weight · **S44**
  cleanup Batch 4 — OSS polish + six founder decisions; **canonical fidelity verdict REJECT
  (8 passes) + follow-up PR #66 — disclosed, not COMPLETE** · **S45** NO-CODE ground-truth
  audit, 🔴 — cadence named nowhere, coverage blind 7 sessions, S44 REJECT recorded COMPLETE ·
  **S46** **the public flip** — repo public, history scrubbed (`1001 → 0`), private reporting on,
  `0.4.0` with provenance where `0.3.0` has none, `t0` recorded, S44 home-path gate repaired.
- 🔄 **S47 (in progress)** — gates that can fail (R1–R9) + P1 ticket ride-along.

## Cost Tracking
- S47 (in progress, measured so far): one opencode session; plan approval carrying
  commit approval + 2 founder decisions requested at plan (D-47-1 S44 record, D-47-2
  crew gate); **9** requirements (R1–R9) + **2** assumptions, both held; delivery so far
  **4 commits** (contract, closeout-gate fixes, S40 backfill + ticket, boot chain),
  each **≤ 3 files** (derived per commit with `git show --numstat`, not asserted);
  **0** product tests added (453 stays 453); **0** lockfile changes; **0** npm secrets;
  **0** new recurring infrastructure. Token/`$` cost **unmeasured** (billed to the
  founder's plan): the correct honest reading. Final counts at closeout.
- S46 measured: one opencode session; **3** founder decisions in-chat (plan approval, P2
  reorder, `home-path-scrubbed` fix) + **1** implicit commit approval; **8** requirements
  (P1, P2, F1–F6) + **2** assumptions, both held; **4 delivery commits, 9 files, max 3
  files per commit** (derived per commit with `git show --numstat`); **1** pre-push
  `--no-verify`, disclosed; **1** release, **0** npm secrets. Token/`$` unmeasured.
- S44 corrected: one session + follow-up PR #66 (`79af323`); **8 cold-review passes
  ending `REJECT`** (canonical verdict — S45-F1, disclosed here and in ROADMAP, never
  COMPLETE); 6 founder decisions + 14 requirements; follow-up closed with a gate.
- S45: one session, 1 founder decision + plan approval, 11 requirements, 6 numbered
  probes + 2 retired + verification commands, 0 code changes. S43: 1 decision, 10
  requirements. S42: 4 decisions, 10 requirements. S41: 6 cold-review passes, 34 files.
  S40: 49 audit probes + 41 re-verifications, 0 code changes.
