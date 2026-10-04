# Session 44 — fidelity map

**Session:** cleanup Batch 4 — OSS polish + the founder decisions D1–D6 (code session)
**Contract:** `prompts/44-task-oss-polish.md`, committed at `11a86ff` (the first commit, before
any work) and amended — never rewritten — under its own `## Contract amendments`: **A1** at
`589a196` (D5's removal set is all 81), **A2–A4** at `3b8ec6f` (the cold review's F2, M1, M2/M3),
and **A5…A11** appended across the seven review passes that followed — read the section for the
list; this summary has now been caught going stale three times.
**Branch:** `session-44-oss-polish` from `main` `1b6c17d` (S43 merge). **PR #65.**
**Delivery size: derive it** (`git rev-list --count main..HEAD`, `git diff --shortstat
main...HEAD`) — pass 3 found the typed commit count already stale, in the same document
that had just explained why typed counts rot. **11 deletions** are D3/D6 being made true —
see *pass 1* below.

## The headline: §4.9's "~60 minutes" does not reproduce — the gate measures ~2–3 minutes

The carried finding said the gate costs ~60 minutes and needs an opt-out. I built the opt-out
**and measured**, and the premise was wrong by roughly 20×:

| scope | shape | result | wall clock |
| --- | --- | --- | --- |
| `full` (default) | every check (`grep -c '^run_check ' scripts/verify-session-44.sh`; **no number here**) | **all green, exit 0** | **~2–3 min** |
| `fast` (`VAJRA_GATE_SCOPE=fast`) | the same checks minus the skip list | **all green, exit 0**, the skip list `SKIP` | **~1 min** |

Neither the check count nor a pass ratio is written down, because both move the moment a check is
added — and the commit that added pass 7's fix is exactly what falsified the numbers this table
used to carry. Read the live figures from the run itself: the gate prints `scope=… checks=… pass=…
fail=…` at the end of every run.

The skip list's own price is read out of the gate's per-check timings and printed by
`gate-scope-switch` itself, which prints **no figure here** — not a number and not a range.
Pass 5 rejected a range quoted from the artifacts, and pass 6 rejected the replacement for
typing a wider range in the very sentence that promised not to: the share moves run to run, and
every run's own number is in its own `.ai/verify/session-44/<timestamp>/gate-scope-switch.log`
next to the run directory it priced. Read it there.

One correction pass 6 forced, about what that share is a share *of*: the denominator is the sum
of the gate's **measured per-check seconds**, not the wall clock it prints at the end — setup and
the summary rewrite are in neither. Those seconds are still wall-clock measurements, so the share
varies with machine load; that is why it is quoted nowhere.

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
| 10 | §4.9: scope switch, measured | **SHIPPED** | `b9d8791` + `e62808c` + `51bf7c3`. `gate-scope-switch` unit-tests the switch, requires every skip-list name to be a real check, forbids skipping anything S44 owns, and prices the list from measured per-check timings — a share of measured check time that **moves run to run**, so no figure is typed here: pass 2 found the old figure frozen at one value, pass 5 caught this map re-quoting a range, and pass 7 caught the range still sitting in *this very cell* while A10.1 promised it was gone. The check names the run it priced; read the number there. `pick_timings_file` takes the newest **complete** run, prints which run it priced, and is driven over a fixture so the selection can go red. `check_verify_demo_scripts` also asserts the default is `full` (pass 1, M3) |
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
| **the pass-1 review was never committed** (medium) | `contract-freshness` clause (a) resolves the commit that **first added** the review file and fails closed without one — pass 1's report was left untracked, so the N1 rule this session ships had no attested feed for one commit | amendment **A5.2** discloses it. Its own remedy sentence was written before the fact and was **false when written** — pass 4 caught that, and the correction is **A8.1**: the report is committed *after* the amendments it is checked against, and the way to verify it is `git log --diff-filter=A -- sessions/session-44-review.md`, not a sentence in this map |
| **req 13 violated by the F2 fix** (medium) | while correcting "16 of 565", four `.ai/` files carried fresh typed counts — "~146 process files" (truth: every tracked process file, `git ls-files … \| wc -l`) and "~30 changed files / ~14 commits" | each site now names the command instead of the number |
| **`A1`-only leftovers** (low/med) | `.ai/TASK.md` and `.ai/ROADMAP.md` still said the contract carries only **A1**; `SESSION-BOOT.md` was right | corrected — and **again** after pass 3, which found two files had been left at A1–A4 while the contract was already at A1–A7. They now name the list up to the last amendment — and pass 5 retracted my claim that any phrasing of it "stays true": it stays right because each pass re-checks it |
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

