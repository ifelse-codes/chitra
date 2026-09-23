# Session 17 — task: lock scatter() to the reference panel language (BACKFILLED)

> **Backfilled contract.** Reconstructed at S36 from merge commit `35376ae` to satisfy
> the closeout prompt↔summary pairing gate. S17 predates the prompt-file convention in
> force today.

## Requirements

1. Re-render `scatter()` in the reference/panel language (dashed frame, eyebrow,
   `+`/`│` guide, `n · x · y · peak` footer).
2. Single-series accents the peak; multi-series accents the **primary group**.
3. Support a decimal y-axis.
4. Add falsifiability tests proving the accent is spent once.
5. Regenerate the docs preview (drift-gated).
6. Add the `### LOCKED: scatter chart` block to `packages/core/README.md`.

## Guardrails

Branch `session-17-scatter-lock`; PR to `main`; core suite stays green.

## Execution

- step 1 — done: bc760f1
- step 2 — done: 38e5593
- step 3 — done: 38e5593
- step 4 — done: 5949192
- step 5 — done: 0af7317
- step 6 — done: bc760f1
