# S22 Cold Fidelity Review — lock the `gauge` chart to the mudra panel language

**Posture:** independent, adversarial, cold. Only two inputs read: `s22-contract.md`,
`s22-delivery.diff`. Nothing else in the repo was opened; runtime was not executed, so
gate *exit codes* are judged by construction, not by running them.

---

## 1. Requirements extracted from the contract

From Acceptance 1–9 plus the testable constitution constraints:

1. Fill = grey tone ramp + matching plain-text shade glyph (`░▒▓█`, one per bucket, light→dark);
   accent hue spent EXACTLY once as a solid `█` on the fill's leading edge; no `theme.colors[i%n]`
   rainbow; raw-RGB verified (1 accent seg, 0 non-ramp/non-accent segs); explicit `thresholds`
   override the ramp tone (glyph unchanged) and the accent edge yields to it.
2. Panel language: dashed frame `┌╌…╌┐`/`└╌…╌┘`, uppercase eyebrow (`LEVEL` or `opts.label`),
   `+╌…╌+` guide + `min..max` scale row, two `│ ╌…╌ │` rules, `─` track kept behind fill,
   `┤`/`├` retired.
3. Fill length = clamped level (past `max` clips full, never `RangeError`); footer reports TRUE
   value + TRUE percent (may exceed 100%/below 0%); non-finite → framed `value n/a` panel.
4. Collapsed range (`max===min`): no div-by-zero; full when `value≥max`, else empty.
5. Footer `value <v> · <min>..<max> · <pct>%` with `value <v>` in accent; facts never fabricated.
6. `toJSON()` additive: `type:"gauge"`, `value`, `min`, `max`, `percent`, `bucket` (0–3, null n/a),
   `plain`; no existing key removed.
7. README `### LOCKED: gauge chart — session 22 design` block stating the rules.
8. `scripts/verify-session-22.sh` exits 0 (all listed sub-gates); `scripts/demo-session-22.sh`
   exits 0 with live renders + falsifiable checks.
9. Docs catalog regenerates in sync (`gen:charts:check` green), description updated, `GaugeOptions`
   unchanged, zero runtime deps, full core suite green.

Constitution: ≤3 files/commit, branch `session-22-*` — branch gate present (`branch-is-s22`).

---

## 2. Evidence hunt (diff-grounded)

- **R1** — `const LEVEL_SHADES = ["░","▒","▓","█"]`; `bucket = Math.min(Math.floor(level*tones.length), tones.length-1)`;
  `buildBar()`: `run = colorize(glyph.repeat(filled-1), fillColor)` + `edge = colorize("█", edgeColor)` + `─` rest.
  `fillColor = override ?? tones[bucket]`, `edgeColor = override ?? acc`. Old `theme.colors[1/3/2]`
  band branch **deleted**. Test `accentCensus` asserts `accent===1, grey===1, other===0`; threshold test
  asserts `accent===0, other===2`. **SHIPPED.**
- **R2** — `buildLines()`: `frameTop`, `frameRule`×2, eyebrow `frameRow`, bar, `buildGuide()`
  (`"+"+"╌".repeat(trackWidth-2)+"+"`), `buildScale()` (`min…max`), summary, `frameBottom`. `─` rest kept
  in `buildBar`. Tests: dashed top/bottom, 2 rules, eyebrow+label-uppercase, guide+scale, `not.toMatch(/[┤├]/)`.
  **SHIPPED.**
- **R3** — `trueLevel` (unclamped) drives `pct`/footer; `level = clamp(0,1)`; `filled = min(trackWidth, max(0, round(level*trackWidth)))`
  → no negative `repeat`. `finite` guard → `value n/a` panel. Tests: value 140 → `140.0%` + no `[░▒▓█]─`;
  value -10 → empty `│ ─+ │` row; NaN → framed `value n/a`. **SHIPPED.**
- **R4** — `collapsed = max===min`; `trueLevel = collapsed ? (value>=max?1:0) : …`. Test asserts no
  `NaN|Infinity`, full at value 50 / empty at 40. **SHIPPED.**
- **R5** — `buildSummary()`: `colorize('value '+v, acc)` + `colorize(' · min..max · pct', label)`. Test
  checks plain `value 73 · 0..100 · 73.0%` and raw `${acc}value 73`. **SHIPPED.**
- **R6** — toJSON hunk adds `percent: finite ? +((trueLevel*100).toFixed(2)) : null` and
  `bucket: finite ? bucket : null`; context lines `value, min, max,` + `plain` preserved, so no key removed.
  Tests: `type/value/min/max/percent/bucket/plain`, bucket 0/1/3, null on NaN. **SHIPPED.**
- **R7** — README block present with 7 rule bullets (intensity=ramp, accent-once, `─` track, panel chrome,
  footer, degenerate-safe, additive surface). **SHIPPED.**
- **R8** — `verify-session-22.sh`: 11 `run_check`s with real `tsx` renders + raw-RGB census, real `pnpm test`,
  `typecheck`, `gen:charts:check`, git branch; each returns non-zero on failure, script `set -euo pipefail`
  and exits 1 if any FAIL. `demo-session-22.sh`: real renders via `render()` (stderr shown, exit propagated),
  falsifiable census/chrome/ramp/degenerate/toJSON checks, honest "This demo does NOT show" section.
  Built to exit 0; **not executed here.** **SHIPPED (construction).**
