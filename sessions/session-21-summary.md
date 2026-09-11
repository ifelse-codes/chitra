# Session 21 — lock `timeline` to the mudra reference/panel language — SUMMARY

Branch `session-21-timeline-mudra` (from `main` post-#22). Single-chat session: plan
approved in chat, executed directly, independent cold review dispatched as a subagent.
Next chart in the founder-named trio (`timeline` → `gauge` → `progress`), cross-checked
against `design-reference/plan-review.html` (the 2026-09-07 mudra recommendation).

## Recommendation check (plan-review.html vs repo, verified in code before the plan)
- Order not broken: `timeline` is the roadmap's next chart; the plan-review order
  (histogram/funnel/waterfall restyles + `deriveTones`) is untouched and still queued.
- The plan-review's 2 real bug fixes (histogram accent-flood + decimal count labels;
  waterfall never-invisible deltas) are STILL OPEN in code — they live in other charts,
  so they did not block this session. Still the right "first code" candidates.
- The glyph gate was never run as a gate → this session introduced NO new glyphs: only the
  locked vocabulary (`█` bars, `─` scale track, `╌` frame/rules, `+` guide). `▶`/`◀` retired.

## Shipped (uncommitted — see handoff below)
- `packages/core/src/charts/timeline.ts` — S18/S19 panel language on the Gantt: ONE accent
  hue spent exactly once on the longest-span event (ties → first in event order, strict `>`
  rule), grey tone ramp `#ECECEF→#C6C6CE→#A4A4AE→#6A6A75` by span bucket for every other
  event (no `theme.colors[i % n]` rainbow; explicit `event.color` stays a user override),
  dashed frame + uppercase `SPAN` eyebrow + `+╌…╌+` guide + `min..max` scale row + two rule
  separators, `─` track kept as the shared time scale (axis colour), point events (no `end`,
  or `end < start`) render exactly one `█`, `▶`/`◀` retired, `n · min..max · span <label>`
  footer (longest event accented), auto-width (label/eyebrow/summary never clipped),
  collapsed-range guard (never divides by zero), empty → framed `n 0 · (no data)` panel,
  `noColor` safe. `toJSON()` gains additive `peak {index, label, span}`. Public API
  (`TimelineOptions`) unchanged, zero runtime deps.
- `packages/core/tests/timeline.test.ts` — 21 falsifiable raw-ANSI tests (accent census,
  chrome, footer, tie-break, user-color override, point-event, collapsed range, backwards
  end, scale overrides, noColor, toJSON).
- `packages/core/README.md` — `### LOCKED: timeline chart — session 21 design` block.
- Docs previews regenerated (`chart-specs.ts` description + `charts.ts` + `ansi-charts.json`)
  — drift gate green. `dist/` rebuilt (untracked).
- `scripts/verify-session-21.sh` (12 checks) + `scripts/demo-session-21.sh` (before/after +
  5 live checks).
- `prompts/21-task-timeline-mudra.md` — the session contract (reviewer's cold input).

## Gates (observed 2026-09-10/11)
- `verify-session-21.sh` — 12/12 ALL GREEN. `demo-session-21.sh` — exit 0, 5/5 PASS
  (after two fixes: a demo-script byte→glyph count fix, and a heredoc-terminator repair —
  an early edit glued `TS` to the accent-census console.log, silently no-op'ing the accent
  check and leaving a temp file that broke typecheck; both caught by the gates, never
  hand-waved).
- `core test` — 259/259 (12 files, +23 timeline). `typecheck` — exit 0.

## Founder refinement (pre-commit, 2026-09-11): shade texture on the bars
- Founder (viewing the throwaway gallery): heatmap's `░▒▓` dot-shade texture should be on
  the timeline bars too — "why did we not have it".
- Why it wasn't: the texture was reserved for magnitude-as-intensity charts (heatmap
  cells, treemap areas); timeline followed its closest relative horizontalBar (flat blocks)
  because bar length already encodes the span.
- Amended design (heatmap rule applied 1:1): intensity IS the shade ramp — every non-peak
  bar renders its tone bucket's glyph (`░ ▒ ▓ █`, light → dark by span bucket) so the
  ordering survives `stripAnsi`/`noColor`; the peak leaves the ramp for a solid `█` accent
  run; a point event renders exactly one `░`. Source, 23 tests (2 new: ramp encoding +
  no-phantom-texture), README LOCKED block, verify (ramp census + ramp-survives-noColor +
  point=░), demo, docs previews, dist — all updated and re-gated: 12/12 verify, 5/5 demo,
  259/259 tests, typecheck 0, drift gate green.

## Governance
- Crew: none dispatched (single-chat session; no pi/Command-Code this time — provenance is
  this transcript). The S139 required-crew gate may still flag this; if so the founder
  waiver covers it (disclosed, not hidden).
- Independent cold fidelity review owed POST-COMMIT (attestation hashes the committed diff
  + prompt): `sessions/session-21-review.md` to follow the handoff commits.

## Exact handoff (paste in a fresh shell on `session-21-timeline-mudra`)
- `V=21; git add packages/core/src/charts/timeline.ts packages/core/tests/timeline.test.ts packages/core/README.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S21: lock timeline to reference language"`
- `git add artifacts/chitra-docs/scripts/chart-specs.ts artifacts/chitra-docs/src/data/charts.ts artifacts/chitra-docs/src/data/ansi-charts.json && VAJRA_ALLOW_COMMIT=$V git commit -m "S21: regenerated docs previews"`
- `git add scripts/verify-session-21.sh scripts/demo-session-21.sh prompts/21-task-timeline-mudra.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S21: verify + demo + prompt"`
- `git add sessions/session-21-summary.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S21: summary"`
- `git add .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S21 closeout: advance session pointer + boot + task to 21"`
- `git add .ai/STATE.md .ai/ROADMAP.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S21 closeout: sync STATE + ROADMAP snapshots"`
- Then: cold review pass → verdict + attestation (`verify-closeout.sh --inputs-sha 21`) →
  commit the review → `scripts/verify-closeout.sh` → PR to `main`.
  Never commit `.commandcode/`, `.freebuff/`, `command-code-session-*.html`,
  `design-reference/*`, `scripts/build-audit-html.mjs` (pre-session noise, not delivery).

## Founder deferral (2026-09-11, at close): plain-English footers — family-wide, later
- Founder flagged the footer `n 4 · 0..8 · span Build` as ugly/confusing under the `0 … 8`
  scale row (repeat + jargon). Decision page built from real renders (throwaway,
  /tmp/footer-options.html): A = trim redundant (timeline + horizontalBar: `4 events ·
  longest Build`), B = plain words on ALL locked charts (`4 events · 0..8 · longest
  Build`), B-diet = B + drop the second rule. Founder: **deferred — "later we will fix it
  for all"**. Record the chosen option in S22+ as ONE family-wide footer session (README
  blocks + tests + previews together); auto-width must grow panels for longer wording.

## Next-session candidates (S22)
- `gauge` → `progress` mudra migration (the rest of the founder-named trio, one per
  session, carrying the shade-texture ruling); the family-wide footer redesign (A/B/B-diet,
  deferred by the founder); histogram/funnel/waterfall restyles + the 2 real bug fixes from
  plan-review (histogram decimals + accent flood, waterfall never-invisible);
  `lineModelToSvg` parity; real `v0.1.0` release; Playwright QA into CI.
