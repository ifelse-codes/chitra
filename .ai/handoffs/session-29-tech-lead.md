---
role: tech-lead
session: 29
agent: opencode-session (single-chat: ballot + 3 build batches + 2 cold reviews)
source-sha: 60438f92ef02da36d3fa4428afd983ea864311a90a1680e5aaac7ccdfbc4127a
captured: 2026-09-20T15:20:00Z
cost_usd: null
---

# Tech Lead crew decision — Session 29 (family-wide footer B-diet+)

## Scope
Session 29 covered two work streams:
1. **Footer lock** (contract task): B-diet+ plain takeaway footers + one
   rule separator across all 20 charts, founder-picked from real-render
   ballots (closes the S21 deferral).
2. **Docs app run** (founder add-on mid-session): regen previews, serve
   `chitra-docs` at :5174 for founder visual pass/fail.

## Crew decisions

crew implementation — required — budget: 3000000 tokens — CODE session: 3 parallel batches (A: timeline/hbar/spark/gauge/progress; B: hist/heatmap/scatter/treemap/bar/line; C: area/pie/donut/waterfall/funnel/sankey/radar/candle/boxplot) + integrator fixes (charts.test.ts line rename, histogram ties test, bar/hbar/line/donut rule asserts). Core library changes only.

crew qa-specialist — required — budget: 1500000 tokens — 444 tests pass (22 files). Updated lock tests (1-rule asserts, plain footer strings, ties-first, plain empties) + histogram ties test + donut rule test. Core typecheck green.

crew demo-producer — required — budget: 1000000 tokens — Docs preview regeneration (ansi-charts.json, charts.ts, footer-only diff, drift gate green) + docs dev server (:5174) for founder review + demo script (4/4 live checks).

crew fidelity-reviewer — required — budget: 2000000 tokens — Independent cold review required for closeout gate (scripts/verify-closeout.sh). First pass REJECT 4/8 (donut proof, rule/ties breadth, gate proof) → fixes → second pass ACCEPT 8/8 with input attestation.

crew researcher — deferred-budget — budget: 300000 tokens — No new research; design language locked since S09–S28, ballot options defined S21.

crew requirements-analyst — deferred-budget — budget: 300000 tokens — 8 acceptance criteria written in contract prompts/29-task-footer.md. No ambiguity to resolve.

crew design-advisor — deferred-budget — budget: 300000 tokens — Founder picked B-diet+ from real renders in-chat. No further design decisions.

crew plan-advisor — deferred-budget — budget: 400000 tokens — Bounded family-wide pass with ballot precedent. Plan is the prompt.

crew release-coordinator — deferred-budget — budget: 300000 tokens — No release this session. dist/ rebuilt (gitignored).

## Rationale
Four required roles map to four deliverables: the lock, the tests, the demo/previews, and the independent review. Budget: ~7.5M raw tokens.

## Handoff Delta
- `+` new: tech-lead handoff for session 29 (footer lock + docs app run)
- prior stage: session 28 closeout (sparkline lock)
