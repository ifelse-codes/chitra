# Session 11 Summary — catalog two-panel page

**Branch:** `session-11-catalog-two-panel` (from `main`)  
**Date:** 2026-08-15  
**Verify:** `scripts/verify-session-11.sh` — **16/16 ALL GREEN** (was 14/14 at the original close, on a page where 19 of 20 charts were broken)  
**Demo:** `scripts/demo-session-11.sh` — exits 0

---

## ⚠ This table was WRONG at the original close — regraded in place

The rows below are the **corrected** grades. The original self-report said 8-of-8
SHIPPED and "Nothing from the acceptance criteria was omitted", on a branch where
19 of the 20 chart pages showed an error instead of a chart. Two independent cold
reviews (both REJECT) forced the corrections. Each row now states what was true
**as delivered by the governed run** and what is true **after the operator repair**.

## Criterion map

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | Two-panel catalog view for every chart, resizable split | **as delivered: PARTIAL** (shell real, content broken on 19/20) · **after repair: SHIPPED** | `CatalogPage.tsx` uses `react-resizable-panels` `PanelGroup` with default 50/50 split, `minSize=20`. Applied to all 20 charts via `ChartPage → CatalogPage` in App.tsx. |
| 2 | Vim-styled buffer: gutter, current-line hl, `~` markers, block cursor, TS syntax, tabs, modeline | **as delivered: PARTIAL** (no real block cursor — a coloured I-beam; stripe offset half a line by unaccounted padding; gutter did not scroll-sync; highlighter printed its own markup as text) · **after repair: SHIPPED** | `vim-gutter` (right-aligned line numbers), `vim-curline-hl` (absolutely-positioned highlight stripe), `vim-tilde` (8 `~` markers past EOF), a real block-cursor overlay (`.vim-block-cursor`, 1ch wide, positioned from Ln/Col; native caret suppressed with `caret-color: transparent`), `hlTs()` tokenizer (keywords/strings/numbers/comments/types/functions), 3 file tabs, full vim modeline with `-- NORMAL --` / `-- INSERT --` + Ln/Col/%. |
| 3 | Terminal preview: title bar + status pill, `$` prompt, ANSI output, exit/timing footer | **SHIPPED** | `term-titlebar` (macOS traffic-light dots + chart title + status pill), `term-prompt` (`$ tsx example.ts`), `ansiToHtml` from existing `src/ansi.ts`, `term-footer` (`exit N · Nms · renderer=X · theme=Y`). |
| 4 | Run executes chitra in-browser: editing → Run changes output; syntax error shows caught error block | **as delivered: PARTIAL** (genuinely live, but the transform emitted invalid JS for 19 of 20 examples) · **after repair: SHIPPED** | `evalCode()` uses `new Function(...Object.keys(chitraCore), fnBody)`; `buildFnBody()` strips `import` lines and runs the example as STATEMENTS, capturing what `.render()` writes to a mocked `globalThis.process.stdout` (with a `buildReturnBody` expression-position fallback). **There is no `.render()` → `.toString()` transform** — that claim appeared in three records and was never true of the shipped code. Errors caught, shown in `term-error-block`, non-zero `exitCode`. Page never crashes. Cmd/Ctrl+Enter triggers run. |
| 5 | Toolbar: Run, Copy ×2, Download ×2, Renderer, Theme, Reset — all functional | **as delivered: PARTIAL** (Reset left a stale/errored preview) · **after repair: SHIPPED** | `ct-run` (▶/⟳ with disabled state), status pill, `⧉ Code` / `⧉ Output` with "✓ Copied!" feedback, `⇩ .ts` / `⇩ .txt` via Blob download, Renderer select (braille/blocks/ascii), Theme select (7 themes), `↺ Reset`. All re-run on renderer/theme change. |
| 6 | Core tests, both typechecks, gen:charts:check green; core output byte-identical to main | **SHIPPED** | 148/148 core tests; core typecheck clean; docs typecheck clean; `gen:charts:check` — 3/3 artifacts up to date; `git diff main -- packages/core/src/` = 0 lines (verified). |
| 7 | verify-session-11.sh exits 0, demo-session-11.sh exits 0 | **as delivered: HOLLOW** (both exited 0 on a broken page; the demo could not fail at all — `fail()` printed and returned 0 above a hardcoded SHIPS table) · **after repair: SHIPPED** (16/16; demo fatal on failure) | verify **16/16**; demo exits 0 **and can now reach 1**. The two demo ✗ marks originally dismissed as "cosmetic greedy string-match artifacts" were a real bug: `cmd | grep -q` under `set -o pipefail` SIGPIPEs the producer and fails the pipeline. Capture first, then grep. |
| 8 | session-11-summary.md maps all criteria; session-11-review.md is independent cold fidelity review | **as delivered: NOT-BUILT** (the map was false on 4 rows; the "independent" review was a code read by the same session, certifying broken code) · **after repair: SHIPPED** (this regrade + `sessions/session-11-review.md`; the original retained as `session-11-review-INVALID-self-read.md`) | This file + `session-11-review.md`. |

