<div align="center">

# chitra

**Terminal charts for CLIs and agents.**

Beautiful, zero-dependency charts rendered as text — for your terminal, your CI
logs, and the language models reading them.

[![npm](https://img.shields.io/badge/npm-%40ifelse.codes%2Fchitra-blue)](https://www.npmjs.com/package/@ifelse.codes/chitra)
[![license: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![dependencies: 0](https://img.shields.io/badge/dependencies-0-brightgreen)](packages/core/package.json)
[![charts: 20](https://img.shields.io/badge/charts-20-blue)](packages/core/README.md)
[![tests: 453 passing](https://img.shields.io/badge/tests-453%20passing-brightgreen)](packages/core/tests)

[Docs](https://chitra.iifelse.com) · [Chart gallery](https://chitra.iifelse.com) · [AI data reference](https://chitra.iifelse.com/ai-data) · [API reference](packages/core/README.md)

</div>

---

```ts
import { line } from "@ifelse.codes/chitra";

line({
  data: [12, 19, 14, 27, 22, 34, 29, 41],
  title: "Weekly active users",
}).render();
```

```text
┌╌ Weekly active users ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
│ ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ │
│ TREND                                                                    │
│ ──*── Series 1                                                           │
│ 41+                                                                ⢀⠔⠊   │
│   │                                                               ⡰⠁     │
│ 36│                                               ⢀⣀⡀           ⢀⠎       │
│   │                                             ⡠⠊⠁ ⠈⠑⠢⡀       ⡔⠁        │
│ 30│                                           ⢀⠎       ⠈⠒⢄⣀ *⠤⠊          │
│   │                            ⣀⠤⣀⡀          ⡰⠁            ⠉             │
│ 25│                          ⡠⠊   ⠈⠒⢄      ⢀⠎                            │
│   │                        ⢀⠎        ⠑⠢⢄⣀*⠔⠁                             │
│ 20│                       ⡰⠁                                             │
│   │      ⡠⠔⠉⠉⠉⠑⠢⢄       ⢀⠜                                               │
│ 15│   ⢀⠔⠉        ⠑⠢⣀  ⢀⡠⠊                                                │
│ 12│*⠤⠊⠁             ⠉⠉*                                                  │
│         +        +         +        +         +        +         +       │
│        1         2        3         4        5         6        7        │
│ * Series 1 · lowest 12 · highest 41 · avg 24.75 · last 41  ▁▃▃▁▅▅▃▆▆▅██  │
└╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘
```

> Chart output in this README is shown without ANSI colour; a real terminal
> renders the same glyphs in full colour.

## Why chitra

| | |
|---|---|
| **AI-agent native** | `toContent()`, `toPlain()` and `toJSON()` hand models clean chart output — no ANSI escape noise to strip. |
| **20 chart types** | line, bar, area, sparkline, histogram, scatter, pie, donut, heatmap, progress, gauge, timeline, radar, boxplot, waterfall, funnel, candlestick, treemap, sankey, horizontal bar. |
| **3 renderers** | Braille (4× resolution), Unicode blocks (broad support), ASCII (SSH and log files). |
| **7 themes** | default, nord, dracula, github-dark, tokyo-night, solarized, monochrome. |
| **Zero dependencies** | ANSI colour, braille math and layout are self-contained. Nothing to audit, nothing to break. |
| **TypeScript-first** | Complete types, strict mode, ESM + CJS builds. No `@types/` package needed. |

## Install

```bash
# From npm
pnpm add @ifelse.codes/chitra

# From source
git clone https://github.com/ifelse-codes/chitra.git
cd chitra && pnpm install && pnpm --filter @ifelse.codes/chitra build
```

Requires Node.js 18+ and any Unicode-capable terminal.

## Quickstart

```ts
import { horizontalBar } from "@ifelse.codes/chitra";

horizontalBar({
  data: [82, 64, 51, 37, 22],
  labels: ["TypeScript", "Rust", "Go", "Python", "Shell"],
  title: "Repo languages",
}).render();
```

```text
┌╌ Repo languages ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
│ ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ │
│ VALUES                           │
│ TypeScript ██████████████████ 82 │
│ Rust       ██████████████     64 │
│ Go         ███████████▂       51 │
│ Python     ████████▁          37 │
│ Shell      ████▇              22 │
│            +╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌+    │
│            0               82    │
│ 5 items · peak TypeScript (82)   │
└╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘
```

Every chart returns a `ChartResult` — one render, five outputs:

```ts
const chart = horizontalBar({ data: [82, 64, 51, 37, 22] });

chart.render();       // → stdout, ANSI colour
chart.toString();     // → ANSI string
chart.toContent();    // → compact, frame-less text (smallest LLM footprint)
chart.toPlain();      // → full plain text, no escape codes
chart.toJSON();       // → structured facts + the plain render
chart.toMarkdown();   // → fenced code block
```

## Built for AI agents

ANSI colour is great for a terminal and noise for a model. chitra's export
methods give an agent the chart without the escape codes — and a structured
shape it can branch on.

```ts
import { bar } from "@ifelse.codes/chitra";

const chart = bar({
  data: [42, 67, 38],
  labels: ["Q1", "Q2", "Q3"],
  title: "Quarterly revenue",
  noColor: true,
});

chart.toContent(); // compact text → drop straight into an LLM prompt
chart.toJSON();    // { type: "bar", data: [42, 67, 38], labels: [...], plain: "..." }
```

MCP tool handler — **not shipped yet.** Deferred until a release draws an actual request
for it. Shown here to document the intended shape, not to advertise a working feature:

```ts
import { plot } from "@ifelse.codes/chitra";

server.tool("render_chart", async ({ type, data, labels, title }) => {
  const builder = plot(data).title(title).labels(labels).noColor();
  const chart =
    type === "bar" ? builder.bar() :
    type === "line" ? builder.line() : builder.pie();

  return { content: [{ type: "text", text: chart.toContent() }] };
});
```

Every chart's `toJSON()` shape, the null-on-empty and true-value-on-clamp rules,
and the untrusted-input guardrail live in the **[AI data reference](https://chitra.iifelse.com/ai-data)**.

## Built for terminals

```ts
import { sparkline, plot } from "@ifelse.codes/chitra";

// Inline sparkline for a live dashboard
sparkline({ data: [3, 5, 4, 8, 6, 11, 9, 13, 12, 15], label: "p99 latency" }).render();

// Fluent API — one chain, all 20 charts
plot([42, 67, 38, 55, 72])
  .labels(["Mon", "Tue", "Wed", "Thu", "Fri"])
  .title("Deploys")
  .theme("tokyo-night")
  .bar()
  .render();
```

```text
┌╌ p99 latency ╌╌╌╌╌╌╌╌╌┐
│ ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ │
│ SPARKLINE             │
│               ██  ██  │
│           ▓▓▓▓██████  │
│   ░░  ▒▒▒▒▓▓▓▓██████  │
│ ░░░░░░▒▒▒▒▓▓▓▓██████  │
│ 10 readings · peak 15 │
└╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘
```

## Chart gallery

| Category | Charts |
|---|---|
| Trend & time | line · area · timeline · candlestick |
| Comparison | bar · horizontal bar · scatter · radar |
| Distribution & density | histogram · boxplot · heatmap |
| Part-to-whole | pie · donut · treemap · funnel |
| Flow & accumulation | sankey · waterfall |
| Single value & progress | gauge · progress · sparkline |

See every chart rendered live at **[chitra.iifelse.com](https://chitra.iifelse.com)**.

## Documentation

- **[Docs site](https://chitra.iifelse.com)** — quickstart, fluent API, and a page per chart
- **[AI data reference](https://chitra.iifelse.com/ai-data)** — per-chart `toJSON()` shapes and the MCP guardrail
- **[API reference](packages/core/README.md)** — every option and the locked design language
- **[Contributing](CONTRIBUTING.md)**

## License

MIT — see [LICENSE](LICENSE).
