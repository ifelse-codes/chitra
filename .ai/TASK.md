# Current Task Pointer

## Session 41 — cleanup Batch 1: the public face tells the truth, and a stranger can build it

- **Branch:** `session-41-repo-cleanup`, from `main` `ece61fc` (== `origin/main`).
- **Contract:** `prompts/41-task-repo-cleanup.md` — **committed at HEAD**, which is what
  `review-inputs-attested` hashes. S40 failed that gate because a NO-CODE session cannot
  commit its contract; this one can, and did.
- **Why:** S40 ground-truth row 2 — the founder's decision is that the repo goes public
  *after* a code cleanup, and that cleanup had no roadmap item, no scope, no owner. The
  npm package is **`@ifelse.codes/chitra@0.3.0`**, live and public-facing, so the repo
  around it has to be true. Two independent audits now set the scope:
  `code-cleanup-plan-session-41.md` and the blind `independent-audit-RESULT.md`. Both are
  committed, so the reasoning is checkable. The blind pass found 8 things the first missed,
  and one of them **inverts the first pass's fix**: a fresh clone fails `pnpm run build`
  because the root script typechecks the docs before `@ifelse.codes/chitra`'s gitignored
  `dist/` exists — not (only) because `PORT` / `BASE_PATH` are unset. Both fixes are in
  scope.
- **The story, in one line:** *a stranger who clones this repo reads nothing false, and
  `pnpm install && pnpm run build` succeeds with no environment variables set.*
- **13 numbered requirements** in three groups: A what a visitor or consumer sees (1–9),
  B what a stranger can do (10–12), C junk that would ship on a careless `git add -A`
  (13). Max 1 story per session, so **Batch 1 only** — Batches 2–4 are now roadmap items
  **S42, S43, S44**, which is the S40 row 2 finding (unowned work) closing.
- **Cross-cutting trap, named in the contract:** the canonical test count is displayed in
  several tracked files and asserted as a literal in the historical verify scripts. That is
  how `main` lost `ece61fc`. So the new drift guard adds **no test file**, and
  `test-count-propagated` *derives* the count from a suite run and fails if any site it
  reads disagrees — its clause list is the inventory, and no document claims how many
  display sites there are, because a hand-counted number about a test count is the thing
  that rots. `verify-session-39.sh` must stay 43/43.
- **Founder decisions this session does not make:** D1 (how much internal process goes
  public — blocks the *flip*, not this work), D2, D3/D6, D4 (personal-path scrub —
  irreversible once public), D5.
- **Open in a new chat** for S42.
