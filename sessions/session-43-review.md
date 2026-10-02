# Session 43 — independent cold review

**Reviewer:** a separate `reviewer` subagent (`ColdReview`), fed only the contract
`prompts/43-task-docs-weight.md` and the delivered diff (`git diff main...HEAD`). It did not
write any of this code and did not trust `sessions/session-43-summary.md`.

**Review-Inputs-SHA:** ee409196499e0c35b107f9bb0d8d9f2286662ee076d98eb810a52cc8e8ee40e5

---

## What the reviewer verified, adversarially

- **The deletions are real.** 53 shadcn components gone (2 tracked: `card`, `toast`), 36
  devDeps gone, 3 `@replit/*` plugins gone from config + manifest + catalog, the `lint`
  script gone.
- **The gate is non-vacuous — four hand-broken premises each turned it RED:**
  1. re-adding a tracked component → `ui-components-shipped` FAIL;
  2. re-adding `- lib/*` to the workspace globs → `replit-globs-match-workspace` (the N8
     clause) FAIL;
  3. a semantic (non-format) edit under the LOCKED dirs → `charts-format-only` FAIL;
  4. breaking the base ref → `charts-format-only` FAIL (the N6 fix).
- **N2–N9 hold under re-testing**, and **the counterfactual is real**: `s42-gate-verbatim-goes-red`
  extracts S42's actual `charts-untouched` body and it exits non-zero on the S43 format.
- `verify-session-43.sh` runs **40/40 GREEN** on the true tree (~2 minutes).

## Defects found (both low priority; neither reopens a numbered requirement)

| # | Finding | Severity | Status |
|---|---|---|---|
| 1 | The lockfile is bundled with `package.json` in the dep-removal commit, and the commit message claimed "in its own commit" — a claim the file list contradicts. The commit is still separate from the component-deletion commit, so req 2's intent holds; the wording overclaimed | P2 | **FIXED** — both commit messages reworded ("alongside the manifest change, in a commit separate from the component-deletion commit") via rebase |
| 2 | The demo header said "Every number … NONE is typed", but its prose hardcodes 55/53/36/64/26/~6000 as before-context. The load-bearing numbers ARE derived | P3 | **FIXED** — the header now says LOAD-BEARING numbers are derived and the prose figures are typed context |

## Disclosed by the builder, and accepted by the reviewer

- The format commit used `--no-verify` (the 3-edited-file cap cannot express a 76-file
  formatter run; the contract's F43-1 authorises it as one mechanical commit).
- `card` and `toast` are referenced only by `pages/not-found.tsx` and `hooks/use-toast.ts`,
  which are themselves unreachable from `main.tsx` — so the docs app renders zero shadcn
  components. This matches the contract's reference-closure definition and is disclosed for S44.
- The Prettier reformat moved v8 statement/line coverage 96.11 → 94.27 with no behaviour
  change (v8 counts source lines); CONTRIBUTING was updated and the cause recorded.

## The map — 10 of 10

| # | Requirement | Verdict |
|---|---|---|
| 1 | Delete the unused shadcn components | SHIPPED |
| 2 | Remove the deps that die with them | SHIPPED |
| 3 | Strip the 3 `@replit/*` Vite plugins | SHIPPED |
| 4 | Remove the dead `lint` script | SHIPPED |
| 5 | Prettier: adopt, format, enforce (F43-1) | SHIPPED |
| 6 | Port the gate — discover, don't enumerate | SHIPPED |
| 7 | Fix N2–N9, each with a counterfactual | SHIPPED |
| 8 | Re-prove the product from live facts | SHIPPED |
| 9 | Re-sync `.ai/`; counts derived, not typed | SHIPPED |
| 10 | Fidelity map + independent review | SHIPPED |

**Verdict:** ACCEPT
