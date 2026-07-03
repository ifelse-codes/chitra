import {
  line,
  bar,
  area,
  sparkline,
  histogram,
  scatter,
  pie,
  donut,
  heatmap,
  progress,
  gauge,
  horizontalBar,
  timeline,
  radar,
  boxplot,
  waterfall,
  funnel,
  candlestick,
  treemap,
  sankey,
  plot,
} from "../packages/core/src/index.js";

const divider = (title: string) => {
  const line2 = "─".repeat(60);
  console.log(`\n${line2}`);
  console.log(`  ${title}`);
  console.log(line2 + "\n");
};

divider("LINE CHART — Braille Renderer");
line({
  data: [10, 20, 15, 35, 28, 45, 38, 52, 44, 60],
  title: "Revenue Trend",
  theme: "tokyo-night",
  width: 60,
  height: 12,
  labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"],
}).render();

divider("MULTI-SERIES LINE CHART");
line({
  data: [
    [10, 20, 15, 35, 28, 45, 38, 52],
    [5, 12, 18, 22, 30, 35, 42, 48],
  ],
  title: "Revenue vs Costs",
  theme: "dracula",
  seriesLabels: ["Revenue", "Costs"],
  width: 60,
  height: 12,
}).render();

divider("BAR CHART");
bar({
  data: [42, 67, 38, 55, 72, 61],
  title: "Monthly Sales",
  theme: "nord",
  labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
  height: 10,
}).render();

divider("MULTI-SERIES BAR CHART");
bar({
  data: [
    [42, 67, 38, 55, 72, 61],
    [28, 45, 52, 48, 60, 55],
  ],
  title: "Sales vs Returns",
  theme: "nord",
  labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
  seriesLabels: ["Sales", "Returns"],
  legend: true,
  height: 10,
}).render();

divider("HORIZONTAL BAR CHART");
horizontalBar({
  data: [892, 645, 534, 421, 387, 312, 289],
  title: "Top Languages",
  labels: ["TypeScript", "Python", "Rust", "Go", "Java", "C++", "Ruby"],
  theme: "github-dark",
  width: 60,
}).render();

divider("SPARKLINES");
const cpuData = [45, 52, 61, 58, 70, 65, 78, 72, 80, 75, 88, 82];
const memData = [60, 62, 65, 63, 68, 70, 72, 69, 74, 76, 75, 78];

sparkline({ data: cpuData, label: "CPU", showValue: true, renderer: "blocks" }).render();
sparkline({ data: memData, label: "MEM", showValue: true, renderer: "braille" }).render();
sparkline({ data: cpuData, label: "NET", renderer: "ascii" }).render();

divider("AREA CHART");
area({
  data: [10, 25, 18, 42, 35, 58, 47, 65, 55, 72],
  title: "Active Users",
  theme: "tokyo-night",
  width: 60,
  height: 12,
}).render();

divider("THEME TOUR — one line chart across all 7 themes");
const themeNames = [
  "default",
  "nord",
  "dracula",
  "github-dark",
  "tokyo-night",
  "solarized",
  "monochrome",
] as const;
for (const theme of themeNames) {
  line({
    data: [12, 24, 18, 36, 30, 48, 42, 54],
    title: `Theme: ${theme}`,
    theme,
    width: 50,
    height: 6,
    labels: ["Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Q7", "Q8"],
  }).render();
}

divider("HISTOGRAM");
const normalData = Array.from({ length: 500 }, () => {
  let s = 0;
  for (let i = 0; i < 12; i++) s += Math.random();
  return (s - 6) * 10 + 50;
});
histogram({
  data: normalData,
  title: "Response Time Distribution (ms)",
  bins: 20,
  theme: "solarized",
  width: 60,
  height: 10,
}).render();

divider("SCATTER PLOT");
scatter({
  data: Array.from({ length: 50 }, () => ({
    x: Math.random() * 100,
    y: Math.random() * 100,
  })),
  title: "Query Latency vs Load",
  renderer: "braille",
  width: 60,
  height: 15,
}).render();

divider("PIE CHART");
pie({
  data: [35, 25, 20, 12, 8],
  title: "Traffic Sources",
  labels: ["Organic", "Direct", "Social", "Email", "Paid"],
  theme: "dracula",
}).render();

divider("DONUT CHART");
donut({
  data: [42, 28, 18, 12],
  title: "Storage Usage",
  labels: ["Code", "Media", "Docs", "Other"],
  theme: "tokyo-night",
}).render();

divider("HEATMAP");
const heatData = Array.from({ length: 7 }, (_, r) =>
  Array.from({ length: 24 }, (_, c) =>
    Math.max(0, Math.sin((c / 24) * Math.PI) * 100 * (r % 3 === 0 ? 1.2 : 0.8) + Math.random() * 20)
  )
);
heatmap({
  data: heatData,
  title: "Activity Heatmap (Hour × Day)",
  xLabels: Array.from({ length: 24 }, (_, i) => String(i).padStart(2, "0")),
  yLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
  cellWidth: 2,
}).render();

