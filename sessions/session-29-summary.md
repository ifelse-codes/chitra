# Session 29 — family-wide footer pass (B-diet+)

- **Type:** CODE. Branch `session-29-footer` from `main@18edc68`.
- **Contract:** founder decision ballot on real renders (in-chat, S29):
  **B-diet+** — plain-words takeaway footers + one rule separator,
  family-wide. Closes the S21 deferral (A trim / B plain / B-diet).
- **Open question resolved (approved):** B-diet+ over A (inconsistent,
  2 charts only) and B (wordy, overflows narrow panels — full spark B
  foot clipped to `· l` on the real render). Full B foot shown to
  overflow; short form + 1 rule picked.

## What shipped (Req 1–8)

- **Footers (Req 1):** takeaway-only plain nouns on all 20 charts —
  timeline `N events · longest L`, hbar `N items · peak L (max)`,
  sparkline `N readings · peak P`, gauge/progress `V of A..B · P%`,
  histogram `N samples · peak M`, heatmap `R×C grid · peak (r, c)`,
  scatter `N points · peak (x, y)`, treemap `N leaves · peak L`, bar
  per-series `name · avg C · peak B`, line per-series
  `lowest/highest` rename (facts kept), area `highest/lowest`,
  radar `average A · peak L (V)`, candlestick
  `N candles · high H · low L · last X`, boxplot
  `G groups · median M · peak L (V)`; pie/donut/waterfall/funnel/sankey
  text unchanged (already plain). Range repeats dropped (scale row
  owns the range).
- **One rule (Req 2) + accent once (Req 3):** 2nd `frameRule` removed
  20/20 (top kept); takeaway keeps the single accent; ties-first
  untouched. Empty panels use plain nouns + null facts (Req 4);
  `toJSON()`/compact/`toContent()` untouched (Req 5).
- **Gates (Req 6–8):** `verify-session-29.sh` 12/12 ALL GREEN (11-chart
  footer census + 0 jargon, 20/20 one-rule, accent spot, 6 empties,
  toJSON stability, suite + typecheck, README block, drift gate,
  dist-carries-lock, zero-deps, branch). `demo-session-29.sh` exit 0,
  4/4 PASS. Full suite **444/444 green**, typecheck clean. Docs previews regenerated (footer-only diff, drift
  green), `dist/` rebuilt (gitignored). README
  `### LOCKED: family-wide footer (B-diet+)` block, authoritative —
  supersedes footer/rule lines quoted in S09–S28 blocks (disclosed,
  not rewritten per-block).

## Commits (all ≤3 files)

- Pending founder commit approval (`VAJRA_ALLOW_COMMIT=29` —
  un-forgeable env marker, cannot self-grant).

## Assumptions (max 2, both approved)

1. B-diet+ ballot definitions are the fidelity target (short forms as
   balloted). 2. `toJSON()`/compact facts unchanged; auto-width grows
   for longer words.

## Fidelity map

Req 1–5 delivery SHIPPED · Req 6–8 gates SHIPPED (8/8 claimed;
independent cold review in `sessions/session-29-review.md` disposes).

## Review response (cold REJECT → fixes)

- First cold pass: REJECT 4/8 — donut hunk, rule asserts in
  bar/hbar/line/charts, ties breadth, dist proof, gate proof.
- Fixed: donut proven exempt-by-design (1 rule, legend owns facts —
  render-verified) + `donut carries exactly one rule` test; 1-rule
  asserts added to bar/hbar/line; histogram ties-first test added
  (spark/hbar ties + FSW empties pre-exist in-suite); dist rebuilt +
  `dist-carries-lock` gate green. Uncommitted-tree artifacts
  (Req 7 scripts/prompt/summary untracked → invisible to
  `git diff`) resolve at commit time — needs `VAJRA_ALLOW_COMMIT=29`.
