# chitra — Continuation Handoff (after S46)

**Resume in a NEW chat (S47).** `.ai/SESSION` = 46; **`@ifelse.codes/chitra@0.4.0` is LIVE on npm
with provenance** (`latest`); the **repo is public** (`gh api repos/ifelse-codes/chitra --jq .private`
→ `false`). `main` = the S46 merge **`86bc909`** (**derive with `git rev-parse main`** — every sha in
this file is a citation, not a fact; re-derive before trusting it). **S46 was the public flip**: P1,
P2, F1–F6 all discharged, contract never amended.

> **The one thing to carry forward:** the flip is done, so the repo's claims are now checkable by a
> stranger — and one door is still not ours to close. **`refs/pull/*` is read-only on GitHub and 56
> of 67 PR heads still expose the pre-rewrite home path**; P1's done-condition (reachable from `HEAD`)
> is met and disclosed, but only a **GitHub support ticket** deletes those refs. That ticket plus
> `sessions/session-45-ground-truth.md` § *Findings, ranked* is the S47 story.

## Where we are

Detail: `sessions/session-46-flip.md` (decisions + before/after evidence) +
`sessions/session-46-summary.md` (fidelity map) + `sessions/session-46-review.md` (cold pass) +
`.ai/STATE.md`.

| S46 delivered | State |
|---|---|
| **P1** history rewrite | **shipped** — `git filter-repo` 2.47.0: **1001 → 0** (commit, file) pairs over **444** commits; tree `8167462…`, count and **367** tracked files unchanged; one force-push with `--no-verify` (pre-push hook blocks *any* `main` push), disclosed |
| P1 residual | **owed** — `refs/pull/*` read-only (422), **56 of 67** PR heads still carry it → **support ticket** |
| **P2** private reporting | **shipped** — `{"enabled":true}`; unsatisfiable before F1 (public-repo-only endpoint, proved against `octocat/Hello-World` with `admin: true`) → **D-REORDER** |
| **F1/F2** | **shipped** — `true`→`false`, `404`→`200`, anonymous clone works; both `before` rows recorded |
| **F3** | **shipped** — `homepage` + `repository.url` **unedited** (only `version` differs from `main`); the URL simply resolves now |
| **F4** | **shipped** — every `REPO-SETTINGS` row re-probed; `SECURITY.md` / `CODE_OF_CONDUCT.md` stopped calling an established route a pre-flip task |
| **F5** | **shipped** — `0.4.0` tagged on merged `main`, CI run `37217761468` published it via Trusted Publishing; **provenance on `0.4.0`, none on `0.3.0`**, **zero workflow edits** |
| **F6** | **shipped** — `t0` = **119 lifetime downloads, none organic**, recorded in `.ai/STATE.md`, derived from the downloads API; the two `.ai/` files that still called the baseline zero were corrected |
| a live gate | **fixed, not left red** — S44's `home-path-scrubbed` demanded a commit that still carries the path, which P1 made permanently unsatisfiable; proof moved to runtime-assembled samples + an inverted history walk |

## S47 — the candidate

`prompts/47-task-*.md` does not exist yet — write it at plan time. The spec is
`sessions/session-45-ground-truth.md` § *Findings, ranked*, chiefly: **`check_session_coverage` is
blind for S38–S44** (squash-merged subjects match nothing; newest belief **S37**; it already missed
`sessions/session-40-summary.md` being absent), **the GT cadence is absent from `AGENTS.md`**
(**vajra-owned** — disclose it, do not smuggle it), **S44's `REJECT` recorded as COMPLETE**, the
**3-file cap unenforced by 17 of 60**, and the stale-fact class. Plus the **support ticket** above.

Alternatives: the **GTM proof pack** (F6 recorded `t0` only — benchmarks, channels, first organic
signal), or **new product surface** (none since `c72cc14`, S09).

## Three process facts worth inheriting

1. **`==>` is the replacement separator in `git filter-repo`, not `=>`.** With `=>` the whole line
   becomes one literal, matches nothing, and the rewrite silently changes nothing but every SHA —
   measured, not guessed.
2. **A counterfactual that requires history to keep a redacted value cannot survive the redaction.**
   S44's gate demanded "some commit still matches"; after P1 the correct state fails it forever.
   Prove a pattern against an **assembled** sample instead — and assemble it, because a literal
   sample inside the gate's own source makes the tree scan flag the gate.
3. **Vajra cannot verify helper provenance outside Claude Code.** `.ai/handoffs/session-46-tech-lead.md`
   validates structurally but reads `unverifiable … gitBranch "session-18-heatmap-lock"`; the crew
   gate's own message prescribes the path: `VAJRA_CLOSEOUT_WAIVER=<NN>` with a reason, at close.
