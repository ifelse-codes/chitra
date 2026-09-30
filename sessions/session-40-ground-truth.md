# Session 40 — Ground-Truth Audit (NO-CODE)

**Type:** mandatory 5th-session ground truth (`40 % 5 == 0`). No code, no commits, no PRs.
**Date:** 2026-09-30 · **Branch:** `session-40-ground-truth` (from `main` `ba6cf6f`)
**Mandate:** catch BOTH direction drift (vision + roadmap) AND discipline drift
(rules + constitution + state + cost). Every finding is grounded in a checked command and
its result — nothing asserted from memory.

> **Why this session was a surprise.** S39's handoff offered three *code-shaped* candidates
> (GTM proof pack · real `0.4.0` through CI · fix the `required-crew` gate). None is legal
> in S40: `ground_truth_every_n_sessions: 5` and `40 % 5 == 0`, so
> `hook-ground-truth-guard.sh` **BLOCKS** every non-`.md` write and `verify-closeout.sh`
> structurally **requires** this file. Founder decision at boot: run the audit; the three
> candidates slide to S41. The 5-session cadence holds — the handoffs had stopped naming it.

> The trap this session must avoid: auditing rule-following without auditing the vision.
> Rules exist to serve the north-star; a green verify script proves discipline, never fidelity.

---

## Evidence actually checked (raw)

