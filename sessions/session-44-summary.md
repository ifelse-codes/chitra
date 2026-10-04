# Session 44 — fidelity map

**Session:** cleanup Batch 4 — OSS polish + the founder decisions D1–D6 (code session)
**Contract:** `prompts/44-task-oss-polish.md`, committed at `11a86ff` (the first commit, before
any work) and amended — never rewritten — under its own `## Contract amendments`: **A1** at
`589a196` (D5's removal set is all 81), **A2–A4** at `3b8ec6f` (the cold review's F2, M1, M2/M3).
**Branch:** `session-44-oss-polish` from `main` `1b6c17d` (S43 merge). **PR #65.**
**Delivery size: derive it** (`git rev-list --count main..HEAD`, `git diff --shortstat
main...HEAD`) — pass 3 found the typed commit count already stale, in the same document
that had just explained why typed counts rot. **11 deletions** are D3/D6 being made true —
see *pass 1* below.

## The headline: §4.9's "~60 minutes" does not reproduce — the gate measures ~2–3 minutes

The carried finding said the gate costs ~60 minutes and needs an opt-out. I built the opt-out
**and measured**, and the premise was wrong by roughly 20×:

| scope | checks | result | wall clock |
| --- | --- | --- | --- |
| `full` (default) | 48 | **48 PASS, exit 0** | **~2–3 min** |
| `fast` (`VAJRA_GATE_SCOPE=fast`) | 42 | **42 PASS, exit 0**, 6 `SKIP` | **~1 min** |

The skip list's own price, read out of the gate's per-check timings and printed by
`gate-scope-switch` itself, has moved between **71% and 80%** of measured check time across the
full runs in this session's artifacts. It is **not** quoted as one number here, because it moves:
`git rev-list`-style honesty applies to percentages too, and the exact figure of every run lives
in its own `.ai/verify/session-44/<timestamp>/run-meta.txt` and `gate-scope-switch.log`.

The first version of that line said **86%** and this map repeated it as a measured fact for two
commits. It was not: the selection kept the **oldest** full run on a tie, so the percentage was
frozen at the first run that ever produced it while looking like a live measurement. Pass 2 of
the cold review named it the fakest green of the delivery. It now selects the newest
**complete** run, prints which run it priced, and has a fixture proving the selection — see
*pass 2* below and amendment **A5.4**.

So the switch is real and worth having — but nobody should quote "~60 minutes" for this gate
again, because it was never the number **this** gate produces. The claim is recorded as measured
rather than inherited (amendment **A4** also corrects two phrases of requirement 10's own
description that did not survive measurement).

## The map — 14 of 14

