# Session 41 — the public repo tells the truth, and a stranger can build it

**Type:** code session (Batch 1 of the cleanup that gates the public repo flip)
**Branch:** `session-41-repo-cleanup`, from `main` `ece61fc` (== `origin/main`, `0 0`)
**Date:** 2026-10-02
**Contract:** this file. **Committed at HEAD** — `review-inputs-attested` hashes it, and
S40 failed that gate precisely because a contract that was never committed cannot be hashed.

## Why this session exists

`.ai/GT-REMEDIATIONS.md` S40 row 2 is the mandate: the founder's decision is that **the repo
goes public after a code cleanup**, and the cleanup that gates that flip had *no roadmap item,
no scope, no owner*. This file is the scope; this session is Batch 1 of it.

Two independent audits now exist and they agree on shape:

| Source | Method | Verdict |
|---|---|---|
| `code-cleanup-plan-session-41.md` | full-tree + full-history sweep, 501 tracked files | product clean, repo around it is not |
| `independent-audit-RESULT.md` | **blind** pass, different agent, no access to the first | *"Not ready to flip — but the gap is the repo around the product, not the product."* |

The blind pass found 8 things the first missed (§9). **One of them invalidates the first
pass's prescribed fix**, and it is the load-bearing one: a fresh clone fails `pnpm run build`
*not* (only) because `PORT`/`BASE_PATH` are unset, but because the root `build` script
typechecks the docs **before** `@ifelse.codes/chitra`'s `dist/` exists — and `dist/` is
gitignored. Defaulting the env vars does not fix it. Both fixes are in scope (items 10, 11).

**The single biggest risk, per the blind pass, is irreversible:** machine-specific absolute
paths and internal publish forensics are already in committed history, so the flip publishes
them forever. That is item D4 / Batch 4 and it is a founder decision — but it must be answered
*before* the flip, not after.

## The one story

> A stranger who clones this repo reads nothing false, and `pnpm install && pnpm run build`
> succeeds with no environment variables set.

`max_stories_per_session: 1`, so **Batch 1 only.** Batches 2–4 (dead-weight deletion, docs
dependency pruning, OSS polish + the founder decisions) become S42–S44 and get roadmap items at
closeout. Each of those carries its own build-break risk and needs its own green gate and its
own cold review.

---

## Scope — 13 numbered requirements

Each is a numbered requirement. The summary must map **every** number to
SHIPPED / PARTIAL / NOT-BUILT with evidence. *Fidelity ≠ discipline:* a green verify script
proves discipline, never fidelity.

### A · What a visitor or a consumer sees

| # | Requirement | Files | Accept when |
|---|---|---|---|
| 1 | The live docs site must not serve the Replit scaffold placeholder as its meta description. It is `https://chitra.iifelse.com`'s search-engine and social-card text *today*. | `artifacts/chitra-docs/index.html` | zero occurrences of `built on Replit` / `Update this description` in the file **and** in the built `dist/index.html`; a real product line in `title`, `description`, `og:*`, `twitter:*` |
| 2 | `VERSION` is exported public API and **ships** as `"0.1.0"` while the manifest is `0.3.0` (`src/index.ts:73`; proven in `dist/index.d.ts:13`). | `packages/core/src/index.ts`, `packages/core/src/version.ts`, `packages/core/build.mjs` or equivalent, `packages/core/tests/composability.test.ts` | `VERSION` is **derived** from `package.json`, never restated; built `dist/index.d.ts` and `dist/index.js` contain no `0.1.0`; **a test asserts `VERSION === pkg.version`** and runs in CI |
| 3 | `packages/core/README.md` **ships to npm** as an internal design log — 19 `### LOCKED: … session NN design` sections naming internal sessions — and contradicts itself: "block (default for line)" vs `line.ts:151` `?? "braille"`, and "Three Renderers" above four bullets. | `packages/core/README.md` | no internal-session design-log sections; the default renderer is stated as `braille`; the renderer count matches the bullets |
| 4 | `CONTRIBUTING.md` is wrong in five places: clone URL says `chitra-dev/chitra` (real org `ifelse-codes/chitra`); the run command uses the removed `--experimental-specifier-resolution` flag and does not run; the chart template omits `toContent()`, which `ChartResult` **requires** (`types.ts:237`), so a contributor following it gets a type error; tests are one file per chart now, not `tests/charts.test.ts`; and it promises ">90% test coverage" while `test:coverage` **fails** at 86.28% functions against a 90% threshold. | `CONTRIBUTING.md` | every one of the five is true as written; the coverage claim states the measured reality, or the threshold is met — no claim left standing that the repo does not satisfy |
| 5 | The documented example command needs a runner that exists. `tsx` is in the catalog but not installed at the root. | `package.json` (root), `CONTRIBUTING.md` | `pnpm example` runs `examples/basic.ts` and exits 0 |
| 6 | `replit.md` states "Node.js 24" and "CI on Node 20/22/24"; `ci.yml` pins `NODE_VERSION: "26"`, one version. Its `ChartResult` list omits `toContent()`. | `replit.md` | matches `ci.yml` exactly; the interface list matches `types.ts` |
| 7 | `release.yml:99-103` asserts provenance cannot happen because the repo is private. True today, **a lie the moment of the flip** — and the flip is the plan's last step. | `.github/workflows/release.yml` | the comment is true in **both** repo states |
| 8 | `README.md:142` points a public reader into `.ai/ROADMAP.md` — internal process, and it dangles if governance is ever slimmed. | `README.md` | no public doc points into `.ai/` |
| 9 | `.ai/STATE.md`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md` currently describe S40 as in progress on a branch that no longer exists, and `.ai/SESSION` reads `40` while S40 is merged. | `.ai/SESSION`, `.ai/STATE.md`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md`, `.ai/ROADMAP.md` | every `.ai/` file describes **S41, on this branch, now** — re-read against live facts, not copied from the prior session's prose (the S35 lesson) |

