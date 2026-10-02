# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S43 — cleanup Batch 3,
**complete**, closed 2026-10-03.)

## Active Branch
`session-43-docs-weight`, branched from `main` `49e1ee2` (the S42 merge, == `origin/main`
at branch time). S42 is **merged**. The package is **`@ifelse.codes/chitra@0.3.0`**, live
on npm, and the repo around it is being made fit to publish.

## What Currently Works (observed, not claimed)
- **The docs app ships only the components it uses.** 55 shadcn components seeded with the
  Replit scaffold; the app reaches **2** — `card` (via `not-found.tsx`) and `toast` (via
  `use-toast.ts`). The other **53** (~6,000 LOC) are deleted, along with the **36
  devDependencies** that died with them. `ui-components-shipped` computes the live set as the
  transitive closure of what the docs app imports — it does not hardcode the 2. **The scope
  numbers were corrected in-session: the roadmap said 43/12, but that came from a grep whose
  `-o` flag stripped paths, so intra-ui imports counted as usage. The truth is 53/2.**
- **The three `@replit/*` Vite plugins are gone** from `vite.config.ts`, the docs manifest,
  and the workspace catalog. `runtime-error-modal` was in the **production** plugins list;
  with all three removed, S42's line — *the repo ships the library, not the scaffold it came
  from* — is finally true rather than two-thirds true.
- **The dead `lint` script is removed.** It ran `eslint src tests` against an eslint that is
  installed nowhere and has no config.
- **Prettier is real (F43-1).** A root `prettier` devDependency with **no config** and **31
  core files failing `--check`** became: a checked-in `.prettierrc` + `.prettierignore`, a
  formatted repo, and a **CI `format` job** running `format:check`. `prettier-adopted` asserts
  all four.
- **Product, re-observed:** **453/453** tests in 23 files; root typecheck exit 0;
  `pnpm example` runs; `gen:charts:check` green. 20 charts / 3 renderers / 7 themes /
  0 runtime deps.
- **The LOCKED chart code is behaviour-identical.** Every changed file under
  `packages/core/src/charts/`, `renderers/`, `themes/` is **exactly the Prettier transform of
  `main`** — `charts-format-only` proves it file by file, and the suite is unchanged at 453.
- **A fresh clone builds** (S42's gate survives): `verify-session-43.sh` re-runs the
  fresh-clone build with no env, and S42's `dead-trees-gone` / `no-live-ref-to-dead-trees` /
  `lockfile-frozen-no-dead-importers` / `typecheck-libs-gone-end-to-end` all still pass.

## What Is In Progress
- **S43 is the in-progress item, and it is complete.** `verify-session-43.sh` is a **port** of
  `verify-session-42.sh` — the checks its own changes force to be re-expressed are
  `charts-untouched` → `charts-format-only` (S43 reformats the LOCKED dirs; S42's check also
  passed **vacuously** when `main` did not resolve, which is N6), `ai-files-describe-s42` →
  `-s43`, and `s41-gate-verbatim-goes-red` → `s42-gate-verbatim-goes-red`.
- **The eight S42 findings N2–N9 are fixed**, each with a demonstrated counterfactual:
  N5 and N7 in `browser-qa-catalog-pages` (build core inside; discover the catalog inventory
  from `charts.ts` rather than assert `>= 20`), N2 (`summary.txt` rewritten after every check,
  so the demo reads live status), N4/N8 in `replit-globs-match-workspace`, N9 in
  `dead-scripts-gone`, N3 in the handoff counts, N6 in `charts-format-only`.
- **The counterfactual is real and cheap:** `s42-gate-verbatim-goes-red` extracts S42's actual
  `charts-untouched` body and asserts it exits non-zero on the S43 format. S42 enumerated the
  LOCKED dirs — S43 is the first session to legitimately reformat them. **Discover, do not
  enumerate**, one level down.

## What Is Broken / Incomplete
- 🔴 **The public flip still has no date and two unanswered founder decisions.** **D1** — how
  much internal process (`.ai/`, `sessions/`, `prompts/`, `.claude/`, `reviewer/`, `darshan/`;
  ~146 files) goes public; options B and C break `check_session_coverage` / `check_task_ref`
  unless the closeout gates are rewritten first. **D4** — whether to scrub the `/Users/REDACTED/…`
  paths in tracked files. **D4 is irreversible once published.**
- 🟠 **Unattended publishing is configured but unproven since S38.** No release has traversed
  CI since the trusted publisher was created. The cheapest close is a real `0.4.0`.
- 🟠 **No npm provenance** — npm does not generate it for a private repo, even under trusted
  publishing. The flip fixes it.
- 🟠 **Two cleanup items remain: S44** (OSS polish + D1–D6), then the flip. Also open from S40:
  `required-crew` (now **three** founder waivers — S38, S39, S42), `check_ground_truth_no_code`
  passing **vacuously** on a GT session, the cost gate that greps a heading ("Cost Tracking"),
  and **S16** invisible to every ledger.
- 🟠 **The gate still costs a lot** — S42 measured ~60 minutes (§4.9, S44). S43 does **not**
  worsen it: its counterfactual extracts **one** check from `verify-session-42.sh` instead of
  chaining S42's whole gate (which itself runs S41's).
