# Session 33 — independent fidelity review (cold pass)

Reviewer: fresh adversarial pass fed only the contract prompt
(`prompts/33-task-release-readiness.md`) + the committed delivery diff
(`b66e8e9..HEAD`). No builder summary trusted; claims re-derived by reading
source and running tests, including mutation tests to prove tests are
non-vacuous.

## Per-requirement verdict

| Req | What was asked | Evidence | Verdict |
|---|---|---|---|
| 1 | `ci.yml` job runs Playwright catalog QA over 20 chart + doc + home, failing on console/page errors; wiring only | `.github/workflows/ci.yml:93-121` adds a real `browser-qa` job: `playwright install --with-deps chromium` (:114), then `node scripts/qa-catalog.mjs` (:118), after `typecheck:libs` + core build. `scripts/qa-catalog.mjs` has 20 chart ids (:16-21), `DOC_PAGES` incl. `ai-data` (:23), visits home/docs/charts (:170-184), tracks `console`+`pageerror` (:98-106), marks FAIL on any error (:228) and `process.exit(1)` (:246-248). `serve` script exists in docs pkg. Not a stub. | SHIPPED |
| 2 | Ties-first: only FIRST tied candle's body accented; second stays grey | `packages/core/tests/candlestick.test.ts:138-186` builds two tied-close candles, walks raw ANSI tracking visible columns, collects accent-coloured `█` cells, asserts every accent col is inside A's body span and B's span is un-accented. `candlestick.ts:80-83` uses strict `>`. **Mutation test:** changing `>`→`>=` at `candlestick.ts:82` makes the new test fail (1 failed / 21 passed). Test is non-vacuous. | SHIPPED |
| 3 | SVG 1:1 parity (tones, markers every 2nd, dash textures, optional grid, captions, accent-once) + drift test; regen `svg-charts.json` | (a) `line.ts:160-161` reads `model.style.accent` / `model.seriesColors`; SVG reads `model.seriesColors`/`model.style` (`line-model.ts:184,207,234`). (b) no `#8ae234`; `ansiToCss` theme mapping (:151-162), markers every 2nd point (:239), accent once via `peakMarkerIndex` (:240-241), `grid`-gated gridlines (:213-219), `DASH_ARRAYS` textures (:68,237), legend/eyebrow/summary (:199-210,256-286). (c) `gen:charts:check` green; corrupting `svg-charts.json` makes it exit 1 (gate real). (d) `tests/line-svg.test.ts` (7 tests) passes; **mutation:** replacing `seriesColors = model.seriesColors` with local `theme.colors` makes it fail (1/7). | SHIPPED |
| 4 | Publish `ai-data` route: per-chart `toJSON()` shapes, empty/null + clamp-true-value, `toContent()` advice, MCP guardrail; link from AI Agents + README + QA list | `App.tsx`: `NAV_SECTIONS` adds `ai-data` (:109), `AiDataPage` (:431-510), route `content()` (:772), `labelFor` (:761), AI-Agents button `onNav("ai-data")` (:426). All 20 `AI_SHAPES` (:437-457) spot-checked against real `toJSON()` — accurate, including progress/gauge clamp-true-value and sparkline/boxplot/radar/heatmap/timeline/treemap/sankey/candlestick null-on-empty (runtime-verified). README link `packages/core/README.md:76-78`; `qa-catalog.mjs:23` doc list. | SHIPPED |
| 5 | `verify-session-33.sh` + `demo-session-33.sh` exit 0; core tests+typecheck, docs typecheck+build, drift gate green | `bash scripts/verify-session-33.sh` → **17 pass, 0 fail, exit 0**. `bash scripts/demo-session-33.sh` → exit 0. Core: 452 tests / 23 files pass; core+docs typecheck pass; drift gate green. | SHIPPED |

## Adversarial notes

- **Candle test mutation-confirmed** (not vacuous): strict-`>` → `>=` fails it. The first loop's `col < aCol+candleW` already excludes B's whole span, so the redundant second loop is harmless.
- **Drift test mutation-confirmed**: reintroducing local colour logic in `line.ts` fails `line-svg.test.ts`. It genuinely guards terminal↔model↔SVG colour drift.
- **Un-guarded drift vectors (minor):** the drift test does not check legend dash chars (`line.ts:54` vs `line-model.ts:67` — duplicated arrays) nor terminal stroke textures (`line.ts:47` vs model `strokeSteps`). Grid rendering also differs in form (terminal `·` every 2nd col vs SVG `stroke-dasharray="2 8"`). Core parity (colours, markers, accent-once, grid on/off) is guarded; these are not.
- **`verify-session-33.sh` is mostly grep-based** (e.g. `candle-exclusivity-test` greps a comment string, `ai-data-*` greps). Alone it could pass on a stub, but it also runs the real core suite, docs typecheck/build, and the drift gate, which cover behaviour.
- **Manual accuracy:** all 20 `toJSON()` shapes match source. Runtime check: `progress({value:150,max:100})` → `value:150, percent:150, bucket:3`; `gauge({value:250})` → `250/250`. Null-on-empty verified for 11 charts. No inaccuracy found.
- Stale comment: `qa-catalog.mjs:3` says "4 doc pages" (now 5). Cosmetic.
- First `verify` run showed `core-tests FAIL` only because it ran concurrently with an in-flight mutation; the clean serial re-run is 17/0.

## Regressions

- **Terminal line output is byte-identical** (claim holds): worktree at `b66e8e9` vs HEAD, 21 option sets (single/multi/noColor/grid/nord/block/ascii/frame-off/compact/no-axes/long/tiny/flat/maxWidth/etc.) → `diff` empty.
- `toJSON()` gained additive fields (`seriesColors`, `strokeSteps`, `noColor`, `grid`, `style`, `eyebrow`); `model.series[].color` is `stripAnsi`-ed to `""` both before and after (`ansi.ts:53`), so no observable change there.
- SVG geometry constants changed (`left/top/bottom`) — intended parity redesign; affects only the new SVG surface.
- No consumer broke: 452 core tests, both typechecks, docs build, and the chart drift gate all green.

**Verdict:** ACCEPT
**Review-Inputs-SHA:** 9948b0f794f71a55505b71fd95ec8452b258dbd4a7af8d0e95d2703afdd79433

> **Post-review governance note:** the only change after this cold pass is the
> governed tech-lead crew handoff (`.ai/handoffs/session-33-tech-lead.md`,
> required by the closeout crew gate). The code delivery diff is unchanged, so
> this ACCEPT still applies; the attestation was recomputed to the new
> canonical inputs hash. The prior hash (`db2ef16f…32f79`) covered the code
> diff before that governance artifact landed.
