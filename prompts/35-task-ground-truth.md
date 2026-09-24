# Session 35 — task: NO-CODE ground-truth audit

**Mandatory 5th-session ground truth (`N % 5 == 0`).** This session exists to
catch **BOTH** direction drift (vision + roadmap) **and** discipline drift
(rules + constitution + state + cost). Rules exist to serve the vision —
auditing rule-following without auditing the vision is the trap.

## Hard mandate (CONSTRAINTS.yaml `ground_truth`)

- **NO code changes. NO commits. NO PRs.** Read-only investigation.
- **Required output:** `sessions/session-35-ground-truth.md`.
- Every finding must be **grounded in checked evidence** (quote the command and
  its result) — never asserted from memory.

## Drift axes (all six)

`vision` · `roadmap` · `rules` · `constitution` · `state` · `cost`

## Required audits (all seven)

| Audit | What it must answer |
|---|---|
| `vision_alignment` | Is the north-star (*the best terminal chart lib ever created — zero-dep, AI-first, delightful*) still the right destination? Is recent work the shortest path to it, or intellectually-fun scope creep? What new evidence would force a pivot or abandon? |
| `roadmap_alignment` | Does each phase still map to the north-star? Is the next item the highest-leverage one, or just the easiest? Any item now obsolete, or any the vision now demands but the roadmap lacks? |
| `state_drift` | Compare `.ai/STATE.md`, `.ai/SESSION`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md` against git + the tree. Name every stale/incorrect claim. |
| `knowledge_staleness` | Is `.ai/KNOWLEDGE.md` still true? Quote any falsehood. |
| `constraint_violation_review` | Walk `.ai/CONSTRAINTS.yaml`: verify/demo required, branch discipline, max-files, approval tokens, one-session-per-chat. Which held, which were skipped? |
| `constitution_review` | Is any rule now **blocking** the vision instead of protecting it? Meta-check: did **this audit's own mechanism** have a blind spot? |
| `cost_review` | Is the cost story honest? Is `.ai/STATE.md` "Cost Tracking" maintained or a dead placeholder? |

## Context to verify (not to trust)

- **S34 just merged** — PR #40, merge commit `5b1d13d`; root `README.md` +
  `LICENSE` (root + `packages/core/LICENSE`) now on `main`.
- **`@chitra/core` is NOT on npm** (registry 404) — the README discloses this.
- **Live docs-hero pills are stale** (`v0.1.0 — stable`, `134 Tests passing`) —
  a disclosed, deferred GTM-consistency fix.
- **Live deploy still FROZEN** (S31 founder order) — visuals not redeployed.
- **S05 ground-truth remediation debt** still open (S04 verify/demo/summary
  backfill + a closeout-integrity gate) — check whether it was ever closed.
- Core suite: **452 tests** at S34. Verify the number yourself.
- The Vajra crew/tech-lead gate (`verify-closeout.sh#check_required_crew`) is
  unpassable in this environment (subagent provenance unverifiable) — sessions
  close under a founder waiver. Is that a real governance hole, or an imported
  mechanism chitra's own constitution doesn't require?

## Output shape

`sessions/session-35-ground-truth.md` with, per audit: a verdict
(✅ / 🟡 / 🔴), the evidence checked, and the finding. End with an overall
verdict, ranked remediations (for the NEXT code session to fold in — not this
one), and the recommended next session.

## Guardrails

- No `main` commits, no branch work, no PRs. The artifact is committed only via
  a `-closeout`-suffixed branch (the ground-truth commit exemption) or folded
  into the next session.
- Do not "fix" anything found — report it. Fixing is the next session's job.
