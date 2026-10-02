# Contributing to Chitra

Thank you for your interest in contributing to Chitra! This guide will help you get started.

## Development Setup

```bash
# Clone and install
git clone https://github.com/ifelse-codes/chitra.git
cd chitra
pnpm install

# Run tests
pnpm --filter @ifelse.codes/chitra run test

# Run tests with coverage
pnpm --filter @ifelse.codes/chitra run test:coverage

# Typecheck
pnpm --filter @ifelse.codes/chitra run typecheck

# Run examples (no build needed — the examples import from src/)
pnpm example
```

## Project Structure

```
packages/
  core/
    src/
      types.ts          — TypeScript types and interfaces
      ansi.ts           — ANSI color primitives
      utils.ts          — Math and formatting utilities
      plot.ts           — Fluent PlotBuilder API
      version.ts        — GENERATED from package.json; see scripts/sync-version.mjs
      themes/           — Built-in theme definitions
      renderers/        — Braille, blocks, and ASCII engines
      charts/           — Individual chart implementations
    tests/              — Vitest test suite, one file per chart
scripts/
  sync-version.mjs      — regenerates src/version.ts from the manifest
```

## Adding a New Chart Type

1. Create `packages/core/src/charts/<name>.ts`
2. Define your options interface in `packages/core/src/types.ts`
3. Export from `packages/core/src/charts/index.ts`
4. Re-export from `packages/core/src/index.ts`
5. Add a method to `PlotBuilder` in `packages/core/src/plot.ts`
6. Write tests in `packages/core/tests/<name>.test.ts` — one file per chart, named
   after the chart (`bar.test.ts`, `line.test.ts`, …)
7. Add an example in `examples/basic.ts`

### Chart Template

`ChartResult` (`src/types.ts`) requires six members. Omitting `toContent()` is a type
error, not a style choice.

```ts
import type { BaseChartOptions, ChartResult } from "../types.js";
import { resolveTheme } from "../themes/index.js";
import { colorize, stripAnsi } from "../ansi.js";

export interface MyChartOptions extends BaseChartOptions {
  data: number[];
  // ... your options
}

export function myChart(opts: MyChartOptions): ChartResult {
  const theme = resolveTheme(opts.theme);
  const noColor = opts.noColor ?? false;

  function buildLines(): string[] {
    const lines: string[] = [];
    // ... render logic
    return lines;
  }

  const output = buildLines().join("\n");

  return {
    render() { process.stdout.write(output + "\n"); },
    toString() { return output; },
    toPlain() { return stripAnsi(output); },
    // Body only — no frame, no eyebrow, no legend, no summary.
    toContent() { return myChart({ ...opts, frame: false, compact: true }).toPlain(); },
    toMarkdown() { return "```\n" + stripAnsi(output) + "\n```"; },
    toJSON() {
      return {
        type: "myChart",
        data: opts.data,
        plain: stripAnsi(output),
      };
    },
  };
}
```

## Adding a New Theme

In `packages/core/src/themes/index.ts`, add your theme:

```ts
export const themes: Record<ThemeName, Theme> = {
  // ... existing themes
  "my-theme": {
    name: "my-theme",
    colors: [h("#color1"), h("#color2"), ...],
    axis: h("#axisColor"),
    label: h("#labelColor"),
    title: h("#titleColor"),
    grid: h("#gridColor"),
  },
};
```

Also add `"my-theme"` to the `ThemeName` type in `types.ts`.

## Bumping the Version

`packages/core/package.json` is the only place the version lives. After editing it:

```bash
node scripts/sync-version.mjs   # regenerates src/version.ts
```

CI runs `node scripts/sync-version.mjs --check` and fails if you forget. Do not hand-edit
`src/version.ts` — a literal there once shipped to npm as `0.1.0` while the manifest said
`0.3.0`.

## Code Style

- TypeScript strict mode
- No runtime dependencies
- Every exported function must have a corresponding test
- Coverage thresholds are enforced by `vitest.config.ts` and run in CI:
  statements 90, branches 85, functions 85, lines 90. Measured today:
  **96.11 / 87.63 / 86.28 / 96.11**. `test:coverage` exits non-zero below the threshold,
  and `scripts/verify-session-41.sh#contributing-coverage-numbers-real` fails if the
  numbers published here stop matching what coverage measures.
- Use `const` over `let` wherever possible
- Name renderers, charts, and utilities consistently

## Testing

```bash
# Run all tests
pnpm --filter @ifelse.codes/chitra run test

# Run tests in watch mode
pnpm --filter @ifelse.codes/chitra run test:watch

# Coverage report (enforces the thresholds above)
pnpm --filter @ifelse.codes/chitra run test:coverage
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-chart`
3. Write code and tests
4. Ensure all tests pass: `pnpm --filter @ifelse.codes/chitra run test`
5. Ensure typecheck passes: `pnpm --filter @ifelse.codes/chitra run typecheck`
6. Open a PR against `main`

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` — new feature or chart type
- `fix:` — bug fix
- `perf:` — performance improvement
- `docs:` — documentation update
- `test:` — adding/fixing tests
- `refactor:` — code refactor
- `chore:` — build/CI changes

## Versioning

We follow [Semantic Versioning](https://semver.org/):

- MAJOR: breaking API changes
- MINOR: new charts, renderers, or themes
- PATCH: bug fixes and performance improvements

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
