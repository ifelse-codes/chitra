import { useState } from "react";
import { useLocation } from "wouter";
import { CHARTS } from "./data/charts";
import { ansiToHtml } from "./ansi";
import ansiCharts from "./data/ansi-charts.json";
import svgCharts from "./data/svg-charts.json";
import { CatalogPage } from "./components/CatalogPage";

const ANSI = ansiCharts as Record<string, string>;

// Use cases + key options per chart — "why would I use this?" context
interface ChartMeta { uses: string[]; options: { name: string; desc: string }[] }
const CHART_META: Record<string, ChartMeta> = {
  line: {
    uses: ["Trend over time — revenue, signups, latency","Comparing two series side-by-side","Braille renderer gives 4× resolution for smooth curves"],
    options: [{ name:"renderer", desc:'"braille" | "blocks" | "ascii" — controls curve resolution' },{ name:"width / height", desc:"Grid dimensions in terminal columns/rows" },{ name:"title", desc:"Optional chart title printed above the chart" }],
  },
  bar: {
    uses: ["Comparing discrete categories — monthly sales, team metrics","Ranking items when order matters","Quick at-a-glance column comparison"],
    options: [{ name:"labels", desc:"Category labels shown on the x-axis" },{ name:"height", desc:"Bar height in terminal rows (default 10)" },{ name:"width", desc:"Total chart width in columns" }],
  },
  area: {
    uses: ["Volume/accumulation over time — requests, bytes, events","Makes the magnitude of change more visible than a line","Good for showing filled volume between a baseline and a trend"],
    options: [{ name:"renderer", desc:'"braille" gives smooth filled area; "blocks" for compatibility' },{ name:"width / height", desc:"Grid dimensions" },{ name:"theme", desc:'Use "nord", "dracula", "github-dark", "tokyo-night", "solarized", or "monochrome"' }],
  },
  sparkline: {
    uses: ["Live dashboard metrics — CPU, memory, network, disk at a glance","Inline status in CLI output, log files, or monitoring scripts","Multiple sparklines stacked = a full system monitor in 6 lines"],
    options: [{ name:"renderer", desc:'"blocks" (default), "braille" (smooth), "ascii" (broadest compat)' },{ name:"label", desc:"Prefix label printed before the sparkline" },{ name:"showValue", desc:"Appends the last data point value after the sparkline" }],
  },
  histogram: {
    uses: ["Understanding the shape of a distribution — latency p50/p90/p99","Spotting bimodal patterns or outliers in a dataset","Frequency of events across value buckets"],
    options: [{ name:"bins", desc:"Number of buckets (default 10)" },{ name:"height", desc:"Bar height in rows" },{ name:"width", desc:"Total chart width in columns" }],
  },
  scatter: {
    uses: ["Correlation between two variables — error rate vs traffic load","Outlier detection — which points are far from the cluster","Cluster visualization before/after a change"],
    options: [{ name:"data", desc:"Array of {x, y} objects — not separate x/y arrays" },{ name:"width / height", desc:"Plot canvas dimensions" },{ name:"renderer", desc:'"braille" gives finest dot resolution for dense scatter' }],
  },
  pie: {
    uses: ["Part-to-whole breakdowns — traffic sources, error types","Small number of categories (≤6 works best)","When relative proportions matter more than exact values"],
    options: [{ name:"data", desc:"Array of numbers — each slice's value" },{ name:"labels", desc:"Slice labels shown in the legend" },{ name:"theme", desc:"Controls the fill characters (█ ▓ ▒ ░ ▪)" }],
  },
  donut: {
    uses: ["Same as pie but the hollow center can show a KPI number","Cleaner visual when slices are similar in size","Primary metric in the center draws the eye first"],
    options: [{ name:"data", desc:"Array of numbers" },{ name:"labels", desc:"Slice labels for the legend" },{ name:"centerText", desc:"Optional string rendered in the hollow center" }],
  },
  heatmap: {
    uses: ["Activity by hour/day — GitHub commit heatmap style","Correlation matrices — which cells are hot?","Spotting time-of-day patterns in 2D data"],
    options: [{ name:"data", desc:"2D array — data[row][col]" },{ name:"width / height", desc:"Grid dimensions in columns/rows" },{ name:"theme", desc:"Controls the density characters (░▒▓█)" }],
  },
  progress: {
    uses: ["Build status, test coverage, bundle size in CI output","Multiple metrics side-by-side in a dashboard","Sub-block precision (▁▂▃…) shows exact partial fill"],
    options: [{ name:"value", desc:"Current value (number)" },{ name:"min / max", desc:"Scale bounds (default 0–100)" },{ name:"label", desc:"Left-aligned label before the bar" }],
  },
  gauge: {
    uses: ["Single KPI that lives in a 0–100 range — CPU load, disk fill","Shows both current value and how far to maximum","Alternative to progress bar when you want a linear meter format"],
    options: [{ name:"value", desc:"Current reading" },{ name:"min / max", desc:"Scale bounds" },{ name:"label", desc:"Label printed below the gauge" }],
  },
  horizontalBar: {
    uses: ["Ranked lists — top languages, most-used endpoints","Long category labels that would be clipped on a vertical bar","Sorting by value makes relative size obvious at a glance"],
    options: [{ name:"data", desc:"Array of numbers" },{ name:"labels", desc:"Row labels — can be long strings" },{ name:"width", desc:"Total chart width including label column" }],
  },
  timeline: {
    uses: ["Gantt charts for sprint planning or release pipelines","Overlapping phases — shows which tasks run in parallel","Simple project schedules without a full Gantt tool"],
    options: [{ name:"events", desc:"Array of {label, start, end} — numeric time units" },{ name:"width", desc:"Total chart width; time scale is derived automatically" },{ name:"title", desc:"Optional title above the chart" }],
  },
  radar: {
    uses: ["Multi-axis comparison — system health across 5–8 dimensions","Performance benchmarks across multiple criteria","Team capability mapping or product feature scoring"],
    options: [{ name:"data", desc:"Array of values — one per axis" },{ name:"labels", desc:"Axis labels — length must match data" },{ name:"width", desc:"Canvas width; radar is square so height follows" }],
  },
  boxplot: {
    uses: ["Statistical summary — median, IQR, whiskers in one view","Comparing distributions across groups (A/B test results)","Spotting skew, outliers, and spread without a histogram"],
    options: [{ name:"data", desc:"2D array — each inner array is [min, q1, median, q3, max]" },{ name:"labels", desc:"Group labels" },{ name:"width / height", desc:"Canvas dimensions" }],
  },
  waterfall: {
    uses: ["P&L breakdowns — revenue minus expenses shows net","Cumulative effect of sequential changes on a baseline","Bridge charts for explaining how you got from A to B"],
    options: [{ name:"data", desc:"Array of numbers — positive adds, negative subtracts" },{ name:"labels", desc:"Step labels" },{ name:"showTotal", desc:"Appends a totals bar at the end" }],
  },
  funnel: {
    uses: ["Conversion funnels — visitors → signups → paid","Drop-off analysis across pipeline stages","Any sequential process where volume decreases each step"],
    options: [{ name:"data", desc:"Descending array of values — each stage's count" },{ name:"labels", desc:"Stage names" },{ name:"width", desc:"Total chart width" }],
  },
  candlestick: {
    uses: ["OHLC price data — stocks, crypto, any financial instrument","Spotting bullish/bearish sessions at a glance","Period summaries where open/close direction matters"],
    options: [{ name:"data", desc:"Array of {open, high, low, close, label}" },{ name:"height", desc:"Canvas height in rows" },{ name:"width", desc:"Canvas width — determines bar spacing" }],
  },
  treemap: {
    uses: ["Hierarchical data where area encodes size — disk usage, codebase","Comparing many items at once when rank order isn't enough","Portfolio or budget breakdowns across categories"],
    options: [{ name:"data", desc:"Array of {label, value} — sorted descending for best layout" },{ name:"width / height", desc:"Canvas dimensions" },{ name:"title", desc:"Optional title above the treemap" }],
  },
  sankey: {
    uses: ["Flow between nodes — traffic sources → pages → conversions","Budget allocation across departments","Any many-to-many flow where you want to see volume on each path"],
    options: [{ name:"nodes", desc:"Array of node name strings" },{ name:"links", desc:"Array of {source, target, value} — source/target are node indices" },{ name:"width", desc:"Total chart width" }],
  },
};

