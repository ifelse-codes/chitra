# Session 44 — cold fidelity review (pass 8)

## Review inputs

Two cold inputs, and nothing else from the repo.

1. **The contract** — `prompts/44-task-oss-polish.md` at HEAD: 14 numbered requirements in the
   `## Scope` section, plus `## Out of scope`, `## Assumptions`, `## Founder decisions answered`,
   `## Contract amendments` (**A1 … A11**), `## Closeout`, `## The counterfactual this session
   demands`. Requirements were extracted from every requirement-bearing section, not only the
   numbered list: the Out-of-scope block, the two Assumptions, the Closeout paragraph and the
   counterfactual paragraph all carry obligations, and each is folded into the row it touches.
2. **The delivery diff** — `git diff $(git merge-base main HEAD) HEAD` with
   `merge-base main HEAD` = `1b6c17d`: 50 files, +3,659 / −4,145, 50 commits.

Also read, because the brief requires them to be judged rather than assumed: the freeze diff
(`git diff $(git merge-base main HEAD) HEAD -- prompts/`), the per-commit history of
`prompts/44-task-oss-polish.md`, and the live repo where a claim is remote (`.github/REPO-SETTINGS.md`
re-derived with `gh api`). `sessions/session-44-summary.md` was treated as a claim to be checked,
never as evidence. Passes 1 through 7 each returned a rejection of this delivery; that history is
stated here in prose and is not itself an input to this verdict.