divider("PROGRESS BARS");
progress({ value: 87, label: "Build      ", showPercent: true }).render();
progress({ value: 62, label: "Tests      ", showPercent: true, theme: "nord" }).render();
progress({ value: 34, label: "Coverage   ", showPercent: true, theme: "dracula" }).render();

divider("GAUGE");
gauge({
  value: 72,
  min: 0,
  max: 100,
  title: "CPU Usage",
  label: "CPU",
  width: 50,
}).render();

divider("TIMELINE");
timeline({
  title: "Sprint 12",
  events: [
    { label: "Design",    start: 0, end: 3 },
    { label: "Backend",   start: 2, end: 8 },
    { label: "Frontend",  start: 3, end: 9 },
    { label: "Testing",   start: 7, end: 11 },
    { label: "Deploy",    start: 10, end: 12 },
  ],
  min: 0,
  max: 12,
  width: 60,
}).render();

divider("RADAR CHART");
radar({
  data: [85, 70, 92, 78, 88, 65],
  labels: ["Speed", "Power", "Range", "Accuracy", "Stamina", "Agility"],
  title: "Character Stats",
  theme: "tokyo-night",
}).render();

divider("BOX PLOT");
boxplot({
  data: [
    [12, 15, 18, 22, 25, 28, 30, 35, 38, 42, 45],
    [8, 12, 18, 20, 28, 32, 38, 42, 50, 55, 60],
  ],
  title: "Response Times by Region",
  labels: ["US-East", "EU-West"],
  width: 60,
  height: 10,
}).render();

divider("WATERFALL CHART");
waterfall({
  data: [500, -120, 80, -60, 150, -30],
  title: "Cash Flow",
  labels: ["Start", "COGS", "Revenue", "OpEx", "Sales", "Tax"],
  showTotal: true,
  width: 60,
  height: 10,
}).render();

divider("FUNNEL CHART");
funnel({
  data: [10000, 6800, 3400, 1200, 340],
  title: "Sales Funnel",
  labels: ["Visitors", "Sign-ups", "Trials", "Paid", "Enterprise"],
  showPercent: true,
  width: 60,
}).render();

divider("CANDLESTICK CHART");
candlestick({
  data: [
    { open: 100, high: 112, low: 96,  close: 108, label: "Mon" },
    { open: 108, high: 118, low: 104, close: 115, label: "Tue" },
    { open: 115, high: 120, low: 108, close: 110, label: "Wed" },
    { open: 110, high: 114, low: 98,  close: 102, label: "Thu" },
    { open: 102, high: 110, low: 99,  close: 107, label: "Fri" },
  ],
  title: "BTC/USD Daily",
  width: 60,
  height: 15,
}).render();

divider("TREEMAP");
treemap({
  title: "Codebase by Language",
  data: [
    { label: "TypeScript", value: 45 },
    { label: "Python",     value: 25 },
    { label: "Go",         value: 15 },
    { label: "Rust",       value: 8 },
    { label: "Shell",      value: 4 },
    { label: "Other",      value: 3 },
  ],
  width: 60,
  height: 16,
}).render();

divider("SANKEY / FLOW DIAGRAM");
sankey({
  title: "User Journey",
  nodes: ["Ads", "Organic", "Referral", "Landing", "Signup", "Active", "Churned"],
  links: [
    { source: "Ads",      target: "Landing", value: 4200 },
    { source: "Organic",  target: "Landing", value: 6800 },
    { source: "Referral", target: "Landing", value: 1900 },
    { source: "Landing",  target: "Signup",  value: 3200 },
    { source: "Signup",   target: "Active",  value: 2100 },
    { source: "Active",   target: "Churned", value: 400  },
  ],
  width: 70,
}).render();

divider("FLUENT PLOT API");
plot([15, 28, 22, 45, 38, 60, 52, 70])
  .title("Monthly Active Users")
  .theme("tokyo-night")
  .width(55)
  .height(10)
  .noColor(false)
  .line()
  .render();

divider("AI AGENT OUTPUT — MCP tool result shape");
const agentChart = bar({
  data: [42, 67, 38, 55],
  labels: ["Q1", "Q2", "Q3", "Q4"],
  title: "Quarterly Revenue",
  noColor: true,
});

const mcpToolResult = {
  name: "render_chart",
  content: [
    { type: "text", text: agentChart.toPlain() },
    { type: "text", text: JSON.stringify(agentChart.toJSON(), null, 2) },
  ],
  isError: false,
};

console.log("MCP tool result passed back to the LLM:");
console.log(JSON.stringify(mcpToolResult, null, 2));
