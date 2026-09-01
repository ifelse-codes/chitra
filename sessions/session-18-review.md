# Session 18 — Independent Fidelity Review (cold pass)

**Reviewer:** cold pass over the contract (`prompts/18-task-heatmap-lock.md`) + the
delivery diff, dispatched to the `fidelity-reviewer` role. Every verdict is backed by an
executable check from `scripts/verify-session-18.sh` (8/8 ALL GREEN) or by reading the
delivered source against the reference (`scatter.ts` + the LOCKED scatter README block).

**Review-Inputs-SHA:** dbe931d60c73b5a7587cd56dc04fe2407b55c6a397fb9eb808d7c6caec491aec

## Per-requirement verdicts

| # | Requirement (from the prompt) | Verdict | Evidence |
|---|---|---|---|
| 1 | Replace the blue→orange→red rainbow (`HEAT_COLORS_DARK`) with the documented grey tone ramp `#ECECEF→#C6C6CE→#A4A4AE→#6A6A75` as the intensity encoding (light→dark); never a `theme.colors[i%n]` rainbow | SHIPPED | `heatmap.ts` colours cells with `tones[idx]` (= `GREY_TONES`); `HEAT_COLORS_DARK` has zero source hits (`no-rainbow-in-source` PASS); test pins the ramp to the literal spec hexes |
| 2 | ONE accent hue, spent EXACTLY once, on the max-value cell (ties → first in row-major, deterministic) | SHIPPED | row-major scan with strict `>` records the first max cell; only that cell painted in `acc`; raw-ANSI census asserts `accent===1` across normal, tie, and zero-variance grids |
| 3 | Same panel language: dashed frame `┌╌…╌┐`, uppercase eyebrow, `│`/`+` guide, two `│ ╌…╌ │` rule separators | SHIPPED | uses shared `frameTop/frameRule×2/frameRow/frameBottom`; eyebrow `DENSITY`; `+` on top grid row, `│` below; tests assert `┌╌`, `└╌`, exactly two rules, eyebrow, and row-anchored guide |
| 4 | Summary footer `rows×cols · min..max · peak (r,c)` with peak coords in the accent | SHIPPED | footer head in label colour, `peak (r, c)` in accent; test matches `4×5 · 1..12 · peak (3, 4)` from real data |
| 5 | Empty grid → framed `n 0`, no Infinity/NaN; all-equal grid → collapsed range | SHIPPED | min/max guarded to 0 on empty, span forced to 1 on equal; empty → `n 0`, grid skipped; tests assert `n 0`, no `NaN|Infinity`, and `2×2 · 5..5 · peak (0, 0)` |
| 6 | README `### LOCKED: heatmap chart — session 18 design` block mirroring the scatter block | SHIPPED | block present (`readme-lock-block` PASS): ramp, one-accent-once, panel chrome, footer, degenerate safety |
| 7 | Falsifiability tests: accent-once raw-ANSI census, ramp is the documented grey ramp, empty/degenerate safe | SHIPPED | `accentCensus` categorises each cell segment accent/grey/other and asserts `other===0` (a `colors[i%n]` leak lands in `other` and fails); 15 heatmap tests green; full core suite 192/192 |

## Honest limits

- Same-agent review; the attestation binds the verdict to the prompt bytes + delivery
  diff per DECISION-003 (bar-raising, not tamper-proof).
- The ramp-identity assertion was hardened this session (commit `e2b6bb9`) to pin the
  literal spec hexes rather than assert the ramp against the same module the chart reads.
- The founder signed off on the rendered heatmap separately (design authority remains the
  founder's; this review attests the build matches the written contract).

**Verdict:** ACCEPT