What I ran: `bash scripts/verify-session-44.sh` (full scope — 49/49 PASS, exit 0, 2m6s), the same
gate at `VAJRA_GATE_SCOPE=fast` (43/43 PASS, 6 SKIP, 26s), `bash scripts/verify-closeout.sh 44`
(14 pass, 3 fail), the suite under coverage (`453 passed (453)`, `Test Files 23 passed (23)`), and
seven hand-built counterfactuals against the two functions this session's newest amendment exists to
make enforceable (`pick_timings_file` and `map_measurement_honesty`, both extracted verbatim into a
scratch harness — no tracked file was touched). The closeout's three failures are
`fidelity-review-accept`, `contract-freshness` (both "no commit in history adds
`sessions/session-44-review.md` — freshness cannot be evaluated (fail closed)") and `required-crew`
(three founder waivers, named in the contract's Out-of-scope block as carried forward). The first
two are the A9.3 ordering, which is the correct behaviour with no report committed yet, not a
finding.

**Review-Inputs-SHA-Pass-1:** 8ea9588b11df72f41ed6088d71bb008610b174fe5d3a2363218ad8061b144be0

**Verdict:** REJECT

## Method controls

- **Separate pass.** This review was produced in a fresh subagent with its own context, not inline
  with the builder's reasoning.
- **Cold inputs only.** The contract and the delivery diff. The builder's fidelity map was read
  only as the object under audit — every claim in it was re-derived from the diff, the gate, or a
  live command before it was believed or disbelieved. The prior review file on disk was pass 7's;
  it was not read for its findings and this file overwrites it.
- **Adversarial framing.** Assume the builder silently re-scoped to whatever yields a green
  checkmark; find the fakest checkmark. Assumed specifically: that a number stated as current is
  really current; that a "fixed" claim covers the set it claims; that a check can go red on the
  string it was written for; that a gate reports 49/49 because the work is right, not because the
  count is small.
- **Every gate claim was driven in both directions.** Where a check claims a counterfactual, I
  rebuilt the counterfactual outside the gate rather than reading the comment.
- **A green gate is one input, not the conclusion.** The gate is green (49/49) and the delivery is
  still rejected below.

## Per-requirement verdicts

| # | Requirement | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | `SECURITY.md` at the root: supported versions, how to report, what is not promised, no invented `security@` | SHIPPED | `484c36b`. File carries `## Supported versions` (latest-only table), `## What is in scope` (incl. the release pipeline), `## What is out of scope`, `## What you should not expect` (no SLA, no paid support, no bug bounty). Zero email addresses — `oss_surface_present` runs the address regex over **both** `SECURITY.md` and the CoC. The route is qualified **before** the promise: "**If** this repository has private reporting switched on, use it", then "A report sent that way reaches the maintainers", then the recorded setting and what to do when it is off. |
| 2 | `CODE_OF_CONDUCT.md`: Covenant 2.1, a real enforcement contact, no placeholder address | SHIPPED | `484c36b`. "Contributor Covenant" + `## Enforcement` + the ladder; states in its own words that the project publishes no mailbox and why a `conduct@` nobody reads is worse; gives the honest fallback (a report with no detail asking for a private route) and says plainly that the private channel may not exist. |
| 3 | Issue + PR templates under `.github/`, every bug-form field actionable | SHIPPED | `eda166e`, `178553c`. `bug-report.yml` has Package version, Terminal and OS, Reproduction, Expected, Actual — all `required: true` — plus the hedged security link; `feature-request.yml`; `config.yml` with `blank_issues_enabled: false` and three contact links; `.github/PULL_REQUEST_TEMPLATE.md`. All three route clauses pass on all seven reader-facing files, and the recorded settings match live `gh api` (`private true`, `has_issues true`, `has_discussions false`). |
| 4 | CI badge in `README.md` pointing at the workflow that really runs | SHIPPED | `178553c`. Badge URL `…/actions/workflows/ci.yml/badge.svg`; `oss_surface_present` extracts every `actions/workflows/*.yml` URL out of the README and requires `.github/workflows/<that file>` to exist — red on `main`, where there is no badge at all. npm / license / dependencies / charts / tests badges all still present. |
| 5 | Coverage enforced in CI; no third-party service; measured numbers disclosed | SHIPPED | `5f21a1e`. `ci.yml#core`'s Test step is now `pnpm --filter … run test:coverage` (the plain `Test` step is gone, so the suite still runs once); four live thresholds in `vitest.config.ts`; the check fails if `codecov|coveralls` appears and if `main` already ran it. My own run: `Tests 453 passed (453)` with per-file percentages printed and `rc=0`. `CONTRIBUTING.md` publishes `94.27 / 87.64 / 86.28 / 94.27` and `contributing-coverage-numbers-real` compares them to the run. |
| 6 | `engines` where provable; no `packageManager` | SHIPPED | `523102a`. Root `>=26` / `>=9.12.3` are read out of `ci.yml`'s own `NODE_VERSION`/`PNPM_VERSION` and asserted equal; `packages/core` `>=22` is stated in CONTRIBUTING with the derivation (zero `node:` builtins, zero runtime deps, newest syntax `?.`) and labelled "A support policy, not a test result"; README's floor is asserted to **equal** the pin (F1); `packageManager` is asserted absent. |
| 7 | D1–D6 answered and recorded where the next session will find them | SHIPPED | Recorded in the contract, `.ai/STATE.md` and the map. `founder-decisions_covered` asserts D1 (six process dirs in the index), D2 (`## Git hooks (opt-in)` + the install line + `"hooks"` in `.claude/settings.json`) and D3/D6 (0 tracked under `playground/`+`design-reference/` — I re-derived 0 — whole-directory ignore rules, plus two live `git check-ignore` probes), green here and red on `main` **twice over**. D4 is `home_path_scrubbed`, D5 is `overrides_gone`, D4b is recorded pending with derived counts. |
| 8 | D4 scrub provably mechanical | SHIPPED | `6024e0d`: 15 files, every one N/N in `--numstat` (I re-derived all 15), nothing added or deleted. `home_path_scrubbed` greps the live tree **and** re-runs the same `(/|-)Users[-/][a-z]+` against the newest pre-scrub commit found by walking history, so a pattern matching nothing anywhere fails rather than passes. |
| 9 | N1: a rule **and** a gate, each with a counterfactual | SHIPPED | `d75a23a`, `dc6b4dc`. Rule in `reviewer/SKILL.md` (amend under `## Contract amendments`, never rewrite in place). `contract_freshness_core` + `contract_freshness_declared_change` are pure; `contract-freshness-teeth` extracts the body with `awk` and drives it: green on S43, red on S42 **naming a commit it then proves touches the contract**, and clause (b) in **both** line orders (N2) plus the two "must not fire" cases. |
| 10 | §4.9: `VAJRA_GATE_SCOPE=full\|fast`, default full, fast measurably faster | SHIPPED | `b9d8791` + `e62808c` + `51bf7c3` + `f0c04e2`. Default resolves to `full`, an invalid scope is rejected, every skip-list name is a real check, nothing S44 owns is skippable (`map-measurements-honest` included), and the switch is priced from measured per-check seconds. **I rebuilt the fixture outside the gate**: current picker → `20100101T000000Z` (newest complete, prices the list); the pre-A11 picker (`cnt > best`, oldest wins the tie — the logic pass 2 called the fakest green) → `20000101T000000Z`, which the fixture's `case` rejects; completeness guard removed → `20100101T000002Z` (half-written), rejected; pricing guard removed → `20100101T000001Z` (prices nothing), rejected. Each trap is caught by its own guard. The in-progress run cannot be priced — both of my runs printed "this run is still being written" and named an older run. Measured: full 49/49 in 126s, fast 43/43 in 26s. |
| 11 | D5: strip `overrides`, regenerate the lockfile in its own commit | SHIPPED | `9d88882`, `589a196`. No `overrides:` key and no `ngrok|esm-loader|@expo/` survivor in `pnpm-workspace.yaml`; `main` still has the block; `git diff main...HEAD -- pnpm-lock.yaml` is empty; `pnpm install --frozen-lockfile` exits 0. A1 discloses that the regen produced an empty diff, so there is no lockfile commit to separate — the honest note, stated rather than faked. |
| 12 | Re-prove the product from live facts | SHIPPED | `fresh-clone-build-no-env`, `core-tests`, `core-typecheck`, `root-typecheck`, `coverage-gate-passes`, `contributing-coverage-numbers-real`, `example-runs`, `chart-drift`, `browser-qa-catalog-pages` all PASS in my full run; 453/453 in **23** files, matching the requirement's figure. CI is green on the branch tip (`gh run list --branch session-44-oss-polish` → `success`, run 37178955691), and `HEAD` == `origin/session-44-oss-polish` (`0 0` ahead/behind) — M4 holds. |
| 13 | Re-sync `.ai/`; **any surviving count is derived, not typed** | PARTIAL | The six `.ai/` files are genuinely re-synced: `ai-files-describe-s44` passes, `ai-names-no-deleted-tree` passes, `test-count-propagated` passes, and the A5.3 / A10.2 typed counts are gone from all of them (the only percentages left in `.ai/` are font facts like `14% wide`, which the new check's comment correctly cites). **But the same rule is broken one document over**: `sessions/session-44-summary.md:20-21` types the gate's check-counts as current — `48` / "48 PASS" and `42` / "42 PASS" — and `:326` types "42/42 … 48/48", in the same paragraph that says the run tally is derived and "**not typed here**". At HEAD the gate has **49** checks in full scope and **43** in fast. See finding 1. |
| 14 | Fidelity map + an independent cold review, no self-certification | SHIPPED | `sessions/session-44-summary.md` maps all 14 requirements to commit-level evidence and records passes 1–7 with their counts, verbatim where the finding was about its own bytes; this file is the eighth cold pass, fed only the contract and the diff. (The map's inaccuracy is counted against requirement 13, where the session itself has consistently counted map counts — A5.3, A8.6, A10.2 all say "req 13".) |

**13 SHIPPED · 1 PARTIAL · 0 NOT-BUILT**

## The fakest green

**`map-measurements-honest`** — the check that exists because pass 7 found that "no gate can go red
because the map quotes a figure", and the one A11.1 titles "the gate that finally covers the class".

Its rule is `[0-9]%`. The class it was created for is *a number stated as current that does not
reproduce*. So on the very document it guards, one screen above the percentages it polices, the map
states two current counts that are wrong — and the check reports, in a confident green line, "the
map states no percentage as a current measurement: the requirement rows carry none at all, and the
rest is marked as history". The message is true about percentages and reads as a clean bill of
health for the map's numbers.

It is not a hollow check. I drove all three counterfactuals A11.1 claims and they are real: green on
the current map; red on pass 7's exact string re-injected into row 10; red on a bare "The gate
measures 73% of its wall clock"; green on a legitimate history quote. Rule 1 is genuinely structural
— the blunt "no percentage in a `| N |` row" is the right instrument and it fires on the exact string
it was written for, which rule 2 alone did not. And it is correctly registered in the owned list: my
fast run's `summary.txt` shows `map-measurements-honest PASS`. What it does not do is the one thing
its name and A11.1's headline say it does, and the commit that added it is the commit that made the
map's headline numbers wrong.

## Findings

### (a) Material

**1. [medium-high] The fidelity map types two gate check-counts as current, and neither reproduces —
and the commit that made them wrong is the commit that shipped pass 7's fix.**
Requirement 13 (and, through the map, 14). Commit that must answer it: `f0c04e2`; file:
`sessions/session-44-summary.md:20-21` and `:326`.

- `sessions/session-44-summary.md:20` — `| \`full\` (default) | 48 | **48 PASS, exit 0** | **~2–3 min** |`
- `sessions/session-44-summary.md:21` — `| \`fast\` | 42 | **42 PASS, exit 0**, 6 \`SKIP\` | **~1 min** |`
- `sessions/session-44-summary.md:326` — "the last of each green, **42/42** in ~1 min and **48/48** in ~2–3 min"

Measured on this branch, at HEAD: `bash scripts/verify-session-44.sh` prints
`scope=full checks=49 pass=49 fail=0`; `VAJRA_GATE_SCOPE=fast` prints
`scope=fast checks=43 pass=43 fail=0`. `grep -c '^run_check '` = 49. So the map's `48` is **49** and
its `42` is **43**; the `6 SKIP` figure still reproduces.

The cause is exact and one commit old. `git show <c>:scripts/verify-session-44.sh | grep -c '^run_check '`:
`9cfa4f6` = **48**, `f0c04e2` = **49**. `f0c04e2` — *"make the class enforceable instead of promising
it — pass 7's one material finding"* — added `map-measurements-honest`, which runs in both scopes,
so adding the check that keeps the map's percentages honest is precisely what falsified the map's
headline check-counts one commit later. Nothing anywhere records the change.

Why this is material and not a nit:

- Requirement 13 says **"any surviving count is derived, not typed."** These are counts, typed, and
  they do not reproduce. Nothing derives them: the map names commands for the *run* tally two lines
  above and then types the *check* tally in the same breath.
- It is the same defect pass 6 raised and this session recorded as material — A10.2, *"a count that
  reproduced from neither command it named"* — and the session's own remedy for it was applied to the
  run count and not to the check count.
- It is the same class as pass 1's **F2** (*"a typed figure that does not reproduce"*), which this
  session's whole amendment apparatus exists to end.
- Nothing can go red. `map-measurements-honest` matches `[0-9]%` only; no other check reads the map's
  check-counts; `contract-at-head` counts requirement headings, not prose. The gate is green and the
  document the gate polices misstates the gate's own shape.
- The map is the artifact requirement 14 makes load-bearing, and the wrong figure sits in its
  **headline table** — the first thing a reader sees, presented as the measured result.

The fix is a command, not a sentence, in the spirit of A8.1: the table should read what
`grep -c '^run_check ' scripts/verify-session-44.sh` and the newest `run-meta.txt` say (49 / 43, and
`PASS + FAIL` for the fast-scope count), or `map-measurements-honest` should be widened to counts in
the requirement rows and headline table. Either way the numbers must stop being typed.

### (b) Residual nits

**2. [low-medium] Rule 2 of `map-measurements-honest` is satisfied by any of thirteen substrings, and
one of them is a substring of unrelated words.** The word list is matched with `grep -qiE`, so `old`
also matches `thresholds`, `hold`, `folder`, `cold`, and `was` also matches `waste`. Demonstrated
against the real function: `"The gate measures 73% of its wall clock, as was measured."` → **GREEN**;
`"The coverage thresholds leave the gate removing 73% of its measured check time."` → **GREEN**. The
natural phrasings *are* caught (a bare current claim goes red), and A11.1 is accurate that rule 2
alone was too loose and that the rows needed the structural rule — so this is a documented limit, not
a false statement. But the map's current claims live in prose (the headline section), and prose is
governed only by this list. Worth one honest sentence in the check's comment: rows are structural,
prose is a heuristic a common word satisfies.

**3. [low] Rule 1's row pattern is broader than A11.1 describes, and the message mislabels what it
caught.** A11.1 states the rule as rows `| 1 |` … `| 14 |`; the implementation matches any line
starting `| <digit>` and ending in a `|`-delimited cell, which also covers the map's 12-row
"Defects found by running the thing" table. Injecting a percentage into defects row 6 goes red with
the message `requirement row: …`. Over-strict in the safe direction, but a future session recording
a legitimate historical percentage in that table gets a failure that names the wrong thing.

**4. [low] `SECURITY.md:36` is ungrammatical: "If it off, see …".** The word "is" is missing. It was
introduced by `f0c04e2` — the pass-7 fix commit — in the exact sentence A11.2 says it re-ordered, so
the re-ordering shipped with a broken clause in the one public file that finding was about.

**5. [low-medium] The map's own header still enumerates the contract's amendments as far as A4.**
`sessions/session-44-summary.md:4-7` reads "… under its own `## Contract amendments`: **A1** at
`589a196` …, **A2–A4** at `3b8ec6f` …". The contract carries **A1…A11**. `732f968` brought
`.ai/TASK.md`, `.ai/SESSION-BOOT.md` and `.ai/ROADMAP.md` to "A1…A11" — "the amendment list reaches
A11 in all three files that name it" — and the map, last touched at `3a6d3f2`, was left naming a list
that stops seven amendments short. A8's remedy for exactly this defect was "every file that names the
list names it up to the last amendment", and A9.4 retracted the claim that any phrasing of such a list
stays true by itself. The map's later pass sections do record A5–A11 individually, which is why this
is a nit rather than a material finding — but the header is the map's contract line, not its history.

**6. [low] The route clause's two-intervening-word allowance still misses one ordinary phrasing.**
A11.2 raised the allowance so "Report this in a public issue" would be caught — verified caught, along
with "file a new issue", "open a blank issue", "post it in a public issue", "log an issue", "drop an
issue", "raise a GitHub issue" and "start an issue", while "do not open a public issue" and "open a
bug report through the form" stay legal. `"Tell me about it in an issue"` (three intervening words)
still escapes. Bounded heuristic, error direction is a miss rather than a false failure; worth one
more word of reach rather than a redesign.

**7. [low] `demo-session-44.sh`'s requirement-1 blurb is the one place that describes private
reporting without the hedge its requirement-2 blurb carries explicitly.** Case 2 says "points at GitHub
private reporting **AS A ROUTE, not as a promise**"; case 1 summarises `SECURITY.md` as "Now: private
reporting through the Security tab". The file itself is properly hedged (`SECURITY.md:32-36`,
`:44-53`), so this is a summary line, not a promise — but it is the asymmetry A10.3 was raised about.

### Confirmed, for the record

Freeze (A7.4 / A8.5): `909eaa4` rewrote requirement 7's **D4** row and requirement 8's body in place
— A8.5's correction of A7.4's "D4b" is right, the D4b row was unchanged context — before the first
cold feed and before the N1 rule existed, and it is disclosed with a `68662bf..HEAD` qualifier.
Sufficiency verified independently: all eight later prompt commits (`589a196`, `3b8ec6f`, `0b61a40`,
`5d0311a`, `57100e9`, `3dd62bc`, `9cfa4f6`, `f0c04e2`) contain **zero** removed lines — the freeze is
append-only from `909eaa4` onward, and A1…A11 are genuine appends under the amendments heading.
A9.3's ordering: `git log --all --diff-filter=A -- sessions/session-44-review.md` is empty right now,
`contract-freshness` fails closed exactly as A9.3 says it will, and A9.3 states the ordering as a
mechanism rather than claiming the commit exists — sufficient and accurate. A10.5's carried claims all
still hold: A9.1's three sweeps are complete at HEAD (the "closeout runs `full`" phrase survives only
in `.ai/KNOWLEDGE.md:430` inside the sentence that corrects it), and the live `gh api` output matches
`.github/REPO-SETTINGS.md` on all three rows. Requirement 12's "453/453 in 23 files" reproduces;
M4 holds.

Is the real scope "one narrow slice presented as the whole," or a faithful build of the whole
contract? **A faithful build.** Fourteen requirements of real work, each gated by a check I could
drive red, on a branch whose CI is green and whose `HEAD` is the pushed tip. The one defect left is
the last one this repo knows how to make: a number, typed into the fidelity map, one commit out of
date, that nothing can catch — in the commit that shipped the check meant to catch it.