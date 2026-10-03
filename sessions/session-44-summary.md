# Session 44 — fidelity map

**Session:** cleanup Batch 4 — OSS polish + the founder decisions D1–D6 (code session)
**Contract:** `prompts/44-task-oss-polish.md`, committed at `11a86ff` (the first commit, before
any work), amended once at `589a196` under its own `## Contract amendments` → A1.
**Branch:** `session-44-oss-polish` from `main` `1b6c17d` (S43 merge). **PR #65.**
**19 commits · 36 files changed · +2,413 / −299 · 9 added · 0 deleted · 0 lockfile changes.**

## The headline: §4.9's "~60 minutes" does not reproduce — the gate measures 2m33s

The carried finding said the gate costs ~60 minutes and needs an opt-out. I built the opt-out
**and measured**, and the premise was wrong by roughly 24×:

| scope | checks | result | wall clock |
| --- | --- | --- | --- |
| `full` (default, what closeout runs) | 47 | **47 PASS, exit 0** | **2m33s** (153s) |
| `fast` (`VAJRA_GATE_SCOPE=fast`) | 41 | **41 PASS, exit 0**, 6 `SKIP` | **26s** |

The skip list's own price, read out of the gate's per-check timings: **98s of 113s = 86%** of
the measured check time. So the switch is real and worth having — but nobody should quote
"~60 minutes" for this gate again, because it was never the number **this** gate produces.
The claim is recorded as measured rather than inherited.

## The map — 14 of 14

| # | Requirement | State | Evidence |
| --- | --- | --- | --- |
| 1 | `SECURITY.md` | **SHIPPED** | `484c36b`. Supported versions, private disclosure route, no-SLA/no-bounty/latest-only, release pipeline in scope. `oss-surface-present` asserts the section headings and that **the same code is RED on `main`** |
| 2 | `CODE_OF_CONDUCT.md` | **SHIPPED** | `484c36b`. Contributor Covenant 2.1 + enforcement ladder, **no invented mailbox** — the check *fails* on any email address in the file, and the file says why it publishes none |
| 3 | Issue forms + PR template | **SHIPPED** | `eda166e` (bug + feature forms, `config.yml`, blank issues off) + `178553c` (`.github/PULL_REQUEST_TEMPLATE.md`) |
| 4 | CI badge on the workflow that runs | **SHIPPED** | `178553c`. The check reads every `actions/workflows/*.yml` URL out of `README.md` and requires `.github/workflows/<that file>` to exist; RED on `main`, where there is no badge at all |
| 5 | Coverage enforced in CI | **SHIPPED** | `5f21a1e`. `ci.yml#core` runs `test:coverage` **instead of** the plain `Test` step — suite runs once, four live thresholds, and the check **fails if a coverage service appears** |
| 6 | `engines` where they are provable | **SHIPPED** | `523102a`. Repo `>=26` / `>=9.12.3` **copied from `ci.yml`'s own pins**; package `>=22` stated in CONTRIBUTING *as a support policy, not a test result*, with the derivation (zero `node:` builtins, zero runtime deps, newest syntax `?.`). No `packageManager` field — `pnpm/action-setup@v4` already takes its version from `ci.yml` |
| 7 | D1–D6 answered and recorded | **SHIPPED** | `6024e0d` (D4), `9d88882` (D5), `589a196` (D4b + A1). Answers in contract req 7, this file, and `.ai/STATE.md` — not in the transcript |
| 8 | D4 scrub, provably mechanical | **SHIPPED** | `6024e0d`: 15 files, `numstat` N/N on every one, nothing added or deleted. `home-path-scrubbed` greps the live tree **and** runs the same pattern against the newest pre-scrub commit derived from history — a pattern that matched nothing would fail, not pass |
| 9 | N1: rule + a gate that can go red | **SHIPPED** | `d75a23a`. `reviewer/SKILL.md` (amend, never rewrite) + `contract-freshness` in `verify-closeout.sh` with a **pure** core. `contract-freshness-teeth` extracts that body and runs it twice: **green on S43**, **red on S42** — whose contract *this session's own scrub* rewrote after its review — naming a commit it then proves touches the contract |
| 10 | §4.9: scope switch, measured | **SHIPPED** | `b9d8791` + `e62808c` + `51bf7c3`. `gate-scope-switch` unit-tests the switch, requires every skip-list name to be a real check, forbids skipping anything S44 owns, and prices the list from measured per-check timings (86%) |
| 11 | D5 overrides stripped, own-commit regen | **SHIPPED** | `9d88882` + `589a196`. **81 → 0**; `pnpm install --lockfile-only` left `pnpm-lock.yaml` byte-identical, then full install, `--frozen-lockfile`, typecheck and **453/453** all exit 0. A1 records why the removal set is 81, not the 11 the literal wording named |
| 12 | Re-prove the product from live facts | **SHIPPED** | Gate: `fresh-clone-build-no-env`, `core-tests` (453), `core-typecheck`, `root-typecheck`, `coverage-gate-passes`, `contributing-coverage-numbers-real`, `example-runs`, `chart-drift`, `browser-qa-catalog-pages` — all PASS |
| 13 | Re-sync `.ai/`; counts derived, not typed | **SHIPPED** | `37511d0`, `daf9c4c`, `9efc28c`. `ai-files-describe-s44`, `ai-names-no-deleted-tree`, `test-count-propagated` |
| 14 | Fidelity map + independent review | **SHIPPED** | This file + `sessions/session-44-review.md` |

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

## Honest gaps

- 🔴 **D4b is not done, by decision.** The **tree** is clean; **16 of 565 commits** still carry
  the home path. A rewrite moves every recorded SHA (`.ai/` cites `main` at `49e1ee2`), so it
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
N1 + §4.9 scope) with commits pre-approved · **14 requirements** · **19 commits** · **36 files**
(+2,413/−299) · **9 added, 0 deleted** · **0** product-code changes · **0** new product tests
(453 stays 453) · **0** lockfile changes (the D5 regen produced an empty diff — recorded as A1)
· **0** releases · **0** npm secrets · **0** new recurring infra (coverage rides the existing
`core` job; no coverage service) · **1** `--no-verify` commit for the 15-file mechanical scrub,
authorised by the contract because the 3-file atomic cap cannot express it · gate runs: 3 fast
(26s each) + 4 full (2m33s each), the last two green at 47/47 · token cost unmeasured (billed
to the founder's plan) · npm cost $0.
