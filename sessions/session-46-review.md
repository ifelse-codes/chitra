# Session 46 — independent fidelity review (cold, adversarial)

Reviewer: independent subagent (did not build this delivery). **Pass 2.** Reviewed HEAD
`6167ba5eac0255b7ea92a12648916397a2d7ca61` on branch `session-46-public-flip`
(pass 1 reviewed `2d45acc22984268f9fdb0e76b87904ab034741bf`).

## 1. Method controls

**Fed (only these two inputs, both passes):**

1. The contract: `prompts/46-task-public-flip.md` (read in full, 142 lines) — preconditions P1/P2,
   requirements F1–F6, the *Also owed by S46* paragraph, AS-1/AS-2, D-F1/D-F2/commit approval,
   the Closeout list, and the counterfactual demand.
2. The delivery diff: `git diff 8a083c8bcc233c2f957f61f49b3e9853d7ea6fc8 HEAD`
   (merge-base with `main`..HEAD).

**Refused to read** (builder narrative; none opened, none quoted for evidence):
`sessions/session-46-summary.md`, `sessions/session-46-flip.md`, `.ai/STATE.md`,
`.ai/SESSION-BOOT.md`, `.ai/TASK.md`, `.ai/ROADMAP.md`, `.ai/CONTINUATION-PROMPT.md`.
One incidental exposure, disclosed: a *gate log* (`.ai/verify/session-46/20261004T165902Z/p1-history-and-tree-clean.log`)
printed one line of `.ai/STATE.md` while explaining that run's FAIL (a redaction-rules line, not
narrative); I never opened `.ai/STATE.md`. I also executed the delivery's own
`f6_t0_baseline_recorded`, `p_*` demo probes and S44's `home_path_scrubbed` extracted with `awk` —
they grep those files internally and report pass/fail only.

**Probes run in pass 1 (read-only):**

- `git rev-list HEAD` walked **every** reachable commit with the P1 pattern → 0 matching commits;
  `git grep -E '(/|-)Users[-/][a-z]+' HEAD -- .` → no hits; same scan over **all** local refs
  (572 commits across refs) → 0 hits.
- `.git/filter-repo/{commit-map,changed-refs,first-changed-commits,already_ran}` → 571 old→new SHA
  mappings; sampled pre-rewrite SHAs (`000182d4…`, `0095172b…`, …) **GONE** locally.
- `gh api repos/ifelse-codes/chitra/pulls/65 --jq .head.sha` → `abe19fd2…`: **served by GitHub,
  absent locally**; its tree `b4923671…` **equals** `git rev-parse session-44-oss-polish^{tree}` →
  SHAs moved while trees stayed byte-identical. `git ls-remote origin 'refs/pull/*/head'` → 68 heads,
  **67 not in local history**.
- `gh api repos/ifelse-codes/chitra --jq '{private,visibility,has_issues,has_discussions,…}'`,
  `curl -o /dev/null -w '%{http_code}' https://github.com/ifelse-codes/chitra`,
  `gh api …/private-vulnerability-reporting`, plus control `gh api repos/octocat/Hello-World/private-vulnerability-reporting`.
- `npm view @ifelse.codes/chitra [version|homepage|repository.url]`, `…@0.4.0 dist.attestations`,
  `…@0.3.0 dist.attestations`, `dist.signatures`, `time`; `git diff 8a083c8..HEAD -- packages/core/package.json`;
  `git diff 8a083c8..HEAD --name-only -- .github/workflows/`.
- `gh run list`, `gh api …/actions/runs/37217761468`, `gh run view 37217761468 --log`, and the
  pre-flip control `gh run view 37212844249 --log` (v0.3.0).
- `curl api.npmjs.org/downloads/point/2020-01-01:$(date +%F)/@ifelse.codes/chitra` (F6) + the range
  endpoint for the day-by-day shape.
- `git rev-list --count 8a083c8` (444), `git ls-tree -r 8a083c8 | wc -l` (367), `git ls-files | wc -l`,
  `git tag --contains`, `git merge-base --is-ancestor`, `git show --stat` per delivery commit,
  `bash -n scripts/demo-session-46.sh`, `git status`, `git reflog`, APFS birth times of
  `.git/filter-repo` (20:20:46) vs `sessions/session-46-flip.md` (20:20:03).
