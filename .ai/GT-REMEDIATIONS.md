# Ground-Truth Remediation Ledger

> The teeth the S35 audit found missing: ground-truth findings used to be written and
> forgotten (S05's remediation debt sat open 30 sessions). Every ground-truth session's
> remediations are copied here and **must be dispositioned `DONE`, `WAIVED`, or
> `DEFERRED`**; a `DEFERRED` row is founder-deferred and its Evidence cell **must
> carry a `reason` and an `expiry`** (a `YYYY-MM-DD` date or the word "expiry") —
> otherwise the next closeout blocks. `scripts/verify-closeout.sh#check_gt_remediations`
> fails on any other status. One row per remediation, newest ground-truth first.

## S35 (`sessions/session-35-ground-truth.md`) → folded into S36

> **Superseded in part by S39 (2026-09-29):** the shippable package is now
> `@ifelse.codes/chitra@0.3.0` (`latest`). The rows below are a **ledger of what S35 found**,
> so they keep the names that were true at the time — row 2 in particular records the S37
> publish of `@ifelse.codes/core@0.1.0` and is not stale. Do not read this file for the
> current package name; read `.ai/STATE.md` or the "What chitra is" section of `KNOWLEDGE.md`.
> `@ifelse.codes/core` is **not** deprecated (founder decision — no public release, no
> external user to redirect).

| # | Finding (S35) | Status | Evidence |
|---|---|---|---|
| 1 | Stale local `v0.1.0` tag on the 2026-07-29 commit; push would publish July code | DONE | stale tag deleted (`git tag -d v0.1.0`); `release.yml` made idempotent. Re-cut of `v0.1.0` travels with the publish (item 2) |
| 2 | `@ifelse.codes/core` not on npm (E404); distribution stalled | DONE | S37 published `@ifelse.codes/core@0.1.0`; `npm view @ifelse.codes/core version` → `0.1.0`, consumer install verified (38 files / 94.2 kB). Two-layer root cause: (a) the token needed the web/passkey 2FA flow — npm's `otplease` only runs it on a real TTY (fixed with tmux); (b) `@chitra` was an npm org the account does not own, so the package was renamed to the founder's `@ifelse.codes` scope |
| 3 | Docs-hero pills stale (`v0.1.0 — stable`, `134`) | DONE | `App.tsx` → `v0.1.0` / `452`; site redeployed and verified in the live bundle |
| 4 | KNOWLEDGE.md false facts (142/163/442, 7 files, dist, CI, main range) | DONE | `.ai/KNOWLEDGE.md` corrected; one canonical count (452) |
| 5 | STATE/SESSION-BOOT/TASK a merge behind (S34 PR #40) | DONE | `.ai/` synced to S36 |
| 6 | S05 closeout-integrity debt (S17/S32 artifact-less) + no CI gate | DONE | S17/S32 backfilled; `verify-closeout.sh#check_session_coverage` added |
| 7 | GT findings have no closure mechanism | DONE | this ledger + `check_gt_remediations` gate |
| 8 | "No code in Ground Truth" declared hook-enforced but no hook | DONE | `.ai/hooks/hook-ground-truth-guard.sh` + `check_ground_truth_no_code` |
| 9 | Cost tracking has no number | DONE | `STATE.md#Cost Tracking` carries a measured line |
| 10 | Vision (AI-first) demands an MCP item the roadmap lacks | DONE | MCP-server item added to `.ai/ROADMAP.md` |
| 11 | README `/ai-data` link points at an undeployed page | DONE | site redeployed with the S33 AI-data page live (verified HTTP 200) |

## S40 (`sessions/session-40-ground-truth.md`) → for S41

> Every S40 row is **DEFERRED to S41**, which is the founder's boot decision: the three
> S39 code candidates slide to S41 and S40 ran as the mandatory 5-session audit
> (`40 % 5 == 0`). Each row carries a reason and an expiry, per the S37 hardening — a
> deferral may not rot silently. **Reorder by leverage inside S41; the order here is the
> audit's ranking, not a schedule.**
>
> **Rows 1 and 2 were re-ranked mid-session** after the founder supplied two facts the audit
> lacked: that nothing has been marketed, and that the repo goes public after a code cleanup.
> The evidence was re-checked, not overwritten — the numbers stand, the 404s stand, and only
> the *verdict* they carried was wrong. See the fidelity note in the audit.

| # | Finding (S40) | Status | Evidence |
|---|---|---|---|
| 1 | **The adoption baseline is zero — and it is the correct pre-launch reading** (founder: nothing has been released-and-marketed). The real finding is that **the number had never been read before S40**: no trend, no comparison. The 304 downloads on `@ifelse.codes/core` are all inside a 5-day window starting on the publish day and are CI/founder shaped, so they must never be cited as traction; `@ifelse.codes/chitra` is unindexed by the downloads API entirely. The GTM proof pack must record this as its explicit `t0`. | DEFERRED | reason: needs a measurement + a claim, which is code work — illegal in a NO-CODE session. expiry 2026-10-31. `downloads/range/2026-09-15:2026-09-28` → 0×9 then 75/17/12/181/19; `api.npmjs.org/downloads/…/@ifelse.codes/chitra` → not found (registry itself 200) |
| 2 | **The repo goes public after a code cleanup** (founder decision). The 404s today — `README.md:75` `git clone`, npm `repository.url`, npm `homepage` — are a **known, sequenced, temporary** state, not an open decision. **The finding is the prerequisite, not the decision:** the "clean up the code and make it good" step that gates the public flip has **no roadmap item, no scope, no owner**. Public then resolves all three links *and* adds npm provenance. | DEFERRED | reason: roadmap/scope authoring, not a NO-CODE edit. expiry 2026-10-31. `gh repo view` `isPrivate:true`; anonymous `api.github.com` / `raw.githubusercontent.com` / `github.com` → all 404 |
| 3 | **`KNOWLEDGE.md` L97–98 served three falsehoods** — "main hosts S00–S37 (PR #43 `fd8a96e`)" and "v0.1.0 is on main HEAD". This is S35 row 4's exact class, closed in S36 and drifted back, with **no guard**. | DONE | Fixed **in S40, not deferred** — the cold review caught that the first draft deferred this on a *false* legality premise ("illegal in NO-CODE"). It is markdown in `.ai/`, which `hook-ground-truth-guard.sh:56` explicitly allows and which the contract's own output #3 required. L97 now reads S00–S39 / PR #59 / `ba6cf6f` and carries an instruction not to copy the range; L214's pill now reads `v0.3.0 · npm` with the S39 guard named. **Still owed to S41:** a *guard* — assert `main`'s tip against `origin/main` rather than letting prose carry it (same shape as `ai-docs-quote-real-score`) |
| 4 | **S16 vanished and no gate can see it.** S16 has no prompt/verify/demo/summary/review; its only commit is a parked WIP (`74b3c17`) and nothing landed on `main`. It is not grandfathered (only S04/S06 are), not in the S35 ledger, and sits below `check_session_coverage`'s S17 floor. | DEFERRED | reason: backfilling session records is code/commit work, illegal in NO-CODE. expiry 2026-10-31. `git log --all --grep=S16` → 1 parked commit; `git log main` → 0 S16 commits |
| 5 | **The `required-crew` gate is still structurally wrong** — and S40 is the **third** failure, **unwaived**. Waived S38 and S39; at S40 it read `verdict: NOT READY` with zero `WAIVED` lines. It demands a tech-lead handoff that `AGENTS.md`'s 9-step Session Loop never asks for, and a **ground-truth session cannot dispatch one at all** — so it is unsatisfiable by construction here. | DEFERRED | reason: `verify-closeout.sh` change is code, illegal in NO-CODE. expiry 2026-10-31. `grep -c WAIVED .ai/verify/closeout/latest/required-crew.log` → **0**. S40's real closeout is therefore **RED** (13 pass / 3 fail) and is disclosed as such in the audit |
| 6 | **The 5-session GT cadence is on no board.** Constitutional, hook-enforced, and named in zero of the last four handoffs — which is how S40 came to be a surprise. | DONE | Added to `.ai/ROADMAP.md` as `Session 40 (S40)` with the cadence stated in the line itself, so the next handoff reads it. (The first draft deferred this while conceding in the same cell that the edit *was* permitted in NO-CODE — the cold review caught the self-contradiction. Fixed in place, not deferred.) `verify-closeout.sh#roadmap-references-N` also now finds `Session 40` |
| 7 | **The GT artifact was self-certified and not durable.** S35's meta-remediation: no independent pass on the audit itself, and the file round-tripped through the *next* code session's commit (S35's arrived via S36's `c2cbcec`) instead of the `-closeout` branch suffix `CONSTRAINTS.yaml` already exempts. | DONE | **The independent pass is DONE** — `sessions/session-40-review.md`: cold, `ACCEPT-with-conditions`, 41 probes independently re-run, **38 reproduce byte-for-byte, 0 fabricated**, 7 conditions all fixed in place. It judged the two founder corrections **legitimate re-reads, not capitulation** (neither deleted a finding; one *added* a finding; overall stayed 🔴). **Still owed:** commit the artifact on a `-closeout` branch — S40 proved that is also the **precondition for `review-inputs-attested`**, whose SHA covers the committed contract. reason: the second half needs a commit, which a NO-CODE session cannot make. expiry 2026-10-31 |
| 8 | **The cost gate greps a heading.** `cost-tracking-present.log` passes on the string "Cost Tracking"; any text passes, including a lie. The prose is honest ("unmeasured"), the check verifies nothing. | DEFERRED | reason: `verify-closeout.sh` change is code, illegal in NO-CODE. expiry 2026-10-31. Unchanged from S35 §7 probe #24 — same line |
| 9 | **Two "Hook-enforced" / `true` declarations are false.** "Max 3 files per atomic commit" holds on the branch but 8 of the last 60 `main` commits exceed it — all GitHub squash merges, which never run a local hook. `one_session_per_chat` is wired but unfireable: it blocks only on a same-chat `N→N+1` boundary, and `.ai/.session-owner` is untracked and pinned at `12`. | DEFERRED | reason: `.ai/AGENTS.md` is vajra-owned; correcting the wording is a vajra-side change, and the guard redesign is code. expiry 2026-10-31 |
| 10 | **The GT no-code backstop is blind in the harness it exists for.** `check_ground_truth_no_code` diffs `merge-base..HEAD`; a GT session commits nothing, so the range is empty and the check passes **vacuously**. Counterfactually proved: a planted `packages/core/src/*.ts` left it reading `OK: no code changes` / `INTEGRITY: PASS`. S40's real NO-CODE evidence is `git status` (6 `.ai/*` files + 2 new `.md`, zero tracked source), **not** the gate. | DEFERRED | reason: `verify-closeout.sh` change is code, illegal in NO-CODE. expiry 2026-10-31. `git merge-base main HEAD` == `HEAD` == `ba6cf6f`; planted-probe run still `INTEGRITY: PASS` |
| 11 | **The closeout is unsatisfiable in a NO-CODE session — and the two halves fail in *opposite* directions.** S40's real closeout: **RED, 13 pass / 3 fail**. `required-crew` needs a tech-lead a GT session cannot dispatch; `review-inputs-attested` needs a `Review-Inputs-SHA` whose preimage requires the **contract committed at HEAD**, which a no-commit session never has (`git cat-file -e HEAD:prompts/40-…` → *exists on disk, but not in HEAD*). The sharp form: the **same** no-commit condition makes one of this gate family **fail-closed** (attestation) and another **fail-open** (no-code, above) — so "the gates passed" would have pointed a reader at the wrong one. | DEFERRED | reason: `verify-closeout.sh` change is code, illegal in NO-CODE. expiry 2026-10-31. `bash scripts/verify-closeout.sh 40` → RED (13/3); `bash scripts/verify-closeout.sh --inputs-sha 40` → *canonical input hash uncomputable* |

## Template for the next ground truth

| # | Finding | Status | Evidence |
|---|---|---|---|
| 0 | _(none yet)_ | DONE | — |
