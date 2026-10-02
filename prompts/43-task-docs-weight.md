# Session 43 — docs weight: the docs app ships the components it uses

**Type:** code session (Batch 3 of the cleanup that gates the public repo flip)
**Branch:** `session-43-docs-weight`, from `main` `49e1ee2` (== `origin/main`, the S42 merge)
**Date:** 2026-10-03
**Contract:** this file. **Committed at HEAD** — `review-inputs-attested` hashes it, and
S40 failed that gate precisely because a contract that was never committed cannot be hashed.

## Why this session exists

S42 removed the dead trees. This session removes the dead **weight** inside what is left:
the docs app carries **55 shadcn components** and reaches **12**. The other **43** are
~5,000 LOC of a component library that was seeded with the Replit scaffold — a select, a
calendar, a carousel, a chart wrapper, a command palette — imported by nothing the docs app
renders. Thirty devDependencies exist to serve them.

Three more pieces of Replit scaffold survive in the same app: the `@replit/*` Vite plugins
(one still wired into the production `plugins` list), a `lint` script in `packages/core`
that calls an `eslint` nobody installed, and a root `prettier` devDependency with no config
file anywhere and 31 core files failing `--check` under bare defaults.

**Batch 2 proved a fresh clone builds. Batch 3 proves it builds the library and the docs app
it actually uses — not the scaffold they came from.**

## The one story

> A stranger who clones this repo finds the docs app ships the components it renders and
> nothing else: no 43 unused UI primitives, no Replit plugins, no dead `lint` script, and a
> Prettier config that is real, formatted, and enforced in CI.

`max_stories_per_session: 1`, so **Batch 3 only.** Batch 4 (OSS polish + founder decisions
D1–D6) is S44; then the public flip.

## Scope — 10 numbered requirements

### A · The deletions (discovered, never enumerated)

1. **Delete the 43 unused shadcn components.** The live set is **12** — `button`, `card`,
   `dialog`, `input`, `label`, `separator`, `sheet`, `skeleton`, `textarea`, `toast`,
   `toggle`, `tooltip` — computed as the transitive closure of everything referenced outside
   `src/components/ui/`. The complement of that closure (43 files) goes. **Discover the
   live set; do not hand-copy the list.** Re-adding any one of the 43 must turn the gate red.

2. **Remove the dependencies that die with them, in their own commit.** ~30 devDependencies
   are imported by no surviving file: 20 `@radix-ui/react-*` packages, `cmdk`,
   `embla-carousel-react`, `input-otp`, `next-themes`, `react-day-picker`, `react-hook-form`,
   `recharts`, `sonner`, `vaul`, and the resolvers/types that rode with them. **Keep
   `react-resizable-panels`** — `CatalogPage.tsx` imports it. Regenerate the lockfile in a
   commit separate from the deletion commit so the two stay separable (the S42 precedent).

3. **Strip the three `@replit/*` Vite plugins** from `artifacts/chitra-docs/vite.config.ts`
   and from `devDependencies`. `runtime-error-modal` is in the production `plugins` list
   today; `cartographer` and `dev-banner` load only under `REPL_ID`. None is load-bearing for
   a static public docs build. With them gone, S42's one-liner — *the repo ships the library,
   not the scaffold it came from* — becomes true rather than two-thirds true.

4. **Remove the dead `lint` script** from `packages/core/package.json`. It runs
   `eslint src tests`; `eslint` is installed nowhere and has no config. A script that can only
   fail is not a script.

### B · Prettier — adopt, format, enforce (founder decision F43-1)

5. **Make Prettier real.** The repo carries a root `prettier` devDependency, **no config
   file**, and 31 core files that fail `--check` under bare defaults. Per **F43-1**, do not
   delete it: add a checked-in `.prettierrc` (+ `.prettierignore`), format the repo in one
   mechanical commit, add `format` / `format:check` scripts, and **wire `format:check` into
   CI** so it can never silently rot back to red.

### C · The gate

6. **Port S42's gate to `scripts/verify-session-43.sh` — port, do not copy.** Discover the
   live UI-component set and the workspace globs; never name a path that this session can
   delete. Every check carries a demonstrated counterfactual, and a check that cannot fail is
   a bug. This session deletes 43 more files, so S42's lesson applies directly: **any gate
   that names a path breaks the moment that path is deleted. Discover, do not enumerate.**

