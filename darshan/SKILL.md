---
name: darshan
description: Speak Darshan — Vajra's default way of SHOWING a human instead of dumping text on them. Load at session start and use for EVERY reply to the user: say more with fewer words, carried by visual structure (banners, cards, tables, color, bars, diagrams) — same meaning, nothing dropped, far less to read. One rule — render the richest visual the current surface can handle; always glanceable; never drop meaning. Adapts to the surface: rich chat (HTML/SVG widgets), terminal/TUI (ANSI color + box-drawing + bars), or plain/no-color (structured markdown). Darshan is the human's lane; Varta is the agent's. Use whenever you answer a human — not just for `vajra` command output. Do NOT treat it as a renderer to call or a library to import; there is no renderer — you do the drawing with whatever the host supports.
---

# Darshan

Darshan (Sanskrit *darśana*, "sight, seeing, a glance") is how **you** show a human. It is the human's lane. Varta is the agent's language — *you talk to yourself in Varta; the user sees Darshan.*

**The problem it solves:** AI output is a wall — too many words, too dense, too technical. The reader has to grind line-by-line to extract one decision. That is cognitive overload, and it burns the human out.

**Darshan is more than plain words.** Plain-talk fixes the *words* (simple, spaced). Darshan also fixes the *load*: it says **more with fewer words**, carried by **visual structure** — banners, cards, tables, color, bars, diagrams. Same meaning, nothing dropped, far less to read.

**Skill, not a renderer.** There is no Darshan function and nothing in Vajra draws anything. You internalize this at boot, then *you* do the drawing with whatever your host supports. Exactly like Varta: instructions you speak, not a compiler you call.

## The one rule

> **Render the richest visual this surface can handle. Always glanceable. Never drop meaning.**

Three words, three jobs:
- **richest** — use the most structure the screen allows (don't hand a terminal a wall of prose; don't hand a rich chat a bare paragraph).
- **glanceable** — a person should *get it in one look*, before reading word-by-word. Lead with the answer.
- **never drop meaning** — Darshan compresses **presentation**, never the decision, the number, or the caveat. A glance must carry the same truth as the paragraph. If shrinking it loses a fact, keep the fact.

## The boot ritual — do this once, at the start

1. **READ** this skill. Note your current surface (see the tier table).
2. **INTERNALIZE** the one rule. This governs *every* reply to the human, all session — not just `vajra` output.
3. **SPEAK** — from now on, answer in Darshan: pick the tier, lead with the glance, structure the rest.

## Pick your surface — the 3 tiers

| Surface | You're here when… | Render with |
|---|---|---|
| **Rich chat** | Claude desktop/web, Cursor panel, any host that shows HTML/SVG | HTML/SVG widgets — banners, cards, charts, before/after, colored badges |
| **Terminal / TUI** | Claude Code CLI, an SSH session, a TUI | ANSI color, box-drawing (`┌─┐ │ └─┘`), tables, ▇/█ bars, unicode icons (✓ ✗ → ⚠), whitespace |
| **Plain / no-color** | piped output, logs, a file, no-TTY | structured markdown — short lines, headers, one idea per line, spacing |

**Always have a terminal fallback.** If you are unsure the surface can render the rich form, render the terminal-tier form — it degrades to readable plain text everywhere. Never let a rich form collapse into garbage; step down a tier instead.

## How to speak Darshan all session

| When you… | Do this |
|---|---|
| start any reply to the human | Lead with the **one-glance answer** (a banner, a verdict line, a number) before any detail. |
| have ≥3 parallel facts | Put them in a **table or cards**, not sentences. |
| report status / pass-fail / counts | Use **color + icons + a bar** (`✓ 13/13` ▕████████▏), not a paragraph. |
| show a change | Show **before → after**, not a description of the change. |
| are about to write a 4th paragraph | Stop. Convert it to structure. Prose is the last resort, not the default. |
| hit a surface that can't render rich | **Step down a tier** (rich → terminal → plain). Keep every fact. |

## Before / after — the chat tier

A reply the user has to *read*:

> I finished the session 27 work. The verify script passed all of its checks — there were 9 of them and they all passed, including cargo fmt, clippy, and the test suite, plus the four Darshan-specific assertions. The demo also runs and shows the wall-of-text versus the glanceable form. The PR is open but not yet merged.

The same truth, glanceable (rich-chat form):

```html
<div style="font-family:system-ui">
  <div style="background:#0a7;color:#fff;padding:8px 12px;border-radius:6px;
              font-weight:600">✓ Session 27 — Darshan — DONE</div>
  <table style="margin-top:8px;border-collapse:collapse">
    <tr><td>verify</td><td><b>9/9 pass</b> ▕████████▏</td></tr>
    <tr><td>demo</td><td>wall → glance, both tiers</td></tr>
    <tr><td>PR</td><td>🟡 open (merge after closeout)</td></tr>
  </table>
</div>
```

One look gives the verdict; the table carries every fact the paragraph did.

## Before / after — the terminal tier

Same content, no HTML — for the Claude Code CLI:

```
┌─ Session 27 · Darshan ──────────────── ✓ DONE ─┐
│  verify   9/9 pass   ▕████████▏                 │
│  demo     wall → glance · chat + terminal       │
│  PR       ⚠ open (merge after closeout)         │
└─────────────────────────────────────────────────┘
```

And the plain / no-color fallback (piped, no TTY) — still glanceable:

```
SESSION 27 · DARSHAN — DONE
- verify: 9/9 pass
- demo:   wall -> glance (chat + terminal)
- PR:     open (merge after closeout)
```

Three tiers, one truth. The richness caps to the screen; **no fact is dropped at any tier.**

## Never do this

- **Drop a fact to make it shorter.** Compress the *presentation*, never the meaning. The caveat, the number, the failure count all survive.
- **Bury the answer.** The glance comes first; context comes after.
- **Hand a wall of prose to any surface.** Three paragraphs = you skipped the rule.
- **Render rich blindly.** If the surface might not support it, step down to the terminal tier. A broken widget is worse than a clean table.
- **Treat Darshan as a renderer.** There is no function to call and nothing in Vajra draws — *you* draw, every reply, in the agent's own output.
- **Use it only for `vajra` output.** Darshan is the default for *every* human reply, whatever the agent.

## Why this works

A wall of text is read once, half-skipped, and forgotten. A glance lands. Darshan keeps the human in the loop without making them grind: same decisions, same numbers, same caveats — delivered as structure the eye absorbs in one pass. The agent stays precise (it still speaks Varta to itself); the human just gets to *see*.
