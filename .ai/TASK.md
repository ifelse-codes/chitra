# Current Task Pointer

## Session 21 — lock the `timeline` chart to the mudra reference/panel language — COMPLETE (closeout pending founder env steps + post-commit cold review)

- **Branch:** `session-21-timeline-mudra` (close on branch; main untouched)
- **Shipped:** `timeline()` re-rendered in the locked panel language — the S18/S19 language
  on the Gantt. Rainbow `theme.colors[i % n]` removed: ONE accent hue spent exactly once on
  the longest-span event (ties → first in event order) as a solid `█` run, grey tone ramp
  (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`) + `░▒▓` shade texture by span bucket for every other
  event (the heatmap language — ordering survives noColor); dashed frame,
  uppercase `SPAN` eyebrow, `+╌…╌+` guide + `min..max` scale row, two rule separators; `─`
  track kept as the shared time scale; point events render exactly one `░`; `▶`/`◀` retired;
  `n · min..max · span <label>` footer (longest event accented); collapsed-range guard;
  empty/all-equal/single safe; `noColor` safe. `toJSON()` gains additive
  `peak {index, label, span}`. Public API unchanged, zero runtime deps. Docs previews
  regenerated, `dist/` rebuilt, README `### LOCKED: timeline chart — session 21 design`
  block added.
- **Plan-review cross-check:** recommendation order unbroken; the 2 real bug fixes
  (histogram decimals + accent flood; waterfall never-invisible) remain open in other
  charts — queued, not blockers; no new glyphs introduced.
- Verify: `scripts/verify-session-21.sh` — 12/12 ALL GREEN (core 259/259, +23 timeline).
  Demo exit 0, 5/5 PASS. Summary: `sessions/session-21-summary.md`. Review: cold pass owed post-commit
  (attestation binds the committed diff + prompt).

**Next session (S22 candidates):** `gauge` → `progress` mudra migration; the
founder-deferred family-wide footer pass (A/B/B-diet); plan-review bug-first queue
(histogram, waterfall, funnel); `lineModelToSvg` parity; real `v0.1.0` release; Playwright
QA into CI. Open in a **new chat**.
