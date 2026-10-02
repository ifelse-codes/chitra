# Session 42 — fidelity map

Cleanup **Batch 2: dead weight.** Contract: `prompts/42-task-dead-weight.md` (at HEAD).
Branch `session-42-dead-weight` from `main` `4893683`. PR #63.

**13 commits · 130 files changed, +1296 / −12418 · 110 deleted, 3 added, 17 modified ·
0 files under the LOCKED chart code · S42 gate 33/33 · S39 gate 43/43 · 453/453 tests.**

> **Fidelity ≠ discipline.** A green gate proves discipline, never fidelity. Every numbered
> requirement below is mapped to evidence, and the ones that are not fully delivered are
> called PARTIAL or NOT-BUILT rather than rounded up. The independent verdict is
> `sessions/session-42-review.md`; it is fed only the contract and the diff, and it does not
> trust this document.

---

## The map — 10 of 10

| # | Requirement | State | Evidence |
|---|---|---|---|
| 1 | Delete the four dead trees | **SHIPPED** | `ccfcd9c` — 103 files, 511 → 409. `dead-trees-gone`: 0 tracked under each. Verified 69 + 20 + 11 + 3 = 103 |
| 2 | Cut the 9-file reference chain | **SHIPPED** | `06ef402` + `3bf9111`. All nine cut; `no-live-ref-to-dead-trees` proves 0 surviving refs in build/config/script files |
| 3 | `typecheck:libs` gone end-to-end | **SHIPPED** | `b83cbe7`. `typecheck-libs-gone-end-to-end` asserts absence from the script, `ci.yml`, `release.yml` **and disk** |
| 4 | Delete 6 dead scripts | **SHIPPED** | `a2794f4`. `dead-scripts-gone` also re-runs the scripts typecheck, so the two dangling refs are proven cut, not assumed |
| 5 | Lockfile regenerated, `--frozen-lockfile` green | **SHIPPED** | `4e564e5`, its own commit. +67 / −3177, 10 → 4 importers. `lockfile-frozen-no-dead-importers` asserts both halves |
| 6 | S42's gate is a **port**, not a copy | **SHIPPED** | `5b2f13c`, then three corrections in `4eca871`. 33 checks. `vite-configs-discovered` + `s41-gate-verbatim-goes-red` |
| 7 | The product re-proven from live facts | **SHIPPED** | `fresh-clone-build-no-env`, `core-tests`, `core-typecheck`, `root-typecheck`, `s39-suite-still-green`, `example-runs` — all green in the gate run |
| 8 | Browser QA + green CI | **SHIPPED** | `node scripts/qa-catalog.mjs` → 20 chart pages, 0 console errors, 0 page errors, persistence PASS. CI run `36981925367` → `conclusion: success` |
| 9 | `.ai/` re-synced; frozen history untouched | **SHIPPED** | `daadeba`, `1d7d1f5`, `d1e6bfd`, `a38b3f5`. `ai-files-describe-s42`, `ai-names-no-deleted-tree`, `test-count-propagated` |
| 10 | Fidelity map + **independent** review | **PARTIAL** | This file is the map. The independent review is `sessions/session-42-review.md` |

### The one PARTIAL, stated plainly

**Req 10 — the review.** The map is done. The independent pass is a separate agent fed only
the contract and the diff. It is the only thing that can say whether requirements 1–9 were
*delivered* rather than *attempted*, and it has rejected this delivery's predecessors twice.

Req 8 was PARTIAL while this file was first written — local QA was green but "green CI" is a
claim about a remote run. It is now **SHIPPED** against CI run `36981925367`, `success`.

---

## What is NOT-BUILT, and was named before work started

Not smuggled in, not deferred quietly:

- **S43** — 43 unused shadcn components (~5,000 LOC), Prettier (31 core files fail `--check`),
  the `lint` script pointing at an eslint nobody installed.