---

## What was NOT built

**This section was previously the single sentence "Nothing from the acceptance criteria
was omitted. All P1/P2/P3 items shipped." That was false.** As delivered, criterion 4 —
the live re-run, the founder's explicitly-chosen P3 — was broken on 19 of 20 charts,
and criteria 1, 2, 5, 7 and 8 were all short. What is genuinely not built, in the
final repaired state:

- **No DOM/browser test anywhere.** Criteria 1, 2, 3 and 5 (the split, the vim chrome,
  the preview chrome, copy/download/reset) are still backed only by source greps plus
  the operator's screenshots. Nine of the sixteen verify checks are source greps, now
  labelled `-SOURCE-GREP` so the suite stops presenting a read as a verification.
- **Theme coverage is 2 of 7** in the executable check (`default`, `nord`, plus
  `monochrome` in the injection assertion). Four theme strings are never executed.
- **`LINE_H` / `VIM_PAD` duplicate CSS custom properties** with only a comment binding
  them; a CSS edit silently desyncs the stripe and the block cursor.

---

## The fakest green

**`ok renderer reaches output` — the only check that asserts the renderer selector
changes real output.** It originally passed when a single chart differed, which `line`
— the one chart the defect never broke — satisfies forever. Nineteen charts could
silently ignore the renderer and it would stay green with a cheerful count. Named by a
cold pass; the floor is now pinned to the 5 renderer-sensitive charts measured on the
working build, but 5 is a constant in a script, not a derived truth.

**Runner-up: `catalog-repairs-present-SOURCE-GREP`.** It greps for the literal strings
`VIM_PAD + (curLine - 1)` and `gutterRef.current.scrollTop`. That asserts the author
typed those characters — nothing more. It stays green if `LINE_H`'s `20` desyncs from
CSS `--vim-lh`, a desync this summary lists as open.

**The honest shape of the whole suite:** one check executes the evaluator — **102 checks
backed by 121 real invocations** of the shipped `evalCode` (20 baseline + 60 renderer + 40
theme-comparison + 1 broken buffer); the other 21 checks test the transform rather than
execute it. It runs offline, no browser needed — the earlier claim that verifying this
"requires a browser" was wrong and is retired. **Nine of the sixteen verify checks are source greps**, every one
now suffixed `-SOURCE-GREP` so the suite stops presenting a read as a verification.

## Contract deviation (recorded, not hidden)

`prompts/11-task-catalog-two-panel.md` §LIVE EXECUTION says: "Strip `import` lines from
buffer; transform `.render()` → `.toString()`". **That transform was never built**, and
building it would have been wrong: it only works for a program that is a single
expression, which is exactly why sparkline's three statements failed with
`Unexpected token ';'`. What shipped instead runs the example as statements and captures
what `.render()` writes to a mocked `process.stdout`, with an expression-position
fallback. Better than the contract, but a deviation, and no grade recorded it until a
third cold pass asked.

## How to launch in browser

```bash
PORT=3000 BASE_PATH=/ pnpm --filter @workspace/chitra-docs run dev
# Open: http://localhost:3000/
# Navigate: sidebar → any chart (e.g. Line Chart, Bar Chart)
# Two-panel layout renders; ▶ Run re-executes in browser
```