| # | Requirement | State | Evidence |
| --- | --- | --- | --- |
| 1 | `SECURITY.md` | **SHIPPED** | `484c36b`. Supported versions, private disclosure route, no-SLA/no-bounty/latest-only, release pipeline in scope. `oss-surface-present` asserts the section headings and that **the same code is RED on `main`** |
| 2 | `CODE_OF_CONDUCT.md` | **SHIPPED** | `484c36b`. Contributor Covenant 2.1 + enforcement ladder, **no invented mailbox** — the check *fails* on any email address in the file, and the file says why it publishes none |
| 3 | Issue forms + PR template | **SHIPPED** | `eda166e` (bug + feature forms, `config.yml`, blank issues off) + `178553c` (`.github/PULL_REQUEST_TEMPLATE.md`) |
| 4 | CI badge on the workflow that runs | **SHIPPED** | `178553c`. The check reads every `actions/workflows/*.yml` URL out of `README.md` and requires `.github/workflows/<that file>` to exist; RED on `main`, where there is no badge at all |
| 5 | Coverage enforced in CI | **SHIPPED** | `5f21a1e`. `ci.yml#core` runs `test:coverage` **instead of** the plain `Test` step — suite runs once, four live thresholds, and the check **fails if a coverage service appears** |
| 6 | `engines` where they are provable | **SHIPPED** | `523102a`. Repo `>=26` / `>=9.12.3` **copied from `ci.yml`'s own pins**; package `>=22` stated in CONTRIBUTING *as a support policy, not a test result*, with the derivation (zero `node:` builtins, zero runtime deps, newest syntax `?.`). No `packageManager` field — `pnpm/action-setup@v4` already takes its version from `ci.yml`. **F1** (pass 1): `README.md` claimed Node **18+**, so the public repo carried two floors — corrected to the engines floor, and `engines-derived` now asserts README's number *is* the pin |
| 7 | D1–D6 answered and recorded | **SHIPPED** | `6024e0d` (D4), `9d88882` (D5), `589a196` (D4b + A1). **And made checkable:** `a58a26b` untracked the 11 files D3/D6 says stay local, `dc6b4dc` added `founder-decisions-covered`, which asserts D1 (six process dirs still tracked), D2 (the `## Git hooks (opt-in)` section + install line + `.claude/settings.json` hooks) and D3/D6 (nothing tracked, whole-directory ignore rules) — green here, **red on `main` for both halves**. A decision with no gate is a claim; pass 1 proved it |
| 8 | D4 scrub, provably mechanical | **SHIPPED** | `6024e0d`: 15 files, `numstat` N/N on every one, nothing added or deleted. `home-path-scrubbed` greps the live tree **and** runs the same pattern against the newest pre-scrub commit derived from history — a pattern that matched nothing would fail, not pass |
| 9 | N1: rule + a gate that can go red | **SHIPPED** | `d75a23a` + `dc6b4dc`. `reviewer/SKILL.md` (amend, never rewrite) + `contract-freshness` in `verify-closeout.sh`, split into **two pure functions**. Clause (a): `contract-freshness-teeth` extracts the body and runs it twice — **green on S43**, **red on S42**, naming the commit it then proves touches the contract. Clause (b): pass 1 found it could **not go red** (N2, below); the teeth check now drives it in *both* line orders against synthetic reviews, and the pre-fix logic is reproduced as rc=0 where the contract demands 1 |
| 10 | §4.9: scope switch, measured | **SHIPPED** | `b9d8791` + `e62808c` + `51bf7c3`. `gate-scope-switch` unit-tests the switch, requires every skip-list name to be a real check, forbids skipping anything S44 owns, and prices the list from measured per-check timings — **71–80%** of measured check time across the full runs on disk, never quoted as one number because it moves (pass 2 found the old fixed 86%). `pick_timings_file` takes the newest **complete** run, prints which run it priced, and is driven over a fixture so the selection can go red. `check_verify_demo_scripts` also asserts the default is `full` (pass 1, M3) |
| 11 | D5 overrides stripped, own-commit regen | **SHIPPED** | `9d88882` + `589a196`. **81 → 0**; `pnpm install --lockfile-only` left `pnpm-lock.yaml` byte-identical, then full install, `--frozen-lockfile`, typecheck and **453/453** all exit 0. A1 records why the removal set is 81, not the 11 the literal wording named |
| 12 | Re-prove the product from live facts | **SHIPPED** | Gate: `fresh-clone-build-no-env`, `core-tests` (453), `core-typecheck`, `root-typecheck`, `coverage-gate-passes`, `contributing-coverage-numbers-real`, `example-runs`, `chart-drift`, `browser-qa-catalog-pages` — all PASS |
| 13 | Re-sync `.ai/`; counts derived, not typed | **SHIPPED** | `37511d0`, `daf9c4c`, `9efc28c`. `ai-files-describe-s44`, `ai-names-no-deleted-tree`, `test-count-propagated` |
| 14 | Fidelity map + independent review | **SHIPPED** | This file + `sessions/session-44-review.md`. Pass 1 came back **REJECT** (12 SHIPPED · 2 PARTIAL) and is documented below; pass 2 re-reviewed the corrected diff under a fresh inputs hash |

## The counterfactual, and what it actually proves

`s43-gate-verbatim-goes-red` pulls **S43's own `ai-files-describe-s43` body out of
`scripts/verify-session-43.sh`** with `awk` and `eval`s it here. It must exit non-zero, and for
the *named* reason: S43's check hard-codes `.ai/SESSION = 43` and the branch
`session-43-docs-weight`, so S44's re-sync breaks it by construction. The port re-expresses it
as `ai-files-describe-s44`.

