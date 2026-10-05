# Session 47 — summary · gates that can fail

**Contract:** `prompts/47-task-gate-truth.md` — requirements **R1–R9**, spec
`sessions/session-45-ground-truth.md` § *Findings, ranked*.
**Branch:** `session-47-gate-truth` (from `main` `a218ac5`).
**Story:** every governance check derives the population it governs instead of
curating it in prose — no vacuous green survives, and every stale fact ships with
the command that re-derives it.

---

## What shipped

| # | Requirement | Status | Evidence |
|---|---|---|---|
| **R1** | coverage sees squash merges; S40 backfilled | **SHIPPED** | `check_session_coverage` population = merge subjects UNION squash subjects, newest belief recorded (**S46**), empty refuses; merge-only newest measured **S37** beside it (the blindness); `sessions/session-40-summary.md` backfilled (disclosed, from S40's own artifacts); `coverage-new-sees-squash` green, zero MISSING |
| **R2** | no-code fails closed; offender exercised | **SHIPPED** | GT artifact required non-empty; empty/unresolvable range BLOCKS (was N/A/OK); `gt-no-code-fails-closed` green: N=47 N/A exit 0, planted `packages/core/src/__s47_probe__.ts` under synthetic GT N=50 red |
| **R3** | cost tracking is a measurement | **SHIPPED** | predicate: decisions + commit/requirement counts + derivation words over 200 chars; `cost-tracking-needs-measurement` green on live STATE, heading-only fixture correctly short |
| **R4** | S44 REJECT disclosed | **SHIPPED** | review carries one `**Verdict:** REJECT` (L37, 8 passes); STATE + ROADMAP record REJECT + PR #66, never COMPLETE; `s44-verdict-disclosed` green |
| **R5** | delivery cap derived, history scoped | **SHIPPED** | `commit_cap_respected` derives per-commit counts over `merge-base..HEAD` (all ≤ 3); CONSTRAINTS comment corrected where owned; AGENTS line disclosed, not edited |
| **R6** | stale facts fixed + guarded | **SHIPPED** | main S00–S46/PR #70, version 0.4.0/latest, post-rewrite tag SHAs re-derived with commands beside each; `stale-facts-guarded` scans the six live files + display-site agreement (scan scoped — frozen history legitimately quotes old SHAs) |
| **R7** | crew row re-pointed, waiver honest | **SHIPPED** | ROADMAP row owns S47 with done-condition; `roadmap-crew-repointed` green; closeout records waiver-or-green, never satisfied-when-waived |
| **R8** | P1 ticket rides along | **SHIPPED (prepared, not filed)** | `sessions/session-47-support-ticket.md`: live 422 re-derived, 70 heads, request text, filing path; filing needs a human in GitHub Support — status DISCLOSED |
| **R9** | cadence named where owned | **SHIPPED (half disclosed)** | BOOT + TASK + ROADMAP + contract carry `N % 5` with derivation; S50 named next GT; `cadence-named` green incl. AGENTS.md untouched; vajra half proposed below, never smuggled |
| — | ledger S45 rows 1–6 DONE | **SHIPPED** | each with S47 evidence, pipe-free; `ledger-dispositioned` + closeout integrity green |
| — | step-5 scripts | **SHIPPED** | `scripts/verify-session-47.sh` (14 checks, scope default full) + `scripts/demo-session-47.sh` (9 probed rows, SHIPPED-only-on-`ok`) |

**Assumptions (2, both held):** AS-1 ranked list is the spec (every fix names its
counterfactual); AS-2 one story (ticket rides along as S46-owed, not gate work).

## Vajra-side patch proposal (disclosed, NOT applied — governed body)

`git diff main...HEAD -- .ai/AGENTS.md` is empty. Two lines need a home only Vajra
can give:

1. Hard Rules needs the cadence: `| Ground truth every 5th session | N % 5 == 0 — CODE sessions never land on it (see CONSTRAINTS.yaml) |`
2. The cap line needs scoping: `| Max 3 files per atomic commit | Hook-enforced on branches + session-gate-derived per delivery commit; squash merges bypass local hooks |`

## Product

- **453/453 stands by byte-identity** (no node/pnpm on this machine — two lookups,
  then disclosed fallback, fail-closed on change): zero `packages/core/src` +
  tests diff in delivery, display sites agree 453, S46 measured green.
- Lockfile untouched. No workflow change.

## Verify

`bash scripts/verify-session-47.sh` → 14/14 green (full scope; recorded run in
`.ai/verify/session-47/latest/summary.txt`). `bash scripts/demo-session-47.sh` →
9/9 SHIPPED, exit 0. Closeout `scripts/verify-closeout.sh` green behind the
standing crew waiver (Vajra unverifiable outside Claude Code — same as S46).

## Weakest evidence (stated, not hidden)

1. Suite/typecheck by byte-identity, not a fresh run (toolchain absent). Bounded:
   any product change disables the fallback and fails closed; the displays + the
   S46 measurement agree.
2. The empty-range discriminator is structural (new BLOCKs where old OK'd) but
   demonstrated by clause-presence + offender-path execution, not a live
   empty-range run on main.

## Cost

- One opencode session; plan approval carrying commit approval + blanket
  execution approval ("all approved"); 2 founder decisions requested at plan
  (D-47-1 S44-REJECT-disclose, D-47-2 crew-waiver-or-green — both executed as
  proposed, no countermand).
- **9** requirements (R1–R9) + **2** assumptions, both held.
- Delivery commits ≤ 3 files each (derived per commit); **0** product tests
  added; **0** lockfile changes; **0** npm secrets; **0** new infrastructure.
- Token/`$` unmeasured (founder's plan).

## 3 next options

1. **S48 — GTM proof pack** (F6 recorded `t0` only; benchmarks, channels, first
   organic signal).
2. **S48 — new product surface** (none since `c72cc14`, S09; the gates no longer
   blame the flip).
3. **File the P1 ticket** (human, 5 minutes, closes the last disclosed residual
   when support confirms GC).
