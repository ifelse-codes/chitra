# Session 44 — OSS polish + the founder decisions D1–D6

**Type:** code session (Batch 4 of the cleanup that gates the public repo flip)
**Branch:** `session-44-oss-polish`, from `main` `1b6c17d` (the S43 merge, == `origin/main`)
**Date:** 2026-10-03
**Contract:** this file. **Committed at HEAD** — `review-inputs-attested` hashes it, and
S40 failed that gate precisely because a contract that was never committed cannot be hashed.

## Why this session exists

S41 made the public face honest, S42 removed the dead trees, S43 removed the dead weight.
What is left is the part only the founder can do: the files a public OSS repo is expected to
carry, and the six decisions that have been **recorded but unanswered** since S41.

Everything below was deferred deliberately. S41 wrote them into its contract under
*"Founder decisions this session does NOT make"*, and each one names the consequence of
leaving it open. Four sessions later, **D1 and D4 still block the flip.**

## The one story

> A stranger landing on the public repo finds the things an OSS project is supposed to have —
> a security policy, a code of conduct, a way to file a bug, a green CI badge, an enforced
> coverage bar, a stated Node floor — and none of the founder's home path, dead config
> overrides, or unanswered governance questions.

`max_stories_per_session: 1`, so **Batch 4 only.** The public flip is S45.

## Scope — 14 numbered requirements

### A · The OSS surface (what a stranger expects to find)

1. **`SECURITY.md`** at the repo root: which versions are supported, how to report a
   vulnerability (GitHub private reporting — the repo is private until the flip, and the file
   must be written for the public repo it becomes), and what is *not* promised (no paid
   support, no SLA). It must not claim a `security@` mailbox that does not exist.

2. **`CODE_OF_CONDUCT.md`** at the root: Contributor Covenant 2.1, with a real enforcement
   contact. If no contact route exists, say how to open a private report instead of printing
   a placeholder address — **a CoC nobody can enforce is worse than none.**

3. **Issue and PR templates** under `.github/`: a bug report form, a feature request form,
   a `config.yml` that offers the docs/discussion routes that actually exist, and
   `.github/PULL_REQUEST_TEMPLATE.md`. Every field in the bug form must be something a
   maintainer can act on (version, terminal, reproduction, expected/actual).

4. **A CI badge in `README.md`** that points at the workflow file that really runs
   (`.github/workflows/ci.yml`). Badges are claims: the URL must resolve to this repo's own
   workflow, not a service that is not wired up. Existing badges (npm, license,
   dependencies, charts, tests) stay.

5. **Coverage enforced in CI.** `packages/core/vitest.config.ts` already carries real
   thresholds (statements 90 / branches 85 / functions 85 / lines 90 — the *measured floor*,
   lowered from a 90 nobody met, S41 req. 4) and `test:coverage` exists, but **nothing runs
   it**. The CI `core` job's `Test` step becomes the coverage run, so the suite still runs
   once, under v8, and the thresholds can fail the build. **No third-party coverage service**
   (no Codecov, no new badge): that would be new recurring infrastructure and a number this
   repo cannot yet publish honestly. Disclose the measured number in `CONTRIBUTING.md`, where
   the old one already lives.

6. **`engines`** where they are provable:
   - **root `package.json`** — `"node": ">=26"` and `"pnpm": ">=9.12.3"`, taken from the
     versions `ci.yml` actually pins. Not invented; copy them out of the workflow.
   - **`packages/core/package.json`** — `"node": ">=22"`, the oldest maintained Node line
     today. Derived, not guessed: the shipped source uses **zero** `node:` builtins, **zero**
     runtime dependencies, and its newest syntax is optional chaining (ES2020); CI proves 26.
     **Record the derivation, and record that it is a support policy and not a test result** —
     the suite has never been run on 22. Honesty about which claim is measured and which is
     policy is the point of this session.
   - **No `packageManager` field.** `pnpm/action-setup@v4` is given `version:` in `ci.yml`;
     adding the field invites the action's "multiple versions of pnpm" failure. Do not
     introduce a CI break in the session that adds the badge for it.

### B · The founder decisions — answered, with evidence

