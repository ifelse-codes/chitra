# Session 39 — task: rename `@ifelse.codes/core` → `@ifelse.codes/chitra`

**Resume point.** S38 (PRs #46–#52) built the fully-automated OIDC release path and
published `@ifelse.codes/core@0.2.0` from CI with no human in the loop. `main` = `46edac5`.
Start S39 in a **new chat** (one session per chat).

Founder-approved 2026-09-27: **the scope was never the problem — the part after the slash
is.** `@ifelse.codes` is a namespace the account owns; the package name inside it is a free
choice. Decision: **`@ifelse.codes/chitra`**.

## Context (do not re-derive)

- Availability re-verified this session: bare `chitra` → taken (`chitranga123`, an unrelated
  Angular lib, v0.1.14); `@chitra/core` → 404 (the `@chitra` org is not ours);
  **`@ifelse.codes/chitra` → 404 (free)**; `@ifelse.codes/core` → 0.2.0 (live).
- Adoption is ~104 downloads, all within the last week — essentially the founder's own
  verification installs. **There is nothing to break**, which is why this is worth doing now
  rather than after real users exist.
- S37 already did exactly this rename once (`@chitra/core` → `@ifelse.codes/core`, 26 live
  files, 10 atomic commits) and left frozen `sessions/` + old `prompts/` + old
  `verify-session-*.sh` as history. **Repeat that boundary.**
- ~24 live files carry the old name; `.ai/verify/**` logs and frozen session artifacts do not
  and must not.

## Decisions taken at PLAN (founder, 2026-09-27)

1. **Version/tag = `0.3.0` + `v0.3.0`** — *not* the handoff's `0.1.0`. Tags `v0.1.0`
   (`802ffc7`) and `v0.2.0` (`76d21f3`) already exist on the remote, so a fresh `v0.1.0`
   would mean force-moving a published tag. `0.3.0` keeps tags monotonic, needs no tag
   surgery, and carries the CHANGELOG forward. A new package whose first version is `0.3.0`
   is explained by the deprecation notice on the old one.
2. **`required-crew` is founder-WAIVED again** (`VAJRA_CLOSEOUT_WAIVER=39`), same as S38.
   The gate demands a tech-lead handoff that `.ai/AGENTS.md`'s Session Loop never asks for.
   Fixing the gate is handoff candidate #3 and its own session; folding it in here would
   break max-1-story-per-session.
3. The **directory stays `packages/core/`**. S37 renamed the package *name*, not the path.
   Minimal churn; the path is internal.

## Requirements

1. **Rename the package** in `packages/core/package.json` → `@ifelse.codes/chitra`, and bump
   `version` → `0.3.0`.
2. **Two honesty fixes in the same `package.json`:** **drop `mcp` from `keywords`** (nothing
   ships it — founder-deferred, and a keyword is a promise in a search index) and **lead
   `description` with the name**.
3. **Rename every live reference**, at minimum: `pnpm-lock.yaml`,
   `artifacts/chitra-docs/package.json`, `.github/workflows/ci.yml`,
   `.github/workflows/release.yml` (including the idempotency guard's `npm view` target and
   the `publish` job's display name), `artifacts/chitra-docs/scripts/chart-specs.ts`,
   `artifacts/chitra-docs/scripts/generate-charts.ts`, `artifacts/chitra-docs/src/App.tsx`,
   `artifacts/chitra-docs/src/components/CatalogPage.tsx`,
   `artifacts/chitra-docs/src/data/charts.ts` (**regenerate — never hand-edit**; the drift
   gate must stay green), `README.md`, `CONTRIBUTING.md`, `replit.md`,
   `packages/core/README.md`, `packages/core/CHANGELOG.md`, `packages/core/build.mjs`,
   `scripts/qa-catalog.mjs`, and `.ai/` (KNOWLEDGE / ROADMAP / STATE / SESSION-BOOT / TASK /
   GT-REMEDIATIONS / CONTINUATION-PROMPT).
4. **Fix a live lie found in passing:** the docs hero pill in `App.tsx` reads
   `v0.1.0 · npm` while the real version is `0.2.0` (S38 bumped it and never updated the
   pill). It becomes `v0.3.0 · npm`. Also drop the stale `no @types/chitra needed` comment
   in `App.tsx` — `@chitra` has not been the package name since S37.
5. **Founder: create the npm trusted publisher for `@ifelse.codes/chitra`** on npmjs.com
   (Settings → Trusted Publisher → GitHub Actions): org/user `ifelse-codes`, repository
   `chitra`, workflow filename `release.yml` (filename only, case-sensitive), environment
   empty, and **"allow `npm publish`" explicitly enabled** (configs created after
   2026-09-03 default to `npm stage publish` only, and npm does **not** validate on save).
   One trusted publisher **per package** — `0.2.0`'s config does **not** carry over.
6. **Publish `@ifelse.codes/chitra@0.3.0` from merged `main`** via `v0.3.0`, unattended, and
   prove it the S38 way: npm `time["0.3.0"]` ≥ the Release run's `createdAt`.
7. **`npm deprecate @ifelse.codes/core "renamed to @ifelse.codes/chitra"`.** npm cannot rename
   a package, so the old one stays on the registry; deprecating beats a silent 404. This
   **cannot** run from CI: OIDC mints a token scoped to the package being published, and the
   founder's npm account token was revoked in S38 — so it is a founder browser action (or a
   fresh token). Record it as founder-attested, never claim it repo-verified.
8. **`scripts/verify-session-39.sh` + `scripts/demo-session-39.sh`.** The verify script must
   assert **facts, not phrases** (S38's lesson: a check coupled to a string or a commit's
   position is not a guard) — e.g. read the *committed* name out of `main`'s
   `packages/core/package.json`, prove `charts.ts` is generated not hand-edited via the drift
   gate, and prove the old name is gone from live files.
9. **Summary + independent cold review + closeout**; sync `.ai/` and `.ai/SESSION` → 39.

## Out of scope

- **GTM proof pack** (benchmarks / token-savings) — handoff candidate #1, and it explicitly
  wants the *final* install command, so it comes after this rename.
- **MCP server** — founder-deferred, demand-led. Do not build, do not stub.
- `artifacts/api-server` — still the undecided "if the hosted API is pursued" bet.
- Repo visibility (private ⇒ no npm provenance) — founder's open decision, unchanged.

## Guardrails

Atomic commits ≤3 files; branch `session-39-*`; PR to `main`; founder approval token before
commits (`VAJRA_ALLOW_COMMIT=39`); push the branch before merging. Tag only from merged `main`.
Never claim the deprecation happened until the founder confirms it. Keep the publish step on
`npm publish` — pnpm 9.12.3 cannot exchange an OIDC token.

## Crew dispatch — tech-lead: skipped (disclosed, not self-certified)

Same disclosure S38 recorded, unchanged by this session: `.ai/AGENTS.md`'s Session Loop has
no crew/tech-lead step, so `check_required_crew` is enforced by a layer the load order never
surfaces. A retroactively authored handoff would be a fabricated governance artifact — a
tech-lead picks the crew and budgets *before* the work. Founder waiver
(`VAJRA_CLOSEOUT_WAIVER=39`) rather than self-granted.

## Execution

- steps 1–4 — pending
- step 5 — **PENDING (founder, npmjs.com)**: trusted publisher for the new name
- step 6 — pending: needs the tag (verify checks legitimately red until then)
- step 7 — **PENDING (founder)**: `npm deprecate @ifelse.codes/core`
- step 8 — pending
- step 9 — pending
