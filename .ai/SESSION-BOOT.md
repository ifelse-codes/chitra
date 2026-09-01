# Session Boot

## Current Session
- **Number:** 18 — COMPLETE
- **Type:** CODE — lock the `heatmap` chart to the reference/panel design language
- **Branch:** `session-18-heatmap-lock` (PR pending)
- **Date last updated:** 2026-09-01

## Repo State Snapshot
- `.ai/SESSION` = 18.
- Remote: `github.com/ifelse-codes/chitra`. `main` has S00–S17; S18 on branch.
- **S18 shipped**: `heatmap()` re-rendered in the locked panel language — the
  10-colour blue→orange→red rainbow (`HEAT_COLORS_DARK`) replaced by the documented
  grey tone ramp (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`, light→dark) as the intensity
  encoding, with the single accent hue spent EXACTLY once on the max-value cell
  (ties → first row-major). Dashed frame, uppercase `DENSITY` eyebrow, `│`/`+` guide,
  two rule separators, and a `rows×cols · min..max · peak (r,c)` footer. Empty/degenerate
  data renders safe. Docs previews regenerated (`gen:charts`); README carries the
  `### LOCKED: heatmap chart — session 18 design` block.
- Verify: `scripts/verify-session-18.sh` — 8/8 ALL GREEN (core 192/192). Demo exit 0.
- Summary: `sessions/session-18-summary.md`. Review: `sessions/session-18-review.md`
  — cold pass, **Verdict: ACCEPT** (attested, 7/7 SHIPPED).

## Next Session
- **Number:** 19 — candidates: carry the locked language into `sparkline`/`histogram`
  (last unlocked families); bring `lineModelToSvg` to terminal parity; exercise a real
  `v0.1.0` release.
- Open in a **new chat** (one session per chat).
