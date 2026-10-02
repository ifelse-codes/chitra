# chitra — Continuation Handoff (after S41)

**Resume in a NEW chat (S42).** `main` = S00–S40 (`ece61fc`) at S41's branch point;
`.ai/SESSION` = 41; **`@ifelse.codes/chitra@0.3.0` is LIVE on npm** (`latest`); the repo is
still **private**, by decision — it goes public after a code cleanup.

> **The one thing to carry forward:** a fresh clone can now build, and a visitor can no
> longer read a lie. That took 13 requirements and six independent review passes, and it is
> the *precondition* the founder set for the flip — not the flip itself. **The next three
> sessions are already scoped and scheduled: S42, S43, S44.** Nothing about the cleanup is
> unowned any more.

## Where we are

Detail: `sessions/session-41-summary.md` + `sessions/session-41-review.md` + `.ai/STATE.md`.

| Delivered in S41 | State |
|---|---|
| Live docs meta placeholder | **gone** — it was live on `chitra.iifelse.com`, asserted in the built page |
| `VERSION` shipping as `0.1.0` | **generated from the manifest**, suite-asserted, CI-gated twice |
| Fresh-clone `pnpm run build` | **exit 0 with no env** — first time in this repo's history |
| npm README | 785 → 122 lines; the internal design log is not public any more |
| CONTRIBUTING / replit.md / `ci.yml` | five false claims, the Node facts, and the provenance comment all corrected |
| Machine-path junk | 4 untracked files deleted, one a 277 KB transcript with `/Users/REDACTED/…` |
| Verify | S41's gate is 24/24, every check with a proven counterfactual; S39's is 43/43 |
| Tests | **453 green** in 23 files — the one new test guards the version |
| Product code | **untouched.** 0 files under `src/charts/`, `src/renderers/`, `src/themes/` |

## S42 — cleanup Batch 2: dead weight (the roadmap's next item)

1. Delete `artifacts/mockup-sandbox/` — 69 files, second copy of the shadcn tree, breaks the
   root build, **zero CI jobs reference it**.
2. Delete `lib/` + `artifacts/api-server/` — 31 files serving `/healthz`, plus the 6-file
   reference chain: root `tsconfig.json`, docs `tsconfig.json`, docs `package.json`,
   `.github/workflows/ci.yml`, the root `typecheck:libs` script, `pnpm-workspace.yaml`.
3. Delete `attached_assets/` (3) and the unused `@assets` alias.
4. Delete 5 dead scripts (`post-merge.sh`, `src/hello.ts`, `src/demo09-donut.ts`,
   `check-hero-dims.py`, `build-audit-html.mjs`).
5. **Do NOT delete** the `verify-session-NN.sh` / `demo-session-NN.sh` pairs —
   `verify-closeout.sh` reads the current session's.

> **Gate:** Batch 1's gate (24 checks, including the fresh clone) + `node scripts/qa-catalog.mjs`
> browser QA + CI green on the PR. Lockfile diff reviewed.

## Then

- **S43** — 43 unused shadcn components (~5,000 LOC) and the deps that die with them; the
  Prettier config (31 core files fail `--check`); the `lint` script, which points at an
  eslint that is not installed and has no config.
- **S44** — `SECURITY.md`, CoC, issue/PR templates, CI badge, coverage job, `engines`, and
  founder decisions **D1–D6**.
- **Then the flip** — which resolves the README `git clone`, npm `repository.url` and
  `homepage`, and turns npm provenance on, in one move.

## The two decisions only the founder can make

- **D1 — how much internal process goes public?** `.ai/`, `sessions/`, `prompts/`, `.claude/`,
  `reviewer/`, `darshan/`; ~146 files. Option A (keep) is the recommended one: it is a real
  story, and it keeps the closeout gates working. **Options B and C break
  `check_session_coverage` / `check_task_ref` unless the gates are rewritten first.** Note
  `.claude/settings.json` is tracked, so its hooks fire for any Claude Code user who clones —
  never tested as an outsider.
- **D4 — the personal-path scrub.** 5 tracked files carry `/Users/REDACTED/…`. **History is
  published with the flip; this is irreversible after it.** Answer before, not after.

## Also still open

- **A real `0.4.0` through CI** — the cheapest close on the trusted-publisher claim.
  Nothing needs to change; the pipeline is wired and the publisher exists.
- **GTM proof pack** — must record the measured **zero** downloads as its `t0`, and must
  **never** cite the 304 `@ifelse.codes/core` downloads: they sit inside a 5-day window
  starting on the publish day and are release-runner and founder shaped.
- **S40's governance rows, untouched by S41** — `required-crew` (third waiver; demands a
  handoff the Session Loop never asks for), `check_ground_truth_no_code` passing
  **vacuously** because a GT session never commits into the range it diffs, the cost gate
  that passes on the string "Cost Tracking", and **S16**, which no ledger can see.