- Read (code/gates, permitted): `scripts/verify-session-46.sh`, `scripts/demo-session-46.sh`,
  `scripts/verify-session-44.sh` (changed region), `scripts/verify-closeout.sh`,
  `.github/REPO-SETTINGS.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `.github/workflows/{ci,release}.yml`,
  and the builder's **gate logs** under `.ai/verify/session-46/*` and `.ai/verify/closeout/*`
  (artifacts, not narrative).

**Probes run in pass 2 (after the one new commit):**

- `git log --oneline 2d45acc..HEAD` → **exactly one** commit, `6167ba5 S46: demo summary rows are
  probed, not typed — the cold review's fakest green`; `git diff 2d45acc..HEAD --stat` →
  `scripts/demo-session-46.sh | 74 +++++++++++++++++++++++-------` and **nothing else**
  (`git diff 2d45acc..HEAD --stat -- prompts/` → 0 lines; the same for
  `.github/ packages/ SECURITY.md CODE_OF_CONDUCT.md scripts/verify-session-{44,46}.sh` → 0 lines),
  so the contract and every other delivery file are untouched.
- Read the whole new region: `row()` prints `SHIPPED` only when the probe **exits 0 and prints
  exactly `ok`**, otherwise prints `NOT PROVEN — <reason>`, increments `FAILS`, and the script ends
  `exit 1`. Each of the nine `p_*` probes carries at least one explicit failure branch
  (`p_p1` walks every commit and fails on the first hit; `p_p2`/`p_f1`/`p_f4` hit `gh api`;
  `p_f2` curls the repo URL; `p_f3`/`p_f5` diff the manifest/workflows against
  `git merge-base main HEAD`; `p_f6` re-derives downloads and greps `.ai`; `p_cap` recomputes
  per-commit file counts) — no probe can print `ok` unconditionally.
- `bash -n scripts/demo-session-46.sh` → rc 0. **Ran the demo**: `bash scripts/demo-session-46.sh`
  → **EXIT=0**, all nine rows `SHIPPED`, each derived at run time (`after 0 (commit, file) pairs
  across 453 reachable commits`, `→ 0.4.0`, `0.3.0 attestations (empty)`, `119 lifetime downloads`,
  `Test Files 23 passed … Tests 453 passed`, `max ≤ 3` over the 9 delivery commits — the last one
  I also recomputed by hand: `max=3 commits=9`).
- Re-confirmed closeout state (see the Closeout row) and re-ran `--inputs-sha` (see §6).

**Not run:** no gate that writes was executed by me; `.ai/verify/**` was not modified by me; no
push, commit, tag, settings change, or file edit other than this review.

## 2. Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| **P1** — home path out of every commit reachable from HEAD; tool + re-verify order decided pre-push; force-push once, SHAs moved | SHIPPED | Independent walk of every commit from `git rev-list HEAD` → `commits_with_matches=0` (448 commits in pass 1, **453** at pass-2 HEAD, re-derived by the demo run); tree scan clean. Rewrite is real, not narrated: `.git/filter-repo/commit-map` = 571 old→new mappings, sampled old SHAs absent (`GONE 000182d4…`), and PR #65's head `abe19fd2…` is still served by GitHub while **absent locally**, its tree `b4923671…` **identical** to the rewritten local branch tree → byte-identity (D-F1 step 2) independently corroborated. Recorded invariants re-derived by me: `git rev-list --count 8a083c8` = **444** and `git ls-tree -r 8a083c8 \| wc -l` = **367**, matching the recorded before-rows; tip tree `8167462a8f21ca400f051635cd6032e233771dbe` = `8a083c8^{tree}`. Tool `git filter-repo` named in delivery (`scripts/verify-session-44.sh` comment; `demo-session-46.sh` case 3). **Residual disclosed, not papered over**: `demo-session-46.sh` case 3 states refs/pull/* is read-only (422) so old blobs survive — I confirmed 67 of 68 PR heads are foreign + still served. Done-condition scope (reachable from `HEAD`) is honored honestly. |
| **P2** — private vulnerability reporting reads `enabled`, re-derived by the recorded command | SHIPPED | Live `gh api repos/ifelse-codes/chitra/private-vulnerability-reporting` → `{"enabled":true}` (re-observed in the pass-2 demo run). Control probe proves the endpoint's semantics: public `octocat/Hello-World` → `{"enabled":false}` while pre-flip ours returned 404 ⇒ 404 meant "private repo", not "off". Pre-flip `404` recorded beside the command in `.github/REPO-SETTINGS.md` ("Pre-flip that same GET returned **404**…"). Ordering deviation F1→P2 is disclosed in the delivery as `D-REORDER`, not hidden. |
| **F1** — repo public, pre-flip `true` recorded beside it | SHIPPED | Live `gh api repos/ifelse-codes/chitra --jq .private` → `false`, `.visibility` → `public`. Before-row in `.github/REPO-SETTINGS.md`: ``\| `private` \| `false` — pre-flip reading `true` \| `gh api … --jq .private` \|``; gate `live-remote-facts` greps for that exact before-row and fails without it (log: `F1 private=false (before: true)`); the demo's `p_f1` now checks the same before-row in `sessions/session-46-flip.md` and would print `NOT PROVEN` without it. |
| **F2** — README clone URL resolves for an anonymous client (200 post-flip, 404 before) | SHIPPED | Live `curl -w '%{http_code}' https://github.com/ifelse-codes/chitra` → `200` (re-observed pass 2, both in case 5 and in `p_f2`); `README.md:76` `git clone https://github.com/ifelse-codes/chitra.git`. Before-row `404` recorded in `.github/REPO-SETTINGS.md` ("before the flip both readings were `404` / `true`") and as the demo's `delta` line. Gate `anonymous-clone` performs a real `git clone --depth=1` as an anonymous client → `tip 86bc9093…`. |
| **F3** — `homepage` / `repository.url` resolve **and are not edited** | SHIPPED | The suspected fakery does not occur: `git diff 8a083c8..HEAD -- packages/core/package.json` shows **only** `-  "version": "0.3.0"` / `+  "version": "0.4.0"` — `homepage` and `repository.url` bytes are untouched (unchanged again by `6167ba5`, which touches only the demo). Live: local `homepage = https://github.com/ifelse-codes/chitra`, `repository.url = https://github.com/…/chitra.git`; `npm view` published metadata equals them. Post-flip 200 = the live F2 probe; pre-flip 404 recorded in `demo-session-46.sh` case 7. Gate `f3-manifest-fields-unedited` PASS; demo `p_f3` re-derives the same diff. |
| **F4** — `.github/REPO-SETTINGS.md` re-derived post-flip; `private`→`false`; P2 row updated; file's binding rule honored | SHIPPED | I re-probed **every** row myself against the live remote: `private:false`✓, `visibility:public`✓, `has_issues:true`✓, `has_discussions:false`✓, `blank_issues_enabled:false`✓ (`.github/ISSUE_TEMPLATE/config.yml`), reporting `enabled:true`✓ — all six equal the table. The table, `SECURITY.md` and `CODE_OF_CONDUCT.md` all moved in **one commit** (`51d83ab`), and the "What the gate actually checks" paragraph was widened in that same commit as required (clause 3 de-keyed from the reporting row, with an explicit statement of what the offline gate cannot read). Paragraph claims match the actual S44 gate behavior (hedge still enforced unconditionally; `private`/`has_issues` still unread). |
| **F5** — `0.4.0` + npm provenance, CI-unattended, asymmetry vs `0.3.0`, **no workflow change** | SHIPPED | `package.json` `0.4.0` == `src/version.ts` `0.4.0`; `ci.yml` (`VERSION in src matches the manifest` → `node scripts/sync-version.mjs --check`, unchanged); `CHANGELOG` has `## [0.4.0]`; `git tag v0.4.0` → `86bc909` = tip of `main` = squash of PR #68 (merged). **No workflow change:** `git diff 8a083c8..HEAD --name-only -- .github/workflows/` → empty (re-confirmed after `6167ba5`). **CI unattended:** run 37217761468 `event:push` on `v0.4.0`, actor `ifelse-codes`, `conclusion:success`; log shows `npm publish --access public`, `npm notice publish Signed provenance statement … from GitHub Actions`, `Provenance statement published to transparency log: https://search.sigstore.dev/?logIndex=3078088104`; `release.yml` contains no `secrets.*` and no `NODE_AUTH_TOKEN` assignment (only `id-token: write`). **Asymmetry:** `@ifelse.codes/chitra@0.4.0 dist.attestations` present (+2 `dist.signatures`), `@0.3.0 dist.attestations` **empty** (1 signature) — and the pre-flip control run 37212844249 shows no provenance line at all. Token control: the masked `NODE_AUTH_TOKEN: XXXXX-…` config line appears **identically in the pre-flip 0.3.0 run** (and prints empty at 15:25:07) → structural npm config output, not a configured token. |
| **F6** — GTM baseline `t0` recorded as a real non-zero number with its non-organic shape disclosed, never "zero" | SHIPPED | I derived the number independently with the contract's own command: `curl … /downloads/point/2020-01-01:$(date +%F)/@ifelse.codes/chitra` → `{"downloads":119,…}`. Range endpoint: total **119**, only **5 non-zero days** → the whole figure sits in a ~6-day window starting on the publish day (2026-09-29), confirming the release-runner shape. Running the delivery's `f6_t0_baseline_recorded` first-party returned rc=0: `t0 = 119 downloads recorded in STATE.md; non-organic shape disclosed; no 'zero' claim anywhere in .ai/`; the demo's `p_f6` re-derives the same live value and fails if `.ai/STATE.md` does not carry it. Caveat for the record: the number lives in `.ai/STATE.md` (closeout-authored, excluded from the delivery diff and from my permitted reading), so my confirmation is (a) the delivery's grep logic — which requires the record to equal the **live** API value, so it cannot be typed — plus (b) my own live derivation of 119. I never read the file. |
| **Also owed by S46** — record P1's tool + re-verify order as a decision before the push; record P2's outcome in F4's table | SHIPPED | Tool: `git filter-repo` named in two delivery files (`verify-session-44.sh`: "the approved `git filter-repo` rewrite, recorded in sessions/session-46-flip.md"; `demo-session-46.sh`: "git filter-repo rewrote every REF we own"). Order: the demo cites "D-F1 step 2/3/4" against the recorded before-values, and the gate `p1-invariants-held` enforces tree==pre-rewrite, commit-count, tracked-count in that order. Timing (content not read, per contamination rules): APFS **birth time** of `sessions/session-46-flip.md` = `2026-10-04 20:20:03`, **before** `.git/filter-repo` was created at `20:20:46` — the decision file predates the rewrite it authorizes. P2's outcome is in F4's table: the `private vulnerability reporting` row reads ``**`enabled`** — `{"enabled":true}` ``. |
| **AS-1** — flip moves whole; `F1–F6`/`P1–P2` identity preserved, no quiet renumbering | SHIPPED | Delivery keeps the identifiers verbatim: `verify-session-46.sh` header "requirements F1–F6, gates P1–P2"; `demo-session-46.sh` summary lists exactly `P1, P2, F1, F2, F3, F4, F5, F6` (pass 2 keeps the same eight rows, now probed instead of typed); no requirement renamed or renumbered. |
| **AS-2** — one story; the 11 S45 audit findings not smuggled in | SHIPPED | Delivery touches only flip surfaces (REPO-SETTINGS, the two public docs, CHANGELOG, manifest, `version.ts`, two step-5 scripts, one S44 gate). `scripts/verify-closeout.sh` — the explicitly named out-of-scope gate — is **untouched** (re-confirmed: `6167ba5` changes only the demo). The single gate edit (`verify-session-44.sh`'s `home_path_scrubbed`) is P1's forced side-effect, not a finding fix: the old counterfactual ("history must contain a matching commit") became permanently unsatisfiable the moment the rewrite landed, and the commit + in-file comment say exactly that. ROADMAP/STATE edits are the closeout sync the contract itself prescribes (S47 carrier). |
| **D-F1** — P1's rewrite tool and re-verify order decided before the push (irreversible once public) | SHIPPED | See "Also owed": `filter-repo` over `filter-branch` recorded, order steps 2/3/4 enforced by `p1-invariants-held` and cited by the demo; decision file born 20:20:03 vs rewrite dir born 20:20:46; rewrite ran while the repo was still private (20:20) and the flip came later (release 22:13 IST) — the irreversible step was decided before, not after. |
| **D-F2** — enable private vulnerability reporting (repository-setting change only the founder can make), or record a waiver | SHIPPED | Live `{"enabled":true}`; `SECURITY.md` and `CODE_OF_CONDUCT.md` stop calling it a pre-flip task and now say it **is** established, while keeping the hedge (S44's hedge gate condition still satisfied: SECURITY/CoC contain `if private reporting`/fallback phrasing; `config.yml` keeps "If the link does not work…"). No waiver was used — the setting itself was changed. |
| **Commit approval** | SHIPPED | PR **#68** "S46: the public flip" merged to `main` (`86bc909`), CI green on `pull_request` (2 runs) and on `main` push; the release tag was pushed onto that merged commit. Approval is embodied in the merge, not asserted in prose. |
| **Counterfactual** — every remote fact has a `before` row captured pre-flip and an `after` row post-flip, each with its re-deriving command; a flip with no recorded `before` FAILS | SHIPPED | All three contract-listed commands have recorded before-values **in the delivery**: `.github/REPO-SETTINGS.md` records `private` → pre-flip `true`, `visibility` → pre-flip `private`, reporting → pre-flip `404` (with the public-repo control comparison), and the clone URL → pre-flip `404`; `demo-session-46.sh` renders each as a `before → after` `delta` with the live command substituted for the after value. The gate enforces it as a hard condition: `live-remote-facts` fails with "the pre-flip 'true' row is missing — a flip with no recorded before FAILS", and its recorded run PASSes. F3's before/after (`404` → `200`, same bytes) is recorded in demo case 7. |
| **Closeout** — `verify-session-46.sh` + `demo-session-46.sh`; `session-46-summary.md`; `session-46-review.md` (cold, attested); `.ai/` synced; `verify-closeout.sh` exit 0 | PARTIAL | Present and real: `scripts/verify-session-46.sh` (16 checks, `resolve_scope` defaults to `full`, satisfies `check_verify_demo_scripts`' `grep -qF`) and `scripts/demo-session-46.sh` both exist, non-empty, and — after `6167ba5` — the demo actually runs green (`EXIT=0`, every row re-derived). The contract writes them under `sessions/`, but `verify-closeout.sh:221-222` looks in `scripts/`, the repo's convention for all 40+ prior sessions: a naming slip, not a missing artifact. `sessions/session-46-summary.md` committed (`2d45acc`); this review is the cold review; `.ai/` synced (`79ef889`, `c22e0f0`). **Open:** the only *complete* `verify-closeout.sh` run for `N=46` (`.ai/verify/closeout/20261004T171026Z`, 22:40 IST — before this file existed) was green **by founder waiver**, not by proof: `fidelity-review-accept.log` reads `MISSING: sessions/session-46-review.md … WAIVED: VAJRA_CLOSEOUT_WAIVER=46` and `required-crew.log` reads `BLOCK: session 46 is missing its tech-lead handoff …`, with the waiver reason addressing the handoff rather than the absent review. (Later empty `closeout/` dirs are `--inputs-sha` invocations — the script `mkdir -p`s `$ARTIFACTS` at line 11–12 before arg dispatch — not additional runs.) A non-waived closeout green with this review present and the attestation below matching has **not been recorded**; it is owed as the final step, not faked. |

## 3. Count

**15 of 16 SHIPPED** (1 PARTIAL: Closeout, whose only open item is the post-review,
non-waived `verify-closeout.sh` run).

## 4. The fakest green

**Pass 1 named:** `scripts/demo-session-46.sh`'s Summary table — eight literal `SHIPPED` strings
printed unconditionally (`printf '%-34s %s\n' "F5 0.4.0 + provenance via CI" "SHIPPED"`), a string
literal in a file whose own header boasted "Every number printed below is DERIVED at run time". It
would have printed `P1 … SHIPPED` while the real gate was RED 14/16.

**Pass 2 status: fixed and verified, not merely claimed.** `6167ba5` replaced every cell with the
output of its own probe: `row()` prints `SHIPPED` only on `rc==0 && why=ok`, otherwise
`NOT PROVEN — <reason>` and `exit 1`. I read all nine `p_*` bodies (each has explicit failure
branches — none can print `ok` unconditionally), ran `bash -n` (rc 0) and **ran the demo**:
`EXIT=0` with all nine rows `SHIPPED`, each derived at run time (453-commit history walk → 0 hits,
live `gh api`/`curl`/`npm view`, manifest and workflow diffs, live downloads = the recorded `t0`).
The named defect is gone.

**Weakest remaining evidence (new):** the closeout green that exists today is **waiver-based** —
the one complete `N=46` run waives the very check this review satisfies, and its waiver reason
talks about the tech-lead handoff, not the missing review; so `verify-closeout.sh exit 0` is still
unproven on the merits. Secondary, unchanged from pass 1: `f4-repo-settings-rows-match` asserts only
**2 of the 6** rows F4 covers (I probed the other four myself — they match), and `commit_cap_respected`
/ `p_cap` count only `merge-base..HEAD`, so the 9-file squash commit on `main` stays outside their
count (the cap finding, E1, is out of scope anyway).

## 5. Pass 1 → pass 2 movement

Pass 1 of this review, cast against HEAD `2d45acc`, attested the cold-input hash
`6006cb8122f2c240c2ca48f7c1d0f98a336f3138f2c5d35f5094e02acbbf0865`. The delivery then moved by
**exactly one commit**, `6167ba5`, which touches **only** `scripts/demo-session-46.sh` and fixes
precisely the defect this review named as the fakest green; nothing else in the delivery changed and
the contract `prompts/46-task-public-flip.md` was never touched. The attestation printed below is
therefore computed over the final diff (HEAD `6167ba5`), so this acceptance now binds what actually
shipped rather than the pass-1 diff.

## 6. Verdict

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 4f3372b3a159e7a222514be2931fe42c9b849f5fe3b13f5d04d4143649dc201e