// Per-chart accent colors
const CHART_ACCENT: Record<string, string> = {
  line: "blue", bar: "green", area: "purple", sparkline: "cyan",
  histogram: "green", scatter: "blue", pie: "amber", donut: "pink",
  heatmap: "teal", progress: "cyan", gauge: "indigo", horizontalBar: "green",
  timeline: "pink", radar: "indigo", boxplot: "purple", waterfall: "amber",
  funnel: "teal", candlestick: "amber", treemap: "blue", sankey: "purple",
};

const NAV_SECTIONS = [
  { label: "Start Here", items: ["install", "quickstart", "fluent-api"] },
  { label: "Chart Types", items: CHARTS.map((c) => c.id) },
  { label: "Agent Output", items: ["ai-output"] },
];

function hl(code: string): string {
  return code
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    .replace(/(\/\/[^\n]*)/g, '<span class="tok-comment">$1</span>')
    .replace(/\b(import|from|export|const|let|var|function|return|if|else|for|of|in|async|await|true|false|null|undefined|type|interface)\b/g, '<span class="tok-kw">$1</span>')
    .replace(/("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|`(?:[^`\\]|\\.)*`)/g, '<span class="tok-str">$1</span>')
    .replace(/\b(\d+(?:\.\d+)?)\b/g, '<span class="tok-num">$1</span>')
    .replace(/\b([A-Z][A-Za-z0-9_]*)\b/g, '<span class="tok-type">$1</span>')
    .replace(/\b([a-z][A-Za-z0-9_]*)\s*\(/g, '<span class="tok-fn">$1</span>(');
}

function CodeBlock({ code, lang = "typescript" }: { code: string; lang?: string }) {
  const [copied, setCopied] = useState(false);
  const copy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 1800);
  };
  return (
    <div className="code-block">
      <div className="code-block-header">
        <span className="code-lang">{lang}</span>
        <button className="copy-btn" onClick={copy}>
          {copied ? "✓ Copied!" : "Copy"}
        </button>
      </div>
      <pre dangerouslySetInnerHTML={{ __html: hl(code) }} />
    </div>
  );
}

function Terminal({ id, plain }: { id?: string; plain?: string }) {
  const html = id && ANSI[id] ? ansiToHtml(ANSI[id]) : null;
  return (
    <div className="terminal">
      <div className="terminal-bar">
        <div className="dots">
          <span className="dot r" /><span className="dot y" /><span className="dot g" />
        </div>
        <span className="terminal-title">chitra — terminal</span>
      </div>
      {html
        ? <pre className="terminal-body colored" dangerouslySetInnerHTML={{ __html: html }} />
        : <pre className="terminal-body">{plain ?? ""}</pre>
      }
    </div>
  );
}

function SvgChart({ id }: { id: string }) {
  const svg = (svgCharts as Record<string, string | undefined>)[id];
  if (!svg) return null;
  return (
    <div className="svg-chart" aria-label={`${id} chart rendered as SVG`}>
      <div className="svg-chart-bar">
        <div className="dots">
          <span className="dot r" /><span className="dot y" /><span className="dot g" />
        </div>
        <span className="terminal-title">chitra — web</span>
      </div>
      <div className="svg-chart-body" dangerouslySetInnerHTML={{ __html: svg }} />
    </div>
  );
}

function AccentChip({ accent }: { accent: string }) {
  return <span className={`accent-chip chip-${accent}`}>{accent}</span>;
}

function RouteCard({
  title,
  detail,
  cta,
  onClick,
}: {
  title: string;
  detail: string;
  cta: string;
  onClick: () => void;
}) {
  return (
    <button className="route-card" onClick={onClick}>
      <span className="route-title">{title}</span>
      <span className="route-detail">{detail}</span>
      <span className="route-cta">{cta}</span>
    </button>
  );
}

/* ── Page: Install ──────────────────────────────────────────── */
function InstallPage() {
  return (
    <div className="page">
      <div className="page-header">
        <div className="page-eyebrow">Getting Started</div>
        <h1>Installation</h1>
        <p className="lead">Install the TypeScript terminal chart library with no runtime dependency chain.</p>
      </div>
      <h2>Package managers</h2>
      <CodeBlock lang="bash" code={`npm install @chitra/core\npnpm add @chitra/core\nyarn add @chitra/core`} />
      <h2>Requirements</h2>
      <ul>
        <li>Node.js 18 or later</li>
        <li>TypeScript 5+ for full type safety (optional)</li>
        <li>Any Unicode-capable terminal, with ASCII fallback when needed</li>
      </ul>
      <h2>Module format</h2>
      <p>Typed ESM imports are the primary path. Full TypeScript types are included, with no <code>@types/</code> package needed.</p>
      <CodeBlock code={`import { bar } from "@chitra/core";\n// Full type inference — no @types/chitra needed\nbar({ data: [1, 2, 3] }).render();`} />
    </div>
  );
}

/* ── Page: Quickstart ───────────────────────────────────────── */
function QuickstartPage() {
  return (
    <div className="page">
      <div className="page-header">
        <div className="page-eyebrow">Getting Started</div>
        <h1>Quickstart</h1>
        <p className="lead">Render a chart, choose a renderer, then reuse the same result in terminals, Markdown, logs, and agents.</p>
      </div>
      <CodeBlock code={`import { bar, line, sparkline } from "@chitra/core";\n\n// Vertical bar chart\nbar({\n  data: [42, 67, 38, 55, 72],\n  labels: ["Jan", "Feb", "Mar", "Apr", "May"],\n  title: "Monthly Deployments",\n  theme: "tokyo-night",\n}).render();\n\n// Braille line chart — sub-character precision\nline({\n  data: [10, 20, 15, 35, 28, 45, 38, 52],\n  title: "Revenue",\n  renderer: "braille",\n}).render();\n\n// Inline sparkline — perfect for dashboards\nsparkline({\n  data: [1, 4, 2, 7, 3, 9, 5, 11, 8],\n  label: "CPU",\n  showValue: true,\n}).render();`} />
      <h2>ChartResult interface</h2>
      <p>Every chart function returns a <code>ChartResult</code> — five output methods for any context:</p>
      <CodeBlock code={`const chart = bar({ data: [1, 2, 3] });\n\nchart.render();       // → stdout with ANSI colors\nchart.toString();     // → ANSI string\nchart.toPlain();      // → plain text, no escape codes\nchart.toMarkdown();   // → fenced code block\nchart.toJSON();       // → { type, data, plain, ... }`} />
      <h2>Themes</h2>
      <CodeBlock code={`// 7 built-in themes\n"default" | "nord" | "dracula" | "github-dark" | "tokyo-night" | "solarized" | "monochrome"`} />
    </div>
  );
}

/* ── Page: Fluent API ───────────────────────────────────────── */
function FluentPage() {
  return (
    <div className="page">
      <div className="page-header">
        <div className="page-eyebrow">Getting Started</div>
        <h1>Fluent API</h1>
        <p className="lead"><code>plot(data)</code> keeps shared options together, then renders the final chart type at the end of the chain.</p>
      </div>
      <CodeBlock code={`import { plot } from "@chitra/core";\n\n// Chain options, call chart type last\nplot([18, 32, 27, 48, 39, 61, 52, 74])\n  .title("Revenue Growth")\n  .theme("tokyo-night")\n  .width(60)\n  .height(14)\n  .renderer("braille")\n  .line()\n  .render();\n\nplot([42, 67, 38, 55, 72])\n  .labels(["Jan", "Feb", "Mar", "Apr", "May"])\n  .title("Deploys")\n  .bar()\n  .render();`} />
      <h2>All builder methods</h2>
      <CodeBlock code={`plot(data)\n  // Metadata\n  .title(string)\n  .labels(string[])\n  .label(string)          // sparkline label\n\n  // Appearance\n  .theme("default" | "nord" | "dracula" | "github-dark" | "tokyo-night" | "solarized" | "monochrome")\n  .renderer("braille" | "blocks" | "ascii")\n  .width(number)\n  .height(number)\n  .noColor()              // strip ANSI — for LLMs / CI logs\n\n  // Chart type (call last)\n  .line()        .bar()         .area()        .sparkline()\n  .histogram()   .scatter()     .pie()         .donut()\n  .heatmap()     .progress()    .gauge()       .horizontalBar()\n  .timeline()    .radar()       .boxplot()     .waterfall()\n  .funnel()      .candlestick() .treemap()     .sankey()`} />
    </div>
  );
}

/* ── Page: AI Agents ────────────────────────────────────────── */
function AiPage() {
  return (
    <div className="page">
      <div className="page-header">
        <div className="page-eyebrow">Reference</div>
        <h1>AI Agent Support</h1>
        <p className="lead">Use the same chart result in a terminal, then hand plain text or JSON to LLMs and MCP tools.</p>
      </div>
      <p>ANSI escape codes are great for terminals and noisy for language models. Chitra's <code>noColor</code>, <code>toPlain()</code>, and <code>toJSON()</code> paths keep agent output readable without a post-processing step.</p>
      <h2>noColor + toPlain</h2>
      <CodeBlock code={`import { bar } from "@chitra/core";\n\nconst chart = bar({\n  data: [42, 67, 38],\n  labels: ["Q1", "Q2", "Q3"],\n  title: "Quarterly Revenue",\n  noColor: true,          // skip ANSI at generation time\n});\n\n// Pass directly to any LLM or agent:\nconst text = chart.toPlain();\nconst json  = chart.toJSON();\n// { type: "bar", title: "Quarterly Revenue",\n//   data: [42, 67, 38], labels: [...], plain: "..." }`} />
      <h2>MCP tool handler</h2>
      <CodeBlock code={`import { plot } from "@chitra/core";\n\nserver.tool("render_chart", async ({ type, data, labels, title }) => {\n  const builder = plot(data)\n    .title(title)\n    .labels(labels)\n    .noColor();\n\n  const result =\n    type === "bar"  ? builder.bar()  :\n    type === "line" ? builder.line() :\n    type === "pie"  ? builder.pie()  : builder.bar();\n\n  return {\n    content: [{ type: "text", text: result.toPlain() }]\n  };\n});`} />
    </div>
  );
}

/* ── Page: Chart detail — two-panel catalog view ──────────────── */
function ChartPage({ id }: { id: string }) {
  const chart = CHARTS.find((c) => c.id === id);
  if (!chart) return null;
  return <CatalogPage chart={chart} />;
}

/* ── Hero ───────────────────────────────────────────────────── */
function Hero({ onNav }: { onNav: (id: string) => void }) {
  return (
    <div className="hero">
      <div className="hero-inner">
        <div className="hero-main">
          <div className="hero-copy">
        <div className="hero-eyebrow">
          <span className="hero-kicker"><span className="hero-kicker-dot" />A clear view of your data</span>
          <span className="pill"><span className="pill-dot" />v0.1.0 — stable</span>
          <span className="pill">MIT License</span>
          <span className="pill">Zero runtime deps</span>
          <span className="pill">TypeScript-first</span>
        </div>

        <h1 className="hero-title">
          Terminal charts<br />
          <span className="grad">for CLIs and agents.</span>
        </h1>

        <p className="hero-desc">
          Twenty generated chart previews, three renderers, and clean output methods
          for terminals, CI logs, Markdown, MCP tools, and LLM workflows.
        </p>

        <div className="hero-stats">
          <div className="stat"><span className="stat-num">20</span><span className="stat-label">Chart types</span></div>
          <div className="stat"><span className="stat-num">3</span><span className="stat-label">Renderers</span></div>
          <div className="stat"><span className="stat-num">7</span><span className="stat-label">Themes</span></div>
          <div className="stat"><span className="stat-num">134</span><span className="stat-label">Tests passing</span></div>
          <div className="stat"><span className="stat-num">0</span><span className="stat-label">Dependencies</span></div>
        </div>

        <div className="hero-actions">
          <button className="btn-primary" onClick={() => onNav("install")}>
            Get started →
          </button>
          <button className="btn-secondary" onClick={() => onNav("quickstart")}>
            First chart
          </button>
          <button className="btn-secondary" onClick={() => onNav("line")}>
            Browse charts
          </button>
        </div>
          </div>

          <div className="hero-terminal-wrap">
            <Terminal id="line" />
          </div>
        </div>

        <div className="route-grid">
          <RouteCard
            title="Install"
            detail="Package managers, runtime expectations, and typed imports."
            cta="Start here"
            onClick={() => onNav("install")}
          />
          <RouteCard
            title="Quickstart"
            detail="Render a bar, line, and sparkline with the ChartResult API."
            cta="Copy code"
            onClick={() => onNav("quickstart")}
          />
          <RouteCard
            title="AI output"
            detail="Use noColor, toPlain, and toJSON in MCP-style tool results."
            cta="View reference"
            onClick={() => onNav("ai-output")}
          />
        </div>

        <div className="features-strip">
          <div className="feature-item">
            <div className="feature-icon">⬡</div>
            <div className="feature-title">Braille renderer</div>
            <div className="feature-desc">4× resolution over block characters — smooth curves with Unicode Braille patterns (⠀–⣿).</div>
          </div>
          <div className="feature-item">
            <div className="feature-icon">🤖</div>
            <div className="feature-title">AI-agent ready</div>
            <div className="feature-desc"><code>toPlain()</code> and <code>toJSON()</code> give LLMs clean, readable chart output without ANSI noise.</div>
          </div>
          <div className="feature-item">
            <div className="feature-icon">◎</div>
            <div className="feature-title">Zero dependencies</div>
            <div className="feature-desc">ANSI colors, Braille math, and all renderers are self-contained — nothing to install beyond the package.</div>
          </div>
          <div className="feature-item">
            <div className="feature-icon">⚡</div>
            <div className="feature-title">Fluent API</div>
            <div className="feature-desc"><code>plot(data).title("...").theme("tokyo-night").bar().render()</code> — all 20 charts from one chainable builder.</div>
          </div>
          <div className="feature-item">
            <div className="feature-icon">🎨</div>
            <div className="feature-title">7 themes</div>
            <div className="feature-desc">Default, Nord, Dracula, GitHub Dark, Tokyo Night, Solarized, and Monochrome.</div>
          </div>
          <div className="feature-item">
            <div className="feature-icon">🔡</div>
            <div className="feature-title">3 renderers</div>
            <div className="feature-desc">Braille for precision, Unicode Blocks for compatibility, ASCII for SSH sessions and minimal environments.</div>
          </div>
        </div>

        <div className="section-heading">
          <span className="section-heading-text">20 chart types</span>
          <span className="section-heading-line" />
        </div>

        <div className="chart-grid">
          {CHARTS.map((c) => {
            const accent = CHART_ACCENT[c.id] ?? "blue";
            return (
              <button
                key={c.id}
                className="chart-card"
                data-accent={accent}
                onClick={() => onNav(c.id)}
              >
                <div className="chart-card-header">
                  <span className="chart-card-name">{c.name}</span>
                  <AccentChip accent={accent} />
                </div>
                <div className="chart-card-preview">
                  {ANSI[c.id]
                    ? <pre dangerouslySetInnerHTML={{ __html: ansiToHtml(ANSI[c.id]) }} />
                    : <pre>{c.preview.split("\n").slice(0, 6).join("\n")}</pre>
                  }
                </div>
                <div className="chart-card-footer">
                  <span className="chart-card-cta">View docs →</span>
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

/* ── Root ───────────────────────────────────────────────────── */
// URL is the source of truth: `/chart/line`, `/install`, … Real routes, so a
// click on "line" lands on `host:port/chart/line` and refresh/back work.
const BASE = import.meta.env.BASE_URL.replace(/\/$/, "");

function pathToActive(path: string): { page: string; chartId: string | null } {
  const p = (path.slice(BASE.length) || "/").replace(/\/+$/, "") || "/";
  const m = p.match(/^\/chart\/([a-zA-Z0-9-]+)$/);
  if (m) return { page: m[1], chartId: CHARTS.some((c) => c.id === m[1]) ? m[1] : null };
  if (p === "/") return { page: "home", chartId: null };
  return { page: p.slice(1), chartId: null };
}

function hrefFor(id: string): string {
  const knownChart = CHARTS.some((c) => c.id === id);
  const prefix = `${BASE}/`;
  if (id === "home") return BASE || "/";
  return knownChart ? `${prefix}chart/${id}` : `${prefix}${id}`;
}

export default function App() {
  const [location, navigate] = useLocation();
  const { page: active, chartId } = pathToActive(location);
  const [mobileOpen, setMobileOpen] = useState(false);

  const nav = (id: string) => {
    navigate(hrefFor(id));
    setMobileOpen(false);
    window.scrollTo(0, 0);
  };

  const labelFor = (id: string) => {
    const map: Record<string, string> = {
      install: "Installation", quickstart: "Quickstart",
      "fluent-api": "Fluent API", "ai-output": "AI Agents",
    };
    return map[id] ?? CHARTS.find((c) => c.id === id)?.name ?? id;
  };

  function content() {
    if (active === "home")       return <Hero onNav={nav} />;
    if (active === "install")    return <InstallPage />;
    if (active === "quickstart") return <QuickstartPage />;
    if (active === "fluent-api") return <FluentPage />;
    if (active === "ai-output")  return <AiPage />;
    // A /chart/<unknown-id> URL falls back to the catalog home rather than a blank pane.
    if (chartId)                 return <ChartPage key={chartId} id={chartId} />;
    return <Hero onNav={nav} />;
  }

  return (
    <div className="layout">
      <header className="topbar">
        <button className="logo" onClick={() => nav("home")}>
          <span className="logo-icon">◈</span>
          <span>chitra</span>
        </button>
        <nav className="topbar-nav">
          <button className={`topbar-link ${["install","quickstart","fluent-api"].includes(active) ? "active" : ""}`} onClick={() => nav("install")}>Docs</button>
          <button className={`topbar-link ${CHARTS.some(c=>c.id===active) ? "active" : ""}`} onClick={() => nav("line")}>Charts</button>
          <button className={`topbar-link ${active==="ai-output" ? "active" : ""}`} onClick={() => nav("ai-output")}>AI Agents</button>
        </nav>
        <div className="topbar-right">
          <a className="topbar-icon-link" href="https://github.com" target="_blank" rel="noreferrer" title="GitHub">
            <svg viewBox="0 0 16 16" fill="currentColor" width="18" height="18">
              <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
            </svg>
          </a>
          <a className="topbar-cta" href="https://npmjs.com/package/@chitra/core" target="_blank" rel="noreferrer">
            npm install @chitra/core
          </a>
        </div>
        <button className="mobile-menu-btn" onClick={() => setMobileOpen(!mobileOpen)}>☰</button>
      </header>

      <div className="main-layout">
        <nav className={`sidebar ${mobileOpen ? "open" : ""}`}>
          <button className="nav-home" onClick={() => nav("home")}>⬡ chitra</button>
          {NAV_SECTIONS.map((s) => (
            <div key={s.label} className="nav-section">
              <div className="nav-section-label">{s.label}</div>
              {s.items.map((id) => (
                <button
                  key={id}
                  className={`nav-item ${active === id ? "active" : ""}`}
                  onClick={() => nav(id)}
                >
                  <span className="accent-dot" />
                  {labelFor(id)}
                </button>
              ))}
            </div>
          ))}
        </nav>

        <main className={`content${CHARTS.some((c) => c.id === active) ? " content-catalog" : ""}`}>
          {content()}
        </main>
      </div>
    </div>
  );
}
