# Session 24 — docs site: grouped chart catalog nav + mudra status badges

> **Type: CODE** (docs app — S13/S14/S15 precedent: docs sessions carry the full gate set).
> Branch `session-24-docs-nav-groups`, cut from `main` after the S23 PR merges. One story:
> reorganize the chart-catalog sidebar into six semantic groups with collapsible headers and
> generated mudra lock-status badges, per the founder-approved visual contract
> (`design-reference/nav-groups-mock.html` — approved 2026-09-13).

## Goal

The catalog sidebar lists 20 charts in one flat, history-ordered list. The founder approved a
grouped redesign: **six semantic categories** (stable, reader-facing), **collapsible group
headers**, and **minimal status badges** (`locked` / `in flight` / violet `trio` marker only —
NO session numbers, NO "queued" chips; unported charts carry no badge). Status is a badge, not
a taxonomy: the nav grouping must never reshuffle as ports land.

## Named references (read ONLY these)

- `design-reference/nav-groups-mock.html` — the approved visual contract (tokens, spacing,
  badge styles, caret behavior, expand/collapse-all buttons).
- `artifacts/chitra-docs/scripts/chart-specs.ts` — where the `group` field is authored.
- `artifacts/chitra-docs/scripts/generate-charts.ts` — the generator to thread it through.
- `artifacts/chitra-docs/src/data/charts.ts` — GENERATED output (never hand-edit).
- `artifacts/chitra-docs/src/index.css` — sidebar/nav styles (`.nav-section-label`,
  `.nav-item` are the existing vocabulary to extend).
- `artifacts/chitra-docs/src/components/CatalogPage.tsx` — the sidebar renderer.
- The `### LOCKED:` blocks in `packages/core/README.md` — the badge SOURCE OF TRUTH.

## Acceptance (testable, EARS-style)

1. WHEN the catalog renders, THEN the 20 charts are grouped into EXACTLY six categories —
   Trend & time (line, area, timeline, candlestick) · Comparison (bar, horizontalBar,
   scatter, radar) · Distribution & density (histogram, boxplot, heatmap) · Part-to-whole
   (pie, donut, treemap, funnel) · Flow & accumulation (sankey, waterfall) · Single value &
   progress (gauge, progress, sparkline) — group membership derived from a `group` field
   authored in `chart-specs.ts` and threaded through `generate-charts.ts` into the generated
   `charts.ts`. Hand-editing `src/data/charts.ts` is forbidden; the drift gate stays the
   enforcer.
2. WHEN a group header is clicked (or focused + Enter/Space), THEN its items collapse and
   expand, the caret rotates `▾`→`▸`, and the collapsed state persists in `localStorage`
   (survives reload); an `expand all` / `collapse all` pair of controls exists per the mock.
3. WHEN the page navigates to a chart, THEN that chart's group is auto-expanded (even if the
   user collapsed it in a previous visit) and the active row highlights as today.
4. WHEN a chart is mudra-locked (its `### LOCKED: <name> chart` block exists in
   `packages/core/README.md`), THEN the sidebar shows a small green `locked` badge on its row;
   badge DATA is derived from the README blocks at generation time (a `locked` boolean
   computed by the generator or its check), never hand-typed in the spec file.
5. The founder-named trio rows (timeline, gauge, progress) carry a violet `trio` badge; the
   in-flight session's chart may additionally show `in flight` via the same generated field.
6. No session-number badges (`S09` etc.), no `queued` chips, anywhere in the nav.
7. The visual result matches the approved mock: same tokens (DM Sans / JetBrains Mono,
   `--text-dim` group labels at 10px/600/0.12em, 5px nav rows), group count tags, glyphs.
8. `scripts/verify-session-24.sh` exits 0 — MUST include: (a) the six groups with exactly
   their member ids present in the generated data, (b) a generated-vs-README lock-badge
   consistency check (every README LOCKED chart has badge data true), (c) the drift gate
   (`gen:charts:check`) green, (d) docs `typecheck` + `build` green, (e) collapse behavior
   verified by the scripted Playwright pass (click toggle → hidden items → reload → state
   kept; navigating to a chart auto-expands its group), and `scripts/demo-session-24.sh`
   exits 0 with live before/after renders of the sidebar.
9. The full existing QA stays green: `check:catalog` passes, the S15 Playwright suite passes
   (sidebar assertions updated for the new DOM), and no hand-edits to generated files.

## Session constraints (constitution)

- One story. Max 3 files per atomic commit. No autonomous commits (founder runs them with
  `VAJRA_ALLOW_COMMIT=24`). Verify exit 0 required. Independent cold fidelity review owed
  post-commit (`sessions/session-24-review.md`, per `reviewer/SKILL.md`) before ACCEPT.
- The mock HTML itself is a design artifact — do NOT commit it; extract its values into the
  real source (that is the story).
