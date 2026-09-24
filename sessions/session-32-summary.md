# Session 32 — wall-stagger playbook (KNOWLEDGE) (BACKFILLED at S36)

> **Backfilled record.** S32 shipped and merged (PR #38, merge `b66e8e9`, 2026-09-21)
> as a knowledge-only session — one file, `.ai/KNOWLEDGE.md` (+15). It left no prompt,
> verify/demo, summary, or review. Reconstructed at S36 to close the S05
> closeout-integrity debt. Missing scripts/review **explicitly waived** (knowledge-only,
> no code, nothing to verify).

## What shipped

- The **wall-stagger playbook** appended to `.ai/KNOWLEDGE.md`: when a rendered chart
  frame's right wall staggers while its text measures column-uniform, the renderer is
  re-widthing glyphs. The chain: (1) refresh-flash test → webfont swap; (2) canvas
  `measureText` per codepoint per family (JetBrains Mono drew braille `⣿⠿` at 7.52px
  vs 6.6px base; Cascadia Mono held every frame glyph at 6.45px); (3) lead the uniform
  family on the chart-text stack + `font-variant-ligatures: none; font-kerning: none;
  letter-spacing: 0`, placed AFTER any theme font override; (4) prove with pixels —
  screenshot the text body, assert one shared right edge (19/19 @ x=1001, spread 0).

## Evidence

| Item | Value |
|---|---|
| PR | #38 (`ifelse-codes/session-32-wall-playbook`) |
| Merge commit | `b66e8e9` (2026-09-21) |
| Diff | 1 file, +15 (` .ai/KNOWLEDGE.md`) |

## Waivers (explicit)

- verify/demo scripts and independent review — **waived** (knowledge-only, no code).
