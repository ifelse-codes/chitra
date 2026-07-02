# chitra — AI Agent Constitution

> Every AI agent MUST read this file and the load order below before executing any task.

## What This Repo Is

chitra. Managed by the Vajra workflow.

## Speaking Skills (Load at Boot)

**Darshan** (`darshan/SKILL.md`) is your default human-output skill — read and internalize
it at boot, then speak it all session. One rule: *render the richest visual this surface can
handle; always glanceable; never drop meaning.* It is a skill, not a renderer — nothing in
the binary parses or draws it. The user sees Darshan in every reply.

## Mandatory Load Order

1. `.ai/AGENTS.md` (this file)
2. `.ai/SESSION`
3. `.ai/SESSION-BOOT.md`
4. `.ai/TASK.md`
5. `.ai/STATE.md`
6. `.ai/CONSTRAINTS.yaml`
7. `.ai/KNOWLEDGE.md` (on demand)
8. `.ai/ROADMAP.md` (on demand)

## Session Loop

1. BOOT — Read load order. Confirm goal.
2. BRANCH — `session-NN-<slug>` from `main`.
3. PLAN — Bullets. Max 2 assumptions. Wait for approval.
4. EXECUTE — Atomic changes. Max 3 files per commit.
5. VERIFY + DEMO — `scripts/verify-session-NN.sh` exits 0. `scripts/demo-session-NN.sh` shows what was built (cumulative).
6. PR — Open PR to `main`.
7. SUMMARY — `sessions/session-NN-summary.md`. 3 next options.
8. CLOSEOUT — Sync `.ai/` files. `verify-closeout.sh` exits 0.
9. CLOSE — New chat from next prompt file.

## Hard Rules

| Rule | Detail |
|---|---|
| Max 2 assumptions | More = STOP and ask |
| Max 2 retries | 3rd failure = escalate |
| No autonomous commits | Wait for approval |
| No `main` commits | Branch first |
| Max 3 files per commit | Atomic changes |
| Verification = exit 0 | Never leave red |

## Communication Style

- Under 200 words per response
- Bullets and tables, no paragraphs
- No filler phrases, no trailing summaries
- Code first, explanation after
