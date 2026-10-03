## What changed

<!-- The why, not the what. Link the issue if there is one. -->

## How was it verified

<!-- A command someone else can run, or "it is a docs-only change". -->

- [ ] `pnpm run format:check` passes (CI runs it)
- [ ] `pnpm --filter @ifelse.codes/chitra run typecheck` passes
- [ ] `pnpm --filter @ifelse.codes/chitra run test` passes — **453** on `main`; a change that
      adds or removes a test says so in the description
- [ ] `pnpm run build` passes from a clean state

## Scope

- [ ] No change under `packages/core/src/charts/`, `renderers/`, or `themes/` — those are
      locked (circular/area, line, and the Darpan-parity chrome are reference-locked)
- [ ] No new runtime dependency (the package ships **zero**)
- [ ] Generated chart previews regenerated if a chart's rendering changed
      (`pnpm --filter @workspace/chitra-docs run gen:charts:check`)
- [ ] `src/version.ts` regenerated if the version changed (`node scripts/sync-version.mjs`)
