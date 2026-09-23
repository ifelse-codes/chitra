# Session 33 — task: release readiness (CI browser QA, candle exclusivity, SVG parity, AI-data manual)

Founder direction (in-chat, S33): clear the four buyer-visible / release-hygiene
items from `jev-readiness-plan.md` that do not need founder-only secrets.
Founder-waived multi-story session (four stories in one chat), disclosed like
S26/S27.

## Numbered requirements

1. **CI browser QA.** Add a `ci.yml` job that runs the Playwright catalog QA
   (`scripts/qa-catalog.mjs`) over all 20 chart pages + doc pages + home, failing
   on any console/page error — wiring only, the suite already passes locally.
2. **Candle ties-first exclusivity test.** Assert that when two candles tie for
   the highest close, only the FIRST candle's body carries the accent and the
   second tied candle stays entirely on the grey tone ramp (the existing test at
   `tests/candlestick.test.ts` only proves *some* accent exists).
3. **SVG parity with the terminal.** Bring `lineModelToSvg()` to 1:1 parity:
   the same theme tones, the same glyph markers at every 2nd point, the same
   monochrome dash textures, the same optional `grid` gridlines, the same
   legend/eyebrow/summary captions, and the same "accent spent once on the
   peak" rule. Add a drift test so the two surfaces cannot diverge again.
   Regenerate `svg-charts.json`; the drift gate must stay green.
4. **AI-data manual.** Publish one reference page (`ai-data` route) documenting
   the `toJSON()` shape per chart, empty/null + clamp-true-value behaviour, the
   `toContent()`-for-context recommendation, and an MCP untrusted-input
   guardrail. Link it from the AI Agents page and `packages/core/README.md`;
   add it to the browser-QA doc-page list.
5. **Gates.** `scripts/verify-session-33.sh` exits 0; `scripts/demo-session-33.sh`
   exits 0; core tests + typecheck, docs typecheck + build, and the chart drift
   gate all stay green.
