# S23 Cold Fidelity Review — lock the `progress` chart to the mudra panel language

**Posture:** independent, adversarial, cold. Only two inputs read: `s23-contract.md`,
`s23-delivery.diff`. Nothing else was opened; runtime was not executed, so gate exit codes
are judged by construction, not by running them.

## 1. Requirements extracted from the contract

**Acceptance items (EARS):**
- **R1** — Fill is the grey tone ramp with matching shade glyph (`░ ▒ ▓ █`, one per tone bucket, light→dark, survives `stripAnsi`/`noColor`); accent hue spent EXACTLY once as a solid `█` on the fill's leading edge; no `theme.colors[i % n]` rainbow ever; verified at raw-ANSI level (one accent bar segment, zero non-ramp/non-accent bar segments); `style` still accepted but every style renders the same shade-ramp panel (no `▁▂▃`, no `=`/`.`, no naked `[…]` bracket bar).
- **R2** — Panel language: dashed frame (`┌╌…╌┐`/`└╌…╌┘`), uppercase eyebrow (`PROGRESS` or uppercased `opts.label`), `+╌…╌+` value-axis guide, `0..max` scale row under the bar, two `│ ╌…╌ │` rule separators; `─` track (axis colour) behind the fill; auto-expanding width (explicit `width` is a floor, not a cap).
- **R3** — Fill length = level clamped to track (past-`max` clips at full width, never negative `repeat`); footer and `toJSON()` report TRUE value and TRUE percent (may exceed 100% / fall below 0%); old silently-clamped-and-lying `value` gone.
- **R4** — Collapsed range (`max === 0`) renders honestly, no division by zero (full when `value ≥ max`, empty otherwise); non-finite `value` renders a framed `value n/a` panel — never `NaN`/`Infinity`.
- **R5** — Footer `value <v> · 0..<max> · <pct>%` with `value <v>` in accent hue; `showPercent: false` drops the `· <pct>%` fact.
- **R6** — `toJSON()` additive: `type: "progress"`, `value` (TRUE, unclamped), `max`, `percent` (TRUE, `null` when n/a), `bucket` (0–3, `null` when n/a), `plain`; no existing key removed; `ProgressOptions` shape unchanged.
- **R7** — README carries `### LOCKED: progress chart — session 23 design` block stating the rules, mirroring the gauge block's style.
- **R8** — `scripts/verify-session-23.sh` exits 0 covering: raw-ANSI accent census, panel chrome, footer format, retired-glyph check, ramp-survives-noColor, degenerate-safe (out-of-range honest footer + collapsed + n/a), no-rainbow/no-sub-block/no-ascii-bar source check, core tests + typecheck, README block, docs chart-drift gate, branch check; `scripts/demo-session-23.sh` exits 0 with live renders + falsifiable checks.
- **R9** — Docs catalog preview regenerated in sync (`gen:charts:check`) with locked render + updated description; full core suite green with the outdated clamped-`toJSON` assertion in `charts.test.ts` updated; zero runtime deps.

**Constitution constraints:**
- **R10** — One story.
- **R11** — Max 3 files per atomic commit.
- **R12** — No autonomous commits (founder runs them with `VAJRA_ALLOW_COMMIT=23`).
- **R13** — Verify exit 0 required (gate must block, not warn).
- **R14** — Independent cold fidelity review owed post-commit (`sessions/session-23-review.md`) before ACCEPT.

## 2. Evidence hunt (diff-grounded)