7. **Answer D1–D6 and record each answer where the next session will find it**
   (this contract, `.ai/STATE.md`, `sessions/session-44-summary.md`). The answers given at
   plan approval:

   | # | Decision | Answer |
   |---|---|---|
   | **D1** | How much internal process goes public (~146 files: `.ai/`, `sessions/`, `prompts/`, `.claude/`, `reviewer/`, `darshan/`) | **A — keep all.** The honest-build story ships whole; `check_session_coverage` / `check_task_ref` keep working with no gate rework |
   | **D2** | `core.hooksPath .githooks` is **local config only** — a fresh clone gets no hooks, and no doc says so | **Documented**: `CONTRIBUTING.md` states that hooks are opt-in and gives the one-line install; `.claude/settings.json`'s hooks are named as firing for any Claude Code user who clones |
   | **D3/D6** | Track `playground/` and the `design-reference/*.html` mockups as demos, or ignore them? | **Ignore.** `.gitignore` already ignores them; they stay local and **untracked**, so the flip publishes neither |
   | **D4** | The founder's personal home path in tracked files — the `/Users/<name>/…` form and the path-encoded `-Users-<name>-` variant — **irreversible once published** | **Scrub the working tree**, every live occurrence, in one mechanical commit. See D4b below |
   | **D4b** | The same paths in **git history** (16 of 565 commits, earliest from S10) | **Not done here, recorded as pending.** Rewriting history changes every commit SHA — `.ai/` cites `main` at `49e1ee2`, PR merge history and every recorded ref move with it — so it is a pre-flip operation for S45, not a cleanup-commit. **Disclosed, not silently skipped** |
   | **D5** | `pnpm-workspace.yaml` `overrides` cruft (expo/ngrok/… not in the dependency graph) | **Stripped**, lockfile regenerated **in its own commit**, install + typecheck + suite green on both sides |

8. **The D4 scrub is a tree change and must be provably mechanical.** Every replacement is
   the personal home prefix → `~`, and the path-encoded `-Users-…-` variant → `-home`;
   nothing else. No file added, no file deleted, no line count changed outside those substitutions — the
   diff must be readable in one pass and contain nothing but path text.
   **The check is `git grep -nE '(/|-)Users[-/][a-z]+' -- .` exiting non-zero** at the end of
   this session: it catches both spellings of the path, so rewording one of them cannot satisfy
   it. Its counterfactual is restoring a single occurrence and going red.
   **Disclosed consequence:** the same scrub edits `prompts/10-…` and `prompts/42-…`, which sit
   in the *prompt half* of `canonical_inputs_sha` — so the recorded `Review-Inputs-SHA` for
   **S10 and S42 no longer matches their contract's current bytes.** Those reviews are frozen
   historical records that no live gate recomputes, and the edit is mechanical and
   D4-mandated; it is stated here rather than discovered later.

### C · The two carried findings

9. **N1 — the contract-rewrite freshness hole** (`sessions/session-42-review.md` §N1, HIGH).
   `check_review_attestation` recomputes `sha256(prompt ‖ diff)` from **whatever the contract
   currently says**, so an edit made *between* a REJECT pass and the ACCEPT pass silently
   rebinds the attestation to a spec that already contains its own rebuttal. Fix it in two
   parts, and each part needs a counterfactual:
   - **A rule**, written into `reviewer/SKILL.md`, that freezes `prompts/NN-*.md` for the
     duration of a review cycle: corrections are **appended** under a `## Contract amendments`
     heading, numbered, each naming the finding that forced it — the original requirement line
     is never rewritten in place. A correction that rewrites the requirement it failed is the
     defect, not the fix.
   - **A gate**, `check_contract_freshness`, in `scripts/verify-closeout.sh`, that fails when
     the contract was modified by any commit **after** the commit that first added
     `sessions/session-NN-review.md`, and fails when the review declares a first-feed inputs
     hash that differs from the final one without a matching `## Contract amendments` section.
     Re-introducing the S42 edit (or any post-acceptance contract commit) must turn it **red**.

