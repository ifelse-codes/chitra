# Session 35 — Ground-Truth Audit (NO-CODE)

**Type:** Mandatory 5th-session ground-truth (`35 % 5 == 0`). No code, no commits, no PRs.
**Date:** 2026-09-23 · **Branch:** `session-35-ground-truth`
**Mandate:** catch BOTH direction drift (vision + roadmap) AND discipline drift
(rules + constitution + state + cost). Every finding is grounded in a checked
command and its result — nothing asserted from memory.

> The trap this session must avoid: auditing rule-following without auditing the
> vision. Rules exist to serve the north-star; a green verify script proves
> discipline, never fidelity.

---

## Evidence actually checked (raw)

| # | Probe | Result |
|---|---|---|
| 1 | `git status` | on `main` at session start; untracked `prompts/35-task-ground-truth.md` (S35 prompt is **not committed**) |
| 2 | `git log --oneline -15` | HEAD `5b1d13d Merge pull request #40 … session-34-gtm-readme` — **S34 is merged to `main`** |
| 3 | `git tag -n1` | `v0.1.0  Release v0.1.0` (annotated) |
| 4 | `git show -s v0.1.0` | points at `4e0409a` dated **2026-07-29**, ancestor of `main` |
| 5 | `git ls-remote --tags origin` | **empty** — tag exists **locally only**, never pushed |
| 6 | `npm view @chitra/core version` | **E404** — not on npm |
| 7 | `pnpm --filter @chitra/core run test` | **452 passed (23 files)** ✅ |
| 8 | `ls packages/core/dist` | populated (`index.js`, `index.cjs`, `index.d.ts`, …) — dist **is** built |
| 9 | `ls packages/core/tests` | **23** test files |
| 10 | `grep -n '\*\*Number:\*\*' .ai/SESSION-BOOT.md` | `34`; `.ai/SESSION` = `34` |
| 11 | `.ai/STATE.md` L69 | "PR **#40** … → `main` → next session" — **false, #40 is merged** |
| 12 | `grep -n 'stable\|134' artifacts/chitra-docs/src/App.tsx` | L541 `v0.1.0 — stable`, L561 `134` Tests passing |
| 13 | session coverage loop (S01–S35) | **S04, S06, S16, S17, S32** have no prompt/verify/demo/summary/review |
| 14 | `.ai/verify/closeout/*/session-file-valid.log` | N values present: 8–31, 33, 34 — **no 17, no 32** |
| 15 | `grep -niE 'ground' .ai/hooks/* .githooks/*` | only a **boot reminder** (`hook-session-start.sh:49`); no enforcing hook |
| 16 | `grep -rniE 'ground.?truth\|% 5' .githooks .ai/hooks scripts` | no GT-code/commit/PR guard exists |
| 17 | `.github/workflows/ci.yml` jobs | `core · docs · chart-drift · browser-qa` — **no closeout/ground-truth gate** |
| 18 | `.github/workflows/release.yml` | `on: push: tags: ["v*"]` → publish |
| 19 | `git log --all --grep=deploy` | last deploy commit is **S30**; none since. Freeze confirmed |
| 20 | `grep -n 'ai-data' README.md` + freeze | README links `chitra.iifelse.com/ai-data`; that page is **S33, never deployed** |
| 21 | `.ai/KNOWLEDGE.md` L34/80/185 | `142 tests`, `163 core tests`, `442 tests` — all disagree with **452** |
| 22 | `.ai/KNOWLEDGE.md` L28/88/21/91 | `7 files`, "dist not produced by build", `CI targets 20/22/24`, "`main` hosts S00–S08" — all false |
| 23 | `.ai/verify/closeout/latest/*.log` | S34 crew gate `verdict: NOT READY` → `WAIVED: VAJRA_CLOSEOUT_WAIVER=34` |
| 24 | `grep -n 'Cost Tracking' .ai/STATE.md` + `verify-closeout.sh:118` | section present; gate only **greps the heading** |
| 25 | `.ai/.session-owner` | `12` — one-session-per-chat ownership last recorded **S12** |

---

## 1. vision_alignment — 🟡

**North-star:** *the best terminal chart lib ever created — zero-dep, AI-first, delightful.*

