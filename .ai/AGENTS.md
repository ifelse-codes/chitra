# chitra — AI Agent Constitution

> Every AI agent MUST read this file and the load order below before executing any task.

## What This Repo Is

chitra. Managed by the Vajra workflow.

## Speaking Skills (Load at Boot)

**Darshan** (`darshan/SKILL.md`) is your default human-output skill — read and internalize
it at boot, then speak it all session. One rule: *render the richest visual this surface can
handle; always glanceable; never drop meaning.* It is a skill, not a renderer — nothing in
the binary parses or draws it. The user sees Darshan in every reply.

<!-- vajra:governed-body - do not edit below this line - vajra owns and upgrades these bytes -->

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
7. SUMMARY + FIDELITY REVIEW — `sessions/session-NN-summary.md` + an independent `sessions/session-NN-review.md` (a cold pass; see `reviewer/SKILL.md`). 3 next options.
8. CLOSEOUT — Sync `.ai/` files. `scripts/verify-closeout.sh` exits 0 (structurally requires an ACCEPT review).
9. CLOSE — New chat from next prompt file.

## Hard Rules

| Rule | Detail |
|---|---|
| Max 2 assumptions | More → STOP and ask |
| Max 2 error retries | 3rd failure → escalate |
| No autonomous commits | Wait for approval token |
| No `main` commits | Branch first |
| No code in Ground Truth | Hook-enforced |
| Verification = exit 0 | Never leave red |
| State is snapshot | Never append history |
| Max 1 story per session | Larger → split |
| Max 3 files per atomic commit | Hook-enforced |
| ~2h per session cap | Marathon = drift |
| One vajra-session per chat | New session = new chat (step 10). Convention until Vajra enforces it. |
| **Fidelity ≠ discipline** | Following the rules is not delivering what was asked. Map **every** numbered requirement in the prompt to evidence (SHIPPED / PARTIAL / NOT-BUILT). A green verify script proves discipline, never fidelity. |
| **No self-certification** | The builder does not accept its own delivery. Fidelity is judged by an **independent** pass fed only the prompt + the diff, adversarially — not by the agent that wrote the code. See `reviewer/SKILL.md`. |

> **Derived, not typed.** These 13 rules are generated at build time from
> Vajra's own constitution, so a rule added there reaches this file with no action
> taken. `scripts/scaffold-drift.sh` in the Vajra repo fails when the two diverge.
> Declared omissions: **none** — every binding rule Vajra runs on is above.
> Reworded details (the rule is unchanged; its wording was rewritten for you, with the reason):
> - scaffold-retexts-rule: **Fidelity ≠ discipline** — the live detail cites DECISION-002, a decision record only this repo has
> - scaffold-retexts-rule: **No self-certification** — same DECISION-002 citation, replaced by the pointer to `reviewer/SKILL.md` that the scaffold does ship

## Communication Style

- Under 200 words per response
- Bullets and tables, no paragraphs
- No filler phrases, no trailing summaries
- Code first, explanation after
<!-- vajra-render-sha: 1ffeb0c5f9755ff97426daa7976a1f786205bbb284ba65de35d33b0837035dbe -->