10. **§4.9 — the gate costs ~60 minutes.** It transitively runs S41's whole gate, the suite
    ~5×, two clone installs, a docs build and a Playwright run, on a repo that now has a
    **growing** load-bearing artifact. Add a **scope switch** to `scripts/verify-session-44.sh`
    (`VAJRA_GATE_SCOPE=full|fast`, default **full**): `fast` skips the chained S41/S42
    counterfactual half — the two clone installs and the inherited chain — while keeping every
    check this session owns. **The fast path prints that it is fast, the closeout still runs
    `full`, and the switch's counterfactual is that `fast` must actually be faster**, measured
    and printed as wall-clock minutes.

### D · D5 on its own

11. **Strip the `overrides` cruft and regenerate the lockfile — in its own commit** (the S42/S43
    precedent: a regen bundled with an unrelated change is a claim the file list contradicts).
    Entries are removed only when the package they override is **not in the dependency graph**;
    `pnpm install` with a frozen lockfile, typecheck, and the full suite must be green **before**
    the strip and **after** the regen.

### E · Proof and honesty

12. **Re-prove the product from live facts.** Fresh clone → install → build with no env;
    **453/453** tests in 23 files (now under coverage, thresholds enforced); root typecheck;
    `pnpm example`; `gen:charts:check`; the browser QA re-run; CI green on the branch.

13. **Re-sync `.ai/`** — `STATE.md`, `SESSION-BOOT.md`, `TASK.md`, `ROADMAP.md`,
    `KNOWLEDGE.md`, `CONTINUATION-PROMPT.md` describe S44 on this branch; any surviving count
    is **derived, not typed**; the frozen `sessions/` and old `prompts/` are not edited.

14. **Fidelity map + independent cold review.** `sessions/session-44-summary.md` maps every
    numbered requirement to evidence (SHIPPED / PARTIAL / NOT-BUILT), and
    `sessions/session-44-review.md` is a **cold** adversarial pass fed only this contract and
    the diff. **No self-certification.**

## Out of scope — named, so it cannot be smuggled in

- **The public flip** — S45. It resolves the README clone URL, npm `repository.url` /
  `homepage`, npm provenance, **and D4b's history rewrite** in one move.
- **Any change under `packages/core/src/`** — `charts/`, `renderers/`, `themes/` are LOCKED.
- **The seven dead docs deps S43 named but did not remove** (`framer-motion`, `react-icons`,
  `@tanstack/react-query`, `zod`, `date-fns`, `@tailwindcss/typography`, `tw-animate-css`) —
  a separate weight session, not a governance one.
- **`required-crew`** (three founder waivers), `check_ground_truth_no_code`'s vacuous pass,
  the cost gate that greps a heading, disposition **S16**, the **GTM proof pack**, a real
  **`0.4.0`** through CI — carried forward, untouched.
- **Historical `verify-session-NN.sh` / `demo-session-NN.sh` pairs** — frozen; unrun, unrepaired.

## Assumptions (2 — the constitution's cap)

1. **The flip is S45, not S44.** Same shape as S41's: this session makes the tree
   flip-*ready* and stops. D4b exists precisely because a history rewrite cannot be a
   cleanup commit.
2. **Coverage rides inside the existing `core` CI job rather than becoming a sixth job.**
   The suite still runs exactly once; the thresholds become enforceable; §4.9's ~60-minute
   gate does not get worse because this session added a badge to it.

## Founder decisions answered at plan approval

D1 = **A** · D2 = **document** · D3/D6 = **ignore** · D4 = **scrub the tree** ·
D4b = **record, do not rewrite history** · D5 = **strip + own-commit regen** ·
N1 + §4.9 = **fix both**. Recorded in requirement 7 rather than left in chat, because a
decision that lives only in a transcript is a decision the next session cannot find.

## Contract amendments

Appended, never written into the requirement above — the N1 rule this session ships, applied
to this contract from the start. Each amendment names the requirement it touches and the
evidence that forced it.

### A1 — requirement 11: the removal set is all 81 `overrides` entries, not the 11 whose package
is absent from the lockfile

Requirement 11 says an entry goes only "when the package they override is not in the dependency
graph". Measured literally that is **11 of 81** — `@esbuild-kit/esm-loader` plus the ten
`@expo/ngrok-bin-*` — because the other 70 name platform packages that do appear in
`pnpm-lock.yaml`.