### B · What a stranger can do

| # | Requirement | Files | Accept when |
|---|---|---|---|
| 10 | **The build-order fix (blind-pass E10; the first pass's fix is insufficient).** Root `build` = `typecheck && pnpm -r build`. `typecheck` typechecks `artifacts/chitra-docs`, which imports `@ifelse.codes/chitra`, whose `types` is `./dist/index.d.ts` — **gitignored, and nothing builds it first**. Fresh clone → `TS2307: Cannot find module '@ifelse.codes/chitra'`, *with* `PORT`/`BASE_PATH` set. CI already gets this right (`typecheck:libs` → core build → docs typecheck → docs build); the root script must match CI. | `package.json` (root) | a **fresh clone** with no env: `pnpm install --frozen-lockfile && pnpm run build` exits 0. The order is asserted, not assumed. |
| 11 | Both vite configs **throw** when `PORT`/`BASE_PATH` are unset, so a human following the README cannot build. CI sets them; a person does not. | `artifacts/chitra-docs/vite.config.ts` | `process.env.PORT ?? "5000"`, `process.env.BASE_PATH ?? "/"`; CI still overrides |
| 12 | `pnpm-workspace.yaml:4` globs `lib/integrations/*` — no such directory exists. | `pnpm-workspace.yaml` | glob removed; `pnpm install --frozen-lockfile` still resolves |

### C · Junk that would ship on a careless `git add -A`

| # | Requirement | Files | Accept when |
|---|---|---|---|
| 13 | 19 untracked paths. Two carry **machine-specific absolute paths** and must never be committed: `command-code-session-8b98ceae.html` (277 KB agent transcript) and `.commandcode/settings.json`. Two are **stale and false**: `jev-readiness-plan.md` (Sep 22, superseded), `.ai/CHITRA-FRAME-FIX.md` (claims 435 tests; actual 452). The rest are undecided (D3/D6). | `.gitignore`, plus deletions | the two path-bearing files are **deleted**, not ignored; the two stale files are deleted; the undecided ones are **gitignored** (not tracked, not deleted — D3/D6 are unanswered and this session does not guess them); `git status` shows no junk |

### Cross-cutting requirement — the canonical test count

The canonical test count is **displayed in nine places** — `README.md` (badge),
`App.tsx` (hero stat), `replit.md`, the `.github/workflows/ci.yml` header comment, and
the permanent-facts header, guardrail and "next steps" lines of `.ai/KNOWLEDGE.md`,
`.ai/ROADMAP.md`, `.ai/SESSION-BOOT.md`, `.ai/CONTINUATION-PROMPT.md` — and **asserted as
a literal in 15 tracked files** once the historical `verify-session-*.sh` /
`demo-session-*.sh` are counted. (An earlier draft claimed "12 places"; the cold review
counted and it was wrong in both directions. Corrected.) This is exactly the trap that
cost `main` commit `ece61fc` ("a line of mine broke S39's `ai-docs-quote-real-score`
gate").

- **Preferred:** add requirement 2's drift assertion **inside an existing test file**, so
  no new file appears. Note that adding an `it()` still moves the count — the count is
  the number of tests, not the number of files.
- **If the count moves**, every place that *displays* it changes in the same session, and
  `verify-session-39.sh` is updated with it. Nothing historical under `sessions/`, the
  dated sections of `KNOWLEDGE.md`, or the dead pre-rename verify scripts is rewritten.
- **A guard, not a convention.** `verify-session-41.sh#test-count-propagated` derives the
  count from the suite run and fails if the badge, the docs hero stat, `KNOWLEDGE.md`, the
  `ROADMAP.md` guardrail, `SESSION-BOOT.md`, the `ci.yml` header comment or
  `verify-session-39.sh` disagree. Restating a number in nine files and hoping is how this
  bit twice. **The guard covers those seven sites, not every display that may be added
  later** — a new one has to be added to the check, and that limit is written into the
  check's own comment rather than papered over.
- Either way: **`bash scripts/verify-session-39.sh` must be 43/43 on the branch tip.**

### Also landing with this contract (evidence, not scope)

`code-cleanup-plan-session-41.md`, `independent-audit-prompt.md`, `independent-audit-RESULT.md`
are the evidence base this contract is written from. They are untracked; they get committed
(≤3 files per commit, so two commits) so the next reader can check the reasoning.

---

## Gates — every one must be exit 0

```bash
pnpm --filter @ifelse.codes/chitra run test          # 452 passed, 23 files
pnpm run typecheck                                   # exit 0
pnpm --filter @workspace/chitra-docs run gen:charts:check   # exit 0
bash scripts/verify-session-39.sh                    # 43/43 — the regression guard
# the gate that has never been met, in any session, on any commit:
git clone --local . /tmp/s41-fresh && cd /tmp/s41-fresh \
  && pnpm install --frozen-lockfile && pnpm run build # exit 0, NO env vars
bash scripts/verify-session-41.sh                    # exit 0
bash scripts/demo-session-41.sh                      # shows before → after
```

`verify-session-41.sh` asserts **behaviour, not strings**: it runs the built `dist` and
compares `VERSION` to the manifest, greps the *built* docs HTML for the placeholder, and
executes the fresh-clone build. A check that passes on a lie is a bug (S40's rule).

## Out of scope — named, so it cannot be smuggled in

- **Batch 2** — delete `artifacts/mockup-sandbox/` (69), `lib/` + `artifacts/api-server/` (31,
  and the 6-file chain that references them), `attached_assets/` (3), 5 dead scripts.
- **Batch 3** — 43 unused shadcn components + the docs dependency prune; Prettier; eslint.
- **Batch 4** — `SECURITY.md`, CoC, issue/PR templates, CI badge, coverage gate, `engines`,
  the `.ai/` freshness of npm forensics, the personal-path scrub, **and founder decisions
  D1–D6**.
- The **public flip** itself, a `0.4.0` release, the MCP server, the GTM proof pack, and
  `GT-REMEDIATIONS` rows 4/5/8/10/11 (the governance gates — real work, S42+, not this story).
- `packages/core/src/charts/**` — LOCKED design language (S09–S28). Only item 2's `VERSION`
  touches `packages/core/src`, and only `index.ts`.

## Founder decisions this session does NOT make

| # | Decision | Consequence of leaving it open |
|---|---|---|
| **D1** | How much internal process (`.ai/`, `sessions/`, `prompts/`, `.claude/`, `reviewer/`, `darshan/`, ~146 files) goes public. **Unanswered.** | Batches 2–4 proceed; the flip cannot. B/C slimming would break `check_session_coverage` / `check_task_ref` unless the gates are rewritten first |
| **D2** | `core.hooksPath .githooks` is local config only — fresh clones get no hooks and no doc says so | outsider experience; note it in CONTRIBUTING if A is chosen |
| **D3/D6** | `playground/` and untracked `design-reference/*.html`: track as demos, or ignore? | item 13 gitignores them — reversible, not a decision |
| **D4** | Personal-path scrub in 5 tracked files — **irreversible once public** | highest-risk open item; must be answered before the flip |
| **D5** | `pnpm-workspace.yaml` `overrides` cruft (expo/ngrok/rollup/… not in the graph) | needs a lockfile regeneration in its own commit with CI green either side |

## Assumptions (2 — the constitution's cap)

1. **Batch 1 only.** Batches 2–4 become S42–S44. One story per session, ~2h cap, and each
   later batch has its own build-break risk. If the founder wants all four in one session, the
   session splits — it does not stretch.
2. **The flip is not in S41.** S41 makes the tree flip-*ready* and stops. D1 stays open and is
   recorded, not guessed.

## Closeout

- `sessions/session-41-summary.md` — the **fidelity map**: all 13 requirements + both
  assumptions → SHIPPED / PARTIAL / NOT-BUILT, with evidence.
- `sessions/session-41-review.md` — **cold, independent, adversarial**, fed only this contract
  and the diff. Not written by the builder. *No self-certification.*
- 3 next-session options.
- `.ai/` files synced against live facts; `scripts/verify-closeout.sh 41` exit 0.
- Roadmap items created for S42–S44 so batches 2–4 stop being unowned — which is the S40 row 2
  finding this session exists to close.