- **R9** — `ansi-charts.json` + `charts.ts` preview + descriptions updated; `chart-drift-gate` runs
  `gen:charts:check`; no `GaugeOptions` field added (only existing `opts.*` read); no new imports beyond
  intra-package `panel.js`. **SHIPPED.**

---

## 3. Adversarial sweep — fakest-green tells

- **Gates that only warn:** none — every `run_check`/demo check propagates a non-zero exit; `set -euo pipefail`.
- **Weak proxy greps:** `source-locked` strips comments then `grep "theme\.colors\["`, and `readme-lock-block`
  greps only the heading string. The demo's text checks use `grep "value 73 · 0..100 · 73.0%"` with
  **unescaped** `.` (regex wildcards) — a soft proxy. *However,* the rainbow claim is independently nailed by
  the raw-RGB `accentCensus` (`other===0`), so the weak greps are backstopped, not load-bearing.
- **Hand-written deltas:** the `charts.ts` `preview` block (lines 41–49) is a hand-typed panel render. Only
  `gen:charts:check` would catch drift; if that generator treats `charts.ts` as an *input* rather than a
  regenerated artifact, the preview is an unverified manual string. This is the softest consequential gate.
- **Honesty theater:** the demo's BEFORE block is `cat`-ed and explicitly labelled "reconstructed from git —
  NOT a live render"; the AFTER is a real render. Honestly disclosed, not disguised.

### Named test-bug notes (per instructions)

- **vitest-matcher bug:** the `toMatch` assertions correctly **escape** regex metacharacters
  (`/value 73 · 0\.\.100 · 73\.0%/`, `/\+╌+\+/`), and `toBeNull()` is called *with* parentheses
  (lines 542–543, not the no-op `toBeNull` property access). The only sloppy matcher is the demo's
  unescaped-`.` grep, which lives outside the test suite. **Handled correctly — not a fake-green vector.**
- **toJSON-cast bug:** the assertions cast via `toJSON() as Record<string, unknown>` and
  `as { bucket: number|null; percent: number|null }`. These are *narrowing* casts over a superset object
  (the impl returns both keys as `number|null`), so no unsound `as` conversion hides a type mismatch, and
  the runtime assertions (`percent===70`, `bucket===2`, nulls on NaN) compute correctly. **Handled correctly.**

### FAKEST GREEN

**`readme-lock-block` (`grep -q "### LOCKED: gauge chart — session 22 design"`).** Its checkmark is
trivially true: it passes the instant the *heading line* exists, verifying none of the seven rule bullets
beneath it. A builder could satisfy it by typing one heading over an empty/incorrect body. It is the
checkmark most decoupled from the behaviour it claims to certify (runner-up: the `charts.ts` hand-typed
preview, whose only guard is `gen:charts:check`). Neither, however, undermines a requirement that is
independently proven elsewhere in the diff.

---

## 4. Verdict table

| Requirement | Verdict | Evidence |
|---|---|---|
| R1 ramp fill + glyph + accent-once, no rainbow, threshold override | SHIPPED | `LEVEL_SHADES`, `bucket`, `buildBar` run/edge, `fillColor/edgeColor = override ?? …`; `accentCensus` asserts 1/1/0 |
| R2 panel chrome, `─` track, retired `┤├` | SHIPPED | `frameTop/Rule/Row/Bottom`, `buildGuide`, `buildScale`; `not.toMatch(/[┤├]/)` |
| R3 clamp + true value/pct + n/a panel | SHIPPED | `trueLevel` vs clamped `level`, `filled=min(trackWidth,max(0,…))`, `finite` guard; value-140 / -10 / NaN tests |
| R4 collapsed range safe | SHIPPED | `collapsed = max===min` branch; min==max test, no `NaN/Infinity` |
| R5 footer format + accented value | SHIPPED | `buildSummary` `colorize('value '+v, acc)`; plain + raw `${acc}value 73` tests |
| R6 additive `toJSON` | SHIPPED | toJSON hunk adds `percent`(null)/`bucket`(null), preserves `value/min/max/plain`; bucket/null tests |
| R7 README LOCKED block | SHIPPED | `### LOCKED: gauge chart — session 22 design` + 7 rule bullets |
| R8 verify + demo exit 0 | SHIPPED | 11 real `run_check`s + falsifiable demo checks, `set -euo pipefail`, non-zero propagation (not executed) |
| R9 docs in sync, API unchanged, 0 deps | SHIPPED | JSON+preview+description updated, `gen:charts:check` gate, no `GaugeOptions` change, intra-pkg import only |

**SHIPPED: 9 of 9.**

The delivery is a faithful, complete rewrite of the gauge to the locked S18–S21 panel language: the
rainbow band and dead `labelLine` are genuinely removed, the `RangeError` path is genuinely fixed with a
clamped `filled`, the accent-once invariant is enforced by a raw-RGB census rather than a prose claim, and
the two named test-authoring pitfalls (vitest matcher escaping, toJSON narrowing cast) were handled
correctly. The soft spots are proxy greps and a hand-typed docs preview, each backstopped by a harder gate.
No requirement is partial or missing.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** b1d716f1ece0d54f10d7dd64428016c1d52781306d03debd841408052c407e21