Extracting the body (rather than transcribing it) is the point: an edit to S43's gate follows
through, so this cannot be satisfied by a stale copy of a check nobody runs.

Every other new check carries a counterfactual that needs **no synthetic state** — the OSS and
decision checks are run twice, green on this branch and **red on `main`**, where none of it
exists. Breaking nothing to prove a check works is better than breaking something.

## Defects found by running the thing, not reading it

| # | Defect | Caught by |
| --- | --- | --- |
| 1 | **An apostrophe terminated a single-quoted check body.** `S44's` inside `bash -c '…'` closed the string; the rest of the check executed in the main shell under `set -u` and died on `$n: unbound variable`. The same class as S42's findings — I wrote it anyway | First fast run |
| 2 | **`charts-format-only` called a clean tree "vacuous."** S43's check *requires* a non-empty diff (it proved S43's reformat was pure Prettier). S44 changes nothing under the LOCKED dirs, so the inherited premise was false. Re-expressed as `charts-untouched` + a derived probe commit | First fast run |
| 3 | **`no-live-ref-to-dead-trees` enumerated gates and demos (41, 42, 43)** and flagged the new one for quoting S42's own check bodies. Exemption is now **discovered by class** from the index | First fast run |
| 4 | **Two new sites displayed the canonical count** — the PR template typed it (a stale number waiting to happen) and the gate's own inherited comments. Template de-typed; the own-gate exemption extended to 44 | `test-count-propagated` |
| 5 | **The badge check compared `ci.yml` against the repo root.** The URL is `…/actions/workflows/ci.yml`; the file is `.github/workflows/ci.yml`. It was failing on a correct badge | `oss-surface-present` |
| 6 | **`date +%s` is second-granular on macOS**, so every fast-scope check cost 0s and the scope check correctly reported that `fast` removed nothing | `gate-scope-switch` |
| 7 | **The timings pick read the wrong file.** A line-count tie (41 = 41) was broken by `sort -rn`'s last-resort comparison putting `latest/` above a timestamp, so it priced an old fast run. `latest` is a symlink and can name the run that is *not* in progress | `gate-scope-switch` |
| 8 | **The selection loop clobbered the line counter** (`41 + 47 = 88` "checks" in its own message). `skipped`/`total` were right; the count was not | Reading the message it printed |
| 9 | **`about:` in YAML contained an unquoted `: `** — Prettier refused to parse the issue-template config | First `prettier --write` |
| 10 | **`printf … \| grep -q` under `set -o pipefail` reports SIGPIPE as "no match."** `grep -q` exits the instant it matches, the `printf` on the left of the pipe takes SIGPIPE, the pipeline returns **141**, and `\|\|` reads it as failure. The new decision check failed on a `.claude/settings.json` that *does* contain `"hooks"`. Every such pipe in the new code is a here-string now, and each failure names what it could not read | First full run |
| 11 | **Two listings fused into one line.** `$( )` strips trailing newlines, so concatenating two `ls-tree` outputs merged line 3 with line 4 and the counterfactual claimed **10** files where there are **11** | Reading its own message |
| 12 | **An unconditional `$'\n'` append is not a non-empty list.** The fix for row 11 appended a newline whether or not `lsat` returned anything, so with both directories clean `hits` was `"\n"` — non-empty — and the check reported `still tracked:` over three blank lines | First full run, after the row-11 fix |

## Cold review, pass 1: **REJECT** — 12 SHIPPED · 2 PARTIAL

An independent reviewer was fed only this contract and the delivery diff, and told that REJECT
is a legitimate answer. It was the answer. Neither PARTIAL survived reading:

