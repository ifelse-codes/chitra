# Independent Audit — chitra (blind pass)

**Audited:** 2026-10-01 · branch `main` @ `ece61fc` (== `origin/main`) · remote `https://github.com/ifelse-codes/chitra.git`
**Method:** every claim below is backed by a file:line or a command I ran in this checkout (or in a fresh `git clone --local` at `/tmp/chitra-audit-clone`). I did not read the prior audit before writing this; a diff against `code-cleanup-plan-session-41.md` is in §8.

**Assumptions (2, both stated rather than guessed):**
1. The public repo is `github.com/ifelse-codes/chitra` and the flip publishes *this* tree with *this* history (no history rewrite).
2. "Ready" means a stranger can clone → install → build → test → read honest docs with no founder-only context.

---

## 1. Verdict (3 lines)

**Not ready to flip — but the gap is the repo around the product, not the product.**
`packages/core` is genuinely clean (452/452 tests on a fresh clone, zero runtime deps, no dead markers, correct published tarball); the failures are public-surface honesty, ~100 files of Replit-scaffold dead weight, and a broken documented build path.
**Single biggest risk: irreversible privacy — machine-specific absolute paths and internal publish/audit forensics are committed now, so the flip publishes them to history forever.**

---

## 2. 🔴 REMOVE

| # | What | Files | Evidence it is dead |
|---|---|---:|---|
| R1 | `artifacts/mockup-sandbox/` | 69 | Replit design sandbox. Its `vite.config.ts` throws on missing `PORT`; `pnpm run build` (root, dist present) dies on it: `Error: Invalid PORT value: "0"` → `Failed` (`/tmp/build.out`). Zero CI jobs reference it. Ships a second copy of the 55-file shadcn tree. |
| R2 | `lib/db`, `lib/api-zod`, `lib/api-client-react`, `lib/api-spec` + `artifacts/api-server/` | 20 + 11 | `artifacts/api-server/src/routes/health.ts:2` imports `@workspace/api-zod`; nothing else imports any `lib/*` package except project references (`tsconfig.json`, `artifacts/chitra-docs/tsconfig.json:21`) and the docs `devDependency` (`artifacts/chitra-docs/package.json:57`), which is never imported in `src/`. api-server exposes `/healthz` only. |
| R3 | Unused shadcn components in `artifacts/chitra-docs/src/components/ui/` | **43 of 55** | Reachability walk over `src/**` (script in §7): only 12 are reachable — `button, card, dialog, input, label, separator, sheet, skeleton, textarea, toast, toggle, tooltip`. (Prior audit said 46; my count is 43 — they likely counted the 2 hooks plus one more. Either way the set is dead.) Each unused file drags a radix dep: `accordion, alert, alert-dialog, aspect-ratio, avatar, badge, breadcrumb, button-group, calendar, carousel, chart, checkbox, collapsible, command, context-menu, drawer, dropdown-menu, empty, field, form, hover-card, input-group, input-otp, item, kbd, menubar, navigation-menu, pagination, popover, progress, radio-group, resizable, scroll-area, select, sidebar, slider, sonner, spinner, switch, table, tabs, toaster, toggle-group`. |
| R4 | `attached_assets/` | 3 | Original prompt paste + screenshot + `chakra-plot-lib__standalone__….html`; its only reference is the `@assets` alias at `artifacts/chitra-docs/vite.config.ts:68`, which nothing in `src/` imports. |
| R5 | Dead scripts: `scripts/post-merge.sh`, `scripts/src/hello.ts`, `scripts/src/demo09-donut.ts`, `scripts/check-hero-dims.py`, `scripts/build-audit-html.mjs` | 5 | `post-merge.sh` runs `--filter db` against a package named `@workspace/db`. `hello.ts` is scaffold (`console.log("Hello from @workspace/scripts")`). `demo09-donut.ts` is only in `scripts/tsconfig.json`'s exclude list. `build-audit-html.mjs` is untracked and hardcodes a `.pnpm/markdown-it@14.1.1` path. |
| R6 | Untracked local junk a careless `git add -A` would ship | 19 paths | `git status --porcelain` lists `.commandcode/`, `.freebuff/`, `command-code-session-8b98ceae.html` (277 KB agent transcript containing `/Users/REDACTED/...`), `code-cleanup-plan-session-41.md`, `jev-readiness-plan.md` (2026-09-22, stale), `.ai/CHITRA-FRAME-FIX.md` (claims "435 tests pass", actual 452), `playground/buffy-dashboard/`, `playground/chart-card-mock.html`, `playground/field-test-prompt.md`, 9 × `design-reference/*.html`, `scripts/build-audit-html.mjs`, `independent-audit-prompt.md`. No secrets in them (scanned), but `.commandcode/settings.json` and the transcript carry machine paths. |
| R7 | `packages/core/README.md` internal design log | 1 (ships to npm, 50.4 kB) | 19 `### LOCKED: … session NN design` sections (lines 95–783) reference internal sessions and the `mudra` design reference; the npm page currently prints this. See E3. |
| R8 | Internal process tree (founder call, §5 D1): `.ai/` 27, `sessions/` 67, `prompts/` 37, `.claude/` 11, `reviewer/` 1, `darshan/` 1, `.githooks/` 2 | 146 | Not "dead" — internal. `reviewer/SKILL.md` and `darshan/SKILL.md` describe another project's ("Vajra") machinery and cite `sessions/session-55-review.md`, `session-93-summary.md` (do not exist here; max session 40). |

