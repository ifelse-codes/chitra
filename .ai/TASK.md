# Current Task Pointer

## Session 18 — lock the `heatmap` chart to the reference/panel language — COMPLETE

- **Branch:** `session-18-heatmap-lock` (PR pending)
- **Shipped:** `heatmap()` re-rendered in the locked panel language — grey tone ramp
  (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`, light→dark) as the intensity encoding replacing the
  old 10-colour rainbow (`HEAT_COLORS_DARK`); the single accent hue spent EXACTLY once on
  the max-value cell (ties → first row-major); dashed frame, uppercase `DENSITY` eyebrow,
  `│`/`+` guide, two rule separators, `rows×cols · min..max · peak (r,c)` footer;
  empty/degenerate data safe. Docs previews regenerated; README `### LOCKED: heatmap
  chart — session 18 design` block added.
- Verify: `scripts/verify-session-18.sh` — 8/8 ALL GREEN (core 192/192). Demo exit 0.
- Summary: `sessions/session-18-summary.md`. Review: `sessions/session-18-review.md`
  — cold pass, **Verdict: ACCEPT** (attested, 7/7 SHIPPED).

**Next session (S19 candidates):** carry the locked language into `sparkline`/`histogram`
(last unlocked families); bring `lineModelToSvg` to terminal parity; exercise a real
`v0.1.0` release. Open in a **new chat**.