| finding | what was wrong | fixed in |
| --- | --- | --- |
| **N1** (high) — a founder decision recorded with a false premise | The contract says D3/D6 = "they stay local and **untracked**, so the flip publishes neither." Eleven files **were** tracked (3 mockups + the `sre-dashboard` subtree), `.gitignore` covered only some patterns, and its own comment still said the question was unanswered. At S45 they would have gone public while the record said they would not. Aggravating: no gate covered D1/D2/D3/D6 — demo row 7 cited two checks that prove D4 and D5 | `a58a26b` (untrack + whole-directory ignore), `dc6b4dc` (`founder-decisions-covered`, green here / red on `main` twice over) |
| **N2** (medium) — a required gate failure mode that cannot fail | `contract_freshness_core` read the final hash with an unanchored `Review-Inputs-SHA`, which also matches `Review-Inputs-SHA-Pass-1:`. A review that prints Pass-1 **first** made the two compare equal, so clause (b) returned 0 where the contract demands 1 — demonstrated in a scratch clone: `rc=0` for Pass-1-first, `rc=1` for Pass-1-last. Whether a gate passes must not depend on which line was typed first | `dc6b4dc` — two pure functions, anchored pattern, teeth check drives **both** orders |
| **M1/M2/M3** — contract prose that is not true | req 13 vs req 8 contradict each other over the scrub's `sessions/` edits; "the two clone installs" (there is one); "the closeout still runs `full`" (nothing invokes the gate) | `3b8ec6f` — **A3**, **A4** appended, never edited in |
| **F1** — two Node floors in the public repo | `README.md:80` said "Requires Node.js **18+**" one screen from `engines >=26` | `3b8ec6f` + `engines-derived` now asserts it |
| **F2** — a typed figure that does not reproduce | "16 of 565 commits" appears in seven places; neither number derives (`461` reachable from `HEAD`, `585` across all refs, `367` whose tree matches, `11` whose diff touches a line) | `3b8ec6f` — **A2** records the real derivations; every surviving site derives instead |
| **M4** — CI green on the pushed tip, not on HEAD | The branch was one commit ahead of `origin` | pushed before pass 2 |

Pass 2 re-ran the whole review against the corrected diff under a fresh inputs hash. It also
returned **REJECT** — see below. A review that cannot return REJECT is not a review, so both
rejections are recorded here rather than quietly overwritten.

## Cold review, pass 2: **REJECT** again — the fakest green was my own

Pass 2 was given the same cold inputs (contract + delivery diff), the six pass-1 claims to
verify, and permission to reject. It did, and it was right about something I had just
finished building:

| finding | what was wrong | fixed in |
| --- | --- | --- |
| **the fakest green** (medium) | `gate-scope-switch` printed "*fast removes 86% of this gate's own wall clock*" as a **measured** figure. It was not: it picked the timings file with the most lines and kept the old one **on a tie** — and every full run writes the same number of lines, so the number was frozen at the first full run ever made. The reviewer's own full run measured **73%** while the gate still printed 86% | selection is newest-first and prints its source run; `pick_timings_file` is extracted and driven over a fixture, so "newest wins" is a fact the check can lose on (below) |
| **the pass-1 review was never committed** (medium) | `contract-freshness` clause (a) resolves the commit that **first added** the review file and fails closed without one — pass 1's report was left untracked, so the N1 rule this session ships had no attested feed for one commit | amendment **A5.2** discloses it; pass 3's report is committed, and every amendment after it is checkable |
| **req 13 violated by the F2 fix** (medium) | while correcting "16 of 565", four `.ai/` files carried fresh typed counts — "~146 process files" (truth: every tracked process file, `git ls-files … \| wc -l`) and "~30 changed files / ~14 commits" | each site now names the command instead of the number |
| **`A1`-only leftovers** (low/med) | `.ai/TASK.md` and `.ai/ROADMAP.md` still said the contract carries only **A1**; `SESSION-BOOT.md` was right | both corrected to A1–A4 |
| **two docs pointed at a closed door** (low/med) | `blank_issues_enabled: false`, yet `SECURITY.md` told a reporter to "say so in a **public** issue" and the CoC sent every non-secret report to an issue — a route that does not exist for anyone outside the maintainers | amended **A6**; both docs route to Discussions/private reporting, and `oss-surface-present` now fails on any doc that sends the reader to the tracker while blank issues are off (the pattern is broader than the word "open", because the defective sentence never used it) |
| **M4 half-fixed** (low/med) | HEAD was one commit ahead of `origin` when pass 2 looked | pushed |
| **stale pointer** (low) | `CONTRIBUTING.md` cited `verify-session-43.sh#contributing-coverage-numbers-real`; the live check is in the S44 gate | corrected, with the reason |
| **phrase-coupled clauses** (low) | two fact-based checks also grep for a disclosure phrase, so rewording a doc can turn a check red while the fact is untouched | the label assertions now say in their message that only the wording moved |