That was the wrong test. The question is whether the override **affects resolution**, and the
experiment answers it for every entry: delete all 81, run `pnpm install --lockfile-only`, and
the lockfile diff is **empty**. Then a full `pnpm install` exits 0, `pnpm install
--frozen-lockfile` exits 0, root typecheck exits 0, and **453/453** pass. The 70 platform
entries are inert — `@esbuild/darwin-arm64@0.27.3` sits in `node_modules/.pnpm` *while*
`esbuild>@esbuild/darwin-arm64` is overridden to `"-"`.

All 81 go, so the requirement's intent — no dead config in the workspace manifest — is met
rather than a quarter of it. The requirement text above is unchanged, which is the point of
having an amendments section at all.

**The "in its own commit" clause needs one honest note.** The regen ran and its result is the
empty diff above: `pnpm-lock.yaml` did not change, so there is no lockfile commit to separate
from the manifest change. `git log -1 --format=%h -- pnpm-lock.yaml` still names S43's commit,
and that *is* the evidence that this session regenerated it and nothing moved.

**Not covered by this amendment, deliberately:** `minimumReleaseAgeExclude:
stripe-replit-sync` is the same species of Replit-scaffold cruft but is not an `overrides`
entry, so requirement 11 does not reach it. Named here rather than smuggled in.

### A2 — requirement 7, D4b: the "16 of 565" figure was typed and does not reproduce

Named by the S44 cold review **F2**. The D4b row above carries two counts nobody can
re-derive. Measured on this branch:

| derivation | value |
| --- | --- |
| `git rev-list --count HEAD` — commits a rewrite would move | **461** |
| `git rev-list --count --all` | **585** |
| commits whose **tree** matches `(/\|-)Users[-/][a-z]+` | **367 of 461** |
| commits whose **diff** touches a matching line (`git log -G`) | **11 of 461** |

"565" is `--all` minus this branch's commits as they stood at plan time, which is why it
drifted; "16" has no derivation at all. The row's other claim — **earliest from S10** — is
true: `45cd37e`, "docs(s10): session prompt — reference-lock the line chart".

**Corrected record:** D4b is still pending; a rewrite moves every commit reachable from
`HEAD`; `main` still carries the path, so the rewrite is still required; the earliest
carrier is `45cd37e` (S10). The counts are derived where they are used —
`scripts/demo-session-44.sh` prints them from git instead of repeating literals — because
requirement 13 says surviving counts are derived, not typed. The row above is not
rewritten; that is the point of this section.

### A3 — requirement 13 vs requirement 8: the scrub's `sessions/` edits

Named by the S44 cold review **M1**. Requirement 13 says "the frozen `sessions/` and old
`prompts/` are not edited"; requirement 8 mandates scrubbing "every live occurrence".
Read literally they contradict. Requirement 8 won — it is the one with a check — and its
disclosed-consequence paragraph names only the two `prompts/` files. It also edits
**five** session records, each a one-for-one path substitution, all inside `6024e0d`:
`sessions/session-{25,26,41,42}-summary.md` and `sessions/session-40-review.md`.

Recorded so the omission is a disclosure and not a discovery. No gate re-reads those
bytes: `check_review_attestation` is `$N`-scoped and the ledger hashes the recorded
attestation string, not the file.

### A4 — requirement 10's own description: one clone install, and no code path runs the gate

Two phrases in requirement 10 are not what the gate does (S44 cold review **M2**, **M3**):

- **"the two clone installs"** — this gate contains exactly **one** `git clone`
  (`fresh-clone-build-no-env`). The other clone sites sit in
  `verify-session-41/42/43.sh`, which it does not invoke: `s39-suite-still-green` runs
  `verify-session-39.sh`, which has no clone. The skip list itself is real, measured and
  correct; "two" was not.
- **"the closeout still runs `full`"** — `verify-closeout.sh` never invokes the gate. It
  asserts the two scripts exist (`check_verify_demo_scripts`), so no code path could run
  them with `fast`. The sentence was true by default only. What is enforced: the default
  is `full`, `resolve_scope` rejects anything else, and `gate-scope-switch` asserts both —
  so `VAJRA_GATE_SCOPE=fast` is not set anywhere in the repo.