## Cold review, pass 4: **REJECT** — and the fakest green was a sentence about my own compliance

**11 SHIPPED · 3 PARTIAL · 0 NOT-BUILT.** Pass 4 did what a reviewer is for:

| finding | what was wrong | fixed in |
| --- | --- | --- |
| **a false sentence of mine** (high) | amendment **A5.2** claimed "pass 3's report is committed, and every amendment after it is checkable". No review report was committed — and `verify-closeout.sh 44` said so itself: `contract-freshness` **FAIL**, *"no commit in history adds sessions/session-44-review.md — freshness cannot be evaluated (fail closed)"*. A false claim about compliance, inside the amendment that discloses non-compliance | **A8.1** replaces the sentence with the **command** that proves it, and the report is committed after the amendments it is checked against. A promise cannot be audited; `git log --diff-filter=A -- sessions/session-44-review.md` can |
| **the same unverified claim, five places** (high) | A7 fixed the two prose docs; "routes private reports through the one private channel that reaches maintainers" also survived in `STATE.md`, `TASK.md`, `ROADMAP.md` and the demo — and `gh api …/private-vulnerability-reporting` returns 404, which is also what an account without admin access gets | **A8.2** — all four now name it a route, not a promise, and point at the recorded settings |
| **an invariant wider than the gate** (med) | `REPO-SETTINGS.md` claimed the gate "reads the two `has_` rows"; it reads one, plus `blank_issues_enabled` from `config.yml` | **A8.3** — the file states exactly what is enforced and requires future widenings to update that paragraph in the same commit |
| **the route a visitor clicks first** (med) | the advisories contact link offered `security/advisories/new` with no hedge — the one link that may 404, and the reason req 3 came back PARTIAL | **A8.4** — it carries the same hedge as the docs, including what to do when it fails |
| **typed counts again** (med/low) | the map's gate-run count was stale by one run; the demo printed `15 tracked files` as a literal under a header naming derived counts | **A8.6** — both derive: `run-meta.txt` globbed, `git show --numstat` on the commit `git log -G` selects |
| **the amendment list going stale** (med) | two files still said the contract carries **A1–A4** when it carried A1–A7 | **A8** — all three name the list up to the last amendment. Pass 5 retracted my "the only way that stays true" (see **A9.4**): no phrasing stays true by itself, the list stays right because each pass re-checks it |

Pass 4 also re-derived the settings itself (`has_discussions: false` and the two others match the
record) and found **A7.4's D4b/D4 slip**, corrected in **A8.5**.

## Cold review, pass 5: **REJECT** — the fakest green was the *scope* of my own gate clause