- **R1** — `progress.ts`: `const LEVEL_SHADES = ["░", "▒", "▓", "█"];`, `const bucket = Math.min(Math.floor(level * tones.length), tones.length - 1);`, `const fillColor = tones[bucket]!;`, and `buildBar()` = `colorize(glyph.repeat(filled - 1), fillColor, …)` + `colorize("█", acc, …)` + `─` track. The old rainbow (`const colorIdx = normalized < 0.33 ? 2 : …; theme.colors[colorIdx % theme.colors.length]`) is deleted; no `theme.colors` reference survives in the new source. Raw-ANSI census exists three times over: `accentCensus()` in `progress.test.ts` (`expect(c.accent).toBe(1); expect(c.other).toBe(0); expect(c.grey).toBe(1);`), verify criterion `raw-ansi-accent-once` (`if (accent !== 1) … process.exit(1)`), and the demo census. Style supersession: test "the style option stays accepted but the locked design supersedes it" iterates all four styles, asserts identical ramp render + census 1, and asserts no `[`/`]`, no `▁▂▃▄▅▆▇`, no `=`. **SHIPPED**
- **R2** — `buildLines()` pushes `frameTop(effectiveWidth, "PROGRESS", …)`, `frameRule`, eyebrow row (`(opts.label ?? "PROGRESS").toUpperCase()`), bar, `buildGuide()` (`"+" + "╌".repeat(trackWidth - 2) + "+"`), `buildScale()` (`lo + spaces + hi`), second `frameRule`, summary, `frameBottom`. Auto-width: `effectiveWidth = Math.max(opts.width ?? 36, eyebrow.length + 4, summaryPlain.length + 4)` — `width` is a floor. Tests: two rules exactly (`rules.length).toBe(2)`), uniform row widths (`widths.size).toBe(1)`), `width: 12` still consistent. **SHIPPED**
- **R3** — The literal lie removal: `-const value = Math.min(Math.max(opts.value, 0), max);` → `+const value = opts.value;`; `trueLevel` (unclamped) vs `level = Math.min(1, Math.max(0, trueLevel))`; `filled = Math.min(trackWidth, Math.max(0, Math.round(level * trackWidth)))`. Tests: footer `value 140 · 0..100 · 140.0%` with full bar, `value -10 · 0..100 · -10.0%` with all-track row, `toJSON` 200/200. **SHIPPED**
- **R4** — `const collapsed = max === min;` (min = 0), `trueLevel = collapsed ? (value >= max ? 1 : 0) : value / max`; `finite = Number.isFinite(value) && Number.isFinite(max)`; `summaryPlain = "value n/a · 0..100"` fallback. Tests assert no `NaN|Infinity`, framed `┌╌`/`└╌` on the n/a panel, collapsed-full (census accent 1) and collapsed-empty. Verify `degenerate-safe` criterion repeats all four at runtime. **SHIPPED**
- **R5** — `pctTail = opts.showPercent === false ? "" : " · ${pct}"`; `buildSummary()`: `colorize(`value ${formatNumber(value)}`, acc, noColor)` as the leading accent segment. Tests: `/value 87 · 0\.\.100 · 87\.0%/`, raw `toContain(`${acc}value 87`)`, `showPercent:false` footer without `%` while `toJSON.percent` stays 87. **SHIPPED**
- **R6** — `toJSON()` returns `type: "progress"`, `value` (raw), `max`, `percent: finite ? +((trueLevel * 100).toFixed(2)) : null`, `bucket: finite ? bucket : null`, `plain`. Old keys (type/value/max/percent/plain) all retained; `types.js` untouched so `ProgressOptions` is unchanged. Tests cover 70→bucket 2, 20→0, 45→1, 95→3, NaN→null/null. **SHIPPED**
- **R7** — README diff adds `### LOCKED: progress chart — session 23 design` with bullet rules covering tone ramp (+ hex values), accent-once, style-superseded, `─` track, panel chrome, footer/`showPercent`, out-of-range/degenerate honesty, additive agent surface — mirroring the gauge block's bold-lead bullet style (the S22 gauge block is visible as context immediately above). **SHIPPED**
- **R8** — Both scripts are new files with `set -euo pipefail`. `run_check()` executes each criterion via `if "$@" > "$LOG" 2>&1` and increments `FAIL` on non-zero; final `if [ "$FAIL" -eq 0 ]; then … exit 0; else … exit 1; fi` — failures propagate to a non-zero script exit (the `if` wrapper deliberately converts aborts into counted FAILs, not silent passes). All eleven contract-listed checks are present: census, chrome, footer, retired-glyphs, noColor ramp, degenerate-safe, `source-locked` (sed comment-stripped grep for `theme.colors[` / `buildHorizontalBlockBar|buildAsciiHBar` failing, plus positive greps for `frameTop`/`theme.accent`/`LEVEL_SHADES`), `core-tests-green` + `core-typecheck` + `progress-tests` (real `pnpm` invocations), `readme-lock-block`, `chart-drift-gate` (`gen:charts:check`), `branch-is-s23`. Demo runs the real chart through `tsx`, aggregates `DEMO_FAIL`, exits 0/1 on it; its two `|| true` swallows are backstopped by content-equality checks (`"$RETIRED" = "CLEAN"`, JSON greps), so a crashed render still fails. Judged by construction only — not executed here. **SHIPPED**
- **R9** — `artifacts/chitra-docs/scripts/chart-specs.ts` description + code updated; `ansi-charts.json` `"progress"` regenerated to the framed panel; `charts.ts` preview updated. The generated JSON is internally consistent with the shipped renderer (BUILD 0.87 → bucket 3, `#6A6A75` `█`×27 + accent `█` + 4 `─`; TESTS 0.62 → bucket 2 `▓` `#A4A4AE`; COVERAGE 0.34 → bucket 1 `▒` `#C6C6CE`; accent `139;124;246` once per bar; `+╌` guide, `0…100` scale, two rules, accented `value 87` footer) — i.e. genuinely regenerated, not hand-painted. `charts.test.ts`: `-expect(j.value).toBe(100);` → `+expect(j.value).toBe(200); +expect(j.percent).toBe(200);`. No `package.json`/dependency hunk in the diff → zero runtime deps preserved. `gen:charts:check` greenness asserted by construction only. **SHIPPED**
- **R10** — Every hunk serves the single story: the chart, its tests, its gates, its README lock, its docs catalog. **SHIPPED**
- **R11** — Not observable: the diff is one flat 9-file delta with no commit structure; whether it was split into ≤3-file atoms is unknowable from the inputs. **PARTIAL** (missing: commit atomization evidence).
- **R12** — Not observable: no commit metadata, author, or `VAJRA_ALLOW_COMMIT` trace exists in a diff. **PARTIAL** (missing: who committed / how).
- **R13** — The gate is constructed to block, not warn: counted `FAIL` → `exit 1` in both scripts; inner `bash -c` snippets each `exit $rc` after `npx tsx`. The actual green run is a runtime fact this cold review cannot execute. **SHIPPED** (construction real; run status unverified here).
- **R14** — `sessions/session-23-review.md` does not appear in the diff — correctly so, since this document is that owed review. **PARTIAL** (owed by this very audit, not a builder artifact).

