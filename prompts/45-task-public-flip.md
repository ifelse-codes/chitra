# Session 45 — the mandatory ground-truth audit; the public flip carries to S46

**Status:** contract drafted **before any work**, at plan-approval stage. **Never committed, never fed
to a reviewer** — so this is a draft, not an amendment: `reviewer/SKILL.md`'s freeze rule (N1) has not
attached yet, and no `## Contract amendments` entry is owed for the restructure below.

**Repo state when written:** `main` = `5a39c43` (derive — `git rev-parse main`), which is **S44
merged** (PR #65 + follow-up #66). `.ai/SESSION-BOOT.md` and `.ai/TASK.md` still describe S44 as
in-progress on `session-44-oss-polish`; that is stale, and req 9 re-syncs it.

---

## Why this session is an audit and not the flip

**`45 % 5 == 0`.** `CONSTRAINTS.yaml` sets `ground_truth_every_n_sessions: 5`.
`.ai/hooks/hook-ground-truth-guard.sh` reads the session number off the branch, returns early unless
`N % 5 == 0`, and at this repo's live maturity **L3** **BLOCKS** every write outside
`sessions/*`, `.ai/*`, `prompts/*`, `*.md`, `*.txt`. S40 was the last one; **this is the next one**,
and it is the audit the cadence exists to produce.

The flip cannot run here, and the block is not a technicality:

| The flip needs | Guard |
|---|---|
| repo visibility → public | ✅ remote state, no file write |
| `.github/REPO-SETTINGS.md` re-derived, README clone URL, npm links | ✅ `*.md` — and req F3 needs **no** edit |
| **`0.4.0` version bump** | ❌ **`packages/core/src/version.ts`** + `packages/core/package.json`. `ci.yml:41` asserts `VERSION in src` matches the manifest, so it cannot be routed around |
| `scripts/verify-session-45.sh`, `demo-session-45.sh` | ❌ `.sh` — and `check_verify_demo_scripts` **exempts** `N % 5 == 0` anyway ("no session scripts expected"), so nothing is lost but a gate that could not be honest here |

**Founder decision, recorded:** the public flip **carries forward to S46**, whole. The two open red
items remain **pre-flip prerequisites, not plan items** — see *Preconditions* below, and reqs 7–8,
which carry them on with owner and tool-decision still open.

## The one story

> **The constitution is audited on the session before the repo goes public — because the flip makes
> every vision, roadmap and state sentence in it falsifiable by a stranger, and five sessions of
> unreviewed prose is what it would be falsified on.**

---

## Preconditions — pre-flip, owed to S46, and NOT requirements of this contract

A prerequisite with no done-condition is a wish. These keep their numbers so S46 inherits them.

| # | Prerequisite | State at contract time (derived) | Done-condition |
|---|---|---|---|
| **P1** | **D4b — the home path out of every commit reachable from `HEAD`** | `git rev-list --count HEAD` → **443** commits. `(/|-)Users[-/][a-z]+` matches **0** files in the tree at `main` and **0** at `HEAD`, but **1001** (commit, file) pairs across history; earliest carrier S10. **The handoff's wording is stale** — it says "`main` still carries the home path"; after PR #65 the *tree* does not, only *history* does | the pattern matches **nothing** in **any** commit reachable from `HEAD`, re-derived by walking `git rev-list HEAD` |
| **P2** | **Private vulnerability reporting established** | `gh api repos/ifelse-codes/chitra/private-vulnerability-reporting` → **404**; `.github/REPO-SETTINGS.md` records the row **`unknown`** ("also what a caller without admin access gets", so it cannot distinguish off from not-allowed-to-ask). `SECURITY.md` and `CODE_OF_CONDUCT.md` both hedge it — a **closed door with honest signage**, not a lie | the row reads `enabled`, re-derived by the command already recorded beside it |

**P1 is irreversible once the repo is public** — rewriting afterwards means force-pushing onto a URL
strangers already hold. That is why S46 gates the flip on it rather than following it with it.

---

## Scope — 11 numbered requirements

### A · The audit

1. **`sessions/session-45-ground-truth.md`** carries **all seven** required audits
   (`vision_alignment`, `roadmap_alignment`, `state_drift`, `knowledge_staleness`,
   `constraint_violation_review`, `constitution_review`, `cost_review`) across **all six** drift axes
   (`vision`, `roadmap`, `rules`, `constitution`, `state`, `cost`), answering the **three** vision
   questions, the **three** roadmap questions and the **three** constitution questions as written in
   `CONSTRAINTS.yaml`.
2. **Both directions, or it is not the audit.** Rules exist to serve the vision; auditing
   rule-following without auditing the vision is the trap `CONSTRAINTS.yaml` names. A drift axis that
   finds nothing is reported as **probed and clean, with the probes shown** — not omitted, and not
   asserted.
3. **Every finding is a probe, not a claim:** the command, its live output, and the output that
   falsifies it. The bar S40 set and this session holds: **a finding whose number cannot be re-derived
   by the command printed beside it is not a finding.** S40's 41 probes were independently re-run and
   **38 reproduced byte-for-byte**; that is the standard, not a high-water mark.
4. **The meta-check is answered, not gestured at** — *did this audit's own mechanism have a blind
   spot?* It has a known one: **`check_ground_truth_no_code` diffs an empty range and returns `OK`**,
   proved in S40 by planting a `packages/core/src/*.ts` file and reading `INTEGRITY: PASS`
   (GT-REMEDIATIONS row 10). So this session's real NO-CODE evidence is
   `git diff --name-only main...HEAD` naming only `sessions/ .ai/ prompts/ *.md` — **not** that gate.

### B · The ledger

5. **`.ai/GT-REMEDIATIONS.md` gains an S45 section, newest ground-truth first**, one row per finding,
   each dispositioned `DONE` / `WAIVED` / `DEFERRED` — and **every `DEFERRED` row carries a `reason`
   and an `expiry`** or `check_gt_remediations` blocks closeout. The current ledger reads **7**
   `DEFERRED` rows against **16** `DONE`, and **8** `expiry 2026-10-31` mentions (today is
   **2026-10-04**).
6. **No S40 row is re-dispositioned by assertion.** Each of the 7 deferred rows is re-probed against
   live facts and moves only on the output printed beside it — including row 7's still-owed second
   half (*commit the artifact on a `-closeout` branch*), which is why this session's branch carries
   that suffix (see req 11). A deferral that quietly rolls its own expiry forward is the rot this
   ledger was built to stop.

### C · The carry-forward — the flip, handed on intact

7. **Every public-flip requirement is carried into `prompts/46-task-public-flip.md` with its number
   and its done-condition intact**, alongside P1 and P2 with owner and tool-decision still open.
   The drafted requirements are recorded in *Carried to S46* below. **Nothing is dropped in the
   handoff** — a requirement that loses its number loses its identity, which is how S16 became
   invisible to every ledger.
8. **`.ai/STATE.md` and `.ai/ROADMAP.md` name S46 as the flip session**, so the handoff cannot repeat
   S40's recorded failure: a constitutional, hook-enforced obligation that appeared in **zero of the
   last four handoffs**, which is exactly how S40 arrived as a surprise.

### D · Proof and closeout

9. **`.ai/` re-synced** — `.ai/SESSION` → 45, `SESSION-BOOT.md`, `TASK.md`, `STATE.md`, `ROADMAP.md`,
   `KNOWLEDGE.md` on demand — with **every count derived by a command, never typed**. The red
   *"the public flip still has no date"* closes by naming S46 as its session, not by deletion.
10. **Fidelity map over all 11 requirements + `sessions/session-45-review.md`** — an **independent**
    cold pass fed **only** this contract and the delivery diff, with the summary, `.ai/STATE.md` and
    `SESSION-BOOT.md` stripped out, framed adversarially, expected score withheld. The builder does not
    accept its own delivery.
11. **Closeout runs, and its known-red is named rather than routed around.** `scripts/verify-closeout.sh`
    exits 0 under `VAJRA_CLOSEOUT_WAIVER=45` **only** where a check is structurally unsatisfiable in a
    NO-CODE session, and each waiver is stated in the summary with its reason — S40's precedent is
    `required-crew`, which demands a tech-lead handoff a GT session cannot dispatch. The branch is
    **`session-45-ground-truth-closeout`** because `CONSTRAINTS.yaml`'s
    `ground_truth_commit_exempt_branch_suffixes: [-closeout, -enforcement]` is what makes the contract
    and the audit artifact committable — and, per S40 row 11, a contract **not** at `HEAD` makes
    `canonical_inputs_sha` uncomputable, so `review-inputs-attested` can only pass on a `-closeout`
    branch. That is the whole reason for the suffix.

---

## Carried to S46 — the public flip, whole

Recorded here so nothing is lost and every number keeps its identity. **S46 is a code session**
(`46 % 5 == 1`), so none of this is blocked by the GT guard there.

| S46 req | Requirement | Done-condition |
|---|---|---|
| **F1** | Repo visibility → public | `gh api repos/ifelse-codes/chitra --jq .private` reads `false`, with the **pre-flip** reading (`true`) recorded beside it |
| **F2** | README `git clone` URL resolves anonymously | HTTP **200** post-flip; the pre-flip **404** recorded beside it |
| **F3** | npm `repository.url` + `homepage` resolve — **and are not edited** | Both fields **already hold correct values** in `packages/core/package.json`; they were unreachable, not wrong. Evidence = their current bytes + the pre-flip 404 + the post-flip 200. **Editing either field is a FAILURE of F3, not a delivery** |
| **F4** | `.github/REPO-SETTINGS.md` re-derived post-flip | every row re-probed by its recorded command; `private` → `false`; the file's own rule honoured — extending its clauses requires widening its "what the gate actually checks" paragraph in the same commit |
| **F5** | `0.4.0` + **npm provenance**, released by CI unattended | `packages/core/package.json` + `src/version.ts` bumped, CHANGELOG, tag `v0.4.0` on merged `main`; published through Trusted Publishing with **no human, no tmux, no passkey, no `NODE_AUTH_TOKEN`**; `0.4.0` **carries provenance and `0.3.0` does not** — the asymmetry is the proof. `release.yml` already runs `npm publish --access public` with no `--provenance` flag because provenance attaches automatically from a public repo, so **F5 changes no workflow** |
| **F6** | GTM baseline recorded as `t0` = the measured zero | with the deriving command; **never** the **304** `@ifelse.codes/core` lifetime downloads (release-runner and founder shaped, all inside a 5-day window from the publish day) |
| **P1** | D4b history rewrite | as above — **irreversible once public**, so it gates F1 |
| **P2** | private vulnerability reporting | as above — a repository setting only the founder can change |

**F1–F6 are one story** — *the repo stops being private and every claim it makes becomes checkable* —
and they are gated on P1 and P2. **S46 must decide the rewrite tool and the re-verify order before
the push**, and must record a `before` and an `after` for every remote fact: **a visibility change
leaves no trace in the tree, so a flip with no recorded `before` fails** — otherwise a session can type
`private: false` into a markdown table and every gate in this repo will agree.

---

## Out of scope — named, so it cannot be smuggled in

| Item | Why |
|---|---|
| **The flip itself (F1–F6)** | needs `packages/core/src/version.ts`; **blocked by the GT guard**. → **S46**, reqs 7–8 |
| **P1 / P2** | preconditions, not deliverables (founder direction). Owner and tool-decision open |
| Seven dead docs deps | `framer-motion`, `react-icons`, `@tanstack/react-query`, `zod`, `date-fns`, `@tailwindcss/typography`, `tw-animate-css` — a weight session |
| `minimumReleaseAgeExclude: stripe-replit-sync` | same species as the D5 overrides, but not an `overrides` entry |
| S40's governance rows | `required-crew` (three waivers already), the vacuous `check_ground_truth_no_code`, the cost gate that greps a heading, **S16** — each re-dispositioned in the ledger, none *fixed* here (fixing needs code) |
| The rest of the GTM proof pack | benchmarks / token-savings / before-after. F6 is `t0` only |
| The MCP server | founder-DEFERRED since S38. Not built, not stubbed |

---

## Assumptions (2 — the constitution's cap)

- **AS-1 — which two reds are the prerequisites.** `.ai/STATE.md` carries **three** 🔴 under *What Is
  Broken / Incomplete*, not two: **D4b**, **"the public flip still has no date"**, and **private
  vulnerability reporting**. Read as: **P1 and P2 are the prerequisites**; the third is the flip's own
  missing date, which F1–F5 supply in S46. If a different pair was meant, this is wrong and says so.
- **AS-2 — a NO-CODE session commits only on a `-closeout` branch.** Read from
  `CONSTRAINTS.yaml`'s `ground_truth_commit_exempt_branch_suffixes` plus S40 row 11's finding that a
  contract not at `HEAD` makes `review-inputs-attested` uncomputable. Hence
  `session-45-ground-truth-closeout`.

## Founder decisions needed at plan approval

- **D-F1 — confirmed by the founder: the flip carries to S46, this session is the audit.** The contract
  above is written on that basis.
- **D-F2 — P1's owner and rewrite tool are decided at S46, not here.** P1 is irreversible once
  public, so the decision cannot slip past S46's own gate without a recorded waiver.
- **Commit approval** for this contract at HEAD (on the `-closeout` branch, per AS-2).

---

## Closeout

`sessions/session-45-ground-truth.md` + `sessions/session-45-summary.md` (fidelity map) +
`sessions/session-45-review.md` (cold) · `.ai/` synced per req 9 · `scripts/verify-closeout.sh` under
`VAJRA_CLOSEOUT_WAIVER=45` with every waiver named · three next options for the S46 prompt file.

## Contract amendments

_None yet. Corrections are **appended here**, numbered `A1`, `A2`, …, each naming the requirement it
touches and the evidence that forced it. The requirement's own text is never rewritten in place — a
correction that rewrites the requirement it failed is the defect, not the fix (`reviewer/SKILL.md`, N1;
enforced by `contract_freshness` in `scripts/verify-closeout.sh`)._

---

## The counterfactual this session demands

**A green gate is not evidence here, and the constitution says so twice.** The GT backstop that exists
to catch a NO-CODE violation **passes vacuously on an empty range** (req 4), and the cost gate
**passes on a heading** (GT-REMEDIATIONS row 8). So this session's proof cannot be "the gates passed."

It has to be: **the audit's numbers re-derived by the command printed beside each one, and the
diff's file list read directly.** If a finding cannot be reproduced from the artifact alone, it is not
in the audit. If the diff names a file outside `sessions/ .ai/ prompts/ *.md`, the session is not
NO-CODE, whatever any log says.