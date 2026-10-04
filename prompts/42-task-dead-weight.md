# Session 42 — dead weight: the repo ships the library, not the scaffold it came from

**Type:** code session (Batch 2 of the cleanup that gates the public repo flip)
**Branch:** `session-42-dead-weight`, from `main` `4893683` (== `origin/main`, the S41 merge)
**Date:** 2026-10-02
**Contract:** this file. **Committed at HEAD** — `review-inputs-attested` hashes it, and
S40 failed that gate precisely because a contract that was never committed cannot be hashed.

## Why this session exists

S41 made the public face honest. This session removes the parts of the repo that are not the
product: **103 tracked files** of Replit scaffold that no code path reaches, plus **6** dead
scripts, plus the **9-file** chain that references them.

The repo was seeded as a Replit full-stack app and the product was extracted out of it. What
remains of the original app is dead: a sandbox app, an API server with one route, a generated
OpenAPI client stack nothing imports, and three pasted binary/text attachments.

**A stranger who clones this repo should not have to read 103 files to find the library.**

## The one story

> A stranger who clones this repo finds a terminal charting library, not a Replit full-stack
> app with a charting library somewhere inside it — and the build is still green.

`max_stories_per_session: 1`, so **Batch 2 only.** Batch 3 (43 unused shadcn components,
Prettier, the broken `lint` script) is S43; Batch 4 (OSS polish + founder decisions D1–D6) is
S44; then the public flip.

## Two claims in the roadmap that did not survive contact with the tree

Both were found by running things rather than reading about them, and both are recorded here
because the contract is what the cold review is fed.

| ROADMAP / audit claim | Observed at S42 boot | Consequence |
|---|---|---|
| `mockup-sandbox` "**breaks the root build**" | `pnpm --filter @workspace/mockup-sandbox run build` → **exit 0**; `run typecheck` → **exit 0** | The justification is now **weight, not breakage**. S41's build-order fix (req 11) cured it. The contract states the real reason rather than repeating a stale one. |
| "5 dead scripts" incl. `build-audit-html.mjs` | That file **does not exist** — not tracked, not untracked | **4** remain from S41's list, plus **2** more with zero live refs that S41 missed. |

---

## Scope — 10 numbered requirements

Each is a numbered requirement. The summary must map **every** number to
SHIPPED / PARTIAL / NOT-BUILT with evidence. *Fidelity ≠ discipline:* a green verify script
proves discipline, never fidelity.

### A · The deletions

1. **Delete the four dead trees — 103 tracked files.**
   - `artifacts/mockup-sandbox/` — 69 files, a Vite sandbox of design mockups.
   - `lib/` — 20 files: `@workspace/api-spec` (OpenAPI 3.1), `@workspace/api-zod` (zod, generated
     from that spec), `@workspace/api-client-react` (orval-generated TanStack Query client),
     `@workspace/db` (drizzle-orm schema). Nothing imports any of them.
   - `artifacts/api-server/` — 11 files, a Node server whose only route is `/healthz`.
   - `attached_assets/` — 3 files: two screenshots and a pasted text file.
   **Foundation-approved:** delete outright, no archive branch. Git history is the archive.

2. **Cut the 9-file reference chain.** Every surviving reference to a deleted tree, verified by
   grep over the tree with the deleted trees excluded — not from memory:
   | # | File | Reference |
   |---|---|---|
   | 1 | `tsconfig.json` | 3 project `references` → `./lib/db`, `./lib/api-client-react`, `./lib/api-zod` |
   | 2 | `artifacts/chitra-docs/tsconfig.json` | `references` → `../../lib/api-client-react` |
   | 3 | `artifacts/chitra-docs/package.json` | `"@workspace/api-client-react": "workspace:*"` |
   | 4 | `artifacts/chitra-docs/vite.config.ts` | `@assets` alias → `../../attached_assets` |
   | 5 | `package.json` | `typecheck:libs`, and `typecheck` calling it |
   | 6 | `pnpm-workspace.yaml` | `lib/*` glob |
   | 7 | `.github/workflows/ci.yml` | **two** `pnpm run typecheck:libs` steps (L81, L129) + the comment explaining them |
   | 8 | `.github/workflows/release.yml` | **one** `pnpm run typecheck:libs` step (L63) — *the publish path* |
   | 9 | `pnpm-lock.yaml` | 5 importers die: `api-server`, `mockup-sandbox`, `api-client-react`, `api-spec`, `api-zod`, `db` |
   `grep -n "@assets" artifacts/chitra-docs/src` returns **zero hits** — the alias is
   unreachable, which is why `attached_assets/` is dead and not merely unreferenced.