## 3. Adversarial sweep — fakest-green tells

- `readme-lock-block` greps only the heading `### LOCKED: progress chart — session 23 design` — the textbook weak proxy. Trivially green against a hollowed README. Today it masks nothing (the block is genuinely in the diff and comprehensive), but it is the one checkmark whose truth costs one `paste` to earn.
- The accent census scopes its count to segments whose body matches `/[░▒▓█]/` — a hypothetical non-ramp glyph fill would be invisible to the census. That hole is closed by the ramp-progression checks (`rowFor(20)).toMatch(/░+█/)` etc. in tests, verify criterion 5, and the demo), so the combined gate is sound; no single point is load-bearing alone.
- `source-locked` is a source grep, not behavior — but it is supplementary to the runtime census/degenerate checks, and its comment-stripping sed errs toward false positives, not false negatives.
- The demo's `BEFORE` bar is a hand-typed `cat <<'EOF'` string, honestly labelled "reconstructed from git — NOT a live render" — the opposite of honesty theater. The demo even ends with "a green demo is evidence, not a passing delivery — the gates decide that."
- `artifacts/chitra-docs/src/data/charts.ts` keeps a hand-maintained plain `preview` string duplicating the generated `ansi-charts.json` render; if `gen:charts:check` covers only the generated pipeline, this second copy could drift silently. It matches the real render today (verified structurally against the JSON).
- No deltas or tracking claims are hand-written into any doc that code doesn't also compute — the JSON catalog entries are provably renderer-consistent down to bucket/tone/glyph counts.
- Minor nits, not breaches: `toJSON().value` is `NaN` (not `null`) for non-finite input (contract specifies `null` only for `percent`/`bucket`); `bucket` for `value: 200` is the clamped-render index 3 (defensible — it is the shade actually drawn, and the README says so); `toMarkdown()` switched from inline backtick to fenced block (contract-silent, family-consistent).