Pass 2 also confirmed, independently: the contract freeze is clean (**0 deletions** in the
numbered requirements from `68662bf` to HEAD; A1–A4 are genuine appends), the D4 scrub is
mechanical (15 files, N/N numstat), the N1 gate is green on S43 and red on S42 **naming the
commit that answers it**, and req 6's derivation facts hold (zero `node:` builtins, zero
runtime deps, no post-ES2020 syntax).

## Cold review, pass 3: **REJECT** again — my own fix was built on a false premise

Pass 3 was given the pass-1 and pass-2 claims to re-verify and the same permission to reject.
**10 SHIPPED · 4 PARTIAL · 0 NOT-BUILT.** It found the most serious thing in this session, and it
was mine:

> I documented as fact that "`blank_issues_enabled: false` means the issue tracker is not a route
> that exists for anyone outside the maintainers", wrote a gate clause enforcing that, and then
> **rerouted both public docs to GitHub Discussions — which is off.**

`gh api repos/ifelse-codes/chitra --jq .has_discussions` → **`false`**. I moved readers from one
closed door to another while writing an amendment that called the first door closed, and the
clause forbade the one true sentence while permitting the two false ones.

| finding | what was wrong | fixed in |
| --- | --- | --- |
| **A6's premise** (high) | the clause enforced a false invariant across four public docs | amended **A7**: the invariant is now *no doc may route to a channel the recorded settings say is off*, checked offline against a new tracked record, `.github/REPO-SETTINGS.md`, which holds each setting **with the command that re-derives it**. Both clauses proven red on the old wording, green on the new |
| **the CoC's routes** (high) | it named two routes and neither was established; one ("reaches the maintainers directly") was an unverified claim | both docs now state plainly that the private channel may not exist, and give the only honest fallback — a report with no detail, asking for a private route. Recorded as a **pre-flip task for S45** in `.ai/STATE.md`, because it is a repository setting, not a file |
| **the freeze claim** (med) | "the freeze is clean" was asserted unqualified; `909eaa4` rewrote req 7's D4 row and req 8's body **before** the first feed and before the N1 rule existed | **A7.4** discloses it; the map's claim is scoped to `68662bf..HEAD` |
| **A4's "closeout runs full"** (med) | the sentence A4 declares untrue survived in the gate header, `STATE.md` and `KNOWLEDGE.md` | all three now say what is enforced: the default is `full`, and nothing ever *invokes* the gate with a scope |
| **a typed count, again** (med) | the map said "28 commits" (actual: more) — in the document that had just explained why typed counts rot | the map derives its own size now |
| **the demo's typed count** (med) | `demo-session-44.sh` printed "~146 process files" under a header claiming counts are derived | it counts `git ls-files` at run time |
| **the fixture's error message** (low/med) | two of its four traps were caught by the completeness guard, not the guards the message named | each trap now exercises its own guard; the message names only what it checks |
| **`main` cited at `49e1ee2`** (low) | that is the S42 merge as named in the S43 records; `main` is `1b6c17d` | **A7.3** — the `.ai/`/`prompts/` records cite `main` by SHA, several times, and any citation moves in a rewrite; read `git rev-parse main` |
| **invented mailbox** (low) | the check ran on the CoC only; requirement 1 forbids one in `SECURITY.md` too | both files, one rule, proven red by injecting `security@example.com` |

Pass 3 independently re-confirmed pass 2's fixes, including that **the pre-fix selection logic
fails the new fixture** and that the live figure moved 86% → 71% and names its run.

## Honest gaps

- 🔴 **D4b is not done, by decision.** The **tree** is clean; **`main` still carries the home
  path**, so the purge is still required — and a rewrite moves **every** commit reachable from
  `HEAD` (`git rev-list --count HEAD`, derived; the contract's typed "16 of 565" was wrong and
  is corrected in **amendment A2**). A rewrite moves every recorded SHA (`.ai/` cites `main` at
  `49e1ee2`), so it
  is a pre-flip operation for **S45**, not a cleanup commit. Contract req 7 and this file both
  say so; nobody should read "D4 done" as "history clean".