7. **Fix the eight inherited findings N2–N9** (`sessions/session-42-review.md` pass 2; table in
   `.ai/ROADMAP.md`), each with a done-condition that can be checked:
   - **N5** — `browser-qa-catalog-pages` must build core inside the check, then pass in a
     **clean clone** for the right reason. **Do N5 first.**
   - **N7** — the coverage claim must not be a hardcoded `CHART_IDS`: adding a 21st catalog
     page must turn the check red.
   - **N2** — `summary.txt` must be written before the demo reads it, so the demo prints real
     PASS/FAIL rather than 10 × NOT PROVEN.
   - **N6** — `charts-untouched` must go **red** when the base ref does not resolve, not pass
     vacuously.
   - **N3** — the hand-written check counts in the handoff must be **derived**, and a stale
     display must fail the gate.
   - **N4** — `replit-globs-match-workspace`'s success line must print the three real globs.
   - **N8** — re-adding `- lib/*` must turn the glob check **red**, independent of the
     historical mention clause.
   - **N9** — `dead-scripts-gone` clause (iv) must be able to detect the condition its comment
     names: deleting `- scripts` from the workspace globs must turn it red.

### D · Proof and honesty

8. **Re-prove the product from live facts.** Fresh clone → install → build with no env;
   **453/453** tests in 23 files; root typecheck; `pnpm example`; the **browser QA** re-run
   (not inherited — this session deletes 43 files under the docs app); CI green on the branch.

9. **Re-sync `.ai/`** and kill the hand-written check-count rot: `STATE.md`, `SESSION-BOOT.md`,
   `TASK.md`, `ROADMAP.md`, `KNOWLEDGE.md` describe S43 on this branch; the frozen `sessions/`
   and old `prompts/` are not edited; any surviving count is derived, not typed.

10. **Fidelity map + independent cold review.** `sessions/session-43-summary.md` maps every
    numbered requirement to evidence (SHIPPED / PARTIAL / NOT-BUILT), and
    `sessions/session-43-review.md` is a **cold** adversarial pass fed only this contract and
    the diff. **No self-certification.**

## Out of scope — named, so it cannot be smuggled in

- **Any change under `packages/core/src/`** — `charts/`, `renderers/`, `themes/` are LOCKED.
  This is a docs-weight and repo-hygiene session. Formatting under Prettier is the one
  exception, and it must not change behaviour.
- **`pnpm-workspace.yaml`'s ~140 lines of `overrides`** (expo, ngrok) — **D5**, S44, needs its
  own lockfile regen. This session regenerates the lockfile for the docs deps and deliberately
  leaves `overrides` alone so the two regens stay separable.
- **OSS polish** (`SECURITY.md`, CoC, templates, CI badge, coverage job, `engines`) and
  founder decisions **D1–D6** — S44.
- **The public flip** — after S44.
- **`required-crew`**, `check_ground_truth_no_code`'s vacuous pass, the cost gate that greps a
  heading, disposition **S16**, the **GTM proof pack**, and the **~60-minute gate cost**
  (§4.9) — carried forward, untouched.
- **Historical `verify-session-NN.sh` / `demo-session-NN.sh` pairs** — frozen; unrun, unrepaired.
- **The `artifacts/api-server` bet** — closed in S42; git history keeps it.

## Assumptions (2 — the constitution's cap)

1. **The 43 components and the ~30 dependencies are safe to delete wholesale.** Verified at
   plan time: every "dead" component is unreferenced outside `src/components/ui/` (transitive
   closure computed), and every "dead" dependency has **zero** imports outside the deleted
   files. `react-resizable-panels` is the one shared dep and is kept.
2. **The three `@replit/*` plugins are non-load-bearing** for the static public docs build.
   `runtime-error-modal` wraps the dev overlay; `cartographer`/`dev-banner` load only under
   `REPL_ID`. Removing them changes no rendered output.

## Founder decision F43-1 — Prettier: adopt, format, enforce

At plan approval the founder chose **format + adopt + enforce** over deleting Prettier: add
the config, format the repo, and gate it in CI. Recorded here because it is a decision, not a
default, and because "delete the config" was the cheaper path the roadmap offered.

## Closeout

`scripts/verify-session-43.sh` exits 0; `scripts/verify-closeout.sh` exits 0 (or a founder
waiver is recorded exactly as S38/S39/S42 did for the structurally-unsatisfiable
`required-crew`); the S39 suite still green; CI green on the branch. Summary + cold review
written, `.ai/` re-synced, PR opened to `main`.

## The counterfactual this session demands

`S42-gate-verbatim-goes-red` — S42's gate, run unmodified on this branch, must exit non-zero,
and the reason is **`charts-untouched`**: S43 formats the LOCKED dirs (the F43-1 exception),
S42's check diffs `main...HEAD` by path and cannot tell a formatting change from a semantic
one, so it reports 25 changed files where it demands 0. The S43 gate re-expresses it as
`charts-format-only` — proving the change under those dirs is *exactly* Prettier's
transformation. **This is the S42 lesson one level down:** S42's gate discovered its vite
configs (S41's enumerated them and broke), but it still *enumerated* the LOCKED dirs, so the
first session that legitimately reformats them turns it red. Discover, do not enumerate.