### FAKEST GREEN
`run_check "readme-lock-block" bash -c 'grep -q "### LOCKED: progress chart — session 23 design" packages/core/README.md'` — a heading grep standing in for "carries a block stating the rules above." Its greenness is trivially true even if the block body were emptied; it proves a string exists, not that any rule is stated. Mitigated in this delivery only because the full block happens to be present in the same diff.

## 4. Verdict table

| Requirement | Verdict | Evidence |
|---|---|---|
| R1 shade ramp + accent-once + no rainbow + style superseded | SHIPPED | `LEVEL_SHADES`, `buildBar()` run/edge/rest; `accentCensus` tests (`accent 1 / other 0 / grey 1`); old `theme.colors[colorIdx % …]` deleted |
| R2 panel chrome + guide + scale + rules + auto-width | SHIPPED | `buildLines()` (frameTop/2×frameRule/frameRow/frameBottom), `buildGuide()`, `buildScale()`, `effectiveWidth = Math.max(opts.width ?? 36, …+4, …+4)` |
| R3 honest out-of-range, clamped fill only | SHIPPED | `value = opts.value` (clamp line deleted), `trueLevel` vs `level`; tests `value 140 · … · 140.0%`, `toJSON` 200/200 |
| R4 collapsed range + non-finite n/a panel | SHIPPED | `collapsed = max === min`, `finite = Number.isFinite(…)`, `value n/a · 0..100` framed-panel tests |
| R5 footer format + accent fact + showPercent | SHIPPED | `buildSummary()`: accent `value <v>`; `pctTail` drop; test `not.toMatch(/%/)` with `json.percent` still 87 |
| R6 additive honest toJSON | SHIPPED | `percent: finite ? … : null`, `bucket: finite ? bucket : null`; old keys kept; `types.js` untouched |
| R7 README LOCKED block | SHIPPED | `+### LOCKED: progress chart — session 23 design` with all rules, gauge-block style |
| R8 verify + demo scripts exit 0, blocking | SHIPPED | `run_check` FAIL counter → `exit 1`; 11 criteria incl. census/source/drift/branch; demo `DEMO_FAIL` → `exit 1` (judged by construction — not executed) |
| R9 docs in sync + updated tests + zero deps | SHIPPED | regenerated `ansi-charts.json` bucket/tone-consistent with renderer; `charts.test.ts` clamp assertion flipped honest; no dependency hunks |
| R10 one story | SHIPPED | all 9 files serve the progress lock |
| R11 max 3 files per atomic commit | PARTIAL | commit atomization not observable from a flat diff (9 files total) |
| R12 no autonomous commits | PARTIAL | no commit metadata/author in inputs |
| R13 verify gate blocks (exit 0 required) | SHIPPED | explicit `exit 1` on any FAIL in both scripts; inner `exit $rc` propagation (run not executed) |
| R14 cold review owed post-commit | PARTIAL | `sessions/session-23-review.md` absent from diff — it is this document |

**SHIPPED: 11 of 14.**

This is a faithful build of the whole contract, not a narrow slice dressed as the whole: the implementation carries every rule the contract states (ramp+texture, accent-once, chrome, honesty), each rule is pinned by at least one real assertion in the new 244-line test file and re-asserted at runtime by the verify/demo gates whose non-zero exits demonstrably propagate by construction, and the docs catalog was genuinely regenerated (the JSON is bucket/tone/glyph-consistent with the new renderer, which a hand-edit would rarely achieve). The three non-SHIPPED rows are process facts (commit granularity, committer identity, the owed review file) that a diff against the branch point cannot carry; none alleges a defect. The weakest artifact is the heading-grep README gate — a fake-prone checkmark that happens to be backed by a real block today.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** c7bde946dcce5bb103b5ac46b6559d3dd589cfb42885271a7b2cb5644253e679
