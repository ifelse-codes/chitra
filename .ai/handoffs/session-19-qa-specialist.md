---
role: qa-specialist
session: 19
agent: claude-code-subagent (verified: toolu_01VXVKmi4DcBQDCsA4sLwiuv)
source-sha: 8d85c31c95793d0475c73816e28c970ee34399efc36c00879b76b6e0663c8dea
captured: 2026-09-04T04:56:05Z
cost_usd: null
---

# Qa-specialist handoff — session 19

# QA Specialist — Session 19 (horizontalBar lock) — evidence brief

Ran live from repo root; observed only, edited/committed nothing.

## What actually executed
- `bash scripts/verify-session-19.sh` → exit 0, ALL GREEN (11 pass, 0 fail): core-tests-green, core-typecheck, horizontalbar-tests, raw-rgb-accent-count-1, no-phantom-fill-glyph, degenerate-safe, source-locked, readme-lock-block, chart-drift-gate, demo-runs-green, branch-is-s19.
- `pnpm --filter @chitra/core run test` → exit 0 — 10 files, 217 tests passed (incl. horizontalBar.test.ts, 25 tests).
- `bash scripts/demo-session-19.sh` → exit 0 — live scorecard all PASS (accent-once raw-RGB, no-░, panel language, degenerate-safe, auto-scale+auto-width).

## Classification of the 11 verify checks
- EXECUTE-BASED (7): core-tests-green, core-typecheck, horizontalbar-tests, raw-rgb-accent-count-1, no-phantom-fill-glyph, degenerate-safe, demo-runs-green.
- STRUCTURAL / drift (2, not hollow): source-locked (asserts the `theme.colors[` rainbow indexer is ABSENT + frameTop/theme.accent present), chart-drift-gate (runs gen:charts:check).
- HOLLOW behavioural source-grep (2): readme-lock-block (greps README heading), branch-is-s19 (branch-name guard). 2/11.

## Headline assertions
- (a) raw-RGB accent-count==1: EXECUTE-BASED — renders real horizontalBar, extracts ANSI codes before █, asserts accent==1 + every other bar on grey ramp + no rainbow leak. Falsifiable.
- (b) no-░ phantom-fill: EXECUTE-BASED — renders blocks + ascii, asserts no ░. Falsifiable.

## Weakest check
readme-lock-block — bare grep for a doc heading; exercises zero product behaviour.

rec 1 — Treat readme-lock-block as documentation-only, not behavioural evidence.
rec 2 — Consider a full-panel golden/snapshot assertion (chrome asserted as a whole vs scattered substring greps).
rec 3 — Extend the raw-RGB accent-count assertion to a non-default theme (note: the vitest suite already checks the no-rainbow invariant across all 7 themes; only the verify-script's accent-count is default-only).

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (2067 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
