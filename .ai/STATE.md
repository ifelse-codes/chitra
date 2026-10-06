# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S47 — **make the
governance gates able to fail**, complete and closed 2026-10-05: R1–R9 from
`sessions/session-45-ground-truth.md` § *Findings, ranked*, 4 review passes ending
**ACCEPT 13/13**; S46 closed 2026-10-04: P1, P2, F1–F6 discharged, repo public.)

## Active Branch
`session-47-gate-truth` from `main` (`a218ac5` at branch time — derive with
`git rev-parse main`). Delivery: **16 commits** (10 from the builder session, 6 from
the finisher), all `S47:`, max **3 files** each (derived per commit with
`git show --numstat`): `scripts/verify-closeout.sh` fail-closed fixes (R1–R3) +
`scripts/verify-session-47.sh` + `scripts/demo-session-47.sh` +
`prompts/47-task-gate-truth.md` + backfilled `sessions/session-40-summary.md` +
`sessions/session-47-support-ticket.md` (R8 evidence) + `.ai/` sync. No file under
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
- **GTM — the adoption instrument now reads the number (S48 R2).**
  `node scripts/gtm-reads.mjs` (day-level series, release days labelled from the npm
  registry's own publish times): **t1 = 273** through **2026-10-06** — **243** of them
  on the two release days (0.3.0 on 09-29, 0.4.0 on 10-04), **30** across the four days
  after 0.3.0, and **0 on 10-05 and 10-06**. **t0 = 119 reproduces exactly** with
  `--as-of 2026-10-03`, so S46's figure is no longer a typed number. **No organic
  signal yet** — and the day the instrument shows one is the day this line changes.
  Never cite 273 (or 119) as traction.
- **R1 — coverage sees squash merges.** `check_session_coverage` derives its population
  from merge subjects UNION squash subjects (`SNN:`), records newest belief (**S46**;
  the old merge-only body believed **S37** — run both commands beside each other),
  refuses an empty population, and requires a summary per merged session ≥ S17.
  **S40 backfilled** (`sessions/session-40-summary.md`, disclosed backfill) — the exact
  record the old blindness cost.
- **R2 — no-code fails closed, all three conjuncts.** `check_ground_truth_no_code`
  requires the GT artifact non-empty, BLOCKS on an empty/unresolvable range instead of
  passing, and **scans the worktree as well as `base..HEAD`** — so the contract's
  literal stimulus (an untracked `packages/core/src/*.ts` under synthetic GT N) goes
  red. Proven as a pair: a code-free range reads OK, the same range with the plant
  reads RED, plant removed reads OK again; and the clause fires a second time on a
  real committed code change aimed at with `VLT_GT_BASE`/`VLT_GT_HEAD`.
- **R3 — cost tracking is a measurement, not a keyword.** The check requires a NUMBER
  within 60 chars of each of `session|decision|requirement|commit|release` plus a
  derivation word over a 200-char floor; a heading-only block goes red **and** the
  long zero-digit prose block pass 2 shipped as its fakest green goes red (both
  fixtures executed in the session gate).
- **R4 — S44's canonical verdict is REJECT, disclosed.** `sessions/session-44-review.md`
  carries one verdict line (`**Verdict:** REJECT`, 8 passes, follow-up PR #66
  `79af323`); `check_review_attestation` reads N/A for a REJECT, so S44 carries no
  DECISION-003 attestation. STATE/ROADMAP no longer record it COMPLETE.
- **Product:** **453/453** tests in **23** files (derive: `pnpm --filter
  @ifelse.codes/chitra run test`); typecheck, chart drift, prettier clean.

## What Is In Progress
- **S47 is complete.** 4 independent review passes (pass 2 **REJECT** → 2 fixes →
  pass 3 ACCEPT → 2 residual fixes → pass 4 **ACCEPT 13/13**), session gate **14/14**,
  demo **9/9**, closeout green behind the founder crew waiver. What closes it: a new
  chat for **S48**.
- **S50 (`50 % 5 == 0`) is the next NO-CODE ground truth** (cadence:
  `CONSTRAINTS.yaml#ground_truth_every_n_sessions: 5`, named in BOOT + TASK +
  ROADMAP this session). S48/S49 are code sessions.

## What Is Broken / Incomplete
- 🟠 **The P1 residual — founder decision, 2026-10-05: DO NOT FILE.**
  `refs/pull/*` is read-only (`DELETE …/git/refs/pull/67/head` → **`422
  refs/pull/* is read-only`**, re-derived 2026-10-05); **71** PR heads served
  (derive with `git ls-remote origin 'refs/pull/*/head' | wc -l` — this count moves
  with every PR: 70 before #71, 68 at the S46 audit). No API we own deletes them.
  The request text stays prepared in `sessions/session-47-support-ticket.md`, but the
  founder weighed it and chose to leave it: the residue is reachable only by a
  deliberate fetch of old PR refs, no credential is in it, and the worry that GitHub's
  cleanup might remove something we need was checked — deleting `refs/pull/*` touches
  neither `main`, nor tags, nor releases. **Open on purpose, by decision**; only the
  founder can reopen the filing question.
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
- 🟠 **S47's own residuals, listed by the independent review (pass 4), none a
  contract done-condition:** (a) the worktree scan exempts untracked **root-level
  dotfiles** while the committed side catches them — the gap only ever exempts a file
  that never ships; (b) gitignored paths (`dist/`) stay invisible to
  `git status --porcelain`, disclosed in the code comment; (c) the **cost counts are
  asserted, not re-derived** — an honest-but-wrong cost line still passes, unlike the
  test count (suite-derived) and the tag SHAs (`git rev-parse`); (d) one
  `VAJRA_CLOSEOUT_WAIVER` variable waives **both** `required-crew` and
  `review-inputs-attested`, so "17/17 with waiver" is 15 verified + 2 waived;
  (e) the gate's probes `touch`/`rm -f` a named file — an interrupted run leaves
  debris with no check to notice it.
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
- **S47** **make the governance gates able to fail** — coverage sees squash merges
  (S40 backfilled), no-code fails closed on empty ranges *and* planted files, cost
  tracking needs numbers not keywords, S44's REJECT disclosed, the 3-file cap scoped
  honestly, stale facts guarded by derivation, crew row re-pointed, the P1 ticket
  text written, the GT cadence named — closed with **4 review passes ending ACCEPT**.

## Cost Tracking
- S47 measured (final): **2** opencode sessions — the builder session and the finisher
  session that closed its review's REJECT — under **1** chat (founder overrode the
  one-session-per-chat rule explicitly); plan approval carrying commit approval, **2**
  founder decisions at plan (D-47-1 S44 record, D-47-2 crew gate) + **1** crew-waiver
  grant in chat; **9** requirements (R1–R9) + **2** assumptions, both held;
  **16 delivery commits** (10 builder + 6 finisher), each **≤ 3 files** (derived per
  commit with `git show --numstat`, not asserted); **4** review passes (1 ended REJECT,
  2 fixes, final ACCEPT 13/13 by an independent reviewer session); **0** product tests
  added (453 stays 453); **0** lockfile changes; **0** npm secrets; **0** releases this
  session; **0** new recurring infrastructure. Token/`$` cost **unmeasured** (billed to
  the founder's plan): the correct honest reading.
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