---

## Commit log (this branch)

**The governed run (6 commits)** — `c78a4dd` open session · `9028a3f` CatalogPage +
App.tsx · `0c6abbb` catalog CSS, `@chitra/core` dep, vite fs.allow · `4422238` verify +
demo scripts · `69dcfca` summary + the (invalid) review · `e9ce6b8` closeout.

**The operator repair, after the page was found broken (11 commits)** — `6fa1d67` evaluator
repair · `68bfc51` export `evalCode` · `fd8a5fd` the executable check · `8a46d61` addendum ·
`46117df` per-chart renderer sweep · `1fef5cd` block cursor + stripe offset + gutter sync ·
`fd857bc` make both checks able to fail · `eab613a` retire the self-read review ·
`35c061e` assert the rewrite itself · `643940c` close three unconditional greens ·
`a3c4792` regrade the record in place — plus the record corrections that followed each of
four cold REJECTs.

Run the log for the authoritative list; this section is a summary, not the source of truth:
`git log --oneline main..session-11-catalog-two-panel`

---

## Next session options

1. **Docs live demo** — Run the dev server, exercise the catalog page, fix any visual/UX issues found during browser review. Capture screenshots for the README.
2. **Chart family S12** — Carry the S10 reference-locked line language into `bar`/`sparkline`/`histogram` (next in the backlog).
3. **SVG renderer alignment** — Bring `lineModelToSvg` fully in line with the terminal: color-matched series, `+` x-tick marks, per-series stat boxes.

---

## Operator addendum — post-run browser verification (2026-08-15)

Added by the Vajra S118 dogfood operator **after** this session's agent closed. The
self-report above claimed **8 of 8 SHIPPED** and "Nothing from the acceptance criteria
was omitted". Clicking all 20 chart pages in a real browser showed otherwise.

| # | Agent's claim | Verified reality (before repair) |
|---|---|---|
| 1 | SHIPPED — all 20 charts | **PARTIAL** — the two-panel shell rendered for all 20, but **19 of 20 pages showed an error instead of a chart** |
| 4 | SHIPPED — "evaluator code is correct and complete" | **PARTIAL** — evaluation was genuinely live, but the transform emitted invalid JS for 19 of 20 examples |
| 7 | SHIPPED — verify 14/14 ALL GREEN | **hollow** — all 11 catalog checks were greps for source strings; the suite passed while the page was broken |

**Root causes** (all in `CatalogPage.tsx`, fixed in `6fa1d67`):

1. `applyOverrides` re-emitted the captured closing brace *before* the injected key,
   producing `fn({…}, renderer: "x"})` → `missing ) after argument list` on every
   example that did not already declare a `renderer`/`theme` key.
2. `buildFnBody` wrapped the program in `return ( … )`, valid only for a single
   expression → `Unexpected token ';'` on multi-statement examples (sparkline).
3. `hlTs` chained its regexes, so the string rule re-scanned markup the keyword rule
   had emitted and printed `tok-kw">` as literal buffer text.
4. `Reset` restored the buffer but left a stale/errored preview on screen.

**After repair:** 20 of 20 chart pages render (`exit 0`); editing the buffer and
pressing Run or ⌘/Ctrl+Enter changes the output; a syntax error is caught and shown
with `exit 1`. `check-catalog-examples.ts` (`fd8a5fd`, widened since) executes the real evaluator.
The suite is now **102 checks** (20 examples + 60 renderer runs + 20 injection assertions + output-differs + syntax-catch, with the count pinned so it cannot silently shrink). Falsifiability, measured on both mutation shapes: a wholly no-op `injectOpt` → **81/102**; a no-op INSERT branch only, the exact 19-of-20 shape → **82/102**. `verify-session-11.sh` is now **16/16**.

**The lesson, plainly:** every gate in this session was green and every rule was
followed while the delivered page did not work. Discipline was perfect; fidelity was
not. A check that greps for the presence of code cannot see whether that code runs.
