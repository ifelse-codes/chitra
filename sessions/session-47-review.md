# Session 47 — independent fidelity review (cold, first-pass N1)

## Method controls

**Inputs fed (cold only).**
1. Contract: `prompts/47-task-gate-truth.md` (read in full, R1–R9 + assumptions + out-of-scope + closeout).
2. Delivery diff: merge-base `a218ac5`..HEAD `c1acd0e` (9 commits, all `S47:`-prefixed).
   The prescribed multi-exclude diff (`-- ':(exclude)sessions' ...` with no positive
   pathspec) returns **empty on this git** — multiple bare `:(exclude)` with no
   positive pattern select nothing. Worked around with the exact same exclusion
   *intent* via positive pathspecs over every non-excluded delivery file:
   `.ai/CONSTRAINTS.yaml`, `.ai/GT-REMEDIATIONS.md`, `.ai/CONTINUATION-PROMPT.md`,
   `scripts/verify-closeout.sh`, `scripts/verify-session-47.sh`,
   `scripts/demo-session-47.sh`, `sessions/session-40-summary.md`,
   `sessions/session-47-support-ticket.md`. Every hunk studied; both gate scripts
   read in full (924 and 314 lines).

**Probes run (all read-only, with results).**
- `bash -n` on all three scripts: all OK.
- `bash scripts/verify-session-47.sh` → exit 0, 14/14 PASS.
- `bash scripts/demo-session-47.sh` → exit 0, 9/9 SHIPPED (probed).
- `bash scripts/verify-closeout.sh` (full) → exit 1, RED with exactly 2 FAILs:
  `fidelity-review-accept` (this review not yet committed — circular, resolves on commit)
  and `required-crew` (no `vajra` binary on PATH, no founder waiver — D-47-2, pending).
  All 15 other checks PASS, including the three hardened gates.
- Blindness repro: merge-subject newest = S37; union newest = S46. Confirmed.
- Delivery cap recompute over `a218ac5..HEAD`: 9 commits, file counts 1,2,2,2,3,3,2,1,1 → max 3. Confirmed.
- History-cap quote check: last-60-main over-cap recomputes to **20**, not the quoted 17 (window moved with S46; S45-dated evidence, still directionally true — see sweep).
- R2 offender probe: `touch packages/core/src/__s47_probe__.ts` (untracked) +
  `verify-closeout.sh --gt-no-code-only 50` → FAIL with log
  `BLOCK: GT artifact sessions/session-50-ground-truth.md missing or empty` —
  the artifact clause fires first; the probe file is invisible to `git diff` by construction.
- R8 live re-derivation: repo `{"private":false,...}` public; `git ls-remote origin
  'refs/pull/*/head' | wc -l` → 70 (ticket says 70); `gh api -X DELETE
  .../git/refs/pull/67/head` → `422 {"message":"refs/pull/* is read-only."...}`. All match.
