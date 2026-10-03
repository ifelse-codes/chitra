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
   | **D4** | `/Users/suman/…` in tracked files — **irreversible once published** | **Scrub the working tree**, all live occurrences, in one mechanical commit. See D4b below |
   | **D4b** | The same paths in **git history** (16 of 565 commits, earliest from S10) | **Not done here, recorded as pending.** Rewriting history changes every commit SHA — `.ai/` cites `main` at `49e1ee2`, PR merge history and every recorded ref move with it — so it is a pre-flip operation for S45, not a cleanup-commit. **Disclosed, not silently skipped** |
   | **D5** | `pnpm-workspace.yaml` `overrides` cruft (expo/ngrok/… not in the dependency graph) | **Stripped**, lockfile regenerated **in its own commit**, install + typecheck + suite green on both sides |

8. **The D4 scrub is a tree change and must be provably mechanical.** Every replacement is
   `/Users/suman` → `~`, nothing else. The gate must show that the scrub touched **only**
   string content: no file added, no file deleted, no line count changed outside the
   substitutions. **`git grep -n "/Users/suman" -- .` must exit non-zero at the end of this
   session** — that is the check, and its counterfactual is reverting one occurrence.

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
