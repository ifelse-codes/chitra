# Session 31 — antra design atoms into chitra-docs

- **Type:** CODE/DESIGN. Branch `session-31-antra-design` from `main@c43c11e`.
- **Contract:** founder in-chat direction (S31): make chitra-docs feel
  like the antra website — export atoms from `antra/landing/index.html`.
  `prompts/31-task-antra-design.md` (8 numbered reqs, grown in-session:
  atmosphere, editor chrome, fixed-geometry hero rotation, wall fix).
- **Assumptions (max 2):** (1) dark violet accents on chitra's dark
  chrome; (2) CSS translation only, no framework change. Same-chat S31
  (convention waived by founder direction, disclosed).

## What shipped (Req 1–8 + founder follow-ups)

- **Tokens/eyebrow/hero (Req 1–3):** namespaced `--antra-*` violet set;
  `◆` mono-caps eyebrow on kicker + section headings; hero accent word
  solid violet-bright (gradient out).
- **Install strip (Req 4):** click-to-copy `pnpm add @chitra/core` with
  `copy → ✓ copied!` swap, width-aligned to the actions row (560px).
- **Hairline/topbar/footer/reveal (Req 5–7):** route grid 1px-gap;
  topbar mono caps + violet hover; global hairline footer; IO reveal
  with reduced-motion guard. Mandalas + grid + violet glow ported per
  founder follow-up (max 2 wisps, motion-safe).
- **Editor chrome:** blur toolbar, violet Run, 0.22em labels, violet tab
  underline + `$` chip.
- **Hero rotation (founder follow-ups):** 6 fixed-geometry variants
  (`hero-charts.json`, each exactly 19×64, drift-gated) rotating every
  3s with instant cut; mac box hugs content + 8ch right buffer.
- **Wall fix:** stagger root-caused to JetBrains braille 14% wide
  (canvas-measured); `.terminal-body` leads Cascadia Mono (uniform);
  pixel proof 19/19 rows share right edge, spread 0.
- **Gates:** `verify-session-31.sh` 24/24 ALL GREEN (incl. hero-dims +
  typecheck + build + drift); demo exit 0. Live deploys frozen by
  founder order — site NOT redeployed (last live `4107a968` predates
  wall fix + buffer).

## Commits (all ≤3 files; approval-token gated)
## Review
- Cold independent review(s) in `sessions/session-31-review.md`.