| Question | Finding |
|---|---|
| Still the right destination? | **Yes.** Evidence: 452 green tests (#7), 0 runtime deps, `ChartResult` agent surface intact, 20 charts / 3 renderers / 7 themes. Nothing argues for a pivot. |
| Shortest path, or fun scope creep? | **Shortest path has stalled at distribution.** The library is built (dist exists, #8) but **not installable** (`npm view` → E404, #6). S33 (release readiness) + S34 (GTM README) are polish on a product no user can `pnpm add`. This is the same "storefront before the product ships" ordering risk S05 flagged — now recurring. |
| New evidence that would force a pivot/abandon? | (a) npm scope `@chitra/core` unavailable/blocked; (b) zero external adoption 3+ sessions after first publish; (c) an incumbent (Ratatui/`ansi-to-tui`, glimpsed in KNOWLEDGE) absorbing the AI-chart niche. None is observed yet, but (a) is untested. |

**Concrete vision wound (new):** The S34 README — the GTM front door — advertises
`https://chitra.iifelse.com/ai-data` (#20). The AI-data manual shipped in **S33** and
**was never deployed** (freeze since S30, #19). The README therefore points at a page
that the live SPA fallback silently serves as the home page (soft 404). The GTM asset
sends its best lead to a dead link.

## 2. roadmap_alignment — 🟡

| Question | Finding |
|---|---|
| Each phase still maps to north-star? | The S18–S29 chart-lock programme maps (design quality = "delightful"). S30–S34 map (docs/GTM). |
| Is the next item the highest-leverage one? | **Mostly yes.** The roadmap's next candidates — exercise `v0.1.0` release, unfreeze + redeploy, fix stale pills — are exactly the distribution bottleneck. **But** item ordering is soft: the release needs the stale local `v0.1.0` tag resolved first (#3–5), which the roadmap never mentions. |
| Obsolete item? | `artifacts/api-server` is still `/healthz`-only (STATE). The roadmap's "flesh out … *if the hosted API is pursued*" is unowned and drifting. |
| Vision demands, roadmap lacks? | **(a) An MCP server.** Vision says *AI-first*; README advertises `server.tool("render_chart", …)` (#README L150). No MCP package/handler ships and no roadmap item exists. **(b) A GT-remediation closure item** — see §6. |

## 3. state_drift — 🔴

`.ai/STATE.md` and `.ai/SESSION-BOOT.md` describe a repo **one merge behind**.

| Claim | Source | Reality (checked) |
|---|---|---|
| "PR **#40** to `main` to go" | STATE L9, L69; TASK L18 | `#40` merged — `5b1d13d` is `main`'s HEAD (#2) |
| "`main` has S00–S33. PR #40 carries S34" | SESSION-BOOT L11–12 | `main` has S00–**S34** (#2) |
| "close on branch; main untouched until PR #40 merges" | SESSION-BOOT L6 | merge already happened (#2) |
| `.ai/SESSION` = `34` | SESSION | Correct convention (bumps at closeout) but the branch is `session-35-*` |
| 452 tests | STATE | ✅ verified (#7) |
| "S05 ground-truth remediation debt still open" | STATE L50 | ✅ still true (see §5) |
| v0.1.0 tag status | *unmentioned anywhere* | A **local, unpushed `v0.1.0` tag on a 2026-07-29 commit** exists (#3–5) |

**Finding:** the snapshot's *active-branch / in-progress* facts are false. `STATE.md`
was written at S34 closeout **before** the PR merged and was never re-synced (S35 is
NO-CODE, so it won't sync either). The stale `v0.1.0` tag is undocumented and dangerous:
`release.yml` fires on any `v*` tag push (#18) — `git push --tags` would publish a
**pre-product commit from July** as the npm release.

## 4. knowledge_staleness — 🔴

`.ai/KNOWLEDGE.md` is *reloaded every session* and states multiple flat falsehoods.

| Line | Says | Truth |
|---|---|---|
| 34 | `pnpm --filter @chitra/core run test` → **142 tests** | **452** (#7) |
| 80 | "**163** core tests stay green" | **452** (#7) |
| 185 | "Suite is **442** tests" | **452** (#7) |
| 28 | Vitest `packages/core/tests/`, **7 files** | **23 files** (#9) |
| 88 | published `dist` "is **not produced by the current `build` script**" | `packages/core/dist` is populated; build = `build.mjs` + `tsc -p tsconfig.build.json` (#8) |
| 21 | "CI targets **20/22/24**" | `ci.yml` `NODE_VERSION: "26"` |
| 91 | "`main` hosts **S00–S08**" | `main` hosts S00–**S34** (#2) |
| 78 | live preview at **`/tmp/ring-lab/index.html`** | ephemeral, gone |

Three mutually-contradictory test counts in one file (142 / 163 / 442), none equal to
the real 452, is the exact "stale byte that misinforms every future session" class S05
found. The git-repo falsehood was fixed after S05; the test-count/CI/dist facts were not.

## 5. constraint_violation_review — 🟡

Walk of `.ai/CONSTRAINTS.yaml`:

| Rule | Held? | Evidence |
|---|---|---|
| verify + demo required for done | 🟡 | Present for every recent CODE session (S18–S34). **Missing: S17 and S32** (merged via PR #19 / #38 with no scripts, no summary, no review, no closeout run) (#13, #14). |
| branch discipline (`forbid_direct_work_on: main`) | ✅ | Recent history is merge-commits from `session-*` branches (#2). Direct `main` commits are all pre-S07 history. |
| max 3 files per atomic commit | ✅ | `pre-commit` hard-blocks `>3`; S34 commits recomputed at 2–3 files. |
| approval tokens (`VAJRA_ALLOW_COMMIT`) | ✅ | Enforced by `.githooks/pre-commit` (S93) + `.ai/hooks/hook-commit-guard.sh`. |
| one-session-per-chat | ⚠️ | Rule is `true`; the guard is wired, but `.ai/.session-owner` was last written at **S12** (#25) — enforcement has been dormant for 23 sessions. |
| NO code in Ground Truth | 🔴 | `AGENTS.md` Hard Rules says **"Hook-enforced"**; `grep` finds **no such hook** — only a boot reminder (#15, #16). |
| GT artifact path (`-closeout`/`-enforcement` suffix) | ✅ | This file lives on `session-35-ground-truth` and is left **uncommitted** per guardrails. |
| NO commits / NO PRs in GT | ✅ | None made. |

**Closeout-integrity hole (still open from S05):** `verify-closeout.sh` is only ever
invoked as an `--advance` step or by hand — it is **not in CI** (#17) and **not a
pre-merge gate**. S17 and S32 produced **no closeout run at all** (#14) and merged
anyway. The `check_session_pair` gate only iterates summaries that *exist*, so a
session that leaves no summary (S17, S32) is invisible to it. This is the S05
remediation item #4/#5, unfixed **30 sessions** later.

## 6. constitution_review — 🔴

| Question | Finding |
|---|---|
| Is any rule blocking the vision? | **Yes — one is vacuous, and one is mis-declared.** (a) The **required-crew gate is unpassable** in this environment (#23: S34 `verdict: NOT READY` → founder waiver). It is an **imported Vajra mechanism**; chitra's own constitution never required a crew. Every closeout now leans on `VAJRA_CLOSEOUT_WAIVER`, which trains the waiver muscle and hollows the gate. (b) `AGENTS.md` declares "**No code in Ground Truth — Hook-enforced**" but **no hook exists** (#15, #16) — a rule claimed on paper, absent in fact. |
| Meta-check — did *this audit's mechanism* have a blind spot? | **Yes, three, and two are fatal to GT's purpose.** 1. **GT findings have no teeth.** Nothing anywhere reads `session-NN-ground-truth.md` and requires its remediations to be closed. Proof: S05's remediation #4 (backfill S04 verify/demo/summary) and #5 (closeout-integrity gate) are **still open 30 sessions later**; S05's own evidence table even predicted this ("a skipped closeout can rot for 4 sessions"). The next closeout gate checks the *next* session's fidelity, never the *previous* GT's promises. 2. **The auditor is the same lineage as the builder.** This file is written by the agent that ships code, on a self-named branch, and (per guardrails) may be committed without an independent review. `AGENTS.md`'s "No self-certification" rule binds CODE sessions via `reviewer/SKILL.md`, but **not** the GT artifact itself. 3. The 7 audits are all *bookkeeping*; none samples whether the **product is actually good/usable** (no adoption, perf, or user-outcome probe). |

## 7. cost_review — 🟡

- `STATE.md` has a `## Cost Tracking` section (gate `check_cost_tracking` passes), but it
  is **prose, not numbers** — "Cumulative: chitra sessions ~$0", billed to Vajra, a \$20/mo
  plan, subagent counts per session. No per-session token or dollar figure is recorded.
- The gate is **hollow**: `verify-closeout.sh:118-127` only `grep`s for the heading
  "Cost Tracking" (#24). Any text passes.
- Honest? Partially. It correctly discloses S20/founder-plan and S33/S34 subagent usage,
  but "~$0" is an assertion with no receipt. It is *maintained* (better than S05's dead
  `$0.00`), **not *measured***.

---

## Verdicts

| Audit | Verdict |
|---|---|
| vision_alignment | 🟡 north-star right; **distribution stalled** (npm 404); README → dead `/ai-data` link |
| roadmap_alignment | 🟡 next items are highest-leverage; **no MCP item**; stale `v0.1.0` tag unmanaged |
| state_drift | 🔴 STATE/SESSION-BOOT/TASK a merge behind; undocumented local `v0.1.0` tag |
| knowledge_staleness | 🔴 **142 / 163 / 442** test counts, "7 files", "dist not built", "CI 20/22/24", "main S00–S08" |
| constraint_violation_review | 🟡 verify/demo + max-files + approvals held; **S17 & S32 merged artifact-less**; closeout gate not in CI |
| constitution_review | 🔴 "No code in GT — Hook-enforced" is **false**; crew gate unpassable (imported); **GT findings never tracked to closure** |
| cost_review | 🟡 maintained prose, no figures; closeout cost check greps a heading |

**Overall: 🟡 — direction sound, discipline uneven, distribution blocked.**
The product is genuinely good and green (452 tests, 20 charts, zero deps, real renders).
But the north-star's *delivery* is stuck: `@chitra/core` is **not installable**, the GTM
front door points to an **undeployed page**, a **stale local `v0.1.0` tag** could publish
July's code, and the **governance layer's own claims are false** (hook-enforced GT rule,
crew gate, GT closure). The bookkeeping drifted again — exactly what this session exists
to catch. Not a red pivot signal; a yellow "ship it or stop polishing the storefront".

## Ranked remediations (for the NEXT code session to fold in — NOT this one)

1. **Resolve the `v0.1.0` tag before any release (highest risk).** Delete the local
   2026-07-29 `v0.1.0` tag (`git tag -d v0.1.0`), then cut it on the *current* `main` HEAD
   at the moment of release. Never `git push --tags` with the stale tag present
   (`release.yml` publishes on `v*`). — closes §3 risk.
2. **Exercise the real release + unfreeze.** Publish `@chitra/core` (needs the founder
   `NODE_AUTH_TOKEN`), then redeploy `chitra-docs` — which also makes the README's
   `/ai-data` link real (§1 wound) and lets the stale pills be fixed in one deploy.
3. **Fix the docs-hero pills** `App.tsx:541` `v0.1.0 — stable` → honest status and
   `App.tsx:561` `134` → **452** (or remove the hard-coded count). — §3/§4.
4. **Rewrite KNOWLEDGE.md facts:** test count → **452** everywhere (one canonical number),
   test files → **23**, CI Node → **26**, `main` → S00–S34, drop the "dist not produced"
   claim and the dead `/tmp/ring-lab` path. — §4.
5. **Sync STATE/SESSION-BOOT/TASK** to "S34 merged (`5b1d13d`), PR #40 closed". — §3.
6. **Close the S05 closeout-integrity debt for real:** backfill or explicitly waive S17/S32
   artifacts, and wire `verify-closeout.sh` (or a subset) as a **CI/pre-merge gate** so a
   session that leaves no summary cannot merge. — §5.
7. **Make GT findings binding:** add a step to the next CODE session's contract that reads
   `session-35-ground-truth.md` and dispositions every remediation; or add a `-closeout`
   review of the GT artifact itself (breaks GT self-certification). — §6 meta.
8. **Correct `AGENTS.md`:** either implement the "no code in GT" hook or remove the
   "Hook-enforced" label. Resolve the crew gate: drop the imported check or mark it a
   founder-waiver-by-default, so a waiver isn't needed for every close. — §6.
9. **Give cost a number** (per-session tokens/\\$ or explicitly "unmeasured") and make the
   closeout cost check assert content, not a heading. — §7.
10. **Add an MCP-server roadmap item** (vision = AI-first; README already advertises the
    handler). — §2.

## Recommended next session

**S36 — "Ship it": exercise the real `v0.1.0` release and unfreeze the live deploy.**
It is the single highest-leverage step to the north-star: it converts a green library into
an installable one, makes the S34 README's links honest, and lets remediations 1–5 be folded
in under one delivery. Evidence: npm E404 (#6), freeze since S30 (#19), stale `/ai-data` link
(#20), stale `v0.1.0` tag (#3–5). Fold remediations 1–5 into the S36 contract; carry 6–10 to
S37.

---
*No source files were modified and no commits or PRs were made in this session.
This artifact is left uncommitted on `session-35-ground-truth` per the prompt guardrails
(the ground-truth commit exemption requires a `-closeout`/`-enforcement` suffix), or is
folded into the next session.*
