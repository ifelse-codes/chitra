# Session 21 — Independent Cold Fidelity Review (`timeline` → mudra reference/panel language)

## Method controls

Consumed as evidence of scope (and nothing else):

- The contract: `prompts/21-task-timeline-mudra.md` (Acceptance 1–10 + Session constraints).
- The delivery diff: `git diff $(git merge-base main HEAD) HEAD -- ':(exclude)sessions' ':(exclude)prompts' ':(exclude).ai'`
  (8 files: `packages/core/src/charts/timeline.ts`, `packages/core/tests/timeline.test.ts`,
  `packages/core/README.md`, `artifacts/chitra-docs/{scripts/chart-specs.ts,src/data/ansi-charts.json,src/data/charts.ts}`,
  `scripts/verify-session-21.sh`, `scripts/demo-session-21.sh`).

Did NOT read (per cold-input rule): `sessions/session-21-summary.md`, any prior session-21 review,
`.ai/STATE.md`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md`, `.ai/ROADMAP.md`.

Ran (behavior, not diff hunks):

- `npx vitest run` in `packages/core` — 12 files, 259 tests, all pass.
- Own adversarial probes via `npx tsx` (not the builder's tests): single-point-event render + raw-ANSI
  census; all-point-events collapsed census; glyph↔tone lockstep across all four buckets (░▒▓█ vs
  `#ECECEF/#C6C6CE/#A4A4AE/#6A6A75`); byte-exact parity of committed
  `artifacts/chitra-docs/src/data/ansi-charts.json["timeline"]` against a fresh live render; empty-events
  plain render; footer facts on negative/fractional data.
- `npx tsx scripts/generate-charts.ts --check` in `artifacts/chitra-docs` directly (drift gate, independent
  of the verify script) — all three data files up to date; inspected the generator: both `ansi-charts.json`
  and the `charts.ts` preview are derived from live `@chitra/core` renders, so the gate is real, not a stub.
- `bash scripts/verify-session-21.sh` — ALL GREEN (12/12). I read every check: each is exit-code-blocking
  (fail → script exit 1), none warn-only. The accent census requires `accent === 1 && other === 0 && grey > 0`
  classified by exact ANSI code against `GREY_TONES`/`theme.accent` — a rainbow leak lands in `other` and fails;
  a colorless render fails `accent !== 1`. Not trivially true.
- `bash scripts/demo-session-21.sh` — exit 0, 5/5 falsifiable live checks PASS.
- Cross-checked untouched-infra claims: session diff touches neither `packages/core/src/types.ts`
  (`TimelineOptions`/`BaseChartOptions` shape unchanged; `xLabel`/`showAxes` pre-existed) nor
  `packages/core/package.json` (zero `dependencies` block — zero runtime deps holds) nor `ansi.ts`/`themes/index.ts`.
- Commit hygiene: all five S21 commits (`2ab274c`, `e50bf27`, `680259f`, `832519e`, `37e149a`) contain ≤ 3 files each.

## Per-requirement table