Neither changes what ships: the skip list is priced from measured per-check timings and
the gate prints its own wall clock in both scopes. Requirement 10's text stands and is
corrected here.

### A5 — pass 2 of the cold review: a frozen figure, an uncommitted review, and two counts this session typed anyway

Pass 2 of the S44 cold review also returned **REJECT**. Four of its findings amend this
contract; the rest are fixed in the delivery. Nothing above is rewritten.

**A5.1 — A2's own table is typed, and two of its four figures had already moved** (pass-2
finding 7). A2 was written to stop typing counts, and then typed four of them. The table is
a **snapshot at `3b8ec6f`**; the derivations are the commands, and they are the part that
stays true:

| quantity | derivation (not a number) |
| --- | --- |
| commits a rewrite moves | `git rev-list --count HEAD` |
| commits across every ref | `git rev-list --count --all` |
| commits whose tree matches the path | `git log --format=%H --all -- . \| wc -l` with the tree grep below |
| commits whose diff touches it | `git log -G'(/\|-)Users[-/][a-z]+' --format=%H --all \| wc -l` |
| whether the rewrite is still needed | `git grep -qE '(/\|-)Users[-/][a-z]+' main -- .` |

The pattern that matches both spellings is `(/|-)Users[-/][a-z]+`. Within one session the
first two of those numbers already drifted by nine commits — which is the whole argument
for deriving them at the point of use (`scripts/demo-session-44.sh` does) instead of printing
a table of literals. **A2's numbers should be read as "measured at `3b8ec6f`", not as
current.**

**A5.2 — the pass-1 review was never committed** (pass-2 finding 2). `contract-freshness`
clause (a) resolves the commit that **first added** `sessions/session-44-review.md` and fails
closed when no commit adds it. Pass 1's report was written and read but left untracked, so at
the moment A2–A4 were appended there was no attested feed for clause (a) to protect — the rule
this session ships was, for one commit, unfalsifiable. The rule was not weakened: pass 3's
report is committed, and every amendment after it is checkable against it. Disclosed rather
than papered over, because "we shipped the N1 rule and then skipped its first step" is exactly
the kind of sentence that only survives if it is written down.

**A5.3 — requirement 13 was violated by the fix for F2.** Four `.ai/` files carried counts
written while correcting A2: "~146 process files" (the tracked figure) and "~30 changed
files / ~14 commits" (the delivery's size). Both are gone; each site now names the command
that produces the number. Requirement 13 needed no amendment — it was obeyed late, not
reinterpreted.

**A5.4 — requirement 10's headline figure was frozen at the first full run** (pass-2 finding
1, which the reviewer named the fakest green of the delivery). `gate-scope-switch` picked the
timings file with the most lines and kept the old one on a tie; every full run writes the same
number of lines, so the "measured" percentage could never change from the first run that
ever produced it. A full run 80 minutes later measured **73%** while the gate printed **86%**.
Fixed by selecting newest-first, by printing the source run beside the number, and by giving
the selection a fixture (`gate-scope-switch`) so "newest wins" is a fact the check can lose on.

### A6 — the four docs the reviewer found pointing at a closed door

