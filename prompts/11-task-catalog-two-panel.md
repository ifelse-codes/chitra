# S11 — catalog page: two-panel terminal editor + live terminal preview

## Context
Session 11 of the chitra Vajra workflow. S10 landed the reference-locked line chart
(braille, multi-series, smooth splines, tone-ramp). This session rebuilds the docs
site catalog so each chart is presented in a two-panel interactive page: code editor
on the left, live terminal preview on the right — inspired by TanStack Charts catalog,
but entirely terminal-native.

## Goal
`artifacts/chitra-docs` catalog page: two-panel side-by-side layout for all 20 charts.
- **Left panel** — vim/neovim-styled editable code buffer.
- **Right panel** — terminal window showing real chitra output via in-browser execution.
- **Toolbar** — run, copy, download, renderer, theme, reset, status pill.
- **Live re-run** — `@chitra/core` imported into the Vite bundle; `new Function` evaluator
  executes the buffer and re-renders the right panel without a network hop.

## Design

### LEFT PANEL — vim editor
- Tab bar + breadcrumb: `▸ catalog/<id>/example.ts`
- File tabs: `example.ts` (active, editable), `data.ts` (readonly data), `output.txt` (last output)
- Monospace buffer: right-aligned dim line-number gutter, current-line highlight, `~` past-EOF markers, block cursor
- TypeScript syntax highlighting (hand-rolled tokenizer)
- Vim modeline: `-- NORMAL --` / `-- INSERT --`, path, filetype, `Ln n, Col n`, percent
- Buffer is editable; typing re-enables NORMAL on Escape

### RIGHT PANEL — terminal preview
- Title bar: chart title + status pill (`Ready` / `Running…` / `Error`)
- Shell prompt line: `$ tsx example.ts`
- ANSI output via existing `ansiToHtml` from `src/ansi.ts`
- Footer: `[exit 0 · <n>ms · renderer=<r> · theme=<t>]`
- Error block when execution fails (caught, red, non-zero exit, never crashes page)

### TOOLBAR
| Control | Behaviour |
|---|---|
| ▶ Run / ⟳ Refresh | evaluates the buffer |
| ⧉ Copy code | copies example.ts buffer |
| ⧉ Copy output | copies plain-text output |
| ⇩ .ts | downloads example.ts |
| ⇩ .txt | downloads output |
| Renderer | `braille` · `blocks` · `ascii` — re-runs on change |
| Theme | 7 existing themes — re-runs on change |
| ↺ Reset | restores pristine example |
| Status pill | `Ready` / `Running…` / `Error` |

### LIVE EXECUTION
- `@chitra/core: workspace:*` added to docs `package.json` and Vite `server.fs.allow`
- Strip `import` lines from buffer; transform `.render()` → `.toString()`
- `globalThis.process` mocked for stdout capture fallback
- `new Function(...chartApiKeys, fnBody)(...chartApiValues)`
- Renderer/theme toolbar selections injected as overrides into code before evaluation
- Errors caught; shown in terminal panel; page never white-screens

## Plan

- **P1** · `covers: 1,2,3` — two-panel shell + vim editor + terminal preview across all 20 charts
  - `CatalogPage.tsx` component (new)
  - `App.tsx` update: chart pages use `CatalogPage`, content area class override
  - `index.css` additions: catalog layout, vim editor, terminal preview
- **P2** · `covers: 4,5` — toolbar + live in-browser execution
  - Toolbar included in CatalogPage; in-browser evaluator integrated
  - `package.json` add `@chitra/core: workspace:*`
  - `vite.config.ts` add `server.fs.allow` for `../../packages/core`
- **P3** · `covers: 6,7,8` — verify + demo + session artifacts
  - `scripts/verify-session-11.sh`
  - `scripts/demo-session-11.sh`
  - `sessions/session-11-summary.md`
  - `sessions/session-11-review.md`

## Acceptance criteria
1. Two-panel catalog view for every chart, resizable split.
2. Vim-styled buffer: gutter, current-line hl, `~` markers, block cursor, TS syntax, tabs, modeline.
3. Terminal preview: title bar + status pill, `$` prompt, ANSI output, exit/timing footer.
4. Run executes chitra in-browser: editing + Run changes output; syntax error shows caught error block.
5. Toolbar: Run, Copy ×2, Download ×2, Renderer, Theme, Reset — all functional.
6. Core tests, both typechecks, and `gen:charts:check` green; core chart output byte-identical to main.
7. `verify-session-11.sh` exits 0, `demo-session-11.sh` exits 0.
8. `session-11-summary.md` maps each criterion to SHIPPED/PARTIAL/NOT-BUILT; `session-11-review.md` is an independent cold fidelity review.

## Invariants
- No changes to `packages/core` — S10 chart output is LOCKED.
- No new external npm deps — only `@chitra/core: workspace:*` may be added.
- Max 3 files per atomic commit; `VAJRA_ALLOW_COMMIT=11 git commit ...`
- No push, no PR. Local branch only. Founder reviews in browser before anything leaves machine.