| Requirement | Verdict | Evidence |
|---|---|---|
| Req-1 — accent spent EXACTLY once on the single longest span as solid `█`; every other event on the grey ramp `#ECECEF→#C6C6CE→#A4A4AE→#6A6A75` (light→dark by span) with matching shade glyph; no rainbow; ties→first (strict `>`); `event.color` override kept; raw-RGB verified | SHIPPED | `timeline.ts`: strict-`>` `peakIdx` loop ("`if (span > peakSpan)`"); `const color = event.color ?? (isPeak ? acc : tones[toneIdx(spans[i])]!)`; `SPAN_SHADES = ["░","▒","▓","█"]` indexed by the same `toneIdx`. `GREY_TONES` in `themes/index.ts` is literally `["#ECECEF","#C6C6CE","#A4A4AE","#6A6A75"].map(hexToAnsi)`. Tests: `accentCensus` raw-ANSI census (`accent` toBe 1, `other` toBe 0), tie test (`span first`), ramp-step tests, `noColor` test, override test. My probes: glyph↔tone lockstep is exact (`tone0↔░`, `tone1↔▒`, `tone2↔▓`, `ACCENT↔█`), including the `▓` bucket no builder test exercises; collapsed all-points census = 1 accent + grey `░`. |
| Req-2 — dashed frame `┌╌…╌┐`/`└╌…╌┘`, uppercase eyebrow (`SPAN`), `+╌…╌+` guide with `min..max` scale row under events, two `│ ╌…╌ │` rules | SHIPPED | `timeline.ts` `buildLines()`: `frameTop(..., true)` / `frameBottom(..., true)` (dashed), `eyebrow = (opts.xLabel ?? "SPAN").toUpperCase()`, `buildGuide()` (`"+" + "╌".repeat(trackWidth-2) + "+"`), `buildScale()` (`lo…hi` row), exactly two `frameRule(...)` calls. Tests assert `^┌╌`, `^└╌`, `rules.length === 2`, `/SPAN/`, `/\+╌+\+/` and the `0…8` scale row. Verify `panel-chrome` check enforces all five with `rules !== 2` blocking. |
| Req-3 — dim `─` track (axis colour) kept behind events as shared scale; no `▶`/`◀` or any glyph outside `░ ▒ ▓ █ ─ ╌ +` | SHIPPED | `buildEventRows()`: `colorize("─".repeat(startPos), theme.axis, …)` left/right of the ramp run; the only fill glyphs are `SPAN_SHADES`. Test "retires the ▶/◀ markers", residue test (`/^[░▒▓█]*$/` after stripping ANSI + allowlist), track-presence test; verify `no-retired-glyphs` re-proves it against live output. |
| Req-4 — no `end` (or `end` before `start`) → exactly ONE lightest `░`, never crash, never NaN-derived position | SHIPPED | `spans` uses `Math.max(0, (e.end ?? e.start) - e.start)`; zero-length path `endPos = Math.min(startPos + 1, trackWidth)` → one glyph; `toneIdx(0) = 0` → `░` whenever a lighter span exists. Tests: point event (`milestone`) renders exactly one `░`; `end:1, start:4` renders one `░`, no NaN. Edge tension (see fakest-green): when the point event is itself the longest span (e.g. the only event), Req-1/Req-6's accent-once rule wins and it renders exactly one `█` in accent — glyph count still one, still honest, still crash-free. |
| Req-5 — footer `n <count> · <min>..<max> · span <label>`, longest label in accent hue, facts true for arbitrary data | SHIPPED | `buildSummary()`: head in `theme.label`, tail `` `span ${peakLabel}` `` in `theme.accent`; min/max computed from `allStarts`/`allEnds` (`e.end ?? e.start`), honouring explicit `min`/`max`. Tests: `n 4 · 0..8 · span Build`, override `-2..10`. Probe: `-5.5..10` renders via shared `formatNumber` — facts, not fabrication. |
| Req-6 — degenerate input safe: empty → framed `n 0 · (no data)`; single; collapsed range → honest, accent still exactly once; no NaN/Infinity | SHIPPED | `hasData` guards; `range = rangeMax > rangeMin ? … : 1`; `spanRange` same guard. Probe render of empty input: full dashed panel with `n 0 · (no data)`, no guide row, no NaN. Tests cover empty/collapsed/single/backwards with `accentCensus(...).accent` toBe 1 on collapsed and single. Verify `degenerate-safe` blocks on NaN/Infinity or missing frame. |
| Req-7 — `toJSON()`: `type: "timeline"`, `events`, `min`, `max`, `peak` (`{index,label,span}` or `null`), `plain` | SHIPPED | `timeline.ts` `toJSON()` returns exactly those keys; `peak: hasData ? { index: peakIdx, label: peakLabel, span: spans[peakIdx]! } : null`. Test asserts deep equality `{ index: 1, label: "Build", span: 4 }`, `type`, `min`, `max`, and plain-string `plain`. |
| Req-8 — README `### LOCKED: timeline chart — session 21 design` block stating the rules | SHIPPED | Diff adds the exact heading plus six rule bullets (accent-once + tie rule + ramp hexes, shade-ramp texture, `─`-track-as-scale, point events, panel language, footer, degenerate safety). Verify `readme-lock-block` greps the heading. |
| Req-9 — `verify-session-21.sh` exit 0 with the named checks; `demo-session-21.sh` exit 0 with live renders + falsifiable checks | SHIPPED | I ran both: verify ALL GREEN 12/12 — every check named in the contract is present and exit-blocking (raw-rgb-accent-once, panel-chrome, footer-format, no-retired-glyphs incl. point-event, degenerate-safe, source-locked no-rainbow, core-tests-green + core-typecheck + timeline-tests, readme-lock-block, chart-drift-gate, branch-is-s21). Demo exit 0 with 5 falsifiable live checks (raw-RGB census, no-rainbow source, panel language, point-events, degenerate-safe) wired to a scorecard and exit 1 on any FAIL. |
| Req-10 — docs catalog in sync (`gen:charts:check` green) with locked render + updated description; `TimelineOptions` unchanged; zero runtime deps; full core suite green | SHIPPED | Ran the drift gate directly: all three data files "up to date"; generator derives `ansi-charts.json` AND the `charts.ts` preview from live renders. My probe: committed JSON `timeline` value === fresh live render byte-for-byte. Description updated in `chart-specs.ts`. `types.ts` and `package.json` untouched by the session diff; core package has no `dependencies` block. Full suite: 259/259. |

