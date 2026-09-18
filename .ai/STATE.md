# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S28 extension committed, 2026-09-18.)

## Active Branch
`session-28-sparkline` — S28 sparkline lock (earlier) + 12-commit
composability/dashboard extension (this chat), all committed, hooks green.
Review, PR to `main`, and closeout sync still to go.

## What Currently Works (observed, not claimed)
- **Composability on all 20 charts**: `frame?` (default true — full panel),
  `frame: false` (content + eyebrow/legend/summary, no borders),
  `compact: true` (plot body + axes only), `maxWidth?` (ANSI-safe per-line
  cap), `toContent()` (body-only string; `toPlain()` unchanged),
  `height` body-exact everywhere (`fitBodyLines`/`normalizeHeight` for the 10
  charts that ignored it; radar still min-clamps 12; boxplot/waterfall/
  candlestick append axes outside the height budget — known, disclosed).
  `toJSON()` data untouched by display opts. Defaults unchanged (framed).
- `pnpm --filter @chitra/core run test` — **442/442 green** (435 + 7 new
  `composability.test.ts`); `typecheck` exit 0. `lint` unrunnable (eslint
  binary missing — pre-existing, not caused here).
- **SRE dashboard** (`playground/sre-dashboard/`, committed): sim engine, CLI
  `--once` (158 lines, ≤78w) + live mode, HTTP server :4173 — 2-col × 10-row
  no-scroll grid, 20 tiles × exactly 3 rows, client-measured widths
  (`/cells?single=&wide=`), 2s refresh, `/frame` kept for CLI compat.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult`
  output surface (`render`/`toString`/`toPlain`/`toContent`/`toMarkdown`/
  `toJSON`/`toSVG?`). LOCKED families S09–S28 intact (no lock test touched).
- Enforcement belt observed working: 3-file atomic cap + `VAJRA_ALLOW_COMMIT`
  gate blocked correctly until founder approval; branch guard intact.

## What Is Broken / Incomplete
- S28 review + PR + closeout still to go (next session).
- Radar `height` min-clamp (12) and boxplot/waterfall/candlestick axes-outside-
  height are disclosed contract gaps (dashboard works around them).
- `toContent()` is implemented as a compact re-render (double render cost).
- The founder-deferred footer pass (A trim / B plain words / B-diet) awaits a
  founder choice.
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1.
- `artifacts/api-server` exposes only `/healthz`.
- First real release (tag `v0.1.0`) not yet exercised (`NODE_AUTH_TOKEN`).
- QA is local-only; not yet wired into CI.
- **S05 ground-truth remediation debt** still open.
- Dirty-but-not-ours leftovers stay untracked: `.commandcode/`, `.freebuff/`,
  `design-reference/*` (session-21/22/25 demos etc.), `playground/buffy-`
  `dashboard/`, `playground/field-test-prompt.md`, `scripts/build-audit-html.mjs`,
  `.ai/CHITRA-FRAME-FIX.md`, `.ai/CONTINUATION-PROMPT.md`.

## Milestones done
- **S01–S04** docs generator / examples / polish / README · **S05** NO-CODE ground-truth ·
  **S06** publishable dist · **S07** CI workflows · **S08** release.yml + line/SVG ·
  **S09** circular + area LOCKED · **S10** line LOCKED · **S11** catalog two-panel ·
  **S12** bar LOCKED · **S13** Darpan-parity chrome · **S14** URL routes + persistence ·
  **S15** scripted browser QA · **S17** scatter LOCKED · **S18** heatmap LOCKED ·
  **S19** horizontalBar LOCKED (Vajra S144 full-loop dogfood) · **S20** treemap LOCKED
  (recovered: pi + Command Code + closer chat) · **S21** timeline LOCKED (single-chat,
  plan-review cross-checked) · **S22** gauge LOCKED (single-chat, shade-texture ruling
  carried) · **S23** progress LOCKED (single-chat, trio complete) · **S24** grouped
  chart nav, badges out per founder order (single-chat, live glyph tuning) ·
  **S25** histogram LOCKED (single-chat, resumed from a z-code token stop; commits +
  review + closeout completed in the closer chat) ·
  **S26** waterfall + funnel + sankey + radar LOCKED (five stories by founder
  direction; funnel centered by founder order on research record; radar from a
  founder reference image — cold ACCEPT 18/19, row 15 PARTIAL disclosed) ·
  **S27** candlestick + boxplot LOCKED (two stories by founder direction; no audit
  mockups — family language by analogy, waterfall outline precedent; adaptive price
  precision approved at PLAN — cold ACCEPT 13/13, attested) ·
  **S28** sparkline LOCKED + **composability extension** (this chat: frame/compact/
  maxWidth/toContent/exact-height on all 20, 7 conformance tests, 20-tile SRE
  dashboard CLI + web — 12 atomic commits, 442/442 green, review owed).

## What Is In Progress
- S28: cold review of 12 extension commits → PR `session-28-sparkline` →
  `main` → closeout. **Next (S29):** review + PR first; then footer pass /
  SVG parity / release / QA-in-CI / candle hardening. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S28:
  single ZCode chats (boot + plan + execute + verify + demo in one conversation each),
  one cold-review subagent dispatched post-commit per session; dispatches kept narrow.
  S25 additionally needed a closer chat after the build chat hit its token limit
  (state recovery + founder commits + cold review + closeout). S26 ran five stories in
  one session by explicit founder direction (waiver of the 1-story rule, disclosed);
  S27 ran two stories the same way. S28 was preceded by a fossil throwaway
  exploration (mudra gallery + pie/sparkline prototypes in tmp, lib untouched
  until the founder said "lock"). This chat (S28 extension): one conversation —
  boot + 3-issue delivery + dashboard iterations (4→3→2 col) + research spikes
  (TUI landscape, Ratatui bridge) + 12-commit close. Kept tight.
