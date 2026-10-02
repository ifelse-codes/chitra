import {
  line,
  bar,
  sparkline,
  progress,
  pie,
  horizontalBar,
  funnel,
  plot,
  waterfall,
} from "./src/index.js";

console.log("=== LINE CHART (Braille Renderer) ===");
line({
  data: [10, 20, 15, 35, 28, 45, 38, 52, 44, 60],
  title: "Revenue Trend",
  noColor: true,
  width: 52,
  height: 10,
}).render();

console.log("\n=== BAR CHART ===");
bar({
  data: [42, 67, 38, 55, 72, 61],
  title: "Monthly Sales",
  labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
  height: 8,
  noColor: true,
}).render();

console.log("\n=== SPARKLINES ===");
sparkline({
  data: [45, 52, 61, 58, 70, 65, 78, 72, 80, 82],
  label: "CPU",
  showValue: true,
  noColor: true,
}).render();
sparkline({
  data: [60, 62, 65, 63, 68, 70, 72, 69, 74, 78],
  label: "MEM",
  renderer: "braille",
  noColor: true,
}).render();
sparkline({
  data: [12, 8, 15, 6, 20, 18, 25, 22, 30, 28],
  label: "NET",
  renderer: "ascii",
  noColor: true,
}).render();

console.log("\n=== HORIZONTAL BAR ===");
horizontalBar({
  data: [892, 645, 534, 421, 289],
  labels: ["TypeScript", "Python", "Rust", "Go", "Ruby"],
  noColor: true,
  width: 52,
}).render();

console.log("\n=== PROGRESS BARS ===");
progress({ value: 87, label: "Build    ", noColor: true }).render();
progress({ value: 62, label: "Tests    ", noColor: true }).render();
progress({ value: 34, label: "Coverage ", noColor: true }).render();

console.log("\n=== PIE CHART ===");
pie({
  data: [35, 25, 20, 12, 8],
  labels: ["Organic", "Direct", "Social", "Email", "Paid"],
  noColor: true,
}).render();

console.log("\n=== WATERFALL ===");
waterfall({
  data: [500, -120, 80, -60, 150],
  labels: ["Start", "COGS", "Rev", "OpEx", "Sales"],
  noColor: true,
  height: 8,
  width: 50,
}).render();

console.log("\n=== FUNNEL ===");
funnel({
  data: [10000, 6800, 3400, 1200, 340],
  labels: ["Visitors", "Sign-ups", "Trials", "Paid", "Enterprise"],
  noColor: true,
  width: 55,
}).render();

console.log("\n=== FLUENT plot() API ===");
plot([10, 20, 15, 35, 28, 45, 38, 52])
  .title("plot(data).theme('nord').line().render()")
  .noColor()
  .width(52)
  .height(8)
  .line()
  .render();