Named by pass-2 finding 11. `.github/ISSUE_TEMPLATE/config.yml` sets
`blank_issues_enabled: false`, so for anyone outside the maintainers the issue tracker is not
a door — yet `SECURITY.md` told a reporter to "say so in a **public** issue", and
`CODE_OF_CONDUCT.md` sent every non-secret conduct report, and every request for a private
channel, to an issue. Requirement 3 asks for issue forms and templates; it does not ask the
public docs to invent a route that the repo has closed. Both docs now route to GitHub
Discussions or to private reporting, and say plainly what does not exist. `oss-surface-present`
now fails if any of `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `README.md`
directs the reader to the tracker while blank issues are off — with the pattern deliberately
broader than the word "open", because the defective sentence never used it. A sentence that
only **prohibits** a public issue stays legal; the gate must not punish the right advice.

### A7 — A6's premise was wrong: `blank_issues_enabled: false` does not close the tracker

Pass 3 of the S44 cold review returned **REJECT** again and found that **A6 fixed the defect by
assuming something untrue**, which is worse than the defect. What I wrote down as fact:

> with blank issues disabled, the issue tracker is not a route that exists for anyone outside
> the maintainers

Not so. `blank_issues_enabled: false` removes only the **blank** template from the new-issue
page; the bug and feature forms requirement 3 shipped still accept a report from an outside
contributor. So the clause built on that premise forbade the one true sentence and permitted the
two false ones — and the "fix" it drove rerouted both docs to **GitHub Discussions**, which
`gh api repos/ifelse-codes/chitra --jq .has_discussions` reports as **`false`**. I had moved
readers from one closed door to another while writing an amendment that called the first one
closed.

**Verified facts, recorded with the command that re-derives each**, now tracked in
[`.github/REPO-SETTINGS.md`](.github/REPO-SETTINGS.md) (S44 cold review, pass 3):

| setting | value |
| --- | --- |
| `private` | `true` — the flip is S45's job; nothing here is reachable by an outsider yet |
| `has_issues` | `true` |
| `blank_issues_enabled` | `false` — forms only, no untemplated issue |
| `has_discussions` | **`false`** |
| private vulnerability reporting | **unknown** — the API path returns 404, which is also what a caller without admin access gets, so it cannot distinguish "off" from "not permitted to ask" |

**What ships instead of A6's clause.** The invariant is *no public doc may route to a channel
the recorded settings say is off*, and `oss-surface-present` now checks two offline facts: with
blank issues off, a doc that sends the reader to an issue must name a **form**; and while
`has_discussions` is recorded `false`, no public doc may mention Discussions at all (the setting
is documented in `REPO-SETTINGS.md`, where it belongs). Both are proven red against the old
wording and green against the new, in both directions.

**A7.1 — the consequence the docs now state plainly.** Because private reporting is not
established and the repository publishes no mailbox, this project may have **no private channel**
after the flip. `SECURITY.md` and `CODE_OF_CONDUCT.md` say that instead of inventing one, and
give the only honest fallback: a report containing no detail, asking for a private route.
**Enabling private vulnerability reporting is therefore a pre-flip task for S45**, recorded in
`.ai/STATE.md` beside D4b — it is a repository setting, not a file this session can change.

**A7.2 — requirement 1's invented-mailbox rule covered only the CoC.** Requirement 1 forbids
inventing a contact address in `SECURITY.md` too — the file most likely to grow a `security@`
the day someone wants one. The check now runs on both files.

**A7.3 — the contract's own D4b row cites `main` at `49e1ee2`.** That is the S42 merge as named
in the S43 records; `main` is now `1b6c17d`. The row above is frozen, so it is corrected here:
the `.ai/` and `prompts/` records cite `main` **by SHA**, several of them, and any of those
citations moves in a rewrite. Read the live value with `git rev-parse main`; do not trust a
citation, including this one.

**A7.4 — disclosed, pre-feed:** `909eaa4` (the gate's first commit) rewrote requirement 7's D4b
row and requirement 8's body in place, and it did so **before** the first cold review feed and
before the N1 rule existed. It is not a freeze violation — the rule applies from the first feed —
but "the freeze is clean" is only true for `68662bf..HEAD`, and this map used to say so without
the qualifier. It says it with the qualifier now.

## Closeout

`scripts/verify-session-44.sh` exits 0; `scripts/verify-closeout.sh` exits 0 (or a founder
waiver is recorded exactly as S38/S39/S42 did for the structurally-unsatisfiable
`required-crew`); the suite stays **453/453**; CI green on the branch. Summary + cold review
written, `.ai/` re-synced, PR opened to `main`.

## The counterfactual this session demands

**`s43-gate-verbatim-goes-red`** — S43's gate, run unmodified on this branch, must exit
non-zero. The reason must be **discoverable, not asserted**: this session's own changes have
to break a named S43 check (the `ai-files-describe-s43` hand-off, `dead-scripts-gone`'s
script inventory, or the `charts-format-only` base ref), and the port must re-express that
check against S44's live tree. A gate that cannot name what breaks it is a check that cannot
fail — the same defect S43 fixed in N6, one session deeper.
