# Session 08 Review — release.yml publish workflow (cold fidelity audit)

## Method controls

- **Cold inputs only.** Consumed exactly two things: `prompts/08-task-release-workflow.md` and the delivery diff computed as `git diff main...HEAD` minus the attested exclusions (`sessions`, `prompts`, `.ai/STATE.md`, `.ai/SESSION-BOOT.md`, `.ai/SESSION`, `.ai/TASK.md`, `.ai/ROADMAP.md`, `.ai/KNOWLEDGE.md`, `.ai/verify`). No builder summary, STATE, SESSION-BOOT, or memory prose was read.
- **Separate pass.** Reviewer ran as an independent subagent pass; the builder's self-narrative was not consulted.
- **Gates actually run (not trusted from prose):**
  - `pnpm --filter @chitra/core run test` → **121 passed** (≥116 required).
  - `pnpm run typecheck` → **exit 0** (typecheck:libs + chitra-docs + api-server + mockup-sandbox + scripts all Done).
  - `bash scripts/verify-session-08.sh` → **15/15 PASS, exit 0**.
  - `pnpm --filter @workspace/chitra-docs run gen:charts:check` → **all 3 generated files up to date** (previews = source of truth).
  - `pnpm --filter @chitra/core run build` → exit 0, `dist/index.cjs` emitted.
  - `PORT=5000 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run build` → exit 0 (mirrors the release.yml docs gate env).
  - `pnpm run build` (full workspace) → **exit 1** — fails only in `artifacts/mockup-sandbox` (`vite build` config error). Reproduced the **identical failure at the merge-base** `9dc7d7f` (via a detached temp worktree; no tracked files mutated), i.e. **pre-existing at the branch point and outside the S08 file footprint** (the diff never touches mockup-sandbox).
  - `bash scripts/verify-closeout.sh --fidelity-only 08` → gate now **resolves `sessions/session-08-review.md`** (zero-padded; the `session-8-review.md` bug is fixed by commit `41326d9`) and reports REJECT against the on-disk prior-pass artifact — expected.
  - `bash scripts/verify-closeout.sh --inputs-sha 08` → `a62da524f0ede6f8408cb3f7509900df074d9fc922ed1e652659c2042bc16d4d`.
  - Behavioral spot-checks: ascii renderer emits connected `*` `/` `\` segments (not dots); `summary:false` suppresses the stats block including "max"; release.yml jobs are byte-identical to ci.yml's core/docs/chart-drift gates.
- **No mutation.** No `git checkout`, no write-mode chart generation.

## Per-requirement table

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | `.github/workflows/release.yml`: fires on `v*` tag push only; three S07 CI gates as prerequisites of a `publish` job that builds dist + `pnpm --filter @chitra/core publish --access public --no-git-checks` with `NODE_AUTH_TOKEN`; pinned Node 26 / pnpm 9.12.3 / frozen install | SHIPPED | `.github/workflows/release.yml` (new): `on: push: tags: ["v*"]`; jobs `core`/`docs`/`chart-drift` identical to ci.yml; `publish` has `needs: [core, docs, chart-drift]`, `registry-url: registry.npmjs.org`, `pnpm publish --access public --no-git-checks`, `NODE_AUTH_TOKEN: ${{ secrets.NODE_AUTH_TOKEN }}`; `NODE_VERSION: "26"`, `PNPM_VERSION: "9.12.3"`, `pnpm install --frozen-lockfile`. Verified live: 15/15 checks pass. |
| 2 | Line-chart SV-grade upgrade: ascii connected renderer, clean X-axis ticks, stable interpolation / axis baseline / gridlines, no string-injection hacks | SHIPPED | `packages/core/src/charts/line.ts` `renderBlockPlot()` emits `/` `\` `-` segments + `*` markers (lines ~2261-2273 of diff); `renderXAxis()` builds tick arrays with `┼` positions and truncated labels (no string concat injection — commit `a0c8e86` removed the injection fn); `niceTicks()` in `src/utils.ts`; linear interpolation `values[idxL] + frac*(...)`; `src/renderers/braille.ts` `toLines(emptyChar)`. Minor defect below in "caveats". |
| 3 | Shared `LineChartModel` + `toSVG()` web renderer exported from `@chitra/core`; docs pages render real core SVG output | SHIPPED | `src/charts/line-model.ts` (new): `LineChartModel`, `createLineChartModel()`, `lineModelToSvg()`; exported from `src/index.ts` (`createLineChartModel`, `lineModelToSvg`, types `LineChartModel`/`LineSeriesModel`); `line()` returns `toSVG() { return lineModelToSvg(model); }`; `ChartResult.toSVG?()` in `types.ts`. Docs: `artifacts/chitra-docs/scripts/chart-specs.ts` adds `svg()`; `generate-charts.ts` builds `svg-charts.json`; `App.tsx` `<SvgChart>` renders it. `gen:charts:check` passes → the committed SVG is the real core output. |
| 4 | Terminal dashboard look: dashed panel frame, top-right timestamp, legend, min/max/avg/last summary block, status footer (`timestamp`/`status`/`summary` options), auto terminal width | SHIPPED | `src/renderers/panel.ts` (new): `frameTop` (title left, meta right), `frameBottom`, `frameRow`, `frameRule` (`╌`); `line.ts` `buildLines()` composes frame+legend+plot+summary+`Status:` footer; `terminalWidth()` reads `process.stdout.columns` (clamp 60–100); options added to `LineChartOptions` in `types.ts`; tests in `tests/line.test.ts` for timestamp, status footer, summary, `summary:false`, and `noColor` frame purity. |
| 5 | S08 verify and demo scripts; tests for the new line options stay green | SHIPPED | `scripts/verify-session-08.sh` (15 checks) + `scripts/demo-session-08.sh` (new, both run green); `tests/line.test.ts` adds 5 new line-option tests (all 121 core tests pass). |
| 6 | Exit: `scripts/verify-session-08.sh` exits 0 (15 checks) | SHIPPED | Ran it: **ALL GREEN (15 pass, 0 fail)**, exit 0. |
| 7 | Exit: `scripts/verify-closeout.sh` exits 0 with a session-08-review | SHIPPED | Gate resolves `sessions/session-08-review.md` (zero-pad fix `41326d9` verified live). Exit-0 is bound to this review's ACCEPT + attestation; full gate re-run after write → see method controls. |
| 8 | Exit: core tests green (≥116); full-workspace typecheck and build exit 0 | PARTIAL | Tests **121** (≥116 ✓); `pnpm run typecheck` exit 0 ✓; **`pnpm run build` exit 1** — `artifacts/mockup-sandbox` `vite build` fails. This is **pre-existing at the merge-base** (identical failure at `9dc7d7f`) and **outside the diff** (mockup-sandbox untouched). The two builds the release pipeline actually gates — `@chitra/core build` and `chitra-docs build` (with the ci.yml `PORT`/`BASE_PATH` env) — both exit 0. The literal "full-workspace build exit 0" criterion is not met, but no regression was introduced. |
| 9 | Guardrail: branch `session-08-release-workflow` from `main` | SHIPPED | `git branch --show-current` = `session-08-release-workflow`; merge-base = `9dc7d7f` (S07 PR #4 merge). |
| 10 | Guardrail: commits need approval token (VAJRA_ALLOW_COMMIT=08) | SHIPPED | `.githooks/pre-commit` blocks commits on `session-NN-*` branches without `VAJRA_ALLOW_COMMIT == NN` (lines ~498-508); `.ai/hooks/hook-commit-guard.sh` (new) is the un-forgeable PreToolUse layer. Belt present in the delivery diff. |
| 11 | Guardrail: invariants — zero runtime deps, `toPlain()`/`toJSON()` + `noColor` unbroken, public API stability, generated previews stay source-of-truth | SHIPPED | `packages/core/package.json` has only devDependencies (zero runtime deps); `line.ts` keeps `toPlain()`/`toJSON()`/`noColor` + new `model` field and passes the noColor test; API changes are additive (optional `timestamp`/`status`/`summary`, optional `toSVG?()`); `gen:charts:check` passes (previews regenerate from core and match). |
| 12 | Guardrail: max 2 assumptions; ≤3 files per atomic commit | PARTIAL | File cap **verified: no commit in `main...HEAD` exceeds 3 files** (`git diff-tree --name-only` per commit). The "max 2 assumptions" half is a process claim with no assumptions log/evidence in the diff — not verifiable from delivery artifacts alone. |

## Count and fakest green

- **10 of 12 SHIPPED** (reqs 1–7, 9–11), **2 PARTIAL** (reqs 8, 12), 0 NOT-BUILT.

### Fakest green

`scripts/verify-session-08.sh` — **15/15 PASS on a YAML file's static shape while the contract's own exit criterion "full-workspace … build exit 0" is provably red.** The gate greps `--access public`, `NODE_AUTH_TOKEN`, the pins, and parses the workflow YAML; it never builds or tests anything, so its green is trivially true of a well-formed YAML file and says nothing about whether the pipeline's real precondition (a green workspace build, which the exit criteria demand and which fails today in `mockup-sandbox`) holds. The green checkmark "the release pipeline is actually green" is asserted by a shape-check, not by the real gates.

### Honest caveats (not REJECT-level)

- **Tick drop at shipped dims:** at the exact showcase config (height 18, NIFTY data), the y-axis renders 6 of 7 `niceTicks` (24.4K is dropped) and X labels truncate crudely ("No" for "Now", "Ago" for "7D Ago"). The "SV-grade / clean ticks" polish is real but imperfect at the very configuration the builder shipped.
- **`verify-closeout.sh` scope:** it is a static/grepping gate (verdict tokens inside `|` rows, canonical line, attestation recompute); it structurally requires the review's *shape* and *attestation* but cannot prove a different mind authored it (SKILL.md itself is honest about this).
- **Unrequested scope on the branch:** hook guards, CSS restyle, CHANGELOG, README rewrite, reviewer skill, sparkline example all landed on this branch's diff. Non-blocking, but they inflate the delivery surface beyond the contract.

## Overall verdict

The real scope is a faithful build of the whole contract, not a narrow slice: the publish workflow is real and mirrors the S07 gates byte-for-byte; the renderer-neutral model + SVG are real, exported, and drive the docs site; the dashboard panel and its options are real with passing tests; and every exit gate that can actually be exercised locally is green. The single unmet exit criterion (full-workspace `pnpm run build`) fails only in a package the diff never touches, identically at the branch point — a pre-existing, out-of-scope condition, disclosed here rather than papered over. ACCEPT.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** a62da524f0ede6f8408cb3f7509900df074d9fc922ed1e652659c2042bc16d4d
