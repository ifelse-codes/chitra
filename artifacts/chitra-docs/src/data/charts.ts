export interface ChartDef {
  id: string;
  name: string;
  description: string;
  preview: string;
  code: string;
}

export const CHARTS: ChartDef[] = [
  {
    id: "line",
    name: "Line Chart",
    description: "Continuous data over time, rendered with Unicode Braille for sub-character precision.",
    preview: `Revenue Trend
 60│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊
   │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢄⡀⠀⠀⠀⠀⠀⢀⠔⠁⠀
48.89│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠈⠑⠢⢄⡀⡰⠁⠀⠀⠀
   │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠉⠒⠤⣀⠀⠀⡠⠊⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀
37.78│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠀⠀⠀⠀⠀⠉⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
   │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠃⠉⠒⢄⡀⠀⢀⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
26.67│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⠁⠀⠀⠀⠀⠈⠑⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
   │⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⢀⠜⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
15.56│⠀⠀⢀⠔⠊⠀⠉⠑⠢⠤⣀⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 10│⡠⠒⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
   └──────────────────────────────────────────────────────`,
    code: `import { line } from "@chitra/core";

line({
  data: [10, 20, 15, 35, 28, 45, 38, 52, 44, 60],
  title: "Revenue Trend",
  width: 52,
  height: 10,
  theme: "nord",
}).render();`,
  },
  {
    id: "bar",
    name: "Bar Chart",
    description: "Vertical bars for comparing categorical values, with optional grouping and stacking.",
    preview: `Monthly Sales

 72│        █  
   │  █     █  
 56│  █   █ █ █
   │  █   █ █ █
 40│█ █   █ █ █
   │█ █ █ █ █ █
 24│█ █ █ █ █ █
   │█ █ █ █ █ █
  8│█ █ █ █ █ █
  0│█ █ █ █ █ █
   └───────────
    J F M A M J`,
    code: `import { bar } from "@chitra/core";

bar({
  data: [42, 67, 38, 55, 72, 61],
  labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
  title: "Monthly Sales",
  height: 10,
}).render();`,
  },
  {
    id: "area",
    name: "Area Chart",
    description: "Like a line chart but with the area below filled in — great for volume/accumulation.",
    preview: `Area Chart
 52│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠤⠊
   │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠒⠤⢄⣀⠀⠀⠀⠀⠀⡠⠒⠁⠀⢸
40.44│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠀⡇⠀⠀⠀⠉⠒⠢⠔⠉⠀⠀⠀⠀⢸
   │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠒⠤⣀⡀⠀⠀⠀⠀⡠⠊⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸
28.89│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠜⠀⡇⠀⠀⠈⠉⠒⠤⠊⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸
   │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⡇⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸
17.33│⠀⠀⠀⢀⡠⠔⠊⠑⠒⠢⠤⣀⣀⠀⡠⠃⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸
   │⡠⠔⠊⠁⠀⠀⢸⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸
  0│⡇⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸
   └──────────────────────────────────────────────────────`,
    code: `import { area } from "@chitra/core";

area({
  data: [10, 20, 15, 35, 28, 45, 38, 52],
  title: "Area Chart",
  width: 52,
  height: 10,
}).render();`,
  },
  {
    id: "sparkline",
    name: "Sparkline",
    description: "Compact inline charts — perfect for dashboards, logs, and status readouts.",
    preview: `CPU  ▂▃▃▅▄▇▆██ 82
MEM ⣀⠤⠔⠒⠊
NET ._:_|!*|##`,
    code: `import { sparkline } from "@chitra/core";

// Unicode blocks (default)
sparkline({ data: [45, 52, 61, 58, 70, 65, 78, 72, 80, 82],
  label: "CPU", showValue: true }).render();

// Braille renderer
sparkline({ data: [60, 62, 65, 63, 68, 70, 72, 69, 74, 78],
  label: "MEM", renderer: "braille" }).render();

// ASCII fallback
sparkline({ data: [12, 8, 15, 6, 20, 18, 25, 22, 30, 28],
  label: "NET", renderer: "ascii" }).render();`,
  },
  {
    id: "histogram",
    name: "Histogram",
    description: "Distribution of continuous data across configurable bins.",
    preview: `Distribution
 5│                    ████               
  │                    ████               
3.89│               ████ ████               
  │               ████ ████               
2.78│          ████ ████ ████ ████          
  │          ████ ████ ████ ████          
1.67│     ████ ████ ████ ████ ████ ████     
  │     ████ ████ ████ ████ ████ ████     
0.56│████ ████ ████ ████ ████ ████ ████ ████
 0│████ ████ ████ ████ ████ ████ ████ ████
  └───────────────────────────────────────
   1    2    3    4    5    5    6    7   `,
    code: `import { histogram } from "@chitra/core";

histogram({
  data: [1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,7,7,8],
  bins: 8,
  title: "Distribution",
  height: 10,
  width: 40,
}).render();`,
  },
  {
    id: "scatter",
    name: "Scatter Plot",
    description: "Two-dimensional point data for spotting correlations and clusters.",
    preview: `Scatter Plot
 12│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈
   │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
10.18│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
4.73│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
   │⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
2.91│⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  2│⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
   └──────────────────────────────────────────────────────`,
    code: `import { scatter } from "@chitra/core";

scatter({
  data: [
    {x:1,y:2}, {x:2,y:4}, {x:3,y:3}, {x:4,y:7},
    {x:5,y:5}, {x:6,y:9}, {x:7,y:6}, {x:10,y:12},
  ],
  title: "Scatter Plot",
  width: 50,
  height: 12,
}).render();`,
  },
  {
    id: "pie",
    name: "Pie Chart",
    description: "Circular proportional chart for showing part-to-whole relationships.",
    preview: `          ▒          
    ▒▒▒▒▒▒▒▒▒░░░░    
  ▒▒▒▒▒▒▒▒▒▒░░░░░░░  
 ▓▓▓▓▒▒▒▒▒▒▒░░░░░░▪▪ 
 ▓▓▓▓▓▓▓▒▒▒░░░▪▪▪▪▪▪ 
▓▓▓▓▓▓▓▓▓▓███████████
 ▓▓▓▓▓▓▓▓███████████ 
 ▓▓▓▓▓▓▓████████████ 
  ▓▓▓▓█████████████  
    ▓████████████    
          █          

█ Organic: 35 (35.0%)
▓ Direct: 25 (25.0%)
▒ Social: 20 (20.0%)
░ Email: 12 (12.0%)
▪ Paid: 8 (8.0%)`,
    code: `import { pie } from "@chitra/core";

pie({
  data: [35, 25, 20, 12, 8],
  labels: ["Organic", "Direct", "Social", "Email", "Paid"],
}).render();`,
  },
  {
    id: "donut",
    name: "Donut Chart",
    description: "Pie chart with a hollow centre — great for showing a primary metric.",
    preview: `                ▒                
         ▒▒▒▒▒▒▒▒▒░░░░░░         
      ▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░      
    ▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░    
   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░   
  ▒▒▒▒▒▒▒▒▒           ░░░░░▪▪▪▪  
 ▓▓▓▒▒▒▒▒▒             ░▪▪▪▪▪▪▪▪ 
▓▓▓▓▓▓▓▓▓      100      █████████
 ▓▓▓▓▓▓▓▓               ████████ 
  ▓▓▓▓▓▓▓▓▓           █████████  
   ▓▓▓▓▓▓▓▓▓▓▓████████████████   
         ▓▓▓████████████         
                █                

█ TypeScript: 30 (30.0%)
▓ Python: 25 (25.0%)
▒ Rust: 22 (22.0%)
░ Go: 15 (15.0%)
▪ Other: 8 (8.0%)`,
    code: `import { donut } from "@chitra/core";

donut({
  data: [30, 25, 22, 15, 8],
  labels: ["TypeScript", "Python", "Rust", "Go", "Other"],
}).render();`,
  },
  {
    id: "heatmap",
    name: "Heatmap",
    description: "2D grid of values encoded as block density — ideal for activity matrices.",
    preview: `Activity Heatmap

  0  1  2  3  4  
 0      ░░░▒▒▒▓▓▓
 1   ░░░▒▒▒▓▓▓███
 2   ░░░▒▒▒▓▓▓███
 3░░░▒▒▒▓▓▓██████

  low   ░░▒▒▓▓██ high [1–12]`,
    code: `import { heatmap } from "@chitra/core";

heatmap({
  data: [
    [1, 3, 5, 7, 9],
    [2, 4, 6, 8, 10],
    [3, 5, 7, 9, 11],
    [4, 6, 8, 10, 12],
  ],
  title: "Activity Heatmap",
  width: 40,
  height: 8,
}).render();`,
  },
  {
    id: "progress",
    name: "Progress Bar",
    description: "Horizontal progress bars with precise sub-block rendering.",
    preview: `Build     [██████████████████████████▁░░░] 87.0%
Tests     [██████████████████▅░░░░░░░░░░░] 62.0%
Coverage  [██████████▂░░░░░░░░░░░░░░░░░░░] 34.0%`,
    code: `import { progress } from "@chitra/core";

progress({ value: 87, label: "Build    " }).render();
progress({ value: 62, label: "Tests    " }).render();
progress({ value: 34, label: "Coverage " }).render();`,
  },
  {
    id: "gauge",
    name: "Gauge",
    description: "Single-value meter — great for KPIs, CPU usage, battery level.",
    preview: `┤▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░├
0                                      100
CPU Load: 73`,
    code: `import { gauge } from "@chitra/core";

gauge({
  value: 73,
  min: 0,
  max: 100,
  label: "CPU Load",
  width: 40,
}).render();`,
  },
  {
    id: "horizontalBar",
    name: "Horizontal Bar",
    description: "Bars running left-to-right — ideal for ranked lists and comparisons.",
    preview: `TypeScript ███████████████████████████████████  892
Python     █████████████████████████▂░░░░░░░░░  645
Rust       █████████████████████░░░░░░░░░░░░░░  534
Go         ████████████████▄░░░░░░░░░░░░░░░░░░  421
Ruby       ███████████▃░░░░░░░░░░░░░░░░░░░░░░░  289`,
    code: `import { horizontalBar } from "@chitra/core";

horizontalBar({
  data: [892, 645, 534, 421, 289],
  labels: ["TypeScript", "Python", "Rust", "Go", "Ruby"],
  width: 52,
}).render();`,
  },
  {
    id: "timeline",
    name: "Timeline / Gantt",
    description: "Horizontal Gantt-style bars for scheduling and sprint planning.",
    preview: `Sprint Timeline

Design  ▶█████████◀────────────────────────────────
Build   ───────────▶███████████████████◀───────────
Test    ───────────────────────────▶█████████◀─────
Deploy  ──────────────────────────────────────▶███◀

        0                    4                    8`,
    code: `import { timeline } from "@chitra/core";

timeline({
  events: [
    { label: "Design", start: 0, end: 2 },
    { label: "Build",  start: 2, end: 6 },
    { label: "Test",   start: 5, end: 7 },
    { label: "Deploy", start: 7, end: 8 },
  ],
  title: "Sprint Timeline",
  width: 52,
}).render();`,
  },
  {
    id: "radar",
    name: "Radar Chart",
    description: "Spider/radar chart for multi-axis comparison of a single entity.",
    preview: `Radar
        Speed                           
     ············                       
 ····    *●*    ····                    
·    **** · **     ···                  
 ****···········      ··Safety          
* ···     ·     ···    ··               
···     ·····     ·●··· ··              
· ··· ··· · ··· ··· ·    ··             
 *   ·   ···   ·     ·    ·             
·*   ···· · ····    ··*   ·             
  ···**   ·     ···  **·●               
     ···········***** ··  UX            
·        *●***     ···                  
 ····     ·     ····`,
    code: `import { radar } from "@chitra/core";

radar({
  data: [8, 6, 9, 7, 5, 8],
  labels: ["Speed", "Safety", "UX", "Perf", "Cost", "Scale"],
  title: "System Radar",
  width: 40,
}).render();`,
  },
  {
    id: "boxplot",
    name: "Box Plot",
    description: "Statistical summary showing median, quartiles, and whiskers.",
    preview: ` 40│                      ┬                      
   │                      │                      
   │       ┬              │              ┬       
31.27│       │             │ │             │       
   │      │ │            │ │             │       
   │      │ │            ┼─┼            │ │      
22.55│      ┼─┼            │ │            │ │      
   │      │ │            │ │            ┼─┼      
   │      │ │             │             │ │      
13.82│       │              ┴             │ │      
   │       ┴                             │       
  8│                                     ┴       
   └─────────────────────────────────────────────
    Q1             Q2             Q3            `,
    code: `import { boxplot } from "@chitra/core";

boxplot({
  data: [
    [12, 18, 22, 28, 35],
    [15, 20, 25, 30, 40],
    [8,  14, 19, 25, 33],
  ],
  labels: ["Q1", "Q2", "Q3"],
  width: 50,
  height: 12,
}).render();`,
  },
  {
    id: "waterfall",
    name: "Waterfall",
    description: "Running total chart — shows cumulative effect of positive/negative values.",
    preview: ` 550│                            ██████ ██████ 
    │██████ ██████               ██████ ██████ 
427.78│██████ ██████ ██████ ██████ ██████ ██████ 
    │██████                             ██████ 
305.56│██████                             ██████ 
    │██████                             ██████ 
183.33│██████                             ██████ 
    │██████                             ██████ 
61.11│██████                             ██████ 
   0│██████ ────── ────── ────── ────── ██████ 
    └──────────────────────────────────────────
     Start  COGS   Rev    OpEx   Sales  Total  `,
    code: `import { waterfall } from "@chitra/core";

waterfall({
  data: [500, -120, 80, -60, 150],
  labels: ["Start", "COGS", "Rev", "OpEx", "Sales"],
  height: 10,
  width: 50,
  showTotal: true,
}).render();`,
  },
  {
    id: "funnel",
    name: "Funnel Chart",
    description: "Conversion funnel — visualise drop-off across stages of a pipeline.",
    preview: `Visitors     ███████████████████████████████████ 10.0K
                       ▼▼▼▼▼▼▼▼▼▼▼▼▼▼
Sign-ups          ████████████████████████ 6.8K (68.0%)
                          ▼▼▼▼▼▼▼▼▼
Trials                  ████████████ 3.4K (34.0%)
                            ▼▼▼▼
Paid                        ████ 1.2K (12.0%)
                              ▼
Enterprise                    █ 340 (3.4%)`,
    code: `import { funnel } from "@chitra/core";

funnel({
  data: [10000, 6800, 3400, 1200, 340],
  labels: ["Visitors", "Sign-ups", "Trials", "Paid", "Enterprise"],
  width: 55,
}).render();`,
  },
  {
    id: "candlestick",
    name: "Candlestick",
    description: "OHLC financial chart — open, high, low, close per period. Green = bullish (close > open), red = bearish.",
    preview: `CHRX — 10-Day Price Action
    215│                                                        │   
       │                                                        █   
       │                                                        █   
 199.60│                                                  │     █   
       │                                      │     │     █     █   
       │                                      █     ▓     █     │   
 184.20│                    │     │           █     ▓     █         
       │                    █     ▓           █     ▓     █         
       │                    █     ▓     │     █     │               
 168.80│        │           █     ▓     █     █                     
       │        │     │     █     ▓     █                           
       │  │     │     █     █           │                           
 153.40│  █     ▓     █                 │                           
       │  █     │     │                                             
       │  █           │                                             
    138│  │                                                         
       └────────────────────────────────────────────────────────────
        Jan 8 Jan 9 Jan10 Jan11 Jan12 Jan15 Jan16 Jan17 Jan18 Jan19 `,
    code: `import { candlestick } from "@chitra/core";

candlestick({
  title: "CHRX — 10-Day Price Action",
  data: [
    { open: 142, high: 158, low: 138, close: 155, label: "Jan 8" },
    { open: 155, high: 168, low: 148, close: 151, label: "Jan 9" },
    { open: 151, high: 163, low: 143, close: 161, label: "Jan10" },
    { open: 161, high: 182, low: 158, close: 178, label: "Jan11" },
    { open: 178, high: 185, low: 162, close: 165, label: "Jan12" },
    { open: 165, high: 174, low: 155, close: 170, label: "Jan15" },
    { open: 170, high: 192, low: 167, close: 188, label: "Jan16" },
    { open: 188, high: 196, low: 176, close: 179, label: "Jan17" },
    { open: 179, high: 198, low: 178, close: 195, label: "Jan18" },
    { open: 195, high: 215, low: 190, close: 210, label: "Jan19" },
  ],
  height: 16,
  width: 72,
  theme: "neon",
}).render();`,
  },
  {
    id: "treemap",
    name: "Treemap",
    description: "Hierarchical area chart — size encodes value, nesting encodes hierarchy.",
    preview: `Codebase
░TS░░░░░░░░░░░░░░░░░░░░░░░Python░░░░░░░░░░░Rust░░░
░45▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░30▓▓▓▓▓▓▓▓▓▓▓▓▓░░15▓▓▓▓░
░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓░
░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓░
░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓░
░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░`,
    code: `import { treemap } from "@chitra/core";

treemap({
  data: [
    { label: "TS",     value: 45 },
    { label: "Python", value: 30 },
    { label: "Rust",   value: 15 },
    { label: "Go",     value: 7  },
    { label: "Ruby",   value: 3  },
  ],
  title: "Codebase",
  width: 50,
  height: 10,
}).render();`,
  },
  {
    id: "sankey",
    name: "Sankey Diagram",
    description: "Flow diagram showing how quantities move between nodes.",
    preview: `Users      ─────────────────────────────────▶ Free       [60]
Users      ─────────────────────▶ Pro        [30]
Users      ──────▶ Enterprise   [10]
Free       ───────────▶ Churned [20]

Nodes:
  ■ Users    out:100
  ■ Free     in:60  out:20
  ■ Pro      in:30
  ■ Enterprise in:10
  ■ Churned  in:20`,
    code: `import { sankey } from "@chitra/core";

sankey({
  nodes: ["Users", "Free", "Pro", "Enterprise", "Churned"],
  links: [
    { source: 0, target: 1, value: 60 },
    { source: 0, target: 2, value: 30 },
    { source: 0, target: 3, value: 10 },
    { source: 1, target: 4, value: 20 },
  ],
  width: 52,
}).render();`,
  },
];
