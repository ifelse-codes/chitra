# Session 31 — task: antra design atoms into chitra-docs

Founder direction (in-chat, S31): make the chitra docs site feel more
like the antra website — export design elements from
`antra/landing/index.html` (static single-file site, no framework).

## Numbered requirements

1. **Namespaced violet tokens.** `--antra-violet` `#8B7CF6`,
   `--antra-violet-bright` `#B7AEFF`, `--antra-fill`, `--antra-hairline`,
   `--antra-line` on the live `:root` — zero collisions with theater vars.
2. **Eyebrow.** Antra `◆` + mono caps (`0.22em`) on the hero kicker and
   section headings.
3. **Hero accent.** The hero accent word goes solid
   `--antra-violet-bright` (antra `em`), replacing the gradient.
4. **Install strip.** Click-to-copy `pnpm add @chitra/core` hero command
   with `copy → ✓ copied!` swap (antra install-block micro-interaction).
5. **Hairline route grid.** Route cards convert to the 1px-gap hairline
   grid (antra problem/features grids); chart cards keep chitra's own
   per-accent hover system.
6. **Topbar + footer.** Topbar links go mono uppercase with violet hover
   (antra nav); a new global hairline footer (mono caps + links) pins
   below the app shell.
7. **Reveal motion.** IntersectionObserver `.reveal → .visible` on home
   grids/headings, with `prefers-reduced-motion` guard (no mandalas).
8. **Gates.** Typecheck + docs build green; drift gate green;
   `scripts/verify-session-31.sh` green; `scripts/demo-session-31.sh`
   green; redeploy to `chitra.iifelse.com`.

## Founder follow-ups (grown in-session, same bar)

9. **Atmosphere.** Violet top glow + 32px grid lines + wandering mandala
   wisps (max 2, 4 SVG designs, reduced-motion guarded, no layout impact).
10. **Editor chrome.** Blur toolbar, violet Run, 0.22em labels, violet
    active tab + `$` chip.
11. **Hero rotation.** 6 chart variants of FIXED outer dims
    (`src/data/hero-charts.json`, each exactly 19 visible lines × 64
    visible cols, drift-gated) rotating every 3s with instant cut; mac
    box hugs content; 8ch right buffer against font variance.
12. **Wall fix.** Frame right wall pixel-straight on all 6 variants
    (uniform glyph advances, verified by measurement, not eyeball).
