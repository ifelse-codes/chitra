# Code Cleanup Plan — Session 41 (S41)

**Purpose:** scope the code cleanup that gates the public repo flip (founder decision,
2026-09-30 — S40 ground-truth row 2: *"the cleanup that gates the flip has no roadmap
item, no scope, and no owner"*). This file **is** that scope.

**Audited:** 2026-10-01 · branch `main` @ `ece61fc` (== `origin/main`) · 501 tracked
files, every top-level directory scanned, full 501-revision git history scanned.
**Nothing is committed yet** — read this file first, then run the batches in §6.

**Verdict:** the product is clean; the repo around it is not.
`packages/core` needs almost no work. ~90% of this plan is repo hygiene,
public-facing honesty fixes, and dead-weight removal.

---

## 0. Audit method (what was actually run)

| Check | Command / scope | Result |
|---|---|---|
| Secret scan, working tree | regex over `npm_…`, `ghp_…`, `github_pat_`, `AKIA…`, PEM headers, `sk-…`, `xox*…`, `Bearer …` | **0 hits** |
| Secret scan, full history | `git log -p --all` (501 revisions) + `NODE_AUTH_TOKEN` literal-value hunt | **0 hits** |
| Personal paths | `/Users/…`, `/home/…`, `C:\Users` | 6 tracked files (§4 E9) |
| Dead markers | `TODO|FIXME|XXX|HACK`, `debugger` | **0 hits** in code |
| Debug output | `console.*` in `packages/core/src` | **0 hits** (only `demo.ts`, which is a demo) |
| Tests | `pnpm --filter @ifelse.codes/chitra run test` | **452/452 pass, 23 files** |
| Typecheck | `pnpm run typecheck` (root, all packages) | **exit 0** |
| Build (with env) | `PORT=5000 BASE_PATH=/ pnpm run build` | **exit 0** |
| Build (fresh clone, no env) | `pnpm run build` | **FAILS** — see §3 E7 |
| Lint | `pnpm run lint` | **FAILS** — eslint not installed (§5 A3) |
| Format | `npx prettier --check packages/core/src/**/*.ts` | **31 files fail** (§5 A4) |

---

## 1. Repository shape (501 tracked files)

| Directory | Files | Role | Cleanup call |
|---|---:|---|---|
| `packages/core` | 65 | **The product.** 6,474 LOC src + 4,306 LOC tests, 20 charts, zero deps | ✅ keep, near-clean |
| `artifacts/chitra-docs` | ~90 | Docs site (live on chitra.iifelse.com) | ⚠️ prune (§2 R3) |
| `artifacts/mockup-sandbox` | **69** | Replit-era Vite sandbox | ❌ **remove** (R1) |
| `artifacts/api-server` | **11** | `/healthz`-only API stub | ❌ **remove** (R2) |
| `lib/` | **20** | db + api-spec + api-client-react + api-zod (only feed api-server) | ❌ **remove** (R2) |
| `scripts/` | 77 | 36 `verify-session-NN.sh` + 36 `demo-session-NN.sh` + tooling | ⚠️ keep session scripts (closeout gate needs them), remove 3 dead files (R5) |
| `sessions/` | 67 | Session records — `check_session_coverage` gate reads them | ✅ keep |
| `prompts/` | 37 | Task contracts — `check_task_ref` gate reads them | ✅ keep |
| `.ai/` | 27 | Constitution, roadmap, state, hooks | ✅ keep (governance decision §4 D1) |
| `.claude/` | 11 | Agent defs + `settings.json` (hooks) | ✅ keep (§4 D1) |
| `.githooks/` | 2 | pre-commit / pre-push | ⚠️ fix hollow ref (E6) |
| `playground/` | 8 | sre-dashboard (tracked) + untracked experiments | ⚠️ decide (R6) |
| `design-reference/` | 3 tracked (+7 untracked) | Design mockups | ⚠️ decide (R6) |
| `attached_assets/` | 3 | Original Replit prompt paste + screenshot | ❌ **remove** (R4) |
| `examples/` | 2 | Working examples | ⚠️ fix run command (E3/A7) |
| `.github/` | 2 | ci.yml + release.yml | ✅ keep, extend (A5/A6) |
| root misc | — | README ✅, LICENSE ✅, CONTRIBUTING ⚠️, replit.md ⚠️, `replit.md`/`.cursorrules`/`CLAUDE.md`/`AGENTS.md` ✅ | as noted |

---

## 2. 🔴 REMOVE — dead weight (102+ tracked files)

### R1 — `artifacts/mockup-sandbox/` (69 files)
- `pnpm run build` at root **fails on it** unless `PORT` + `BASE_PATH` env vars are set
  (its `vite.config.ts` throws — reproduced: root build exit 1, sandbox "Failed").
- **Zero CI jobs** reference it (ci.yml has core / docs / chart-drift / browser-qa only).
- Only mentions outside itself: `sessions/session-08-review.md` (a 2026-07 review noting
  its build was *already* broken at the merge-base) and `.ai/KNOWLEDGE.md` ("Vite sandbox").
- Its own `src/App.tsx` is a mockup-preview host, not part of the docs site.
- **Also drags** `mockupPreviewPlugin.ts`, `.replit-artifact/`, and a second full copy of
  the 55-component shadcn tree.

### R2 — `lib/` (20 files) + `artifacts/api-server/` (11 files)
- api-server serves `/healthz` only. STATE.md and ROADMAP both call it
  *"the undecided 'if the hosted API is pursued' bet, not a task."*
- `lib/api-client-react` is referenced **only** in `artifacts/chitra-docs/tsconfig.json`
  (project reference) — **never imported in docs `src/`** (grep: 0 files).
- Chain beyond the two dirs, must be edited together:
  1. root `tsconfig.json` → references `./lib/db`, `./lib/api-client-react`, `./lib/api-zod`
  2. `artifacts/chitra-docs/tsconfig.json` → reference to `../../lib/api-client-react`
  3. `artifacts/chitra-docs/package.json` → dep `@workspace/api-client-react`
  4. `.github/workflows/ci.yml` → "Build lib type declarations" step (`pnpm run typecheck:libs`)
  5. root `package.json` → `typecheck:libs` script + typecheck filters for `./artifacts/**`
  6. `pnpm-workspace.yaml` → `lib/*`, `lib/integrations/*` globs
- Removal drops: express, drizzle-orm, pino, pino-http, cors, cookie-parser, orval, and
  the entire `zod`/`@tanstack/react-query` pull from the docs side.
- Git history keeps everything — revivable if the hosted API is ever pursued.

### R3 — 46 of 55 shadcn UI components in chitra-docs (~5,179 LOC)
- **Actually imported (12):** button, card, dialog, input, label, separator, sheet,
  skeleton, textarea, toast, toggle, tooltip.
- **Unused (46):** accordion, alert, alert-dialog, aspect-ratio, avatar, badge,
  breadcrumb, button-group, calendar, carousel, chart, checkbox, collapsible, command,
  context-menu, drawer, dropdown-menu, empty, field, form, hover-card, input-group,
  input-otp, item, kbd, menubar, navigation-menu, pagination, popover, progress,
  radio-group, resizable, scroll-area, select, sidebar, slider, sonner, spinner,
  switch, table, tabs, toaster, toggle-group, + the `use-mobile`/`use-toast` hooks if
  orphaned after removal.
- **Deps that go with them** (verified: 0 usage files in docs `src/`):
  `framer-motion`, `react-icons`, `@tanstack/react-query`, `date-fns`, `zod`,
  `@hookform/resolvers`, `@workspace/api-client-react`, plus the radix packages whose
  only consumer is a deleted component: accordion, alert-dialog, aspect-ratio, avatar,
  checkbox, collapsible, context-menu, dropdown-menu, hover-card, menubar,
  navigation-menu, popover, progress, radio-group, scroll-area, select, slider,
  switch, tabs, toggle-group, `recharts` (only `ui/chart.tsx`), `react-day-picker`
  (only `ui/calendar.tsx`), `embla-carousel-react` (only `ui/carousel.tsx`),
  `input-otp` (only `ui/input-otp.tsx`), `cmdk` (only `ui/command.tsx`),
  `sonner` (only `ui/sonner.tsx`), `vaul` (only `ui/drawer.tsx`),
  `next-themes` (only `ui/sonner.tsx`), `react-hook-form` (only `ui/form.tsx`),
  `react-resizable-panels` — ⚠️ **KEEP**: `CatalogPage.tsx` imports it directly.
- Keep deps confirmed in use: `lucide-react` (21 files), `clsx`, `tailwind-merge`,
  `class-variance-authority` (15 files), `wouter`, `react`, `react-dom`, `vite`, etc.
- Also remove the now-orphaned `components.json` entries if any, and the
  `ui/` barrel assumptions in `index.css` if referenced (check after deletion).

### R4 — `attached_assets/` (3 files)
- Original Replit paste (`Pasted-You-are-a-senior-open-source-library-architect…txt`),
  a screenshot, and `chakra-plot-lib__standalone…html`.
- `artifacts/chitra-docs/vite.config.ts:68` defines alias `@assets → attached_assets`,
  but **nothing in docs `src/` imports `@assets`** (grep: 0).
- Action: delete alias + directory. If the founding prompt has sentimental/story value,
  move the `.txt` into `design-reference/` instead of keeping the whole dir.

### R5 — dead scripts
| File | Why dead |
|---|---|
| `scripts/post-merge.sh` | Runs `pnpm --filter db push` — **no package named `db`** exists (`@workspace/db` does), and the script is wired to nothing |
| `scripts/src/hello.ts` | Scaffold junk (`console.log("Hello from @workspace/scripts")`) |
| `scripts/src/demo09-donut.ts` | Referenced only by `scripts/tsconfig.json` **exclude** list; demo-session-09 uses `tsx -e` inline, not this file |
| `scripts/check-hero-dims.py` | One-off S31 hero check (verify if still called by any verify script before deleting) |
| `scripts/build-audit-html.mjs` | **Untracked** one-off; hardcodes `../node_modules/.pnpm/markdown-it@14.1.1/…` path |

⚠️ **Do NOT delete** `scripts/verify-session-NN.sh` / `demo-session-NN.sh`:
`verify-closeout.sh#check_verify_demo_scripts` requires the pair for the **current**
session, and the historical ones are cited throughout `sessions/`.

### R6 — untracked local junk → gitignore (or delete)
`.gitignore` currently covers `*.log`, `.env*`, `dist/`, `.ai/verify/` — **but not:**

```
.commandcode/
.freebuff/
command-code-session-*.html
jev-readiness-plan.md          # Sep-22, superseded by S33/S38/S40 findings
.ai/CHITRA-FRAME-FIX.md        # stale: claims 435 tests, actual 452
playground/buffy-dashboard/    # decide: track or ignore (§4 D3)
playground/chart-card-mock.html
playground/field-test-prompt.md
design-reference/*.html        # 7 untracked mockups — decide: track or ignore
scripts/build-audit-html.mjs   # unless promoted to tracked
```

None of these contain secrets (scanned). `.commandcode/settings.json` contains
**machine-specific absolute paths** (`~/...`) and long permission strings —
must never be committed.

---

## 3. ✏️ EDIT — public-facing lies & broken instructions

### E1 — `VERSION = "0.1.0"` is shipped to npm (the only live API lie)
- `packages/core/src/index.ts:73` → `export const VERSION = "0.1.0";`
- `packages/core/package.json` → `"version": "0.3.0"`
- **Proof it ships:** `packages/core/dist/index.d.ts:13` →
  `export declare const VERSION = "0.1.0";`
- No test references `VERSION` (grep in `tests/`: 0).
- **Fix:** derive at build (replace in `build.mjs`) or import package.json, **and add a
  drift test** (`expect(VERSION).toBe(pkg.version)`) — same lesson as S38's hero-pill
  hardcoded literal: *derive from the source of truth, never restate it.*

### E2 — `CONTRIBUTING.md:9` wrong clone URL
- Says `git clone https://github.com/chitra-dev/chitra.git` — **wrong org**.
- README:75 says `ifelse-codes/chitra` (404 today, resolves on the public flip).

### E3 — `CONTRIBUTING.md` example command is dead
- `node --experimental-specifier-resolution=node examples/basic.ts` —
  the flag is removed from modern Node; output shows only `MODULE_TYPELESS_PACKAGE_JSON`
  warnings and it does not run the file properly.
- `tsx` is **not installed at root** (`node_modules/.bin/tsx` → not found;
  `pnpm exec tsx` → "Command not found").
- **Fix:** add root script `"example": "tsx examples/basic.ts"` + `tsx` to root
  devDeps (already in catalog), update CONTRIBUTING. (A7)

### E4 — `CONTRIBUTING.md` chart template no longer compiles
- Template's returned object omits **`toContent()`**, but `ChartResult`
  (`types.ts:232-243`) **requires** it → a contributor following the guide produces
  a type error.
- Also stale: "Write tests in `tests/charts.test.ts`" — tests are now one file per
  chart (`bar.test.ts`, `line.test.ts`, … 23 files).
- "Add an example in `examples/basic.ts`" fine; structure section omits `artifacts/`,
  `lib/` (post-R2: nothing), `tests/` naming.

### E5 — `replit.md` stale facts
- Claims "Node.js 24, CI on Node 20/22/24" — `ci.yml` pins **`NODE_VERSION: "26"`**,
  single version, and says so in its own comment.
- `ChartResult` line lists `{render, toString, toPlain, toMarkdown, toJSON}` —
  missing `toContent`.

### E6 — hollow hook references in `.githooks/pre-commit`
- Line 56: `if [ -x scripts/hook-drift-guard.sh ]` → **file does not exist**;
  the guard silently no-ops (fail-open — the exact class S40 flagged elsewhere).
- Line ~70: cites `sessions/session-93-summary.md` → **no S93 exists** (max S40);
  the hook text was copied from the Vajra template repo (also references S69/S56).
- **Fix:** either implement `hook-drift-guard.sh` or remove the block; reword the
  provenance comments to not cite non-existent sessions.

### E7 — fresh-clone `pnpm run build` fails
- Root build = `typecheck && pnpm -r build`. Both `artifacts/chitra-docs/vite.config.ts`
  and `artifacts/mockup-sandbox/vite.config.ts` **throw** when `PORT`/`BASE_PATH`
  are unset → exit 1 (reproduced; with `PORT=5000 BASE_PATH=/` → exit 0).
- CI sets the env; a human following README/replit.md does not.
- **Fix (after R1):** default them in docs vite config: `process.env.PORT ?? "5000"`,
  `process.env.BASE_PATH ?? "/"` (CI still overrides).

### E8 — `packages/core/package.json` metadata gaps
- README claims "Requires Node.js 18+" — no `engines` field to enforce it.
- Missing: `"sideEffects": false` (tree-shaking), `"exports": { "./package.json": ... }`.
- CI badge missing from README (has npm/license/deps/charts/tests badges, no
  `actions/workflows/ci.yml` status badge).

### E9 — personal paths in tracked files (privacy scrub)
`~/...` appears in:
- `.ai/handoffs/session-20-tech-lead.md:4`
- `prompts/10-task-line-chart.md:4`
- `sessions/session-25-summary.md:79`
- `sessions/session-26-summary.md:127`
- `sessions/session-40-review.md:43`
- (`scripts/build-audit-html.mjs` has `.pnpm` version path — untracked, R5)
**Decision:** scrub (rewrite as relative/`~`-style) vs. accept as honest history (§4 D4).

---

## 4. ⚖️ FOUNDER DECISIONS (must answer before the flip)

**D1 — How much governance to expose?** ~170 tracked files are internal AI-workflow
(`.ai/` 27, `sessions/` 67, `prompts/` 37, `.claude/` 11, `reviewer/`, `darshan/`,
`.githooks/`, `AGENTS.md`, `CLAUDE.md`, `.cursorrules`).
- **Option A — keep all** (recommended): it's a genuine, unusual story ("built and
  audited by agents, 452 tests, zero deps"), and cutting it breaks the closeout gates
  that read `sessions/` + `prompts/`.
- **Option B — slim**: keep `.ai/AGENTS.md` + ROADMAP, move `sessions/`+`prompts/`
  to a `/process` branch. ⚠️ breaks `check_session_coverage` / `check_task_ref`
  unless gates are rewritten first.
- **Option C — strip entirely**: highest privacy, highest gate rework.
- ⚠️ **`.claude/settings.json` is tracked** → its hooks fire for *any* Claude Code
  user who clones. They only guard `session-NN-*` branches and main-commits, so
  outsiders on `fix-*` branches should pass — **but this was never tested as an
  outsider.** Test with a scratch clone before the flip.

**D2 — Hooks activation.** `core.hooksPath .githooks` is set only in *this* clone
(local config, not versioned). Fresh clones get **no hooks** unless they run the
setup command, which no document mentions. Decide: document it (CONTRIBUTING) or
accept hooks are founder-only tooling.

**D3 — `playground/` and untracked `design-reference/*.html`** — track as examples
(they're good demos of the library) or ignore them? Half-tracked today (sre-dashboard
tracked, buffy-dashboard not) is the worst option.

**D4 — Personal-path scrub (E9)** — rewrite vs. keep as honest history.

**D5 — `pnpm-workspace.yaml` cruft.** 100+ lines of `overrides` disabling platform
binaries for **expo / ngrok / rollup / lightningcss / esbuild** — expo and ngrok are
**not in the dependency graph** (`grep -c "expo\|ngrok" pnpm-lock.yaml` → 2, both from
the overrides themselves). Replit-template residue. Removing = lockfile regeneration;
do it in its own commit with CI green before/after.

---

## 5. ➕ ADD — public-OSS expectations

| # | Item | Detail |
|---|---|---|
| A1 | `SECURITY.md` + `.github/ISSUE_TEMPLATE/bug_report.md` + `feature_request.md` + `PULL_REQUEST_TEMPLATE.md` | npm package with no vuln-reporting path |
| A2 | `CODE_OF_CONDUCT.md` | Expected for community PRs |
| A3 | **Make lint real** | `pnpm run lint` = `eslint src tests` but **eslint is not installed** (0 matches in pnpm-lock) and no config exists → script fails. Install + flat config + CI step, **or delete the script** (STATE.md already tracks this as "unrunnable") |
| A4 | **Prettier config** | `prettier ^3.8.3` in root devDeps, **no `.prettierrc`**, 31 core files fail `--check`. Add config + `format` script + CI `--check` job (one `--write` pass in its own commit) |
| A5 | CI badge in README | Shields.io GitHub Actions badge next to the npm badge |
| A6 | Coverage gate | CONTRIBUTING promises "Target >90% test coverage"; CI has **no coverage job**. Add `test:coverage` to CI with a threshold, or soften the claim |
| A7 | `pnpm example` root script | Fixes E3; add `tsx` to root devDeps |
| A8 | `engines` field | `"engines": { "node": ">=18" }` in `packages/core/package.json` (matches README claim) — or raise the README claim to what CI proves (Node 26) |
| A9 | VERSION drift test | See E1 |

---

## 6. Execution order (batches — each ends green before the next starts)

> Constitution: branch `session-41-<slug>` from `main`, max 3 files per atomic
> commit, `scripts/verify-session-41.sh` + `demo-session-41.sh` exit 0, cold review,
> PR to `main`.

### Batch 1 — honesty + blockers (nothing else starts until this is green)
1. **E1** VERSION derive + drift test (core: 2 files)
2. **E2/E3/E4** CONTRIBUTING rewrite (clone URL, run command, chart template with
   `toContent()`, test file naming) + **A7** root example script
3. **E5** replit.md facts (Node 26, ChartResult shape)
4. **E7** docs vite defaults for `PORT`/`BASE_PATH`
5. **R6** `.gitignore` additions + delete the junk files listed there
6. **E6** pre-commit hook: drop the phantom `hook-drift-guard.sh` block + fix
   S93 citation
- **Gate:** `pnpm --filter @ifelse.codes/chitra test` (452) · `pnpm run typecheck` ·
  **`pnpm run build` with NO env set, exit 0** · `git status` clean of junk

### Batch 2 — dead weight
1. **R1** delete `artifacts/mockup-sandbox/`
2. **R2** delete `lib/` + `artifacts/api-server/` and edit the 6-point chain listed
   there (root tsconfig, docs tsconfig, docs package.json, ci.yml, root scripts,
   pnpm-workspace)
3. **R4** delete `attached_assets/` + `@assets` alias
4. **R5** delete the 3–5 dead scripts
- **Gate:** same as Batch 1 + **`scripts/qa-catalog.mjs` (browser QA)** +
  `gen:charts:check` + CI green on the PR

### Batch 3 — docs weight (biggest install-time win)
1. **R3** delete 46 unused UI components, then prune package.json deps one-by-one,
   re-running docs typecheck after each group
2. **A4** prettier config + one `--write` pass + CI check
3. **A3** eslint decision + wiring
- **Gate:** docs typecheck + build + browser QA + CI green; lockfile diff reviewed

### Batch 4 — OSS polish + decisions
1. **A1/A2** SECURITY.md, CoC, issue/PR templates
2. **A5/A6** CI badge + coverage
3. **A8** engines field
4. **E9** + **D1–D5** (founder answers) — privacy scrub, governance exposure,
   playground, workspace overrides cleanup
5. Re-run the S40-class probes: secret scan (expect 0), `pnpm run lint` (expect
   pass-or-gone), fresh-clone build (expect 0)
- **Gate:** full verify + **cold independent review** (no self-certification) +
  closeout `verify-closeout.sh 41` green

**Then:** the public flip resolves README `git clone`, npm `repository.url`,
`homepage` (all three 404s) **and** enables npm provenance in one move — the flip is
*after* this plan, not part of it.

---

## 7. What NOT to touch

- **`packages/core/src/` chart implementations** — LOCKED design language (S09–S28),
  452 tests green, no dead markers, zero deps. Only E1 touches it.
- **`scripts/verify-session-*.sh` / `demo-session-*.sh`** — closeout gates read them.
- **`sessions/` + `prompts/`** — `check_session_coverage` / `check_task_ref` read them
  (unless D1 chooses Option B/C *with* gate rewrites).
- **`@ifelse.codes/core` references inside `sessions/`, old `prompts/`, old verify
  scripts, and the dated KNOWLEDGE.md sections** — frozen history, on purpose.
- **`release.yml` OIDC publish path** — configured, and S40 says the cheapest proof is
  a real `0.4.0` through CI (can ride along after Batch 1).

## 8. Known issues deliberately out of scope here (tracked elsewhere)

| Issue | Where tracked |
|---|---|
| Unattended publishing unproven (no release through CI since trusted publisher created) | STATE.md → candidate: real `0.4.0` |
| `required-crew` closeout gate structurally wrong (3rd waiver) | GT-REMEDIATIONS row 5 |
| `check_ground_truth_no_code` fail-open on empty range | GT-REMEDIATIONS row 10 |
| Cost gate greps a heading | GT-REMEDIATIONS row 8 |
| S16 vanished, no gate can see it | GT-REMEDIATIONS row 4 |
| GTM proof pack (record zero downloads as `t0`) | GT-REMEDIATIONS row 1 |
| Height control inconsistent across charts; `toPlain()` keeps frame chars; no `maxWidth` enforcement everywhere | `.ai/CHITRA-FRAME-FIX.md` "Remaining Issues" (delete file, move rows to ROADMAP backlog) |
| MCP server | founder-deferred until demanded |
| Adoption baseline = zero | correct pre-launch reading; never cite the 304 self-downloads |