- **S44** — OSS polish (`SECURITY.md`, CoC, templates, CI badge, coverage job, `engines`) and
  founder decisions **D1–D6**, including **D4**, the `/Users/suman/…` scrub, which is
  **irreversible once published**.
- **The public flip** — after S44.
- **`pnpm-workspace.yaml`'s ~140 lines of `overrides`** (expo, ngrok) — **D5**, S44, needs its
  own lockfile regen. This session regenerated the lockfile and deliberately left `overrides`
  alone so the two regens stay separable.
- **Any change under `packages/core/src/`** — this is a repo-hygiene session.
- **Historical `verify-session-NN.sh` / `demo-session-NN.sh` pairs** — out of scope, and
  `verify-closeout.sh` reads the current session's.
- **The four S40 governance rows and the GTM proof pack** — carried forward untouched.

---

## Three claims that did not survive the tree

Recorded because the contract is what the review is fed, and repeating a stale claim would
have been a fidelity failure dressed as tidiness.

| Claimed | Observed at S42 boot |
|---|---|
| ROADMAP: `mockup-sandbox` "breaks the root build" | `run build` → exit 0, `run typecheck` → exit 0. S41's build-order fix cured it. **The reason to delete it is weight, not breakage** |
| ROADMAP / S41 audit: "5 dead scripts", incl. `build-audit-html.mjs` | That file **does not exist**. Four remained, and S41's audit missed **two more** (`ring-polish-handoff.mjs`, `workflows/15-qacheck.sh`) with zero live refs |
| ROADMAP / S41 audit: the "6-file reference chain" | **9 files.** `release.yml` (the publish path) and `docs/package.json` were missing. Both would have been red CI |

---

## The finding this session is actually about

**S41's own gate breaks under requirement 1.** `vite-configs-no-hard-throw`
(`verify-session-41.sh:116`) enumerated two vite configs by path:

```bash
for f in '"$DOCS"'/vite.config.ts artifacts/mockup-sandbox/vite.config.ts; do
```

Delete that tree and `grep -q` against a missing file exits 1, the guard fires, and the gate
reports a defect that does not exist. Demonstrated, not argued:

```
grep: artifacts/mockup-sandbox/vite.config.ts: No such file or directory
artifacts/mockup-sandbox/vite.config.ts does not default PORT
artifacts/mockup-sandbox/vite.config.ts does not default BASE_PATH
check exit = 1
```

A green gate from the previous session was **not** evidence this session could inherit.

The fix is to **discover** the inventory and assert it is non-empty — an empty discovered list
being the vacuous pass the S41 review caught in a different check. `s41-gate-verbatim-goes-red`
runs S41's **actual** gate and asserts three things, not one: it exits non-zero, it is red on
*that* check, and S41's own log names the deleted path. A gate red for an unrelated reason does
not satisfy it.

> Written into `.ai/CONTINUATION-PROMPT.md` because S43 deletes 43 more files:
> **any gate that names a path will break the moment that path is deleted. Discover, do not
> enumerate.**

---

## Two judgments beyond the contract's wording — both flagged for the review

**1. Root `tsconfig.json` was deleted, not emptied.** The contract's req 2 table says it loses
its three project references. Emptying it would leave
`{ "extends": "./tsconfig.base.json", "files": [], "references": [] }` — knowingly dead weight,
in a session whose thesis is removing dead weight. Its only consumer was `tsc --build` under
`typecheck:libs`, removed in req 3; `git grep` finds no other reference. `tsconfig.base.json`
survives and is what docs and scripts extend. **A judgment, not an instruction.**

**2. `scripts/tsconfig.json` became `files: []`, and the scripts package stays.** Deleting both
files in `scripts/src/` empties it, and `pnpm --filter @workspace/scripts run typecheck` then
exits 2 with `TS18003: No inputs were found in config file`. Run, not assumed. The package stays
because root `pnpm run typecheck` filters on `./scripts`, and `dead-scripts-gone` re-runs that
typecheck so the check cannot pass by doing nothing.

