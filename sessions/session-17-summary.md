# Session 17 — scatter chart LOCKED (BACKFILLED at S36)

> **Backfilled record.** S17 shipped and merged (PR #19, merge `35376ae`, 2026-08-29)
> but left no session prompt, verify/demo scripts, summary, or fidelity review. This
> summary is reconstructed from the merge commit + its diff at S36 to close the S05
> closeout-integrity debt (see `sessions/session-35-ground-truth.md` §5). The missing
> verify/demo/review are **explicitly waived** — they cannot be truthfully fabricated
> after the fact; the git evidence below is the record.

## What shipped

- `scatter()` re-rendered in the reference/panel language: dashed frame, eyebrow,
  `+`/`│` guide, `n · x · y · peak` footer.
- Single-series: peak accent. Multi-series: **primary-GROUP** accent (commit `38e5593`).
- Decimal y-axis support (`packages/core/src/types.ts` +5).
- 152 new lines of falsifiability tests (`packages/core/tests/scatter.test.ts`),
  accent-once proven by RGB method (`5949192`).
- Regenerated docs preview (`artifacts/chitra-docs/src/data/*`).
- `packages/core/README.md` "LOCKED: scatter chart" block (+34).
- Also on the branch: Vajra crew roster completion (`.claude/agents/*`) — process,
  not product.

## Evidence

| Item | Value |
|---|---|
| PR | #19 (`ifelse-codes/session-17-scatter-lock`) |
| Merge commit | `35376ae` (2026-08-29) |
| Key commits | `bc760f1` lock · `0af7317` regenerate · `5949192` tests · `38e5593` group accent |
| Diff | 16 files, +991 / −119 |
| Core test suite at S18 (next) | 192 tests |

## Waivers (explicit)

- verify-session-17.sh / demo-session-17.sh — **waived** (never produced).
- Independent fidelity review — **waived** (never produced).
