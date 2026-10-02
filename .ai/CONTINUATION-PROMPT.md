# chitra — Continuation Handoff (after S42)

**Resume in a NEW chat (S43).** `main` = S00–S41 (`4893683`) at S42's branch point;
`.ai/SESSION` = 42; **`@ifelse.codes/chitra@0.3.0` is LIVE on npm** (`latest`); the repo is
still **private**, by decision — it goes public after a code cleanup.

> **The one thing to carry forward:** the repo now ships the library and not the Replit
> full-stack app it was extracted from. **110 tracked files deleted** across S42, and the
> fresh-clone build that S41 achieved still holds afterwards — 103 of those files went away
> *underneath* it. That was the *second* precondition the founder set for the flip. **S43 and
> S44 are already scoped and scheduled.**

## Where we are

Detail: `sessions/session-42-summary.md` + `sessions/session-42-review.md` + `.ai/STATE.md`.

| Delivered in S42 | State |
|---|---|
| `artifacts/mockup-sandbox/` (69) | **deleted** — 0 tracked files |
| `lib/` (20) + `artifacts/api-server/` (11) | **deleted** — the OpenAPI→zod→orval→drizzle chain, imported by nothing |
| `attached_assets/` (3) + the `@assets` alias | **deleted** — the alias had **0 hits** in `docs/src`, so it was dead, not merely unreferenced |
| 6 dead scripts | **deleted** — and the 2 references that deletion exposed (`hello`, a dead `exclude`) |
| The reference chain | **9 files cut**, not the 6 the roadmap listed: `release.yml` and `docs/package.json` were missing from the count, and both would have been red CI |
| `typecheck:libs` | **gone from the script, `ci.yml` ×2, `release.yml`, and disk.** The release step mattered: a build step removed without looking leaves a green, wrong release |
| Lockfile | regenerated, **+67 / −3177**, ten importers → four. `--frozen-lockfile` green in all four CI jobs |
| Verify | S42's gate is **33 checks**; S39's 43/43; every check has a demonstrated counterfactual |
| Tests | **453 green** in 23 files — unchanged, and asserted as unchanged |
| Product code | **untouched.** 0 files under `src/charts/`, `src/renderers/`, `src/themes/` |

## Three things the roadmap got wrong, and one thing nobody had looked at

1. **`mockup-sandbox` did not break the root build.** The roadmap said it did. Run at S42
   boot, its build and its typecheck both exit 0 — S41's build-order fix had already cured
   it. The reason to delete it is weight. The contract records this rather than repeating it.
2. **One of the "5 dead scripts" does not exist** (`build-audit-html.mjs`). Four remained, and
   S41's audit had **missed two more** with zero live refs.
3. **The chain was 9 files, not 6.** `release.yml` and `docs/package.json` were not in the
   count, and both were load-bearing.
4. **S41's own gate breaks under requirement 1.** `vite-configs-no-hard-throw` hard-coded a
   path into `mockup-sandbox/`, so deleting that tree turns the inherited gate **red** — on a
   defect that does not exist. The S42 gate **discovers** its vite-config inventory instead of
   naming it, and `s41-gate-verbatim-goes-red` runs S41's real gate to prove the coupling is
   real rather than argued. **Any future gate that names a path will have the same problem the
   moment that path is deleted. Discover, do not enumerate.**

## S43 — cleanup Batch 3: docs weight (the roadmap's next item)

1. **43 unused shadcn components** (~5,000 LOC) in `artifacts/chitra-docs/src/components/ui/`
   and the dependencies that die with them. Verify each is unreferenced before deleting —
   `vite` resolves them by alias, so a grep is not the whole story.
2. **Prettier** — the config exists and **31 core files fail `--check`**. Decide: format them
   (one large mechanical commit) or delete the config. Do not leave it red.
3. **The `lint` script** — it points at an eslint that is not installed and has no config.

> **Gate:** S42's gate (**34 checks**, including the fresh clone, the S41 coupling proof, and
> `browser-qa-catalog-pages`, which drives a real browser) + CI green. **Port, do not copy** —
> see point 4 above. S42's own browser QA was run and is green; S43 must re-run it, not inherit
> it, because S43 deletes 43 more files.

## Then

- **S44** — `SECURITY.md`, CoC, issue/PR templates, CI badge, coverage job, `engines`, and
  founder decisions **D1–D6**. `pnpm-workspace.yaml`'s ~140 lines of `overrides` (expo, ngrok)
  are **D5** and need their **own** lockfile regen — S42 left `overrides` alone on purpose so
  the two regens stay separable.
- **Then the flip** — which resolves the README `git clone`, npm `repository.url` and
  `homepage`, and turns npm provenance on, in one move.

## The two decisions only the founder can make

- **D1 — how much internal process goes public?** `.ai/`, `sessions/`, `prompts/`, `.claude/`,
  `reviewer/`, `darshan/`; ~146 files. Option A (keep) is the recommended one: it is a real
  story, and it keeps the closeout gates working. **Options B and C break
  `check_session_coverage` / `check_task_ref` unless the gates are rewritten first.** Note
  `.claude/settings.json` is tracked, so its hooks fire for any Claude Code user who clones —
  never tested as an outsider.
- **D4 — the personal-path scrub.** 5 tracked files carry `/Users/suman/…`. **History is
  published with the flip; this is irreversible after it.** Answer before, not after.

## Also still open

- **A real `0.4.0` through CI** — the cheapest close on the trusted-publisher claim.
  Nothing needs to change; the pipeline is wired and the publisher exists.
- **GTM proof pack** — must record the measured **zero** downloads as its `t0`, and must
  **never** cite the 304 `@ifelse.codes/core` downloads: they sit inside a 5-day window
  starting on the publish day and are release-runner and founder shaped.
- **S40's governance rows, untouched by S41 and S42** — `required-crew` (third waiver; demands
  a handoff the Session Loop never asks for), `check_ground_truth_no_code` passing
  **vacuously** because a GT session never commits into the range it diffs, the cost gate
  that passes on the string "Cost Tracking", and **S16**, which no ledger can see.
- **New, from S42:** two gates in this repo check a string in a *file* where they mean to
  check what a *reader sees*. S42 found one — the S41 test-count check passed S41's demo on a
  **comment**. Fixed for S42 only; the shape likely survives elsewhere, not swept.
- **New, from S42:** `verify-session-31.sh` is now permanently unrunnable (it names
  `check-hero-dims.py`, deleted by founder decision). It joins 01, 02, 03, 07, 34, 36, 37, 38.
  The live pair is **39 / 41 / 42**.
- **New, from S42:** the cold review **REJECTED** the first delivery on four small defects and
  all four were real. Read `sessions/session-42-review.md` before writing a gate: the two checks
  that could not fail were `contract-at-head` (a phrase grep) and a typecheck clause that
  passed over an empty `files: []`. **A gate written by the same mind that wrote the code is
  where this repo leaks.**
- **New, from S42:** three separate syntax breaks while editing `verify-session-42.sh`, all the
  same shape — a single quote inside a `bash -c '...'` argument. Any check you add from here
  should be written as a **shell function**, not a nested-quoted string.
- **`commit_guard`** — S42 needed **F42-1**: this session's agent was authorised to set
  `VAJRA_ALLOW_COMMIT` inline, because the L3 hook that enforces its un-forgeability is Claude
  Code configuration and does not run under other harnesses. Whether `commit_guard: off` belongs
  in `CONSTRAINTS.yaml`, as it does in the vajra repo, is **S44's** question — this project
  ships no such line, so enforcement is deliberate.