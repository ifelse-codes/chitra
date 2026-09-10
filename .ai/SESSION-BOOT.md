# Session Boot

## Current Session
- **Number:** 20 — COMPLETE (closeout pending founder env steps)
- **Type:** CODE — lock the `treemap` chart to the reference/panel design language
- **Branch:** `session-20-treemap-lock` (close on branch; main untouched)
- **Date last updated:** 2026-09-10

## Repo State Snapshot
- `.ai/SESSION` = 20.
- Remote: `github.com/ifelse-codes/chitra`. `main` has S00–S17 (+S19 merge #21); S18 + S19 + S20 on their branches.
- **S20 shipped**: `treemap()` re-rendered in the locked panel language — the S18 `heatmap`
  language rotated onto the hierarchical area chart. Rainbow `theme.colors[i % n]` gone:
  ONE accent hue spent once on the max leaf (first-flatten tie-break), grey tone ramp
  (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`) + shade glyphs (`░▒▓█`) by magnitude, dashed frame +
  uppercase `AREA` eyebrow + `+`/`│` guide + two rule separators, `n · min..max · peak <label>`
  footer (peak accented), honest leaf flatten, SPACE empty grid, sliver regions stay clean
  blocks (labels stamp only when whole). Empty/all-equal/single safe. Docs previews
  regenerated; `dist/` rebuilt (docs catalog executes examples against `dist/`);
  README carries `### LOCKED: treemap chart — session 20 design`. Public API unchanged.
- **Governance (recovered session):** built across pi (`~/.pi/.../2026-09-09T10-19-39...jsonl`)
  + Command Code (`8b98ceae`, Kimi-K3, died on credits) + this chat. Tech-lead dispatched
  FIRST with 4-required/5-deferred verdict (handoff recorded) but pi/Command-Code provenance
  is unverifiable by the S139 gate → closeout needs `VAJRA_CLOSEOUT_WAIVER=20`. Two
  independent cold passes returned REJECT (Req-6 proof hollow; behavior faithful); builder
  tightened verify/test twice since (vacant-zero-cells + residue-membership + sliver rule).
  A 3rd cold pass is owed post-commit before the verdict can flip to ACCEPT.
- Verify: `scripts/verify-session-20.sh` — 12/12 ALL GREEN (core 236/236). Demo exit 0.
- Summary: `sessions/session-20-summary.md`. Review: `sessions/session-20-review.md`
  — cold passes, **Verdict: REJECT** on record (see file for fix delta + owed 3rd pass).
- The locked family now spans circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), **treemap (S20)** — the first
  hierarchical chart in the locked language.

## Next Session
- **Number:** 21 — candidates: `timeline` → `gauge` → `progress` mudra migration (pi proposal,
  one story per session); bring `lineModelToSvg` to terminal parity; exercise a real
  `v0.1.0` release (`NODE_AUTH_TOKEN`); wire the local Playwright QA into CI.
- Open in a **new chat** (one session per chat).
