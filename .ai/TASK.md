# Current Task Pointer

## Session 11 — catalog two-panel page: vim editor + live terminal preview — COMPLETE

- **Branch:** `session-11-catalog-two-panel` (from `main`)
- **Shipped:** `CatalogPage` component — two-panel interactive catalog for all 20
  charts. Left: vim-styled editable buffer (line gutter, current-line highlight, `~`
  markers, TS syntax highlighting, file tabs, modeline with NORMAL/INSERT). Right:
  terminal preview (title bar + status pill, ANSI output via `ansiToHtml`, exit/timing
  footer). Toolbar: Run, Copy ×2, Download ×2, Renderer, Theme, Reset. Live in-browser
  evaluator: `@chitra/core` bundled, `new Function` + `globalThis.process` mock,
  `.render()` → `.toString()` transform, errors caught and shown in panel.
- Verify: `scripts/verify-session-11.sh` — 14/14 ALL GREEN.
- Summary: `sessions/session-11-summary.md`. Review: `sessions/session-11-review.md`
  (ACCEPT, one honest gap: block cursor is amber I-beam, not pixel-exact block).

**Next session (S12 candidates):** browser QA of the catalog page + fix any visual
issues found during dev-server review; carry the reference-locked line language into
`bar`/`sparkline`/`histogram`; bring `lineModelToSvg` in line with the terminal.
Open in a **new chat**.
