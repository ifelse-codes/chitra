---
role: demo-producer
session: 19
agent: claude-code-subagent (verified: toolu_01A2aWAjYALUKvAYktWFfB6X)
source-sha: ce39dd91fc31652fcd52ec2b72f6b4f17ea3100efba901da4e253fe19947c4eb
captured: 2026-09-04T04:50:01Z
cost_usd: null
---

# Demo-producer handoff — session 19

# Demo Producer — Session 19 (horizontalBar locked)

The demo must run the REAL horizontalBar and print observed output — no `2>/dev/null` + `|| true` swallowing, no hardcoded `ok` standing in for a render. Falsifiable claims (accent-once, no-`░`) become real checks that can go red. Before/after: BEFORE is the pre-lock rainbow/`░`/no-chrome form (quoted as reconstructed, since the code is gone) next to a LIVE AFTER render of the same data.

rec 1 — Emit demo:header naming the session + delivery; use header/label/ok helpers but make ok report a real check result.
rec 2 — Emit demo:before_after over ONE dataset with a clear global max, a genuine zero/empty cell, and a near-tie: e.g. Mobile 90, Desktop 30, Tablet 0, Watch 12. BEFORE = pre-lock output labelled reconstructed; AFTER = live real render of identical data. Never AFTER-only.
rec 3 — In demo:cases, render through the real horizontalBar source and print raw stdout; if it throws, fail visibly and exit non-zero.
rec 4 — Make accent-once FALSIFIABLE: count the accent hue raw-RGB escape in live output, assert == 1; assert grey-ramp hexes on non-max bars.
rec 5 — Make no-`░` FALSIFIABLE: grep live output for `░`, assert ZERO; assert the empty cell renders as SPACE inside the frame.
rec 6 — A case that prints the panel chrome from real output: dashed frame, uppercase eyebrow, rotated `+` value-axis guide, min..max scale row, two rule separators, per-item value labels with peak value in accent.
rec 7 — Three degenerate live cases that must not crash: empty, all-equal, single; each prints real framed output; fail on throw or Infinity/NaN.
rec 8 — One auto-scale/auto-width case: a negative value (min(0,dataMin) baseline) and a long label / large value (width auto-expand); print real renders + scale rows.
rec 9 — Emit demo:summary_table as a PASS/FAIL scorecard, one row per acceptance criterion, fed by the real check results where possible, not hardcoded.
rec 10 — Print a "This demo does NOT show" block: it does not run the acceptance tests, prove the README block, or prove verify is green; a green demo is not a passing delivery.

## Handoff Delta
- `+` new: first demo-producer handoff for this session (2143 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