⚠️ **Do not bulk-delete** `scripts/verify-session-NN.sh` / `demo-session-NN.sh` — `scripts/verify-closeout.sh` reads the current session's pair. But note: most historical ones are already unrunnable (E9).

---

## 3. ✏️ EDIT (file:line — the false/broken thing — the fix)

| # | File:line | False / broken | Fix |
|---|---|---|---|
| E1 | `artifacts/chitra-docs/index.html:7,10,14` | **Live** meta text: `"Chitra Docs — built on Replit. Update this description to reflect the app."` — served now at https://chitra.iifelse.com (verified: `read_url` description + in-browser `meta[name=description]`). This is what search engines and social cards show. | Replace title/description/og/twitter with the real product line. |
| E2 | `packages/core/src/index.ts:73` | `export const VERSION = "0.1.0"` while `packages/core/package.json:3` is `0.3.0`. Exported public API, ships in `dist/index.d.ts`. | Derive from package.json at build + add a drift test. |
| E3 | `packages/core/README.md:80-86` | Renderers section says **“`block` (default for line)”**, but `packages/core/src/charts/line.ts:151` is `opts.renderer ?? "braille"`, and the same README's Quickstart says "braille renderer by default". Also "Three Renderers" then lists four bullets. | State the real default (`braille`) and cut the contradictory bullet; strip the internal `LOCKED` design-log sections (R7). |
| E4 | `CONTRIBUTING.md:9` | `git clone https://github.com/chitra-dev/chitra.git` — wrong org (remote is `ifelse-codes/chitra`). | Correct the URL. |
| E5 | `CONTRIBUTING.md:23` | Run-examples command `node --experimental-specifier-resolution=node examples/basic.ts` fails: `ERR_MODULE_NOT_FOUND … packages/core/src/index.js`. `tsx` is not at the root either. | Add a root `example` script using `tsx`; document it. |
| E6 | `CONTRIBUTING.md:117` | "Target >90% test coverage" — `test:coverage` actually **fails**: `ERROR: Coverage for functions (86.28%) does not meet global threshold (90%)` (`vitest.config.ts` thresholds). | Fix coverage or soften the claim + gate it in CI. |
| E7 | `CONTRIBUTING.md:55-72` | Chart template returns `{render,toString,toPlain,toMarkdown,toJSON}` but `ChartResult` requires `toContent()` (`packages/core/src/types.ts:237`) → a contributor following the guide gets a type error. Also "Write tests in `tests/charts.test.ts`" (tests are now one file per chart, 23 files). | Add `toContent()`; fix the test-file guidance. |
| E8 | `replit.md:15,32` | "Node.js 24"; "CI on Node 20/22/24". CI pins `NODE_VERSION: "26"` (`.github/workflows/ci.yml`), one version. | State Node 26 (or the real engines floor). |
| E9 | `scripts/verify-session-07.sh:62` (also `01:28`, `34`, `36`) | Uses the removed package name `--filter @chitra/core` and greps `'116 passed'` (now 452). `pnpm --filter @chitra/core run test` → `No projects matched the filters`. | If kept, mark historical; don't advertise them as runnable gates. |
| E10 | root `package.json:7` | `"build": "pnpm run typecheck && pnpm -r … build"` — **fails on any fresh clone**: docs typecheck resolves `@ifelse.codes/chitra` through the gitignored `dist/`, so `artifacts/chitra-docs/src/components/CatalogPage.tsx(4,29): error TS2307`. Reproduced twice on a clean clone, **with and without** `PORT`/`BASE_PATH`. | Reorder: build `@ifelse.codes/chitra` (or its declarations) before the docs typecheck. ⚠️ This is the place the prior plan's fix is insufficient — see §8. |
| E11 | `artifacts/chitra-docs/vite.config.ts:7-26` (+ `artifacts/mockup-sandbox/vite.config.ts`) | Hard-throws when `PORT`/`BASE_PATH` are unset → root build fails even when `dist` exists. | Default them (`?? "5000"` / `?? "/"`); CI still overrides. |
| E12 | `.githooks/pre-commit:26,28,56-57` | Hollow guard + fabricated provenance: `if [ -x scripts/hook-drift-guard.sh ]` — file does not exist (fail-open), and the comment cites `sessions/session-93-summary.md` (max session here is 40) plus `scripts/hook-commit-guard.sh` (the real file is `.ai/hooks/hook-commit-guard.sh`). | Implement the guard or delete the block; fix the paths/citations. |
| E13 | `.github/workflows/release.yml:99-103` | Comment asserts "the GitHub repo is private, and npm does not generate provenance for private repos … Making the repo public would turn provenance on". True today, **a lie the moment of the flip**. | Re-word on flip: provenance is now produced for public repos. |
| E14 | `README.md:142` | MCP note says deferral is "tracked in `.ai/ROADMAP.md`" — a public README pointing into internal process; dangles if R8 strips `.ai/`. | Point at a public roadmap or drop the pointer. |
| E15 | `pnpm-workspace.yaml:4` | `- lib/integrations/*` — no such directory exists. | Delete the glob (with R2). |
| E16 | `packages/core/package.json` | README claims "Requires Node.js 18+", but there is **no `engines` field anywhere** (`git grep '"engines"'` → none). | Add `engines` matching reality. |
| E17 | 5 tracked files | Personal absolute paths `/Users/REDACTED/...`: `.ai/handoffs/session-20-tech-lead.md:4`, `prompts/10-task-line-chart.md:4`, `sessions/session-25-summary.md:79`, `sessions/session-26-summary.md:127`, `sessions/session-40-review.md:43`. | Scrub or accept as history (§5 D4); decide **before** the flip — history is forever after. |
| E18 | `.ai/STATE.md:3-9` + `.ai/SESSION` | Describes state that is no longer true: "S40 ground-truth audit in progress", branch `session-40-ground-truth`, `.ai/SESSION` = `40` — while S40 is merged (#60/#61) and S41 cleanup is the active work. | Refresh or remove with R8. |
| E19 | `.ai/STATE.md:19-30`, `.ai/KNOWLEDGE.md`, `prompts/37-task-publish-v0.1.0.md` | Internal npm/publish forensics ("CI published 0.3.0 zero times", "A human published at 13:30:46Z", `gh secret set NODE_AUTH_TOKEN`, "trusted publisher … not repo-verifiable"). No secret values, but it is the wrong material for a public front page. | Keep private, or curate deliberately. |

---

## 4. ➕ ADD (what the public launch needs)

| # | Item | Why |
|---|---|---|
| A1 | `SECURITY.md` | Published npm package with no vulnerability-reporting path. |
| A2 | `.github/ISSUE_TEMPLATE/bug_report.md`, `feature_request.md`, `PULL_REQUEST_TEMPLATE.md` | `.github/` today contains only `ci.yml` and `release.yml`. |
| A3 | `CODE_OF_CONDUCT.md` | Expected the moment outside PRs are invited. |
| A4 | Make `lint` real **or delete it** | `packages/core/package.json` has `"lint": "eslint src tests"`, but `eslint` is not a dependency (`grep -c eslint pnpm-lock.yaml` → 0, no config file) → `eslint: command not found`; and root `pnpm run lint` → `ERR_PNPM_NO_SCRIPT Missing script: lint`. |
| A5 | Prettier config (or drop the dep) | `prettier ^3.8.3` is a root devDep; no `.prettierrc`; `prettier --check 'packages/core/src/**/*.ts'` → "Code style issues found in 31 files." |
| A6 | CI status badge in `README.md` | Shields have npm/license/deps/charts/tests but no Actions badge. |
| A7 | Coverage job in CI **or** remove the promise | CONTRIBUTING promises >90%; `test:coverage` is red (E6) and CI never runs it. |
| A8 | `engines` field | E16. |
| A9 | Root `example` script (+ `tsx`) | E5. |
| A10 | `VERSION`-drift test | E2. |

---

## 5. ⚖️ Founder decisions (no agent should make these)

- **D1 — How much internal process goes public?** `.ai/` (27), `sessions/` (67), `prompts/` (37), `.claude/` (11), `reviewer/`, `darshan/`, `.githooks/` (2) = ~146 files, plus `AGENTS.md`/`CLAUDE.md`/`.cursorrules`. Option A keep (unusual honest-build story) / B slim (keep `.ai/AGENTS.md`+`ROADMAP.md`, move session records to a `/process` branch) / C strip. **B and C break `verify-closeout.sh`'s `check_session_coverage` / `check_task_ref`** unless the gates are rewritten first. Note `.claude/settings.json` is tracked — its hooks fire for any Claude Code user who clones; they only guard `session-NN-*` branches and main, but that has never been tested as an outsider.
- **D2 — Hooks activation.** `core.hooksPath .githooks` is local config only. Fresh clones get no hooks; no doc mentions the setup. Document it or accept hooks are founder-only.
- **D3 — `playground/` + untracked `design-reference/*.html`.** Track as demos or ignore? Half-tracked (sre-dashboard tracked, buffy-dashboard not) is the worst state.
- **D4 — Personal-path scrub (E17).** Irreversible after the flip if history is published.
- **D5 — `pnpm-workspace.yaml` template residue.** ~140 lines of `overrides` disabling platform binaries for expo/ngrok/rollup/lightningcss/esbuild; expo and ngrok are not in the graph. Removing means a lockfile regeneration in its own commit.
- **D6 — Untracked junk policy (R6).** Delete vs gitignore — either is fine, but decide before someone runs `git add -A`.

---

## 6. ✅ Verified clean (so the next reader doesn't re-audit)

| Check | Method | Result |
|---|---|---|
| Secrets, working tree | regex over `npm_…`, `ghp_…`, `sk-…`, `AKIA…`, PEM, `xox*` across all tracked files | **0 hits** |
| Secrets, history | `git log --all -p` added-line scan; `-S NODE_AUTH_TOKEN`; every blob for `_authToken/_auth`; `.npmrc`/`.env` ever committed | **0 secret values**; only variable names/comments |
| Dead markers / debug output | `TODO|FIXME|HACK|XXX`, `debugger`, `console.*` in `packages/core/src` | **0** |
| Tests | `pnpm --filter @ifelse.codes/chitra run test` (main + fresh clone) | **452 passed / 23 files**, both |
| Root typecheck | `pnpm run typecheck` | **exit 0** |
| Chart drift | `pnpm --filter @workspace/chitra-docs run gen:charts:check` | exit 0, all four JSON sources up to date |
| CI docs sequence on a fresh clone | `typecheck:libs` → core build → docs typecheck → docs build (`PORT=5000 BASE_PATH=/`) | **all green** |
| Published artifact | `npm view @ifelse.codes/chitra@0.3.0 --json` + `npm pack @ifelse.codes/chitra@0.3.0` | 38 files incl. `dist/index.d.ts`; version/metadata match the local manifest |
| Product facts | `packages/core/src/charts/index.ts` = 20 charts; `types.ts` = 3 renderers, 7 themes; `packages/core/package.json` = 0 deps | **README badge claims are true** (test count 452, charts 20, deps 0) |
| Browser QA gate | read `scripts/qa-catalog.mjs` | Real gate: fails on console/page errors, missing terminal output on any chart page, and failed persistence smoke; not vacuous |
| Live docs | browser at https://chitra.iifelse.com | Renders, `v0.3.0 · npm`, correct install command, 20/3/7/452/0 stats — only the scaffold meta (E1) is wrong |

---

## 7. Batched execution order (every batch ends on a named green gate)

**Batch 1 — blockers + honesty (do not start anything else until green)**
E1 · E2 · E3(+R7) · E4/E5/E6/E7 · E8 · E10 (build order) · E11 (vite defaults) · E12 · E15 · E16 · A9.
Gate: `pnpm --filter @ifelse.codes/chitra run test` (452) · `pnpm run typecheck` · **fresh clone: `pnpm install --frozen-lockfile && pnpm run build` exit 0 with no env** · `gen:charts:check`.

**Batch 2 — dead weight**
R1 · R2 (edit the 6-file chain: root `tsconfig.json`, docs `tsconfig.json:21`, docs `package.json:57`, `.github/workflows/ci.yml` "Build lib type declarations", root `package.json` `typecheck:libs`, `pnpm-workspace.yaml`) · R4 · R5.
Gate: Batch 1 gate + `node scripts/qa-catalog.mjs` (browser QA) + CI green on the PR.

**Batch 3 — docs weight**
R3 (43 components, then prune `artifacts/chitra-docs/package.json` deps group-by-group) · A5 (Prettier) · A4 (eslint decision).
Gate: docs typecheck + build + browser QA + lockfile diff reviewed.

**Batch 4 — OSS polish + decisions**
A1–A3, A6–A8 · E13, E14, E17–E19 · D1–D6.
Gate: full verify + a cold independent review + re-run the §6 probes.

**Then, and only then, the flip** (which also resolves the README clone URL and turns npm provenance on).

---

## 8. Diff vs `code-cleanup-plan-session-41.md` (what one reviewer missed)

**Confirmed independently** (S41 was right; my commands reproduced it): mockup-sandbox breakage, `lib/`+api-server dead, `VERSION=0.1.0`, wrong CONTRIBUTING clone URL, dead example command, stale replit.md Node facts, phantom `hook-drift-guard.sh`, untracked junk, personal paths (exactly 5 files), tests 452, root typecheck 0, published tarball correct.

**Missed by S41:**

1. **The live docs site's scaffold meta (E1).** S41 never mentions `artifacts/chitra-docs/index.html` — yet its meta/og/twitter description is *the Replit template placeholder*, and it is live at chitra.iifelse.com today. This is the highest-visibility honesty defect in the repo and the first audit missed it.
2. **`packages/core/README.md` is an internal design log that ships to npm (R7/E3).** 19 `### LOCKED: … session NN design` sections naming internal sessions and the `mudra` reference; plus a self-contradiction on the line default (`block (default for line)` vs `line.ts:151` `?? "braille"`). S41 reviewed the README badges but not its body.
3. **The prescribed fix for the fresh-clone build does not fix it (E10).** S41's E7 attributes the failure to unset `PORT`/`BASE_PATH` and proposes defaulting them in the vite configs. I reproduced the failure on a pristine clone **with `PORT=5000 BASE_PATH=/` set** — it still fails earlier, at `artifacts/chitra-docs` typecheck, `TS2307: Cannot find module '@ifelse.codes/chitra'`, because core's `dist/` is gitignored and nothing builds it before typecheck. S41's own Batch 1 gate ("`pnpm run build` with NO env set, exit 0") therefore cannot be met by its E7 fix; the build order (or a `paths` mapping for docs) must change too.
4. **The tracked closeout script gates on an external Rust binary and cites foreign sessions (E9, E12).** `scripts/verify-closeout.sh` resolves `vajra` from `PATH` (`BLOCK: vajra not found on PATH`) and comments reference S119/S124/S139/S144 of another project; `reviewer/SKILL.md`, `darshan/SKILL.md` and `.githooks/pre-commit` cite `sessions/session-55/93-review.md`, which don't exist here. S41 flags one hollow hook but presents the rest of the process tree as "keep".
5. **Historical verify scripts are already unrunnable.** `verify-session-07.sh:62` (and 01/34/36) still filter `@chitra/core` and assert "116 tests" / "452 tests" against renamed packages. S41 keeps all verify scripts to protect `verify-closeout.sh` — true for the *current* session's pair, but the older ones are dead weight, not runnable gates.
6. **`.github/workflows/release.yml:99-103` becomes a false statement at the flip** (provenance comment). S41's closing line notes the flip enables provenance but doesn't list the comment as an edit.
7. **`pnpm-workspace.yaml:4` globs `lib/integrations/*`, a directory that does not exist** (folded into S41's D5 cruft but not named).
8. **Minor count correction:** S41's R3 says 46 unused of 55; my reachability walk says **43 unused, 12 reachable** (55 total).

**Where this audit could not go further:** I did not install Playwright Chromium to execute `qa-catalog.mjs` (I reviewed its assertions instead), and I did not exercise a scratch clone *as a non-owner user* to prove `.claude/settings.json` hooks are harmless to outsiders (S41 D1 flags this too — it genuinely needs the founder/another machine).

---

*No file other than this one was modified. Nothing was committed.*