3. **`typecheck:libs` goes end-to-end.** The root script exists only to `tsc --build` the three
   `lib/` projects. With `lib/` gone it is `tsc --build` over an empty reference list. Remove the
   script, remove it from the `typecheck` chain, remove both CI steps and their comment, remove
   the release step. **The publish path losing a step is why this is a requirement and not a
   consequence** — a silently-skipped build step on the release path is how a broken package
   ships.

4. **Delete the 6 dead scripts.** Each verified to have **no live reference** outside frozen
   history (`sessions/`, old `prompts/`) and the two S41 audit documents:
   | Script | Why it is dead |
   |---|---|
   | `scripts/post-merge.sh` | runs `pnpm --filter db push`; no package named `db` exists (`@workspace/db` does), and nothing wires the script to an event |
   | `scripts/src/hello.ts` | scaffold — `console.log("Hello from @workspace/scripts")` |
   | `scripts/src/demo09-donut.ts` | appears only in `scripts/tsconfig.json`'s exclude list |
   | `scripts/check-hero-dims.py` | one-off S31 hero check; the **only** live ref is `verify-session-31.sh` |
   | `scripts/ring-polish-handoff.mjs` | S38 handoff tooling, zero live refs — **missed by S41's audit** |
   | `scripts/workflows/15-qacheck.sh` | unwired `workflows/` dir inside `scripts/`, zero live refs — **missed by S41's audit** |
   `check-hero-dims.py` is a **founder-approved** deletion: it makes `verify-session-31.sh`
   unrunnable, joining the set `STATE.md` already records as unrunnable (01, 02, 03, 07, 34, 36,
   37, 38). The live pair is 39 / 41 / **42**.

5. **The lockfile is regenerated and `--frozen-lockfile` is green.** CI runs
   `pnpm install --frozen-lockfile` in four jobs. A lockfile still carrying five dead importers
   makes **every one of them red**. This requirement is what keeps reqs 1–4 from turning into a
   red pipeline.

### B · The gate

6. **`verify-session-42.sh` inherits S41's 24 checks — with one re-expressed, not copied.**

   `vite-configs-no-hard-throw` (`verify-session-41.sh:116–122`) hard-codes **two** paths:
   `$DOCS/vite.config.ts` and `artifacts/mockup-sandbox/vite.config.ts`. Requirement 1 deletes the
   second, and the check then goes **red**: `grep -q` against a missing file exits 1, the `||`
   branch fires, and the gate reports "does not default PORT".

   So the check must be **re-expressed to discover its inventory** — glob for `vite.config.ts`
   across the workspace and require the list to be non-empty — which is exactly the lesson S41's
   own `test-count-propagated` check was rewritten to embody. **The gate is not a copy; it is a
   port.** Copying it verbatim is a known failure mode and is gated against below.

   Every check in `verify-session-42.sh` carries a **demonstrated counterfactual**. Two are
   mandatory for this session specifically:
   - **`s41-gate-verbatim-goes-red`** — running the *unmodified* S41 gate against this branch must
     fail. It proves the coupling in requirement 6 is a real defect, not a hypothetical one.
   - **`vite-configs-discovered`** — with the glob form, restoring a hard-throwing config anywhere
     in the workspace fails the check, and deleting every `vite.config.ts` fails it too (a
     discovered list that matches nothing is the same vacuous pass S41's review caught).

7. **The product is re-proven from live facts, not inherited from STATE.md.** All must be exit 0:
   | What | Why it is in the contract |
   |---|---|
   | `pnpm install --frozen-lockfile` | req 5 |
   | **fresh clone → install → `pnpm run build`, no env vars set** | the gate that has never been met in this repo's history. S41 landed it; **this session deletes 103 files and rewrites the publish path**, so it is re-run, not assumed. |
   | `pnpm --filter @ifelse.codes/chitra run test` — **453 tests** | the product did not change; a red suite means the deletion touched it |
   | `pnpm --filter @ifelse.codes/chitra run typecheck` + root `pnpm run typecheck` | req 3 changed the typecheck chain |
   | `scripts/verify-session-39.sh` (43/43) | the standing regression guard |
   | `pnpm example` | the command CONTRIBUTING publishes |
   - **0 files changed under `packages/core/src/charts/`, `src/renderers/`, `src/themes/`** — the
     LOCKED chart code. Asserted, not promised.

8. **Browser QA and CI green.** The real entry point is `node scripts/qa-catalog.mjs` — the
   exact command `ci.yml#browser-qa` runs. The docs package has **no `qa` script**, so
   `pnpm --filter @workspace/chitra-docs run qa` prints *"None of the selected packages has a
   'qa' script"* and **exits 0**; it cannot fail, and naming it here would have been a check
   that cannot fail wearing a command's clothes. (Corrected after the cold review; the first
   draft of this line named the non-existent filter.) The command exits 0, and the branch is
   pushed with a green Actions run. The docs site is the only human-facing surface left after
   this session, so it is the one that must not visibly break.

