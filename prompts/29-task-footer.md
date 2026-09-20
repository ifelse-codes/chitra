# Session 29 — task: family-wide footer pass (B-diet+)

Founder direction (S29 decision ballot, real renders shown): **B-diet+** wins —
plain-words takeaway footers + one rule separator, family-wide, one session.
Supersedes the S21 deferral (A trim / B plain / B-diet). B-diet+ = B's plain
words, shortened to the takeaway, minus the second rule.

## Numbered requirements

1. **Plain-words takeaway footers.** Every locked chart drops jargon for plain
   nouns, shortened to the takeaway (range facts already live on the scale row):
   timeline `N events · longest L`; horizontalBar `N items · peak L (max)`;
   sparkline `N readings · peak P`; gauge/progress `V of A..B · P%`;
   histogram `N samples · peak M`; heatmap `R×C grid · peak (r, c)`; scatter
   `N points · peak (x, y)`; treemap `N leaves · peak L`; bar per-series
   `name · avg C · peak B`; line per-series `lowest/highest` rename (facts
   kept); area `highest/lowest` rename; radar `average A · peak L (V)`;
   candlestick `N candles · high H · low L · last X`; boxplot
   `G groups · median M · peak L (V)`; pie/donut/waterfall/funnel/sankey keep
   their already-plain text.
2. **One rule separator.** Drop the second `frameRule` (the one before the
   footer); keep the top rule below the frame top. All 20 charts.
3. **One accent, still spent once.** The takeaway token keeps the single
   accent hue; no new accent floods; ties-first rules unchanged.
4. **Degenerate-safe, plain nouns.** Empty panels use the plain count noun
   (`0 events · (no data)`, `0 readings`, `0 samples`, `0 candles`,
   `0 groups`, `0 axes`, `0 cells`, `0 leaves`, `0 points`, `0 items`);
   null JSON facts unchanged; flat/non-finite/narrow behavior unchanged.
5. **Agent surface unchanged.** `toJSON()` facts intact (counts, min/max,
   peaks, percents); only display strings change. `toContent()`/compact
   paths untouched.
6. **Lock tests.** Every affected test file asserts 1 rule (was 2) and the
   new footer strings, including ties-first exclusivity and empty panels.
7. **Gates.** Full suite + typecheck green; `scripts/verify-session-29.sh`
   green; `scripts/demo-session-29.sh` green (before→after on real renders).
8. **Docs.** `### LOCKED: family-wide footer (B-diet+) — session 29 design`
   README block (authoritative for footers; supersedes footer lines quoted
   in S09–S28 blocks); docs previews regenerated (footer-only diff, drift
   gate green); `dist/` rebuilt.
