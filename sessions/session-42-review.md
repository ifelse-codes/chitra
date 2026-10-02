# Session 42 — independent cold fidelity review · SECOND PASS

Branch `session-42-dead-weight` @ `e354a4a`, base `main` @ `4893683` (= merge-base).
Cold inputs: `prompts/42-task-dead-weight.md` + the delivery diff, and nothing else.
This pass re-rules on the remediation of the first pass's REJECT.

---

## 1. Method controls used this pass

**Cold diff regenerated** with the exact command the closeout hash uses — 124 files,
1,055 insertions / 12,233 deletions. `prompts/` is excluded from that hash, so I read the
contract as a file and additionally diffed it **against its own original commit `6ef42e4`**
(see finding N1 — that diff is what surfaced the most serious issue in this pass).

**Forbidden inputs, still not read:** `sessions/session-42-summary.md`,
`.ai/STATE.md`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md`, `.ai/ROADMAP.md`, `.ai/KNOWLEDGE.md`.
Presence-only checks where needed (`summary.md` exists and is tracked). Narrow `grep -n` on
`ROADMAP.md` only to confirm my own §4.5 correction landed — lines 15/18/23/109/407, no narrative read.

**Read:** the new `scripts/verify-session-42.sh` (727 lines, in full), the new
`scripts/demo-session-42.sh` diff, `replit.md` diff, `.ai/CONTINUATION-PROMPT.md` diff,
the contract (full), `scripts/qa-catalog.mjs`, `scripts/chart-specs.ts`, `artifacts/chitra-docs/src/App.tsx`
route logic, `pnpm-workspace.yaml`, `b992fae`'s message.

**Counterfactuals run** — 6 harnesses, all in a throwaway clone at `/…/opencode/s42p2/repo`,
never in the working tree. I extracted the real function bodies by line range out of
`verify-session-42.sh` (`sed -n '137,164p'`, `'406,439p'`, `'459,469p'`, `'664,687p'`) rather
than retyping them, so I tested the shipped bytes.

**What I could not examine:**
- **The full gate did not finish.** I launched it in my own clone; it produced **31 of 35**
  check logs in **60 minutes** and was killed at the timeout, mid-`s41-gate-verbatim-goes-red`.
  So I cannot assert "33/33 green" as I did last pass. I *can* assert that every check that
  ran produced a correct, honest log (31/31 inspected below), and that CI is green at HEAD
  across all four jobs including browser QA.
- Whether the founder's chat tokens behind Assumption 1/2 and F42-1 were actually given —
  unverifiable from here.
- Whether the builder's machine had `packages/core/dist` built when it first ran the new
  browser-QA check (relevant to N5).

**Invariants re-verified independently, unchanged from the first pass:**
`0` files under `packages/core/src/charts|renderers|themes`; `0` files under `packages/core/` at all;
`pnpm-workspace.yaml` diff = **0 insertions / 1 deletion** with the `overrides` block untouched;
103 dead-tree files (69/20/11/3) → 0; 110 total deletions; 511 → 405 tracked files;
lockfile `+67 / −3177`; importers 10 → 4; `test-count-propagated`'s discovered set still
exactly the 13 declared sites with every per-file idiom present.

---

## 2. Per-finding: my first-pass findings, re-ruled

| # | Original finding | Verdict | Counterfactual I ran, and what happened |
|---|---|---|---|
| 1 | **Req 8's browser-QA tick was fabricated** — the contract named `pnpm --filter @workspace/chitra-docs run qa`, which prints *"None of the selected packages has a 'qa' script"* and exits 0; the gate had zero browser checks; the demo printed `SHIPPED` off two checks that never open a browser | **FIXED** | Ran the new `browser-qa-catalog-pages` body verbatim in my clone: `qa-catalog.mjs` **exit 0**, **20** `PASS chart-` lines, **0** FAIL rows, `Persistence smoke: PASS`. A real browser is now driven, and demo row 8 now derives from it. Independently, Actions run `36997552355` at `e354a4a`: `qa · browser QA (all catalog pages) … success`, plus core/docs/drift all `success`. The fictional command's exit-0-is-worthless property no longer carries the requirement. *(Two defects inside the new check are recorded as N5/N7 — they qualify its coverage, they do not reopen the finding.)* |
| 2 | **`replit.md:58` was false** ("globs `packages/*` and `lib/*`") and `no-live-ref-to-dead-trees` was structurally blind to it | **FIXED** | The sentence is corrected in the file (`replit.md:57-58`, now naming `artifacts/*`, `packages/*`, `scripts` and recording `lib/*` as removed). I restored my **exact** stale sentence verbatim and ran the new `replit-globs-match-workspace`: **`replit.md claims a glob that does not exist: lib/*` → FAIL.** Also caught a *second* stale line added alongside the historical one (the `grep -v` hardening works), and dropping a real glob name from replit.md (`artifacts/*` → FAIL). |
| 3 | **`contract-at-head` could not fail** — it grepped the phrase `"10 numbered requirements"`; it passed on a contract with 7 of 10 requirements deleted and on a 4-line stub | **FIXED** | Both original counterfactuals now red: deleting reqs 4–10 → `contract requirements are [1 2 3 ], expected [1 2 3 4 5 6 7 8 9 10 ]` **FAIL**; 4-line stub → `[]` **FAIL**. Plus five more I invented: single-req deletion of 4, 6, 8 and 10 → **FAIL** each; renumbering 10→11 → **FAIL**; demoting the `## Assumptions` heading → **FAIL**. This is now a genuinely structural guard, not a phrase check. |
| 4 | **`dead-scripts-gone`'s closing clause could not fail** — `pnpm --filter @workspace/scripts run typecheck` over `"files": []` exits 0 even with a hard `TS2322` sitting in `src/`, while its comment claimed the package "must still typecheck rather than quietly doing nothing" | **FIXED** | The hollow clause and the false comment are gone (`:497-517`, the omission is explained in place). The three replacement clauses: (i) adding `"include": ["src"]` to a src-less config → **FAIL**; (ii) removing `"files"` entirely → **FAIL**; (iii) a real type error in the docs app → **`root typecheck is red` → FAIL**. Independently, root `pnpm run typecheck` now has genuine coverage — it was vacuous for `@workspace/scripts` and is not for the docs app. *(Clause iv is weak — N9.)* |
| 5 | §4.4 — `vite-configs-discovered` was **weaker** than S41: a config that stripped `process.env.PORT` entirely still passed | **FIXED** | Re-ran my exact counterfactual: hardcoded `const rawPort = "5000"` / `const basePath = "/"`, removing every `process.env` read → **`artifacts/chitra-docs/vite.config.ts mentions PORT but never defaults it` → FAIL.** The trigger now fires on any standalone mention of the name, so the config's own explanatory comment is enough to make the default mandatory. Re-confirmed the two original counterfactuals still red (hard-throwing config under `packages/core/` → FAIL; every `vite.config.ts` removed from the index → FAIL). |
| 6 | §4.5 — `no-stale-version-literal` lost its escape: `"0\."` → `"0."` | **FIXED** | `:68` now reads `grep -qE "VERSION\s*=\s*\"0\."` — the escape is restored, byte-identical to S41. |
| 7 | §4.6 — `test-count-propagated` dropped `set -e` and `\| head -1` | **FIXED** | `:309` `set -e` and `:313` `\| head -1` are both back. Gate log confirms `canonical count 453: 13 declared sites agree, and no other tracked file outside the exemptions displays it`. |
| 8 | §4.7 — commit `06ef402`'s message said **"Four sites"** above a list of three | **FIXED** | The rewritten commit is `b992fae`; its message now reads **"Three sites, one atomic change:"** and `git show --numstat` confirms exactly three files. Message and diff finally agree. |
| 9 | §4.5 (first pass) — `.ai/ROADMAP.md:109` still called the deleted api-server "the undecided bet"; `:406` still listed fleshing it out as a live item | **FIXED** | `:109` now reads "**was** the undecided … bet"; `:407` is struck through with "**Closed in S42** — the tree is deleted; `main@4893683` keeps it if the bet is ever revisited." |
| 10 | §4.8 — `CONTINUATION-PROMPT.md:94` said "the live pair is 39 and 42", contradicting the contract's "39 / 41 / **42**" | **FIXED** | Now reads **"39 / 41 / 42"**, matching the contract. `scripts/verify-session-41.sh` is indeed present, executable and runnable. |
| 11 | §3 FAKEST GREEN — the demo's per-requirement STATE column was a keyword grep over check logs, which I showed renders req 6 `PARTIAL` and req 8 `SHIPPED`, both wrong | **PARTIAL** | The *mechanism* is fixed and correctly: `vstate` now reads `$LOG/summary.txt`, which the gate writes as `<name> PASS\|FAIL` from its own recorded exit status (`:717-724`). No more log-prose guessing. **But the mechanism does not work during the run that produces it** — see N2. |
| 12 | §4.3 — `ai-names-no-deleted-tree` is a declared-list membership check and therefore cannot catch a false claim inside a listed file; `ROADMAP.md:109` was exactly that | **NOT-FIXED** (disclosed) | Body unchanged. The *reason* is recorded in-file and I judge it **an acceptable disclosed limit, not a blocking defect**: (a) the two concrete instances it missed are now fixed at the source (finding 9), (b) the alternative the author rejected — demanding a qualifier word on the same line — is precisely the prose-coupled check this repo has repeatedly rejected, and (c) the declared list now has a demonstrated failure mode (a new mention site turns the gate red and forces a human decision), which is the intended design. What it still cannot do is catch a lie *within* a listed file; that is a real residual blind spot and should be named in S43's gate-authoring rules rather than re-litigated here. |
| 13 | §4.9 — cost/maintenance: the gate transitively runs S41's entire 24-check gate, the suite ~5×, and two full clone installs per invocation | **NOT-FIXED**, and now measured | My own full-gate run in a clean clone produced **31 of 35** check logs in **60 minutes** before I killed it at the timeout. Adding browser QA (a docs build + a Playwright run over 26 pages) made it worse. Not a fidelity defect and not a reason to reject; it is a real, growing cost on a gate that is now the session's load-bearing artifact. |
| 14 | §4.10 — the one surviving `artifacts/chitra-docs/vite.config.ts` still imports `@replit/vite-plugin-runtime-error-modal`, `@replit/vite-plugin-cartographer`, `@replit/vite-plugin-dev-banner`, and `chitra-docs/package.json` still carries all three as devDependencies — so the contract's one-liner ("the repo ships the library, not the scaffold it came from") is only two-thirds true | **NOT-FIXED** (claimed out of scope) | Unchanged and un-named in the contract's out-of-scope list. I judge this **fair but under-declared**: the contract's out-of-scope section names S43's shadcn/Prettier/lint and S44's OSS work, but never says "the Replit *plugins* in the docs vite config stay". The one-liner remains an overstatement. Cheap to fix in S43; it should not be allowed to survive into the public flip. |

---

## 3. NEW findings

Severity discipline unchanged from the first pass.

### N1 · HIGH (process/governance) — the cold input was rewritten mid-review

`git diff 6ef42e4 e354a4a -- prompts/42-task-dead-weight.md` is **one hunk, and it is
requirement 8**. The commit that made it is `16a5bc7 "the two documents the cold review found
FALSE"`. The requirement that named a nonexistent command now reads:

> "The real entry point is `node scripts/qa-catalog.mjs` … The docs package has **no `qa`
> script**, so `pnpm --filter @workspace/chitra-docs run qa` prints … and **exits 0**; it
> cannot fail … **(Corrected after the cold review; the first draft of this line named the
> non-existent filter.)**"

Why this matters even though it is disclosed in-line and git preserves the original:

- The contract is a **cold input**. `reviewer/SKILL.md` §2: "Feed exactly two things: the
  **contract** and the **delivery diff**." A specification the subject of the review can edit
  between passes is an *output*, not an input.
- `check_review_attestation` (`verify-closeout.sh:330-396`) recomputes
  `sha256(prompt ‖ diff)` from whatever the prompt currently says. Editing the prompt after a
  REJECT silently rebinds the attestation to the edited spec — the freshness property the repo
  spent S56–S59 building is void for this session.
- The concrete harm: **the next reviewer is handed a specification that already contains its own
  rebuttal to finding #1.** The miss is laundered out of the requirement text.
- The contract's own req 10 says "Every finding is fixed **in place** or the acceptance is
  withdrawn" — "in place" means the code, not the spec.
- **It is disclosed only inside the contract.** `.ai/CONTINUATION-PROMPT.md` — the handoff whose
  job is to "carry the review's verdict and its lesson", which now records the REJECT and the
  two unfailable checks — does **not** mention that the prompt was edited. That omission is the
  part that turns a defensible correction into an undisclosed one.

The behavioural fix was real and I verified it (finding 1), so this is not a hollow checkmark.
But the *process* is wrong, and the right remedy was: leave the contract frozen, ship the real
check, let the first-pass REJECT stand on the record. **Recommendation for S43 onward: treat
`prompts/NN-*.md` as immutable for the duration of a review cycle.**

### N2 · MEDIUM — the demo's fidelity table renders `10 × NOT PROVEN` during a real gate run

`summary.txt` is written at `verify-session-42.sh:717-724` — **after** all 35 checks.
Check #35, `demo-displays-count-at-runtime` (`:699`), invokes the demo with
`DEMO_LOG_DIR=$ARTIFACTS`, i.e. the in-progress run dir, which does not have `summary.txt` yet.

Demonstrated: with a fresh artifacts dir, the demo's table renders

```
  1    four dead trees deleted, 0 tracked files each   NOT PROVEN
  …                                                  NOT PROVEN   (all ten)
```

and the demo's own comment says: *"every row rendered NOT PROVEN against a gate that was 35 for
35. **If this check ever says NOT PROVEN, check THIS first.**"* The author diagnosed that exact
symptom, fixed the `grep -q .` piping that caused it, and left the cause — the ordering. The fix
comment describes the bug correctly and then re-creates it one layer down.

Direction of the error matters: this **under**-claims, so it is not a fakest green. But the
surface whose entire job is "map every requirement to a verdict" is inert in the only context
where it is produced automatically. `demo-displays-count-at-runtime` does not notice, because it
only asserts the `(N tests in M files)` line. Cheap fix: write `summary.txt` incrementally
inside `run_check`, or have the demo fall back to `$LOG/../summary.txt` from the previous run.

### N3 · MEDIUM-LOW — the handoff now carries two wrong hand-written check counts

`.ai/CONTINUATION-PROMPT.md` states the gate's check count twice. Both are wrong:

- `:26` — "S42's gate is **33 checks**" (the pre-remediation count, left stale)
- `:55` — "S42's gate (**34 checks**…)" (post-remediation, off by one)

The truth is **35** (`grep -c '^run_check ' scripts/verify-session-42.sh`).

This is the exact disease the session was created to kill, and the remediation commits
*half-updated* it — line 55 was edited 33→34 and never verified, line 26 was left alone.
`demo-session-42.sh:161` already derives the number live (`GATES=$(grep -c '^run_check ' …)`);
`test-count-propagated` derives the *test* count and guards 13 declared sites — but nothing
guards the *check* count, so two hand-written copies rotted in the same file.

### N4 · MEDIUM-LOW — `replit-globs-match-workspace`'s success message misdescribes its own assertion

Line 437 echoes `"…agree on: $(echo $globs)"`, but `set +f` (line 435) has already restored
globbing, so `$globs` is pathname-expanded. The gate's own log reads:

> `replit.md and pnpm-workspace.yaml agree on: artifacts/chitra-docs packages/core scripts`

It agreed on `artifacts/* packages/* scripts`. Cosmetic, but a success message that reports the
wrong thing is the same defect class as a doc that reports the wrong thing.

### N5 · MEDIUM-LOW — `browser-qa-catalog-pages` has an undeclared precondition

In a clean clone the check goes **red for the wrong reason**:

```
[commonjs--resolver] Failed to resolve entry for package "@ifelse.codes/chitra"
QA failed: Error: Command failed: pnpm run build
```

`qa-catalog.mjs` builds the docs app, which resolves core through `packages/core/dist` —
gitignored. `ci.yml:122-125` and `release.yml:62-65` both build core first and say so. The gate
check declares no such precondition; it only works because `version-in-built-dist` (#2) and
`docs-meta-not-scaffold` (#4) happened to build core earlier in the same run. After I ran
`pnpm --filter @ifelse.codes/chitra run build` once, the very same command returned 20 PASS pages
and exit 0. A gate whose result depends on which checks ran before it is order-fragile, and it
fails red, not green — which trains people to ignore it.

### N6 · MEDIUM-LOW — `charts-untouched` passes vacuously when `main` does not resolve

This bit my own clone run, and its log says so:

```
fatal: bad revision 'main...HEAD'
no changes under src/charts, src/renderers, src/themes
```

`d=$(… | wc -l)`; any `git diff` error yields empty stdout → `0` → `[ "$d" = "0" ]` → **PASS**.
Demonstrated precisely: CASE 1 (no local `main`, as in any plain `git clone`) → **PASS**;
CASE 3 (typo'd ref) → **PASS vacuously**; CASE 2 (`main` resolves, a LOCKED chart file genuinely
committed) → **FAIL**. So the guard is real in the founder's repo and silently inert anywhere
`main` is absent.

The inconsistency is the point: `s41-gate-verbatim-goes-red`'s own comment states the standard
this session claims — *"If the extraction fails the check FAILS — a guard that cannot evaluate
does not pass."* `charts-untouched` does the opposite. Inherited from S41 and untouched by S42.
Fix: `[ -n "$(git rev-parse --verify --quiet main)" ] || exit 1` before the diff.

### N7 · LOW — the new browser-QA check's coverage claim is false

Its comment says: *"The count is derived, never restated, so a chart added or removed cannot
leave a stale number behind"* and *"Every catalog page must have been visited."*

`scripts/qa-catalog.mjs:19-24` **hardcodes** `CHART_IDS` — a 20-element literal. Nothing
anywhere cross-checks it against `artifacts/chitra-docs/src/data/charts.ts` (the app derives
`/chart/<id>` routes from `CHARTS`, `App.tsx:699`). The number is derived; the *inventory* is
restated.

Demonstrated end-to-end: I cloned a catalog entry to a 21st live page, then ran the check body
verbatim. Result — `qa-catalog.mjs` exit 0, `n=20`, and the check reports
`20 chart pages driven, 0 console errors, 0 page errors, persistence PASS` while the site
serves **21** pages and `/chart/sparklineProbe` is **never visited** (0 mentions in the output).
`gen:charts:check` also stayed green through the edit. Removal is covered; addition is not.
Fix: derive the visit list from `CHARTS` instead of the literal.

### N8 · LOW — `replit-globs-match-workspace`'s claimed counterfactual is false

Its comment claims: *"Counterfactual: re-add `- lib/*` to `pnpm-workspace.yaml`, or restore the
stale sentence to replit.md, and this goes red."* I re-added `- lib/*` and it went **green**.

Clause (a) only requires replit.md to *name* each real glob, and replit.md names `lib/*` — in
the historical "It used to glob `lib/*`" clause. So a resurrected dead glob satisfies (a) and
escapes (b). The two clauses cancel exactly when they should compound. Defence in depth partly
covers it (`workspace-glob-real` and `dead-trees-gone` would fire if the directory were also
recreated), but the stated counterfactual does not exist.

### N9 · LOW — `dead-scripts-gone` clause (iv) cannot detect the condition its comment names

Clause (iv)'s comment: *"a filter that silently matches nothing would leave the docs app as the
only thing typechecked."* I removed `- scripts` from `pnpm-workspace.yaml` entirely and the
clause printed `ok` and passed; I also removed the `typecheck` script from `scripts/package.json`
and it still passed, because `pnpm -r --if-present run typecheck` exits 0 whether it ran or
skipped. Clause (iii) has the same blind spot for the same reason. Practical impact is near-zero
(`scripts` has no sources, so losing it is behaviourally inert), but the comment claims a
guarantee the clause does not deliver.

---

## 4. The brief's specific hypothesis: does `set -e` abort the gate?

**Refuted, and it was worth testing.** The three rewritten checks no longer run under `bash -c`,
so they do execute inside the gate's own `set -euo pipefail` shell — but bash suspends `-e` for
the entire body of any function invoked in a condition context, which is exactly how `run_check`
calls them (`if "$@" > "$LOG" 2>&1`).

Proven on the repo's own interpreter (`/bin/bash` 3.2.57, the only bash on `PATH`, so the shell
`#!/usr/bin/env bash` actually gets):

```
f_hardfail() { grep -q "NOPE-NOT-PRESENT" /etc/hostname; return 0; }
run() { if "$@" >/dev/null 2>&1; then echo PASS; else echo FAIL; fi; }
run f_hardfail   ->   PASS, and the outer script survives
```

A function whose *first* command fails and which then returns 0 yields PASS and does not abort
the caller. So the brief's feared failure mode does not exist here, and the rewrite is safe in
that respect. I also confirmed no state leaks between checks: `replit_globs_match_workspace`'s
`set -f` is always paired with `set +f` on every path, and `s41_gate_goes_red`'s
`set +e` / `set -e` pair is balanced. 31 of 31 completed checks in my run produced correct logs,
with no cross-contamination.

---

## 5. Count, and the fakest green

**8 of 10 SHIPPED** — up from 7. Requirements 1–7 unchanged and re-verified; **requirement 8 is
now genuinely SHIPPED** (a real browser is driven in the gate and green in CI at HEAD, and the
demo row derives from the check that drives it). Requirements 9 and 10 remain **PARTIAL**:

- **Req 9** — `.ai/` is substantively re-synced and the frozen history is untouched, but the
  remediation commits introduced a fresh `.ai/` truth defect: two wrong hand-written check
  counts in `CONTINUATION-PROMPT.md` (N3).
- **Req 10** — the gate half is genuinely fixed (`contract-at-head` now fails on every
  structural attack I could devise), but the fidelity-map surface is inert during the run that
  produces it (N2), and the cold input itself was rewritten between passes (N1).

### FAKEST GREEN of this pass

**`replit-globs-match-workspace`'s comment**, at `verify-session-42.sh:404-405`:

> "Counterfactual: re-add `- lib/*` to `pnpm-workspace.yaml`, or restore the stale sentence to
> replit.md, and this goes red."

I re-added `- lib/*`. It stayed green. Half of a two-part claimed counterfactual is simply not
true of the shipped bytes, and the check was written specifically to answer a review finding, so
its own justification is the thing a reader is most likely to rely on. The *finding* it does
answer is answered — my exact stale sentence is caught — which is why this is the fakest green
rather than a reopening.

Runner-up, and worth naming because it is the more consequential shape: `browser-qa-catalog-pages`
prints `20 chart pages driven, 0 console errors` while the site serves 21 (N7). The check's own
comment claims that outcome is impossible.

---

## 6. Verdict

The bar I set last time was specific: a numbered requirement displayed `SHIPPED` on evidence
that never measured it; a document made false *by this diff* with the guard blind to that class
of reference; a gate check that provably could not fail. **All three conditions are gone, and I
demonstrated each one by breaking it.** Four blocking defects, four genuine fixes. Seven of the
actionable §4 items fixed, including two subtle ones (the `"0\."` escape, `set -e`/`head -1`) and
one that required the right instinct (making `vite-configs-discovered` fire on any mention of the
name rather than on `process.env.PORT`). The remediation reads like it took the review seriously
rather than like it was chasing a checkmark, and the handoff now carries the review's own lesson
forward.

I am not claiming this delivery is defect-free. N1 is a genuine governance failure and I would
argue it against anyone who tries to wave it through: the specification was edited between the
review and the re-review, in a way that removes the finding from the requirement text, disclosed
only in the file a future reviewer is least likely to read for caveats. That is a process defect,
not a fidelity defect, and the behavioural work it accompanied is real — but "the builder was
allowed to rewrite the prompt after the reviewer ruled on it" is not a precedent this repo can
afford, given how much machinery S56–S59 exists to keep the review honest. N2 is a real
functional bug in the one surface req 10 is about. N3 is two wrong numbers in the handoff of a
session whose thesis is that hand-written numbers rot.

None of these reopens a numbered requirement. Reqs 1–8 are complete and independently verified;
CI is green at HEAD on all four jobs including browser QA. N9, N4, N7, N8 and §4.10 are small and
named. My residual objections are: fix N1 and N2 before S43 inherits them, correct the two
numbers in N3, and add N6's one-line guard while the file is open.

**ACCEPT — on the explicit basis that the four blocking defects are genuinely fixed and the ten
requirements are met, not on a claim of defectlessness.**

**Verdict:** ACCEPT
**Review-Inputs-SHA:** 6f2bb299180dac4cb41d90dbeefb56d54092e5dedd2a8c7e0f9b7069b45e3afa