9. **`.ai/` truth is re-synced, and the frozen history is left alone.**
   `KNOWLEDGE.md` currently describes what chitra is *around* — `artifacts/api-server/`,
   `mockup-sandbox`, `lib/api-spec`, `lib/api-zod`, `lib/api-client-react`, `lib/db` — as
   present tense. After this session every one of those lines is false, and a knowledge base that
   describes deleted trees is the same defect S41 fixed in the npm README. `KNOWLEDGE.md`,
   `STATE.md`, `TASK.md`, `ROADMAP.md`, `SESSION`, `SESSION-BOOT.md` and `.ai/verify` are updated
   to describe this session, read live. **Frozen** `sessions/` records and old `prompts/` are
   **not** rewritten — they are dated history, and `verify-session-31.sh` keeps naming a file this
   session deleted, on purpose.

10. **Fidelity map + independent cold review.**
    `sessions/session-42-summary.md` maps all 10 requirements to
    SHIPPED / PARTIAL / **NOT-BUILT** with evidence, including the two stale roadmap claims above.
    `sessions/session-42-review.md` is an **independent** pass by a different agent, fed **only**
    this prompt and the diff, running adversarially — `reviewer/SKILL.md`. The builder does not
    accept its own delivery; a green gate proves discipline, never fidelity. Every finding is
    fixed in place or the acceptance is withdrawn.

## Out of scope — named, so it cannot be smuggled in

- **The 43 unused shadcn components**, Prettier, the `lint` script pointing at an eslint nobody
  installed → **S43**.
- **`SECURITY.md`, `CODE_OF_CONDUCT.md`, templates, badges, `engines`** → **S44**.
- **Founder decisions D1–D6**, including **D4** (the `~/…` personal-path scrub) which
  is **irreversible once published** → **S44**, before the flip.
- **The public flip itself** → after S44.
- **`pnpm-workspace.yaml`'s ~140 lines of `overrides`** for packages not in the dependency graph
  → **D5, S44**, needs its own lockfile regen. This session regenerates the lockfile anyway;
  **it does not touch `overrides`**, so the two regens stay separable.
- **Any change under `packages/core/src/`** — this is a repo-hygiene session, not a product one.
- **Deleting historical `verify-session-NN.sh` / `demo-session-NN.sh` pairs.**
  `verify-closeout.sh` reads the *current* session's pair; the historical ones are already
  unrunnable and rewriting them is a project this repo has declined three times.
- **The four S40 governance rows** (`required-crew`, the vacuously-passing
  `check_ground_truth_no_code`, the cost gate that greps a heading, disposition S16) and the
  **GTM proof pack** — deliberately carried forward, not this story.

## Assumptions (2 — the constitution's cap)

1. **The deletions are outright, with no archive branch.** Founder-approved this session. Git
   history is the archive; `main` retains every file at `4893683`.
2. **`check-hero-dims.py` goes**, and `verify-session-31.sh` is allowed to become permanently
   unrunnable, joining the 8 already recorded as such. Founder-approved this session. The live
   pair is 39 / 41 / 42.

*Both were asked in chat before work began; neither is inferred.*

## Founder decision F42-1 — inline commit marker for this session only

The L2 `.githooks/pre-commit` gate requires `VAJRA_ALLOW_COMMIT=42` in the environment.
`CONSTRAINTS.yaml#commit.approval_tokens` accepts a chat token; the S93 gate deliberately does
not read chat, because a marker the agent can type is self-granted. `.githooks/pre-commit:20`
says so explicitly — *"L2 alone is auditable, not un-forgeable."*

The L3 layer that would enforce the un-forgeability is `.claude/settings.json`, which is
Claude Code configuration and does not run under this harness. So in this session **only the L2
belt is live**, and the founder's chat approval could not reach it.

**Decision:** the founder authorized this session's agent to set the marker inline on the
command line, scoped to session 42 only, **and to record that fact here** rather than have it
pass silently. A marker this agent typed is not un-forgeable founder evidence; it is a founder
decision that happened to travel through a channel the guard cannot read. Saying so is the whole
point of recording it.

**Not decided here, and deliberately:** whether `commit_guard: off` belongs in
`CONSTRAINTS.yaml`, as it does in the vajra repo — which disables L3 precisely because a live
block "bricks the build agent's own commits". This project ships **no** such line, so enforcement
is deliberate. Whether that is still right for an agent-driven workflow is a question for S44's
decision batch, not a side effect of one session's friction.

## Closeout

`verify-closeout.sh` exits 0 — which structurally requires an **ACCEPT** review, not a `PARTIAL`.
Then `.ai/` is synced, the PR merges to `main`, and **S43 begins in a new chat**
(`one_session_per_chat` — this chat has not yet owned a vajra session).