**11 SHIPPED · 3 PARTIAL · 0 NOT-BUILT.** Its fakest green: `oss-surface-present` stated its
invariant as a **class** in the comment ("no public doc may route to a channel the recorded
settings say is off") while the code looped over **four filenames** — and
`.github/ISSUE_TEMPLATE/bug-report.yml` was doing exactly what the class forbids, unhedged.

| finding | what was wrong | fixed in |
| --- | --- | --- |
| **three "fixed" claims that were not** (high) | the "closeout runs `full`" sweep touched the gate header and one document, leaving the phrase in `STATE.md` and `KNOWLEDGE.md`; the private-route sweep missed `KNOWLEDGE.md` — **six** files carried the claim, not five; the advisories hedge covered `config.yml` and not `bug-report.yml` | **A9.1** — all three corrected, and the lesson recorded: a sweep described as "all sites" is a claim about a set nobody enumerated, and two of three were wrong |
| **the clause's scope** (high) | comment said a class, code said four files | **A9.2** — the loop now names the four public docs **and** the three issue-template files, states its exclusions, and a **third clause** requires any file offering `security/advisories/new` to hedge it in the same file, because that route's recorded status is *unknown* |
| **the range this map quoted** (med) | "moved between 71% and 80%" — the full runs on disk read 60%, 66% and 78%, and one of pass 5's own runs printed **87%** | **A9.5** — no figure or range is typed here; the share is wall clock on a loaded machine, and each run's own number sits in its own log |
| **A8.1's remedy could not be true yet** (residual) | it described the review's future commit as a fact — the same species pass 4 found in A5.2 | **A9.3** — the ordering is the mechanism; the fact is the `git log --diff-filter=A` command |
| **"the only way that stays true"** (residual) | retracted: no phrasing of an amendment list stays true by itself | **A9.4** |
| **an untracked home path** (residual) | `project-status.html` sat untracked *and unignored* carrying `/Users/<name>/…` — invisible to a gate that greps tracked files, one `git add` from being published | kept on disk, now ignored beside the other local HTML reports |

- 🔴 **This session has been rejected five times, and the last three rejections were of my own
  fixes.** Passes 3, 4 and 5 found no new work; they found work I had *just* done — built on an
  untrue premise (**A6**'s "closed tracker"), or claimed in writing when it was not true
  (**A5.2**, **A8.1**), or narrower than the invariant its own comment described (**A9.2**). The
  correction is not better sentences. It is: every claim about this repo's own compliance names
  the **command** that verifies it; every claim about remote state names the **recorded setting**
  and the command that re-derives it; and every sweep over "all sites" either enumerates them or
  says how it enumerated them. Read any bare assertion in this map the way pass 4 read one.
- 🟠 **The map is one review behind by construction.** Its amendments section is complete through
  **A9**; a pass that demands A10 leaves the map's summary of the amendment list stale again —
  which is the defect it has now been caught for twice, and the reason the list appears in three
  `.ai/` files that each pass re-checks rather than in one place that nobody re-reads.

## Cold review, pass 6: **REJECT** — 13 SHIPPED · 1 PARTIAL, and every finding in the honesty layer

The first pass to find **no new work at all**. All three material findings are about how this
session describes itself — which is where every remaining defect now lives.

| finding | what was wrong | fixed in |
| --- | --- | --- |
| **the remedy was false in the sentence stating it** (high, req 10) | **A9.5** promised the map would quote no figure or range; the map typed `60% to 87%` and `(60–87% observed)` — the second **inside the sentence denying the practice**. It also misdescribed the denominator: the share is over the **sum of measured per-check seconds**, not the gate's printed wall clock, as the check's own comment says | **A10.1** — no figure and no range appears anywhere; the denominator is stated correctly; and the rule added: *a remedy sentence is subject to the rule it announces* — "we no longer print X" is a printed claim about X, and when it fails, the fix is to delete the number, not widen it |
| **a count that reproduced from neither command it named** (med, req 13) | "13 fast + full runs" sat beside two commands that today print different numbers in both directions; A8.6 had claimed this count was fixed | **A10.2** — the commands stay, the number goes |
| **the unhedged claim of resolution** (med, reqs 3 + 13) | `STATE.md`, `TASK.md` and the demo still called `config.yml`'s three contact links ones that "resolve", while the settings record the advisories route as **unknown**. A9.1 swept the *promise* out of six files and missed the *claim of resolution* in three more | **A10.3** — all three name two links resolved by hand and the third hedged |

**A10.4** takes pass 6's seven nits rather than deferring them: the route clause's verb list now
covers `report`/`submit`/`log`/`post`/`drop`/`leave`; the scope comment names the one tracked file
deliberately excluded (the PR template) and says what must happen if it ever names a route;
`REPO-SETTINGS.md` lists all three clauses *and what none of them checks*; a comment claiming
requirements `1..10` while the code compared `1..14` now says so and notes the code was right;
the `core-tests` count proxy carries a comment saying what it really is.

Pass 6 also independently confirmed — and that is worth more than another fix — that the freeze is
append-only from `68662bf`, A9.1's three claims are true at HEAD, all three route clauses go red
on wording a reader would plausibly write, pass 2's fixture genuinely rejects the pre-fix
selection logic, the settings record matches live `gh api`, the untracked-home-path class is
closed, and M4 holds. It ran the gate in both scopes and the suite (453/453
in 23 files) and the closeout, and recorded its own figures rather than quoting this map's.

## Cold review, pass 7: **REJECT** — one material finding, and it was the string A10.1 promised was gone

**12 SHIPPED · 2 PARTIAL · 0 NOT-BUILT.** Pass 7 found **one** material item. It is quoted here
verbatim because the whole point is what it says about this map:

> **A10.1 is the fakest green:** it announces a *rule* ("a remedy sentence is subject to the rule
> it announces") and discharges it with a prose promise about its own bytes. **No gate can go red
> because the map quotes a figure.** Fourth instance of the class (A5.2 → A8.1 → A9.5 → A10.1).

The requirement-10 evidence cell still printed the range, inside the sentence that said no figure
was typed there. Three passes had "fixed that" before — **A5.2** claimed a commit that was not
made, **A8.1** described a future commit as a fact, **A9.5** promised no figure and printed two —
and in three of those four cases nothing could have gone red, because nothing checks prose against
itself.

**So the fix is a gate, not a sentence.** `map-measurements-honest` (below) makes the class
enforceable, and the first version of that rule — "a percentage must carry a history word" — was
**too loose**: pass 7's exact string sits in a cell saying "moves run to run", so the word list
waved it through. The same species as the clause that forbade the word "open" and missed a
sentence that never used it. The requirement rows now get the blunt structural rule — **no
percentage inside `| 1 |` … `| 14 |`** — and the word list keeps only the prose around them.

**A11.2** takes pass 7's nits: `ROADMAP.md`'s carried §4.9 row no longer quotes the ~60-minute
premise this session measured; `SECURITY.md` qualifies the private-reporting switch *before*
promising what the channel does; the route clause catches "Report this in a public issue" (the one
ordinary phrasing its verb list missed); the demo's template count carries a comment saying it is
counted.

Pass 7 independently rebuilt pass 2's fixture and ran the **old** picker against it (picks the
oldest run; the fixture forbids it), re-derived the settings from `gh api`, and confirmed the
freeze at **0 deletions / 272 insertions** from `68662bf`.

## Cold review, pass 8: **REJECT** — the fix for pass 7's finding is what falsified the map

**13 SHIPPED · 1 PARTIAL · 0 NOT-BUILT.** One material finding, and it is the sharpest thing any
pass has said about this session:

> The cause is exact and one commit old: `git show <c>:scripts/verify-session-44.sh | grep -c
> '^run_check '` gives 48 at `9cfa4f6` and 49 at `f0c04e2` — the commit that added
> `map-measurements-honest`, i.e. **the fix for pass 7's material finding, is what falsified the
> map's headline numbers.** Same defect as A10.2 and F2, in the document whose newest gate exists
> to prevent it.

The map's headline typed `48` / `48 PASS` and `42` / `42 PASS`. Adding a check moved both, and
the check added at `f0c04e2` matched `[0-9]%` only, so nothing could go red.

**Rule 3** is the answer, and it took three attempts — which are recorded because the attempts are
the lesson (**A12.1**):

1. banning `N/N` anywhere in the map fired on the suite's own `453/453`, which is immutable and is
   the delivery's evidence — a rule like that has to be deleted, not obeyed;
2. flagging the gate's check count, typed as a literal in the check, is wrong the same way the map
   was — so `$n` is **derived at check time**, and the check fails closed if it cannot derive it;
3. letting a history word excuse the count laundered the map's own "**not typed here**" through the
   word `typed` — so the derived count has **no escape hatch**: a historical sentence names the
   *old* count, which by definition is not `$n`.

Two of my own bugs surfaced while proving it, both the species passes 2–7 kept catching: the first
version used `printf | grep -q`, and under `pipefail` the SIGPIPE made **every** long line read as
"no match" — the check passed on exactly the lines it exists to catch; and the harness I proved it
with could not run, because an empty `$n` made the rule degenerate.

**Then it stayed broken after I had "proven" it** (**A12.3**), which is the part worth keeping. The
percentage test was a `case` pattern whose closing paren anchored it to end-of-line, so the
counterfactual sentence quoted here — *"the gate measures <n>% of its own wall clock"* — sailed
through, at `44d598a`. And the history-word rule was laundered by the map's own account of what
the check used to match, which had to name the old rule to describe it. Both are fixed
structurally (a regex; a commit-SHA citation as the escape).

**The pattern across A12.1–A12.3 is the finding:** every one of these rules shipped **green while
being unable to fail on the sentence it was written for**, and each was caught by re-running a
counterfactual rather than by reading the code. A green you have not re-earned is decoration.

Pass 8 also rebuilt `pick_timings_file`'s fixture outside the gate in four directions (current →
newest complete; pre-A11 → the oldest, which the fixture rejects; each trap caught by its own
guard; the in-progress run unpriceable), confirmed the freeze is append-only with **zero removed
lines** across eight later prompt commits, and drove the route clauses red on eight plausible
phrasings while leaving the right advice legal.

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
authorised by the contract because the 3-file atomic cap cannot express it · gate runs: counted by
`ls -1d .ai/verify/session-44/*/ | grep -v latest | wc -l`, split by scope with
`grep -ho '^scope=[a-z]*' .ai/verify/session-44/*/run-meta.txt | sort | uniq -c`, and **not typed
here** — pass 6 found this sentence reproduced from neither command it named — the last of each
green, both scopes in ~1–3 min (the pass ratios are not typed here; every run prints its own —
seconds
vary with load; every run's own figure is in its `run-meta.txt`), with the
red runs left on disk where they can be read · token cost unmeasured (billed to the founder's
plan) · npm cost $0.

Counts above are as of this map's own commit (the review commit follows it, so the delivery
total is `git diff --shortstat main...HEAD`, not a number typed here); the +/- line was dropped
on purpose — it moved every time this file changed, which is exactly the defect requirement 13
is about.