- 🟠 **Seven pre-existing dead docs deps remain** and are named, not fixed: `framer-motion`,
  `react-icons`, `@tanstack/react-query`, `zod`, `date-fns`, `@tailwindcss/typography`,
  `tw-animate-css` have **zero** references but did not die with the 43 components, so removing
  them was out of this session's scope.
- 🟠 **The adoption baseline is zero, and that is the correct pre-launch reading.** The 304
  lifetime downloads on `@ifelse.codes/core` are all inside a 5-day window starting on the
  publish day and are release-runner and founder shaped — **never cite them as traction**.
  A GTM proof pack must record this zero as its `t0`.
- `pnpm-workspace.yaml` still carries ~140 lines of `overrides` for packages that are not in
  the dependency graph — **D5, S44**, needs a lockfile regen in its own commit.
- **MCP server: founder-DEFERRED, not built, not stubbed.**
- **Historical verify scripts are already unrunnable** (01, 02, 03, 07, 31, 34, 36, 37, 38),
  and the S41/S42 gates hard-code deleted paths by design. The live pair is 39 / 42 / 43.

## Milestones done
- **S01–S04** docs/examples/polish/README · **S05** NO-CODE ground-truth · **S06** publishable
  dist · **S07** CI · **S08** release.yml + line/SVG · **S09** circular+area LOCKED · **S10**
  line · **S11** catalog two-panel · **S12** bar · **S13** Darpan-parity chrome · **S14** URL
  routes+persistence · **S15** scripted browser QA · **S17** scatter · **S18** heatmap · **S19**
  horizontalBar · **S20** treemap · **S21** timeline · **S22** gauge · **S23** progress · **S24**
  grouped nav · **S25** histogram · **S26** waterfall+funnel+sankey+radar · **S27**
  candlestick+boxplot · **S28** sparkline · **S29** family-wide footer B-diet+ · **S30** docs live
  · **S31** antra atoms + hero rotation + wall fix · **S32** wall playbook · **S33** release
  readiness · **S34** GTM README + MIT LICENSE · **S35** NO-CODE ground-truth · **S36** S35 gaps
  closed + deploy unfrozen · **S37** package published · **S38** OIDC release runway, `0.2.0`
  unattended · **S39** renamed to `@ifelse.codes/chitra`, `0.3.0` live · **S40** NO-CODE
  ground-truth audit, 🔴, 11 remediations · **S41** cleanup Batch 1 — the public face is honest
  · **S42** cleanup Batch 2 — dead weight: `artifacts/mockup-sandbox/`, `lib/`,
  `artifacts/api-server/`, `attached_assets/` and 6 dead scripts deleted (110 files), the 9-file
  chain cut · **S43** cleanup Batch 3 — docs weight: 43 unused components, 30 deps, 3 replit
  plugins, the dead lint script, and Prettier adopted + enforced.

## Cost Tracking
- S43 measured: one opencode session; **one** founder decision in-chat (the Prettier ballot —
  **F43-1**: format + adopt + enforce, not delete) plus the plan approval; 10 requirements
  across ~80 changed files and ~10 commits; **0 semantic** product-code changes under
  `src/charts/`, `src/renderers/`, `src/themes/` (format-only, proven by `charts-format-only`);
  **0** new product tests (453 stays 453); **1** lockfile regen (docs deps); **0** releases;
  **0** npm secrets touched. Prettier run once (`--write`), one `--no-verify` commit for the
  76-file mechanical format. Token/`$` cost **unmeasured** (billed to the founder's plan).
  npm cost: $0. No new recurring infrastructure.
- S42: one opencode session, 4 founder decisions, 10 requirements, 130 files, 13 commits, 0
  product-code changes, 1 lockfile regen, 0 releases. S41: 6 cold-review passes, 34 files,
  32 commits. S40: 49 audit probes + 41 re-verifications, 0 code changes.