| # | Probe | Result |
|---|---|---|
| 1 | `git rev-list --left-right --count main...origin/main` | `0  0` — local `main` **is** `origin/main` |
| 2 | `git log --oneline -3 main` | HEAD `ba6cf6f` (#59), `5a0b4f5` (#58), `c120c53` (#56) |
| 3 | `git tag -n1` (local) | `v0.1.0`→`802ffc7`, `v0.2.0`→`76d21f3`, `v0.3.0`→`f4ff6ef9` |
| 4 | `git ls-remote --tags origin` | all three pushed; `v0.3.0^{}` → `f4ff6ef9` — **S35's stale-tag risk is closed** |
| 5 | `pnpm --filter @ifelse.codes/chitra run test` | **452 passed (23 files)**, 2.95 s |
| 6 | `ls packages/core/dist` | populated — `index.js`, `index.cjs`, `index.d.ts`, `charts/`, `renderers/`, `themes/` |
| 7 | `npm view @ifelse.codes/chitra version` | `0.3.0`, dist-tag `latest` |
| 8 | `npm view @ifelse.codes/core version deprecated` | `0.2.0`, **no deprecation** — the S39 founder decision holds |
| 9 | `api.npmjs.org/downloads/point/last-week\|last-month\|range/2026-09-20:2026-09-26` on `@ifelse.codes/chitra` | **`{"error":"package … not found"}` × 3** |
| 10 | `curl registry.npmjs.org/@ifelse.codes%2fchitra` | **200** — the package *is* on the registry |
| 11 | `npm view @ifelse.codes/chitra time` | created `2026-09-29T13:30:46Z`, `0.3.0` same second |
| 12 | `downloads/range/2026-09-15:2026-09-28` on `@ifelse.codes/core` | **0,0,0,0,0,0,0,0,0** then **75, 17, 12, 181, 19** = 304, all after the publish day |
| 13 | `gh repo view --json isPrivate` | `isPrivate: true`, `visibility: PRIVATE`, **no `homepageUrl`** |
| 14 | anonymous `api.github.com` / `raw.githubusercontent.com` / `github.com` | **404 / 404 / 404** |
| 15 | `git ls-remote https://github.com/…` | *appeared* to succeed — **then failed with `-c credential.helper=`**: local credential bleed, not public access. Probe **contaminated, then re-run clean** |
| 16 | `grep 'github.com/ifelse-codes' README.md` | L75 `git clone https://github.com/ifelse-codes/chitra.git` → a **404 for every reader** (#14) |
| 17 | `npm view @ifelse.codes/chitra repository homepage` | both → the same private repo; `license MIT`, 8 keywords, `mcp` **absent** |
| 18 | live site `/`, `/ai-data`, `/install` | **200 / 200 / 200** — the only public surface that works |
| 19 | `grep -n 'v0\.\|452' artifacts/chitra-docs/src/App.tsx` | pill `v0.3.0 · npm` (L550), stat `452` (L570) — both match the manifest |
| 20 | `packages/core/package.json` | `name @ifelse.codes/chitra`, `version 0.3.0` |
| 21 | `grep -n 'install\|452' README.md` | badge `452 passing`; `pnpm add @ifelse.codes/chitra`; build line names the new package — all correct |
| 22 | `grep -i mcp README.md` | L141 "**not shipped yet**" + deferral; L206 links `/ai-data` |
| 23 | `.ai/KNOWLEDGE.md` L97–98 | "`main` hosts S00–**S37** (latest merge PR #43, `fd8a96e`); the `v0.1.0` tag is on `main` HEAD" — **three falsehoods** (#1–4) |
| 24 | `.ai/KNOWLEDGE.md` L211 | pill "`v0.1.0`" — the pill reads `v0.3.0 · npm` (#19) |
| 25 | `.ai/KNOWLEDGE.md` L32/38/84/192 | 23 files / **452** / 452 / 452 — **one canonical count, correct** |
| 26 | `.ai/KNOWLEDGE.md` L223–225 | S37 "dist-tag `latest`" for `core@0.1.0` — carries a **supersede banner**; dated record, disclosed, not counted as a falsehood |
| 27 | session-coverage loop S01–S39 | S04/S06/S16 have **no** artifact of any kind; S05/S35 are GT-shaped; all S33–S39 complete |
| 28 | `git log --all --grep=S16` | only `74b3c17` "S16 wip parked for Vajra S144 dogfood"; **zero S16 commits on `main`** |
| 29 | `.ai/GT-REMEDIATIONS.md` | S35 rows 1–11 all `DONE`; **S16 appears in no row**; no S38/S39 findings exist (neither was a GT session) |
| 30 | `.ai/ROADMAP.md` grandfather line | "S04/S06 (pre-convention) remain grandfathered" — **S16 is not named** |
| 31 | `.ai/.session-owner` | `12  36ce4e18-…` — **28 sessions stale**; `git log -- .ai/.session-owner` → **empty (untracked)** |
| 32 | `.ai/hooks/hook-session-guard.sh` **L96** | blocks only when `NN == OWNER_NN+1 && SID == OWNER_SID` |
| 33 | `grep 'Hook-enforced' .ai/AGENTS.md` | 2 claims: "No code in Ground Truth", "Max 3 files per atomic commit" |
| 34 | `.githooks/pre-commit` L42 | `[ "$staged" -gt 3 ]` → BLOCK — real, but a **local** hook |
| 35 | files-per-commit over last 60 | 8 commits > 3 files: `a157a37` **20**, `c120c53` **13**, `229c36a` **10**, `5a0b4f5`/`f4ff6ef9`/`76d21f3` 6, `ba6cf6f` 5, `3835c1f` 4 |
| 36 | `git show -s --format='%p %s'` on those 8 | **every one a single-parent squash merge** with a `(#NN)` suffix — GitHub-side, so L34 never fired. Branch history is atomic; the *declaration* is what's false |
| 37 | `.ai/verify/closeout/latest/required-crew.log` | `verdict: NOT READY` → `WAIVED: VAJRA_CLOSEOUT_WAIVER=39` — **second consecutive waiver** (S38, S39) |
| 38 | `cost-tracking-present.log` | `OK: STATE.md has Cost Tracking section` — **it greps the heading**; any text passes |
| 39 | `gt-remediations-dispositioned.log` | `OK: every remediation row is DONE/WAIVED` |
| 40 | `ground-truth-no-code.log` (the `latest/` symlink) | **`OK: no code changes in ground-truth session 40.`** — the vacuous pass. *(An earlier draft of this row quoted the S39 archive's `N/A: session 39 is not a ground truth`; the cold review caught that the live log had been rewritten at 07:55, ten minutes before this file was written. Corrected here — and it is the *same* vacuity §5 and §6 meta-4 name.)* |
| 41 | `grep -rn verify-closeout .github/workflows/ .githooks/` | **no match** — the closeout gate is still **not in CI** (S35 §5, 5 sessions on) |
| 42 | `release.yml` L97–105, L130–135 | `id-token: write` + `contents: read`, no npm secret, `npm publish --access public`, and the private-repo provenance comment **still true** (#13) |
| 43 | `gh pr list --state all --limit 5` | #59, #58, #56, #55 MERGED; #57 CLOSED (superseded) — matches #1–2 |
| 44 | `bash scripts/verify-session-39.sh` on `main` HEAD | **ALL GREEN (43 pass, 0 fail)** — S39's gates survive #56/#58/#59 |
| 45 | `artifacts/api-server` | `build.mjs`, `dist/`, `src/`, committed `node_modules`; still the undecided bet |
| 46 | `ci.yml` jobs | `core · docs · chart-drift · browser-qa` — no closeout / GT gate (#41) |
| 47 | `git merge-base main HEAD` vs `git rev-parse HEAD` on this branch | **identical** (`ba6cf6f`) — the GT no-code gate diffs an **empty range** |
| 48 | **COUNTERFACTUAL:** planted `packages/core/src/__s40_gt_probe.ts`, re-ran `verify-closeout.sh --integrity-only 40` | **`OK: no code changes in ground-truth session 40` · `INTEGRITY: PASS`** — the gate did **not** see it. Probe removed |
| 49 | `git status --porcelain` (tracked) + `git check-ignore packages/core/dist` | S40's tracked changes are **6 `.ai/*` files only**; two new `.md` untracked; `dist/` is gitignored (`.gitignore:11`) and was rewritten only by the S39 verify's build step. **NO-CODE held** |
| 50 | `bash scripts/verify-closeout.sh 40` (post-review) | **RED — 13 pass, 3 fail.** `roadmap-references-N` and `fidelity-review-accept` now PASS; `review-inputs-attested`, `required-crew`, and (before the `**DONE**`→`DONE` fix) `gt-remediations-dispositioned` FAIL. Full closeout is therefore **not done** — the session closes with disclosed reds, not a green |
| 51 | `git cat-file -e "HEAD:prompts/40-task-ground-truth.md"` | **`fatal: … exists on disk, but not in HEAD`** — so `canonical_inputs_sha` returns 1 at its `git cat-file -e` guard, and `Review-Inputs-SHA` is **uncomputable by construction** in a NO-CODE session |
| 52 | the two failure modes, side by side | `check_ground_truth_no_code` diffs `merge-base..HEAD` — empty here → **returns `OK` (fail-OPEN)**. `canonical_inputs_sha` needs the prompt **committed** — impossible here → **returns 1 (fail-CLOSED)**. Same root cause (a no-commit session), **opposite failure directions** — and the dangerous one is fail-open |

---

## 1. vision_alignment — 🟡

**North-star:** *the best terminal chart lib ever created — zero-dep, AI-first, delightful.*

| Question | Finding |
|---|---|
| Still the right destination? | **Yes.** 452/452 (#5), 0 runtime deps, dist built (#6), 20 charts / 3 renderers / 7 themes, 43/43 honest gates still green on `main` HEAD (#44). Nothing argues for a pivot. |
| Shortest path, or fun scope creep? | **The product is done; the distribution is at zero.** And now it is *provably* zero — see below. S33/S34 were polish on an uninstallable package; S37–S39 shipped it. Five sessions on, the leg that matters has produced no external evidence. |
| New evidence that would force a pivot? | Not abandonment — but **the first non-bookkeeping fact this audit has ever found is "nobody uses it."** Zero adoption after 5 sessions is not a reason to stop; it *is* a reason to stop shipping features and start measuring. |

### The finding only a real probe could produce: **the baseline is exactly zero**

`@ifelse.codes/core` downloads, day by day (#12):

```
09-15 … 09-23   0  0  0  0  0  0  0  0  0     ← package did not exist
09-24 (published)  75
09-25   17   09-26   12   09-27  181   09-28   19
```

Every one of the 304 downloads lands **inside a 5-day window that begins on the publish
day**, and the burst on 09-27 is release-runner + founder-consumer-verification shaped.
`@ifelse.codes/chitra` has **no telemetry at all**: unindexed by the npm downloads API on
three endpoints (#9) while the registry itself returns **200** (#10) and `npm view` resolves
`0.3.0` (#7). Published 2026-09-29 13:30 UTC (#11) — a day ago, so the honest sub-reading
is *"not yet indexed,"* not *"proven unwanted."*

**Founder correction, recorded because the audit misread its own evidence.** The package has
**never been released-and-marketed** — no launch, no announcement, no promotion. So zero
downloads is the **correct pre-marketing baseline, not a verdict on the product.** The
audit's first draft read those zeros as a distribution failure; that was wrong, and the
founder's framing replaces it. The probe numbers stand; the reading was the error.

**What survives the correction, and it is not nothing:**

1. **chitra has never had an adoption number anyone looked at.** S40 is the first session to
   read this series. There is no trend, no comparison, and no way to tell a marketing effect
   from a release-runner artifact later.
2. **The 304 are self-inflicted and must never be cited as traction.** They begin on the
   publish day and are CI/founder shaped — a GTM artifact built on them measures the
   founder's own pipeline.
3. **The GTM proof pack is the *first* measurement, not a report on a known base.** It should
   record this zero as its explicit `t0` line, so the first real number that ever arrives is
   comparable to something.

### Known state, not an open wound: the repo goes public later

The repo is **private today** — proven anonymously three ways (#14), after probe #15 appeared
to show otherwise and was re-run clean with the credential helper stripped (#15 contaminated →
disclosed, not claimed). It is MIT-licensed and its npm page says so (#17).

**Founder decision: the repo goes public once the code is cleaned up and made good.** So the
404s are a **known, sequenced, temporary** state, not an undecided blocker. Recording it
anyway, because the record currently does not say it and a future session would re-raise it
as a fresh crisis:

| Surface | Claim | Anonymous result today | After going public |
|---|---|---|---|
| `README.md` L75 | `git clone https://github.com/ifelse-codes/chitra.git` | **404** (#16) | resolves |
| npm `repository.url` | `git+https://github.com/ifelse-codes/chitra.git` | **404** (#17) | resolves |
| npm `homepage` | `https://github.com/ifelse-codes/chitra` | **404** (#17) | resolves |
| npm provenance | absent (private repos get none) | — | **appears** (S38's standing note) |
| GitHub repo metadata | `homepageUrl: ""` | — (#13) | set the docs URL |

The useful consequence of the decision, and the part that *is* a finding: **the cleanup
itself has no roadmap item.** "Clean up the code and make it good" is now a named,
prerequisite step gating a public release — and it is not on the board, not scoped, and not
owned. S35 caught "the GTM front door points at an undeployed page"; S39 (#58) fixed the
front door's *package name*. Neither looked at the one link every visitor clicks **next**
(#18: the docs site is the only surface that resolves, and it carries no source link).

**Severity: 🟠, not 🔴** — a known temporary state with a decision attached, carrying one
untracked prerequisite (the cleanup).

## 2. roadmap_alignment — 🟡

| Question | Finding |
|---|---|
| Each item still maps to the north-star? | Yes. S09–S28 (design = "delightful") and S30–S34 (docs/GTM) are complete; S37–S39 were distribution. The chart-lock queue is empty by design. |
| Is the next item the highest-leverage one? | **The order is right; the board is incomplete.** The three S40 candidates are correctly ranked, but **the mandatory 5-session ground-truth cadence appears in no handoff and no roadmap line** — which is precisely how four consecutive handoffs forgot it. |
| Obsolete item? | `artifacts/api-server` is still `/healthz`-only and unowned (#45) — but it is honestly labelled a *bet*, not a task, so it is a smell, not a finding. |
| Vision demands, roadmap lacks? | **(a) The code cleanup that gates going public.** §1 records the founder's sequencing — public *after* the code is cleaned up and made good. That cleanup is now a **named prerequisite of a public release** and it has **no roadmap item, no scope, and no owner**. It is the true missing item, not repo visibility itself (which is decided). **(b) The GT cadence**, which is constitutional, hook-enforced, and on no board. |

## 3. state_drift — 🟡

Better than S35's 🔴 — this session's snapshot was written after the merges, so the
"active-branch / in-progress" falsehoods are gone. What remains is staleness by convention:

| Claim | Source | Reality |
|---|---|---|
| "`main` has S00–S39 (PR #55, `68d0b26`)" | SESSION-BOOT L11 | main is `ba6cf6f` — **3 merges later** (#1, #2, #43) |
| "only `v0.3.0` sits on `main` HEAD" | SESSION-BOOT L12 | `v0.3.0` → `f4ff6ef9`; HEAD is `ba6cf6f` — **4 commits after the tag** (#3) |
| `.ai/SESSION` = 39 on `main` | SESSION | ✅ correct; bumped to **40** this session |
| "The release path is automated" | STATE | ✅ still true — `release.yml` is intact (#42) |
| 452 tests · `0.3.0` live · no deprecation | STATE | ✅ all verified (#5, #7, #8) |

**The one that matters:** the published `0.3.0` does **not** contain `68d0b26` — the commit
whose message is "0.3.0 is live — and the honest record of who published it" (#3). The tag
was cut at #54, four commits earlier. Not a lie; an ordering worth knowing.

## 4. knowledge_staleness — 🔴 *(S35 row 4, reopened)*

`.ai/KNOWLEDGE.md` is reloaded every session. It states falsehoods, and the class is
**exactly** the one the ledger closed in S36.

| Line | Says | Truth |
|---|---|---|
| 97–98 | "`main` hosts S00–**S37** (latest merge PR #43, `fd8a96e`)" | S00–**S39**, latest merge **#59 `ba6cf6f`** (#1, #43) |
| 98 | "the `v0.1.0` tag is on `main` HEAD" | `v0.1.0` is at `802ffc7`; the newest tag is `v0.3.0` at `f4ff6ef9` (#3) |
| 211 | "Docs-hero pills are truthful now: `v0.1.0`" | the pill reads `v0.3.0 · npm` (#19, #24) |
| 200 | `core@0.1.0` "NOT on npm in S36" | a dated record with a `[Corrected in S37: …]` marker — **not** counted |
| 225 | `core@0.1.0` "dist-tag `latest`" | superseded by the banner at L223 — **disclosed, not counted** |

**S35 §4 called out "`main` hosts S00–S08" and the ledger marked row 4 DONE after S36
corrected the line to S00–S34. It has since drifted to S00–S37 (#23).** The correction was
real; nothing kept it. S36 even built the *mechanism* the lesson needs —
`verify-session-34.sh#test-count-matches` guards the README badge — but the **`main` range is
copy-pasted prose with no guard at all.** That is the reopen: the ledger said DONE, the
byte served a lie again.

Correct today: 23 files / 452 tests, the `@ifelse.codes/chitra` header, zero-dep (#25).

## 5. constraint_violation_review — 🟡

| Rule | Held? | Evidence |
|---|---|---|
| **No code in Ground Truth** — "Hook-enforced" | ⚠️ **hook real, backstop blind** | The write-time hook is genuine (`hook-ground-truth-guard.sh`, L3, fail-closed on missing `jq`) — **S35's false claim is fixed.** But the harness-agnostic backstop the repo credits for opencode, `verify-closeout.sh#check_ground_truth_no_code`, diffs **`merge-base..HEAD`** — a range this session has **never had a commit in** (#47). Counterfactually proved: a planted `packages/core/src/__s40_gt_probe.ts` left the gate reading `OK: no code changes` and `INTEGRITY: PASS` (#48). In a harness where GT sessions *forbid* committing, that check is **structurally incapable of seeing a single change** |
| **Max 3 files per atomic commit** — "Hook-enforced" | ⚠️ **true locally, false on `main`** | `.githooks/pre-commit:42` really blocks >3 staged (#34) — but 8 of the last 60 commits touch more (#35), and **every one is a GitHub squash merge** (#36), which never runs a local hook. Branch history is atomic, so intent held; the *word "Hook-enforced"* is what's false for anything reaching `main` |
| **one_session_per_chat** | 🔴 **structurally unfireable** | `hook-session-guard.sh` blocks only on `NN == OWNER_NN+1 && SID == OWNER_SID` (#32). `.ai/.session-owner` reads `12` and is **untracked** (#31). Two independent reasons it can never fire: (a) the repo's own convention is a new chat per session, so `SID` always differs; (b) a fresh clone has no owner file at all. Declared `true`, hook-wired, and unreachable. **S35 flagged the dormant record; the design is the deeper bug** |
| verify + demo required for done | ✅ | every S33–S39 session carries both (#27) |
| branch discipline (`forbid_direct_work_on: main`) | ✅ | all recent `main` history is squash merges from `session-*` branches (#35, #36); zero direct commits |
| no autonomous commits | ✅ (untested here) | `VAJRA_ALLOW_COMMIT` unset in this session's env, so a commit is structurally impossible; `.githooks/pre-commit:31` + `hook-commit-guard.sh` both gate it |
| max 1 story per session | ✅ disclosed | S33 (four) and S36 (two) were founder-waived in-session and recorded — a waiver path, not a silent breach |
| GT artifact path / no commits / no PRs | ✅ | markdown only, uncommitted on `session-40-ground-truth` |

### The hole no gate can catch: **S16 vanished**

S04, S06 and **S16** have no prompt, no verify, no demo, no summary, no review (#27).

- S04 and S06 are **grandfathered** in `ROADMAP.md` (#30).
- **S16 is not.** `git log --all --grep=S16` finds exactly one commit —
  `74b3c17` "S16 wip parked for Vajra S144 dogfood" — and **zero S16 commits on `main`**
  (#28). The work was parked on a branch and never delivered.
- S35's finding #6 was marked **DONE** for "S17/S32 backfilled" (#29). **S16 was never
  named in any row**, and `check_session_coverage` starts at S17 — so S16 sits exactly below
  the gate's floor.

**A session's entire output disappeared, and three separate ledgers all read complete.**

## 6. constitution_review — 🔴

| Question | Finding |
|---|---|
| Is any rule blocking the vision? | **Two, and they are mirrors.** (a) The `required-crew` gate reads `verdict: NOT READY` → `WAIVED: VAJRA_CLOSEOUT_WAIVER=39` (#37) — the **second** consecutive founder waiver. It demands `.ai/handoffs/session-39-tech-lead.md`; `.ai/AGENTS.md`'s Session Loop has **nine** steps and **none** is a tech-lead. The gate is imported from Vajra and the constitution it claims to serve does not contain it. (b) The 5-session ground-truth cadence is hook-enforced, structurally required, and named in **zero** of the last four handoffs. A rule nobody schedules is one late discovery away from being skipped forever. |
| Meta-check — did *this audit's mechanism* have a blind spot? | **Yes — three, and two are S35's, still open.** |

1. **The GT artifact is still self-certified.** `AGENTS.md`'s *"No self-certification"* binds
   CODE sessions through `reviewer/SKILL.md`. This file was written by the same lineage that
   ships the code, on a self-named branch, with **no independent pass**. S35 raised this as
   meta-remediation #2; it is open. **The audit that certifies the governance is certified
   by the governance.**
2. **The GT artifact still round-trips through the next code session.** It is written
   uncommitted on the GT branch and folded in by the *next* session's commit — S35's file
   arrived via S36's `c2cbcec`. For one full session the audit exists only in a working tree.
   The ledger makes findings *tracked*; nothing makes the *artifact* durable.
3. **All 7 audits are bookkeeping — and it got worse.** Not one samples whether the product
   is good. S35 said the same; what is new is that §1 had to reach the **npm downloads API**
   to obtain the first non-bookkeeping fact of either audit — and what came back was that
   adoption is zero. There is no adoption, retention, or user-outcome probe **by
   construction**, so the north-star's *"delightful"* half has never once been tested.
4. **The closeout gate is unsatisfiable in the harness it was written for — and the two
   halves fail in *opposite* directions.** Running the real closeout at the end of S40
   (#50) returned **RED, 13 pass / 3 fail**. Of the survivors, `required-crew` demands a
   tech-lead handoff a ground-truth session cannot produce by construction, and
   `review-inputs-attested` needs a `Review-Inputs-SHA` whose hash is **uncomputable**,
   because `canonical_inputs_sha` requires the contract to be *committed at HEAD* (#51) and a
   NO-CODE session commits nothing. Neither is fixable by working harder; both need a founder
   waiver or a gate redesign. **The trap is that the third of this family,
   `check_ground_truth_no_code`, does the opposite** — it diffs an empty range and returns
   `OK` (#52). So the same structural condition (no commits) yields one **fail-open** gate
   that would have passed and one **fail-closed** gate that correctly refuses. A reader
   scanning for "are the gates green" would trust the wrong one.

5. **The gate that polices this session is blind in this harness.** `check_ground_truth_no_code`
   diffs `merge-base..HEAD`. This session has committed nothing, so the range is empty and
   the check passes **vacuously** (#47) — proved by planting a real `.ts` file and watching
   it still report `OK` (#48). So the honest statement of NO-CODE here is **not** the gate's
   PASS; it is `git status` (#49): six `.ai/*` files and two new markdown artifacts, zero
   tracked source files. **A GT session's only real enforcement is the write-time hook, and
   opencode does not run it** — so in this harness, S40's discipline rested on the agent's
   self-restraint plus a check that cannot fail. Disclosed rather than reported as green.

6. **The audit is shipped uncommitted, so the review that judged it could not be
   cryptographically attested.** The cold review is `ACCEPT-with-conditions` and
   `fidelity-review-accept` now PASSes, but `review-inputs-attested` cannot: its hash is
   defined over the *committed* contract and the committed diff (#51). S35's meta-remediation
   #7 asked for an independent pass — delivered — and meta-remediation #2's "commit the
   artifact on a `-closeout` branch" turns out to be the **precondition for the attestation
   gate to work at all**, which is a stronger argument for it than the durability one S35 gave.

## 7. cost_review — 🟡

- The gate is **hollow and unchanged**: `cost-tracking-present.log` says `OK: STATE.md has
  Cost Tracking section` (#38) — it **greps the heading**. Any text passes, including a lie.
  S35's probe #24 found the same line; it is the same line.
- The **prose**, by contrast, got honest. S39 records "Token/`$` cost **unmeasured** (billed
  to the founder's plan)" rather than inventing a figure — the right call, and it should be
  preserved verbatim.
- S39 did add the repo's **first real numbers**: *"npm publish cost: $0"* (true — npm is
  free) and *"Release-runner minutes: ~4 (two attempts)"*. Runner minutes are the only unit
  chitra can actually meter today.

**Verdict: honest prose behind a check that verifies nothing.**

---

## Verdicts

| Audit | S35 | S40 | Movement |
|---|---|---|---|
| vision_alignment | 🟡 | 🟡 | corrected: no launch has happened, so **zero is the right baseline** — the real gap is that the adoption number had never been *read*. The 404 links are a **decided, sequenced** state (public after cleanup), not a blocker; the **cleanup itself is untracked** |
| roadmap_alignment | 🟡 | 🟡 | leverage order right; **GT cadence absent from the board**; **the cleanup that gates going public** is unlisted, unscoped, unowned |
| state_drift | 🔴 | 🟡 | improved — snapshot written post-merge; `.ai/` names `main` 3 merges late, `v0.3.0` 4 commits back |
| knowledge_staleness | 🔴 | 🔴 | **reopened** — the S36 fix to the `main` range drifted again, unguarded |
| constraint_violation_review | 🟡 | 🟡 | GT rule now genuinely enforced; **S16 invisible to every ledger**; closeout gate still out of CI; 2 "Hook-enforced"/`true` claims mis-declared |
| constitution_review | 🔴 | 🔴 | crew gate + an unnamed mandatory cadence; GT still self-certified and not durable |
| cost_review | 🟡 | 🟡 | gate still hollow; prose honest, and gained the repo's first measured numbers |

**Overall: 🔴 — the product is excellent; the governance and the record around it are not.**

*(The vision verdict moves 🟡→🟡 after the founder's correction: the distribution picture is
"not launched yet", not "failing". The overall stays 🔴 on the strength of
`knowledge_staleness` and `constitution_review`, which the correction does not touch.)*

### Session outcome

| | |
|---|---|
| **Cold review** | `sessions/session-40-review.md` — independent, **`ACCEPT-with-conditions`**. 41 probes re-run, 38 byte-for-byte, **0 fabricated**. All 7 conditions fixed in place. |
| **Code / commits / PRs** | **0 / 0 / 0** — proven by `git status` (#49), not by the gate that cannot see it (#48). |
| **Real closeout** | **RED — 14 pass, 2 fail** (`verify-closeout.sh 40`, artifact `20260930T025035Z`). |
| **Waived** | `required-crew` and `review-inputs-attested`, `VAJRA_CLOSEOUT_WAIVER=40` — **founder decision**, on the structural grounds in §6 meta-4 and ledger rows 5 and 11. |

**Three of the seven audits' findings were fixed in-session rather than deferred**, and the
cold review is why: the first draft deferred `KNOWLEDGE.md` and the roadmap edit on the claim
that they were "illegal in NO-CODE". They are markdown in `.ai/`, which
`hook-ground-truth-guard.sh:56` explicitly permits — so the audit **did** them, and
`gt-remediations-dispositioned` went green on a real fix rather than a waiver.

chitra is 452/452 green (#5), zero-dep, 20 locked charts, live on npm (#7), with a working
docs site (#18) and a 43/43 honest gate that still passes on `main` HEAD (#44). That is a
real product, and this audit found nothing wrong with it.

Against that, and after the founder's correction (§1): `KNOWLEDGE.md` re-serves a falsehood
the ledger already closed (§4), an entire session vanished without a trace (§5), two rules
are declared enforced while being unfireable (§5), and the one automated check policing
*this* session is structurally blind in this harness (§6 meta-4). The adoption baseline and
the 404 links are **not** in that list — the first is the correct pre-launch reading, the
second is a decided and sequenced state.

**The sharpest line:** the north-star's distribution leg has **no measurement at all** —
not a bad number, an absent one. S40 read it for the first time. S35's verdict was *"ship it
or stop polishing the storefront"*; S39 shipped it; the product is now on npm with a live
docs site. What has not happened is a **launch** — and the record never said so was missing.

## Ranked remediations — for S41, NOT this session

1. **Scope the code cleanup that gates going public.** The founder's sequencing is
   *clean up the code → make it good → go public*, and that cleanup is a named prerequisite
   with **no roadmap item, no scope, no owner** (§2). It is the true highest-leverage item,
   and scoping it is the prerequisite for scoping anything else. Public then fixes the
   README clone line, both npm links **and** provenance in one move — a real distribution win
   for an MIT package.
2. **Build the proof pack on the measured zero, as `t0`.** The 304 downloads on
   `@ifelse.codes/core` all land in a 5-day window beginning on the publish day (#12) and
   `@ifelse.codes/chitra` has **zero** indexed downloads (#9). Since nothing has been
   marketed, the pack's first job is to *establish* the baseline explicitly, so the first
   real number is comparable — and to never cite the 304 as traction, because they are the
   founder's own CI.
3. **Reopen KNOWLEDGE.md row 4 in the ledger** (§4). The line was corrected in S36 and
   drifted back. Add a guard that asserts `main`'s tip against `origin/main` instead of
   letting prose copy it — the same shape as `ai-docs-quote-real-score`.
4. **Disposition S16** (§5). Backfill its records, or record `tech-lead: skipped — <reason>`
   the way the crew gate offers. It is the only session invisible to every artifact, and
   `check_session_coverage`'s S17 floor means no gate will ever surface it.
5. **Fix or drop the `required-crew` gate** (#37). Second waiver. Either add the tech-lead
   step to `.ai/AGENTS.md`'s Session Loop — making the constitution match the machinery —
   or drop the gate. Today the two disagree on every close.
6. **Put the 5-session GT cadence on the roadmap** (§2). Constitutional, hook-enforced, and
   named in zero of the last four handoffs. ✅ **DONE in S40** — added as `Session 40 (S40)`.
7. **Give the GT artifact an independent pass** (§6 meta-1). S35's #7. ✅ **DONE in S40** —
   `sessions/session-40-review.md`, cold, `ACCEPT-with-conditions`, 41 probes re-run, **0
   fabricated**, all seven conditions fixed in place.
8. **Make the cost gate assert content, not a heading** (§7).
9. **Commit the GT artifact on a `-closeout` branch** — the suffix `CONSTRAINTS.yaml` already
   exempts — instead of round-tripping it through the next code session's commit (§6 meta-2).
   **Upgraded in S40:** this is now also the **precondition for `review-inputs-attested`** to
   work at all, since its hash covers the committed contract (§6 meta-6).
10. **Make `check_ground_truth_no_code` see the working tree.** It diffs `merge-base..HEAD`
    and therefore reports `OK` in exactly the harness that forbids committing (§5, #47–48).
    Add the uncommitted/staged paths — or fail **closed** when the diff range is empty,
    which is the signal that nothing was committed. Today a GT session's one automated
    no-code check is decorative.
11. **Make the closeout satisfiable in a NO-CODE session, or exempt the session type.**
    S40's real closeout is **RED, 13 pass / 3 fail** (§6 meta-4). `required-crew` demands a
    tech-lead dispatch a GT session cannot perform; `review-inputs-attested` needs a
    `Review-Inputs-SHA` whose preimage requires the **contract committed at HEAD** (#51).
    Both are structural, not effort. The sharp form: the *same* no-commit condition makes one
    of this family **fail-closed** and another **fail-open** (#52) — so a reader trusting
    "the gates passed" would have trusted the wrong one.

## Recommended next session (S41)

**"Scope the cleanup that gates the public launch."** The sequencing is now settled —
clean up the code, make it good, then go public — and everything downstream (the 404 links,
npm provenance, the README clone line, and the credibility of any GTM claim) unblocks from
it. So S41's job is to **scope that cleanup and make it real work**, not to relitigate the
decision. Fold in the cheap, unambiguous items alongside: the `KNOWLEDGE.md` `main` range (3),
S16's disposition (4), the `required-crew` gate (5), and the GT cadence on the board (6).

The GTM proof pack (2) becomes materially more valuable *after* that cleanup and the public
flip — it is the first measurement, and a measurement taken before the product is where it
needs to be measures the wrong thing. The **`0.4.0`-through-CI** run stays the cheapest
available close on S39's open trusted-publisher claim, and still needs no code change.

**Fidelity note:** remediations 1 and 2 were re-ranked mid-session after the founder supplied
two facts the audit did not have — that nothing has been marketed, and that the repo goes
public after a cleanup. Both were re-read against evidence, not accepted on authority: the
adoption numbers are unchanged and still self-inflicted (§1), and the repo's privacy is still
real (§1). What changed is the *weight* the audit assigned them. The 304-download and 404
facts stay in the record as measured; only the verdict they carried was wrong. **The
independent reviewer reached the same ruling unprompted**, and recorded the test that would
have flipped it — "a correction that deleted a finding or bought a green" — which neither
correction did.

## Carried forward

- S39's review note stands and this session found three more of its kind:
  `ai-docs-quote-real-score` exists because a number a human maintains goes stale. §4's
  `main` range is the same disease in prose, with no guard.
- S35's stale-`v0.1.0`-tag risk is **closed** (#3, #4) — the highest-risk item of that
  audit is the one thing five sessions later is verifiably better.
- `pnpm run lint` remains unrunnable (eslint not installed) — pre-existing, unclaimed.

---
*No source files were modified and no commits or PRs were made in this session. This artifact,
`prompts/40-task-ground-truth.md`, `sessions/session-40-review.md`, and the `.ai/` bookkeeping
(including two real fixes to `.ai/KNOWLEDGE.md`) are left uncommitted on
`session-40-ground-truth` per the contract's guardrails. The closeout carries two founder
waivers (`VAJRA_CLOSEOUT_WAIVER=40`) and is otherwise RED — see "Session outcome" above and
§6 meta-4. To be folded into S41.*
