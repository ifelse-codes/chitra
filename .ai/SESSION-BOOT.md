# Session Boot

## Current Session
- **Number:** 44 — cleanup **Batch 4: OSS polish + the founder decisions D1–D6**, code session.
- **Branch:** `session-44-oss-polish`, from `main` `1b6c17d` (the S43 merge, == `origin/main`).
- **Contract:** `prompts/44-task-oss-polish.md`, committed at HEAD — with
  **`## Contract amendments` → A1…A12**, the session's own demonstration that a contract is
  amended and never rewritten (the N1 rule this session ships): A1 = D5's removal set, A2 =
  D4b's typed figures, A3 = the scrub's `sessions/` edits, A4 = requirement 10's own prose,
  A5/A6 = pass 2's findings (a frozen percentage, four counts typed while fixing F2, the docs'
  closed door), A7 = A6's own false premise and the settings that decide which door is open,
  A8 = pass 4's findings (a false sentence of mine, and the same claim in five more files),
  A9 = pass 5's (three sweeps that did not cover what they claimed), A10 = pass 6's (a
  remedy clause false in the sentence stating it), A11 = pass 7's (the same class a fourth
  time, and the gate that finally covers it), A12 = pass 8's (the fix that falsified the map,
  and the rule that took three attempts). Read the list, never a summary of it — six passes have
  now caught this file's version of the list going stale.
- **Gate:** `scripts/verify-session-44.sh`, a **port** of `verify-session-43.sh` — count the
  checks with `grep -c '^run_check ' scripts/verify-session-44.sh`, never from prose — plus
  `VAJRA_GATE_SCOPE=fast|full` (default **full**), wall-clock printed either way.
- **The story:** a stranger landing on the public repo finds the things an OSS project is
  supposed to have — a security policy, a code of conduct with a route that exists, issue and
  PR templates, a CI badge pointing at the workflow that runs, a coverage bar CI actually
  enforces, a stated Node floor — and none of the founder's home path, dead config overrides,
  or unanswered governance questions.

## Repo State Snapshot
> Re-read from live facts at S44 boot, not copied from S43's prose.

- `.ai/SESSION` = 44. S43 was **merged** when this session started: `main` = `1b6c17d`
  (the S43 merge) == `origin/main` at branch time.
- **Product untouched:** **453/453** tests in 23 files; root typecheck exit 0; `pnpm example`
  runs; `gen:charts:check` green. 20 charts / 3 renderers / 7 themes / 0 runtime deps. The
  package is **`@ifelse.codes/chitra@0.3.0`**, live on npm. Repo still **private**.
- **Coverage is now enforced, not merely configured.** `vitest.config.ts` has carried four
  thresholds since S41 that **nothing ran**; `ci.yml`'s `core` job runs `test:coverage` in
  place of the plain `Test` step — the suite still runs **once**, under v8.
- **All 81 `pnpm-workspace.yaml` `overrides` are gone** and the lockfile did not move: the
  regen's result is a **zero delta** (`git diff main...HEAD -- pnpm-lock.yaml` is empty), which
  is why there is no lockfile commit of its own. Amendment A1 records why the removal set is
  81 and not the 11 the requirement's literal wording named.
- **The personal home path is out of the tracked tree** — 15 files, one mechanical commit,
  `/Users/<name>` → `~` and `-Users-<name>-` → `-home`. **Git history still carries it**:
  `main` still matches the pattern, so a rewrite is still required — it moves every commit
  reachable from `HEAD` (`git rev-list --count HEAD`, derived not typed), earliest carrier S10
  → **D4b, the flip session**.
- **The gate is a PORT of `verify-session-43.sh`.** Re-expressed by this session's changes:
  `ai-files-describe-s43` → `-s44`, `contract-at-head` → `prompts/44` + requirements 1…14 +
  the amendments section, `s42-gate-verbatim-goes-red` → **`s43-gate-verbatim-goes-red`**
  (extracts S43's REAL `ai-files-describe-s43` body and asserts it exits non-zero here, because
  that check hard-codes S43's branch and session number).
- **The two carried findings are fixed, not recorded:** **N1** gets a rule in
  `reviewer/SKILL.md` plus `contract-freshness` in `verify-closeout.sh` (pure core, extracted by
  the gate and run against two real sessions); **§4.9** gets `VAJRA_GATE_SCOPE` plus per-check
  timings, so "fast is faster" is arithmetic on measured seconds.

## Next Session
- **Number:** 45 — **the public flip.** It resolves, in one move: the README `git clone` URL,
  npm `repository.url` / `homepage`, npm **provenance** (which a private repo cannot generate),
  a real **`0.4.0`** through the trusted-publisher runway, and **D4b** — the git-history rewrite
  that removes the home path from every commit reachable from `HEAD` (**irreversible; every
  recorded SHA moves**).
- Also open, untouched: the **seven dead docs deps** S43 named (`framer-motion`, `react-icons`,
  `@tanstack/react-query`, `zod`, `date-fns`, `@tailwindcss/typography`, `tw-animate-css`),
  `minimumReleaseAgeExclude: stripe-replit-sync` (same species as D5, not an `overrides` entry),
  `required-crew` (three founder waivers), the vacuous `check_ground_truth_no_code`, the cost
  gate that greps a heading, disposition **S16**, and the **GTM proof pack** (record the measured
  **zero** downloads as `t0`; never cite the 304 `@ifelse.codes/core` self-downloads).
- Open in a **new chat** (one session per chat).