Constraints:

| Constraint | Verdict | Evidence |
|---|---|---|
| Req-C1 — one story | SHIPPED | Diff touches only the timeline chart, its tests/docs, and the session scripts. |
| Req-C2 — max 3 files per atomic commit | SHIPPED | All five S21 commits have ≤ 3 files (verified with `git show --name-only`). |
| Req-C3 — no autonomous commits (founder runs with `VAJRA_ALLOW_COMMIT=21`) | NOT-VERIFIABLE | Commit authorship/token usage cannot be proven from the diff; no contrary evidence; the commit series matches the founder-run flow (prompt committed alongside scripts in `680259f`). |
| Req-C4 — verify exit 0 | SHIPPED | Ran `verify-session-21.sh` myself: ALL GREEN, exit 0. |
| Req-C5 — independent cold fidelity review post-commit, before ACCEPT | SATISFIED | This document, produced from contract + committed diff only, post-commit. |

## Count

**10 of 10 SHIPPED** (Req-1..Req-10; constraints C1/C2/C4/C5 satisfied, C3 not independently verifiable from the diff).

## Fakest green

The point-event story ("no `end` → exactly one `░`") looks universally proven — dedicated tests, a demo check, a verify check — yet the single corner where its letter fails is exactly the corner the gates skip: my probe shows a lone point event (itself the longest span) renders one `█` in accent, not `░`, and `verify-session-21.sh`'s degenerate case list contains precisely that case (single `end`-before-`start` event) while asserting only no-NaN + frame, never the glyph. It is hollow only at the letter: the accent-once rule of Req-1 and the collapsed-range clause of Req-6 ("accent still spent exactly once") mandate that outcome, so the builder resolved a contract-internal conflict coherently rather than faking a checkmark — the glyph count is still exactly one and nothing crashes. Second-order note: no builder artifact ever exercised the `▓`/dark-tone buckets; my probe confirms they are correct (tone2↔`▓`, tone3 covered by the accent peak), so the gap is coverage, not behavior.

## Verdict

The real scope is a faithful build of the whole contract: every numbered requirement maps to committed code plus behavioral evidence I reproduced independently, the gates block rather than warn, and the docs surface is byte-exact with the live render.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** ef9cb7bb2ef00f99085883e42deb08c339abb3955390f6a9316ca8d294c16c76
