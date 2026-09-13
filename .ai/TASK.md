# Current Task Pointer

## Session 25 — histogram LOCKED to the mudra panel language — COMPLETE (closeout gate + PR)

- **Branch:** `session-25-histogram-mudra` (close on branch; main untouched until PR merges)
- **Shipped:** `histogram()` re-rendered in the locked panel language — dashed
  frame + `DISTRIBUTION` eyebrow, ONE accent hue spent exactly once as a solid
  `█` on the mode bin (ties → first), grey tone ramp + `░▒▓` shade texture by
  share of modal count, integer-only y-axis count labels, dashed baseline,
  `n · mode · p50 · p99` foot (nearest-rank, mode accented). Both P0 bugs from
  STATE's bug queue retired: decimal count labels + `theme.colors[0]` accent
  flood. Degenerate-safe: empty → framed `n 0 · (no data)` panel with null JSON
  facts; collapsed range → bin 0; non-finite samples excluded. README carries
  `### LOCKED: histogram chart — session 25 design`.
- Verify: `scripts/verify-session-25.sh` — 13/13 ALL GREEN (core 332/332, +23
  histogram tests). Demo exit 0, 7/7 PASS. Summary: `sessions/session-25-summary.md`.
  Review: `sessions/session-25-review.md` — independent cold pass ACCEPT, attested
  (13/14 SHIPPED; `Review-Inputs-SHA b10d5b94…0a761`).
- **PR** (`session-25-histogram-mudra` → `main`) is the last step.

**Next session (S26 candidates):** the audit queue's remaining unlocked charts
(**funnel**, **waterfall**); the founder-deferred footer pass (A/B/B-diet, needs a
founder choice); `lineModelToSvg` parity; `v0.1.0` release; Playwright QA into CI.
Open in a **new chat**.