- 🔴 **The scrub changed two historical cold inputs.** `prompts/10-…` and `prompts/42-…` sit in
  the *prompt half* of `canonical_inputs_sha`, so **S10's and S42's recorded
  `Review-Inputs-SHA` no longer match their contracts' current bytes.** Disclosed in contract
  req 8 *before* the scrub, not discovered after; no live gate recomputes them — and the new
  `contract-freshness` check is precisely what makes this class of change visible from here on.
- 🟠 **`gate-scope-switch` fails closed without a full run's timings.** It reads the gate's own
  `timings.txt`, which is gitignored local state: a fresh clone gets an instruction, not a
  green. Same class as the `latest` symlinks; disclosed rather than softened.
- 🟠 **Requirement 3's "routes that actually exist" is now enforced against a *recorded* fact, not
  a live one.** `.github/REPO-SETTINGS.md` holds `has_issues`, `has_discussions`, `private` and
  the blank-issues rule with the `gh api` command that re-derives each, and `oss-surface-present`
  fails if a public doc routes to a channel recorded as off. That catches a stale *document*; it
  cannot catch a setting that changed after the record was written. The record is dated and the
  commands are printed in it, so the failure mode is "nobody re-derived it", not "the gate
  believes it".
- 🟠 **Whether `https://chitra.iifelse.com` and the npm page resolve is a network fact**, which no
  offline gate can own; pass 2 resolved both by hand. The advisories link additionally needs the
  feature enabled, which is now a named pre-flip task.
- 🟠 **`minimumReleaseAgeExclude: stripe-replit-sync`** is the same species of Replit-scaffold
  cruft D5 removed, but it is not an `overrides` entry, so req 11 did not reach it. Named in
  A1 rather than smuggled in.
- 🟠 **Seven pre-existing dead docs deps** remain (`framer-motion`, `react-icons`,
  `@tanstack/react-query`, `zod`, `date-fns`, `@tailwindcss/typography`, `tw-animate-css`) —
  out of scope here, still on the board.
- 🟠 **`package >=22` is a policy, not a measurement.** No suite has ever run on Node 22.
  CONTRIBUTING says that in those words and the gate checks for the phrase; the honesty is in
  the label, not in the number.
- 🟠 **S40's governance rows are untouched**: `required-crew` (this session needs the same
  founder waiver S38/S39/S42 recorded), the vacuous `check_ground_truth_no_code`, the cost
  gate that greps a heading, and **S16**.
- 🟠 **The product is unchanged and unproved-for-new-reasons**: 453/453 was already true. This
  session's proof is *non-regression*, not new behaviour — no file under `packages/core/src/`
  changed, and `charts-untouched` says so with a probe that can fail.

## Cost Tracking

One opencode session · **5 ballots + plan approval** (D1, D4, D4b, the D2/D3/D5/D6 bundle, the
N1 + §4.9 scope) with commits pre-approved · **14 requirements** · delivery size derived as
above, never typed · **11 deleted** (D3/D6 made true; the files were kept on disk and only
untracked) · **0** product-code changes · **0** new product tests (453
stays 453) · **0** lockfile changes (the D5 regen produced an empty diff — recorded as A1) ·
**0** releases · **0** npm secrets · **0** new recurring infra (coverage rides the existing
`core` job; no coverage service) · **1** `--no-verify` commit for the 15-file mechanical scrub,
authorised by the contract because the 3-file atomic cap cannot express it · gate runs: **13
fast + 13 full + 1 untimed**, a count read out of `.ai/verify/session-44/*/run-meta.txt` rather
than remembered — the last of each green, **42/42** in ~1 min and **48/48** in ~2–3 min (seconds
vary with load; every run's own figure is in its `run-meta.txt`), with the
red runs left on disk where they can be read · token cost unmeasured (billed to the founder's
plan) · npm cost $0.

Counts above are as of this map's own commit (the review commit follows it, so the delivery
total is `git diff --shortstat main...HEAD`, not a number typed here); the +/- line was dropped
on purpose — it moved every time this file changed, which is exactly the defect requirement 13
is about.