- Live tag SHAs: `v0.4.0→fd45ec6, v0.3.0→f17b204, v0.2.0→7664fed` — match KNOWLEDGE L122.
- Smuggling probes: `git diff --name-only a218ac5 HEAD -- .ai/AGENTS.md` → empty;
  `-- packages/ pnpm-lock.yaml` → empty; no `S44.*ACCEPT` claim in any delivery file
  (only the contract's own prohibition line); `.ai/SESSION` = `47`.
- Surgical count/line greps (no full reads) on STATE/ROADMAP/BOOT/TASK/KNOWLEDGE for:
  REJECT, `PR #66`, pass-8, COMPLETE lines, `% 5` derivations, `1b6c17d` absence is
  covered by the passing session gate itself.
- `git log --diff-filter=A --format=%H -- sessions/session-47-review.md` → empty:
  **N1 first-pass** (review uncommitted at review time; no Pass-1 hash applies).

**Refused (contamination control).** Did not read: `sessions/session-47-summary.md`,
`.ai/STATE.md`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md`, `.ai/ROADMAP.md`,
`.ai/CONTINUATION-PROMPT.md` in full. No commits, no pushes, no edits outside this file.
Gate-artifact writes under `.ai/verify/` are untracked and outside the attestation preimage.

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| R1 — coverage sees squash merges | SHIPPED | `scripts/verify-closeout.sh:743-773`: union of merge-subjects + `S[0-9]{2}:` squash subjects, empty-population BLOCK, `seen==0` BLOCK, newest belief logged. Blindness reprobed: merge-only newest S37 vs union S46. `sessions/session-40-summary.md` backfilled (42 lines, committed `761818a`). Old body green / new body red-on-pre-backfill holds by code-read (absent summary → MISSING → FAIL). |
| R2 — no-code fails closed on empty range | PARTIAL | Fail-closed code is real: GT-artifact non-empty required (`verify-closeout.sh:793-799`), unresolvable/empty range BLOCKs (`:800-808`), offender grep present (`:809-818`); N/A path exits 0 for N=47 (probed). But the "offender path exercised" proof is theater: the planted probe is an *untracked* file invisible to `git diff base HEAD`, and the N=50 red comes from the artifact-missing clause that fires two branches earlier (log quoted above). A regression deleting the offender grep keeps this proof green. Demo `p_r2` does not plant at all. See Fakest green. |
| R3 — cost tracking is a measurement | PARTIAL | Heading-only genuinely dies: length <200 BLOCK + decision/commit-word + derivation-word predicates (`verify-closeout.sh:125-143`); live section passes (session gate `cost-tracking-needs-measurement` PASS). But the predicate is word-presence (`decision`, `commit\|requirement`, `deriv\|measur\|per commit\|git show`), not derived numbers — a lying block with the magic words passes, and the S44 omission class (true numbers, missing facts) is caught only by R4's file-wide greps, not this gate. The heading-only *fixture* is asserted short but never executed through the gate. |
| R4 — S44 REJECT disclosed, never COMPLETE | SHIPPED | Session gate `s44-verdict-disclosed` PASS: canonical `**Verdict:** REJECT` exactly once in `sessions/session-44-review.md`; REJECT + `PR #66` + never/not-COMPLETE guard in STATE (L96: 8 passes + PR #66 + not COMPLETE, probed); REJECT + PR #66 + never COMPLETE in ROADMAP L117 (probed). Repo-wide probe: no file claims S44 ACCEPT. Ledger S45 row 3 → DONE (`.ai/GT-REMEDIATIONS.md`). Residual COMPLETE mentions are negations or historical recounts of the defect, never current records. Gate omits a pass-8 assertion, but the fact is present (3 hits probed) — gate-coverage nit, not a record gap. |
| R5 — 3-file cap is honest | SHIPPED | Wording corrected where owned: `.ai/CONSTRAINTS.yaml:9-12` scopes the cap to branch/delivery, names squash-merge bypass, discloses (not edits) the vajra-owned AGENTS.md line. Session gate `commit-cap-respected` (`verify-session-47.sh:162-174`) derives per-commit `numstat` counts over `merge-base..HEAD` and fails on any 4-file commit; independently recomputed: 9 commits, max 3. Local enforcement is real: `.githooks/pre-commit:42-43` BLOCKs `staged > 3`. AGENTS.md untouched in delivery diff. Minor: the quoted `17/60` recomputes to 20 today (window moved with S46's squash merges) — stale-dated evidence quote, load-bearing nowhere. |
| R6 — stale facts guarded, not just corrected | PARTIAL | Corrected facts verified true live: no `1b6c17d` in the six live files (gate PASS), pill at `App.tsx` L927 (KNOWLEDGE L239, readable file), tag SHAs match live (`fd45ec6/f17b204/7664fed`), range S00–S46 (KNOWLEDGE L109), deriving commands cited beside facts (KNOWLEDGE L28/L115/L121). But the contract demands the gate assert "test count, pill line, tag SHAs and main range": `stale-facts-guarded` (`verify-session-47.sh:183-199`) asserts 453 displays + tests-untouched + v0.4.0 existence + range string, and does **not** assert the pill-line value, tag-SHA values, or citation presence. Retyping a tag SHA or pill line stays green. |
| R7 — crew row re-pointed, waiver-or-green honest | SHIPPED | ROADMAP L56 (probed): open crew work re-pointed to S47 ("this is S47 work, not S44's") with done-condition "waiver-or-green recorded honestly at closeout, and no file claims the gate satisfied when it was waived". Session gate `roadmap-crew-repointed` PASS. No open work is assigned to completed S44; remaining S44 mentions are historical recounts. Closeout has claimed nothing yet (RED pre-review), so no satisfied-when-waived claim exists to police. |
| R8 — P1 residual ticket rides along | SHIPPED | `sessions/session-47-support-ticket.md` (41 lines, read — allowed file): DELETE attempted with 422 recorded, all three evidence commands present, GitHub Support request text + done-condition, status honestly "prepared, filing needs a human". Every fact re-derived live: public visibility, 70 PR heads, DELETE→422. STATE records owed-honestly ("ticket text ready, filing needs a human", probed L52). Attempt-authorship is taken on trust, but the evidence is real and current — the requirement's purpose (disclosed, not closed) is fulfilled. |
| R9 — GT cadence named where agents must read | SHIPPED | Owned files carry the cadence *with derivation*, not bare mentions: BOOT L4 (`47 % 5 == 2`) + L14 (`N % 5` note) + L44 (S50 named); TASK L9 + L28; ROADMAP L157 + L166 (S50 `50 % 5 == 0`, scheduling bar); contract itself. Session gate `cadence-named` PASS; AGENTS.md untouched in delivery diff (smuggling half verified). Second half (patch proposal recorded in the session summary) is unverifiable under contamination refusal — noted, not penalized. |
| C1 — session gate + demo exist and run green | SHIPPED | `scripts/verify-session-47.sh` (14 checks, scope default full) exit 0; `scripts/demo-session-47.sh` (probed rows, `ok`-gated table per the S46 fix) exit 0. Both committed (`7b01d37`). |
| C2 — session summary exists | PRESENT-UNREAD | `sessions/session-47-summary.md` present as untracked file; content unread per refusal. Existence only. |
| C4 — support-ticket artifact | SHIPPED | Covered by R8 row above. |
| C5 — `.ai/` synced, SESSION=47 | SHIPPED | `.ai/SESSION` = `47` (probed); closeout `session-boot-current`, `task-ref-current`, `roadmap-references-N` all PASS on the live tree. Remaining sync-file contents unread per refusal. |
| C6 — `verify-closeout.sh` exit 0 | PENDING | Currently RED (15/2): `fidelity-review-accept` FAIL = this review uncommitted (resolves on commit); `required-crew` FAIL = no `vajra` binary, no founder waiver (D-47-2 sixth waiver, founder decision). Both expected pre-review; neither reflects the delivery. |
| O1 — no new product surface | HELD | Delivery file list contains no product, GTM, or MCP surface; `packages/` + lockfile untouched in diff. |
| O2 — no GTM proof pack beyond `t0` | HELD | Same file-list evidence; F6 reading untouched. |
| O3 — no MCP server | HELD | Same file-list evidence; still founder-DEFERRED. |
| O4 — vajra-owned AGENTS.md body unedited | HELD | `git diff --name-only a218ac5 HEAD -- .ai/AGENTS.md` empty; R5/R9 halves disclosed in owned files only. |

## Count

R1–R9: **6 SHIPPED · 3 PARTIAL · 0 NOT-BUILT**. Closeout-grade: C1 SHIPPED, C4 SHIPPED, C5 SHIPPED, C2 present-unread, C6 pending (post-commit + founder waiver). Out-of-scope O1–O4 all held. Assumptions: contract carries exactly 2 (`AS-1`, `AS-2`), out-of-scope named (session-gate `contract-at-head` PASS).

## Fakest green

**R2's "planted probe under N=50 red".** The session-gate log line reads as an
offender-path execution proof, but the exit comes from the GT-artifact-missing
clause two branches before any diff is evaluated, and the probe file is untracked
hence invisible to the very `git diff base HEAD` the offender branch scans. The
fail-closed *code* is genuine (artifact + empty-range + offender grep all read and
real); the *exercise* is honesty theater — deleting the offender grep would not
flip this test. The gate it guards can still fail for its claimed reasons, which
is why R2 is PARTIAL rather than NOT-BUILT, and why this review still accepts:
no vacuous green survives in the shipped gates, but this demonstration must not
be cited as offender-path coverage. (Runners-up, all disclosed above: R3's
never-executed fixture + word-proxy predicate; R6's unasserted pill line and tag
SHAs; the suite/typecheck byte-identity fallback, disclosed and fail-closed.)

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 5d7590b611893dd26ea535f5bf78e2f97866b752991a107d436a3d0a543a6640