---

## Five defects found by the gate that reading the script did not find

Recorded because *how* they were found is the point. Every one was caught by the gate going red.

| # | Defect | Caught by |
|---|---|---|
| 1 | **A commit whose message described three sites and contained one.** `06ef402` was first made without staging the two docs edits. Fixed by amending, since the branch was unpushed — a commit whose prose disagrees with its diff is a lie in history | `git show --stat`, reading my own work |
| 2 | **Two invented per-file idioms and one invented guard.** The ported `test-count-propagated` grepped README and CONTRIBUTING for `"(453 tests"` and App.tsx for `"**453 green**"`. **None of those three strings exists in this repo** — README uses a shields.io badge, App.tsx a `stat-num` span, and CONTRIBUTING does not display the count. Four of S41's guards were missing too | `test-count-propagated` |
| 3 | **A check that judged prose.** `ai-names-no-deleted-tree` required a qualifier word on the *same line* as each mention, and failed on STATE.md's own bullet. The fix would have been to reword STATE.md until it passed — backwards. Replaced with the discovered-set pattern the S41 review already forced into existence | `ai-names-no-deleted-tree` |
| 4 | **A check scoped to its author's habits.** `dead-trees-gone` asserted the directory was *absent from disk*. `mockup-sandbox/dist/` is gitignored build output, so absence is green on a fresh clone and red on the machine that once ran a build. **A gate whose result depends on what the developer last ran is a coin flip** | `dead-trees-gone` |
| 5 | **A regression I introduced, caught by a gate written two sessions earlier.** Rewriting `SESSION-BOOT.md` and `TASK.md` dropped `@ifelse.codes/chitra` from both, and S39's `live-ai-files-state-the-present` went red | `s39-suite-still-green` |

Defect 2 is the one the cold review should press hardest on: **I did not copy, I guessed, and
guessing failed on exactly the thing that cannot be guessed.** A "port" that invents checks is
worse than no port.

---

## Honest gaps

- **The inherited `test-count-propagated` proves a demo displays the canonical count by grepping
  the demo *file*** — which a **comment** satisfies. S41's demo passed on its comment alone. Fixed
  for S42 only, by `demo-displays-count-at-runtime`, which runs the demo and greps its output.
  **The same shape likely survives elsewhere in this repo and was not swept.**
- **Historical verify scripts are already unrunnable** (01, 02, 03, 07, 34, 36, 37, 38) and S42
  added `verify-session-31.sh` to that set, by founder decision. Not repaired; the repo has
  declined that three times.
- **`charts-untouched` compares `main...HEAD`.** It proves this branch did not touch the LOCKED
  chart code. It says nothing about earlier sessions.
- **Cost is unmeasured.** Token/`$` cost was not captured (billed to the founder's plan). npm
  cost $0. No new infrastructure.
- **`s41-gate-verbatim-goes-red` costs a full S41 gate run**, including its own fresh clone. That
  is roughly a third of the S42 gate's runtime, spent proving the session's central claim.

---

## Cost Tracking

One opencode session. **Four in-chat founder decisions** — three asked at boot (outright
deletion with no archive branch; `check-hero-dims.py` and the S31 consequence; include the two
scripts S41's audit missed) and one authorising decision (**F42-1**). 10 requirements, 130
changed files, 13 commits, **0** product-code changes under `src/charts/`, `src/renderers/` or
`src/themes/`, **0** new product tests (453 stays 453 — this session does not touch the product),
**1** lockfile regen, **0** releases, **0** npm secrets touched. Five full S42 gate runs plus a
standalone fresh-clone build, one standalone browser QA run, and ~15 targeted counterfactuals.
**Two** S42 gate checks were wrong before they were right and **one** commit had to be amended.
Token/`$` cost **unmeasured**. npm cost: $0. No new recurring infrastructure.