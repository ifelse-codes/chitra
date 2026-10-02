#!/usr/bin/env node
// qa-nav-groups.mjs — S24: scripted Playwright pass for the grouped chart nav.
// Proves: six groups with exact membership, zero status badges in the nav
// (lock state is internal), click/keyboard collapse, localStorage persistence
// across reload, auto-expand of the active chart's group, expand/collapse-all.

import { chromium } from "playwright";
import { promises as fs } from "fs";
import { fileURLToPath } from "url";
import { dirname, join, resolve } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT = resolve(__dirname, "..");
const DOCS = join(ROOT, "artifacts/chitra-docs");

const EXPECTED = {
  "Trend & time": ["line", "area", "timeline", "candlestick"],
  Comparison: ["bar", "horizontalBar", "scatter", "radar"],
  "Distribution & density": ["histogram", "boxplot", "heatmap"],
  "Part-to-whole": ["pie", "donut", "treemap", "funnel"],
  "Flow & accumulation": ["sankey", "waterfall"],
  "Single value & progress": ["gauge", "progress", "sparkline"],
};
const EXPECTED_COUNTS = {
  "Trend & time": 4,
  Comparison: 4,
  "Distribution & density": 3,
  "Part-to-whole": 4,
  "Flow & accumulation": 2,
  "Single value & progress": 3,
};

const HEADED = process.argv.includes("--headed");
const BASE_URL = "http://localhost:5174";

async function buildDocs() {
  console.log("Building docs...");
  const { execSync } = await import("child_process");
  execSync("pnpm run build", {
    cwd: DOCS,
    stdio: "inherit",
    env: { ...process.env, PORT: "5174", BASE_PATH: "/" },
  });
}

async function startPreview() {
  console.log("Starting preview server on port 5174...");
  const { spawn } = await import("child_process");
  const server = spawn("pnpm", ["run", "serve"], {
    cwd: DOCS,
    stdio: ["ignore", "pipe", "pipe"],
    detached: true,
    env: { ...process.env, PORT: "5174", BASE_PATH: "/" },
  });
  await new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error("Server startup timeout")), 30000);
    server.stdout?.on("data", (data) => {
      if (data.toString().includes("Local:")) {
        clearTimeout(timeout);
        resolve();
      }
    });
    server.stderr?.on("data", (data) => {
      console.error("Server stderr:", data.toString());
    });
  });
  return server;
}

const checks = [];
function check(name, ok, detail = "") {
  checks.push({ name, ok, detail });
  console.log(`${ok ? "PASS" : "FAIL"} ${name}${detail ? ` — ${detail}` : ""}`);
}

async function runQA() {
  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const artifactDir = process.env.QA_ARTIFACTS
    ? process.env.QA_ARTIFACTS
    : join(ROOT, ".ai/verify/session-24", ts);
  await fs.mkdir(artifactDir, { recursive: true });

  await buildDocs();
  const server = await startPreview();

  try {
    const browser = await chromium.launch({ headless: !HEADED });
    const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
    const page = await context.newPage();
    const errors = [];
    page.on("console", (msg) => {
      if (msg.type() === "error") errors.push(msg.text());
    });
    page.on("pageerror", (err) => errors.push(err.message));

    await page.goto(`${BASE_URL}/chart/line`, { waitUntil: "networkidle" });
    await page.waitForTimeout(1200);

    // 1. Exactly six groups, exact labels + count tags.
    const groups = await page.$$eval(".nav-group", (els) =>
      els.map((el) => el.getAttribute("data-group"))
    );
    check(
      "six-groups",
      JSON.stringify(groups) === JSON.stringify(Object.keys(EXPECTED)),
      JSON.stringify(groups)
    );

    let countsOk = true;
    for (const [g, n] of Object.entries(EXPECTED_COUNTS)) {
      const tag = await page.$eval(`[data-group="${g}"] .nav-group-count`, (el) => el.textContent);
      if (tag.trim() !== String(n)) {
        countsOk = false;
        break;
      }
    }
    check("group-count-tags", countsOk, "4·4·3·4·2·3");

    // 2. Exact membership per group.
    let memberOk = true;
    const memberDetail = [];
    for (const [g, ids] of Object.entries(EXPECTED)) {
      const got = await page.$$eval(`[data-group="${g}"] [data-chart]`, (els) =>
        els.map((el) => el.getAttribute("data-chart"))
      );
      if (JSON.stringify(got) !== JSON.stringify(ids)) {
        memberOk = false;
        memberDetail.push(`${g}: ${JSON.stringify(got)}`);
      }
    }
    check("group-membership", memberOk, memberDetail.join("; ") || "20 charts in place");

    // 3. No status badges anywhere in the nav — lock state is internal.
    const badgeCount = await page.$$eval(".sidebar .badge", (els) => els.length);
    check("no-badges", badgeCount === 0, `${badgeCount} badges (want 0)`);
    const sidebarText = await page.$eval(".sidebar", (el) => el.textContent || "");
    check("no-session-badges", !/\bS\d{2}\b/.test(sidebarText), "no S09-style chips");
    check("no-queued-chips", !/queued/i.test(sidebarText), "no queued chips");

    // 4. Click collapse → items hidden; reload → state kept (localStorage).
    await page.click('[data-group="Comparison"] .nav-group-label');
    await page.waitForTimeout(300);
    const hiddenAfterClick = await page.$$eval('[data-group="Comparison"] [data-chart]', (els) =>
      els.every((el) => !el.checkVisibility())
    );
    const collapsedClass = await page.$eval('[data-group="Comparison"]', (el) => el.className);
    check(
      "click-collapse",
      hiddenAfterClick && collapsedClass.includes("collapsed"),
      "Comparison hidden"
    );
    await page.reload({ waitUntil: "networkidle" });
    await page.waitForTimeout(1200);
    const hiddenAfterReload = await page.$$eval('[data-group="Comparison"] [data-chart]', (els) =>
      els.every((el) => !el.checkVisibility())
    );
    check("collapse-persists", hiddenAfterReload, "survives reload");

    // 5. Navigating to a chart auto-expands its group.
    await page.goto(`${BASE_URL}/chart/scatter`, { waitUntil: "networkidle" });
    await page.waitForTimeout(1200);
    const scatterVisible = await page.$eval('[data-chart="scatter"]', (el) => el.checkVisibility());
    const scatterActive = await page.$eval('[data-chart="scatter"]', (el) => el.className);
    check(
      "auto-expand-active",
      scatterVisible && scatterActive.includes("active"),
      "scatter visible + active"
    );

    // 6. Keyboard: focus header + Enter toggles.
    await page.focus('[data-group="Flow & accumulation"] .nav-group-label');
    await page.keyboard.press("Enter");
    await page.waitForTimeout(300);
    const kbHidden = await page.$$eval('[data-group="Flow & accumulation"] [data-chart]', (els) =>
      els.every((el) => !el.checkVisibility())
    );
    check("keyboard-toggle", kbHidden, "Enter collapses");

    // 7. Expand all / collapse all pair.
    const expandBtns = await page.$$(".nav-expand-btn");
    check("expand-collapse-pair", expandBtns.length === 2, `${expandBtns.length} controls`);
    await page.click(".nav-expand-btn >> nth=0"); // expand all
    await page.waitForTimeout(300);
    const allVisible = await page.$$eval("[data-chart]", (els) =>
      els.every((el) => el.checkVisibility())
    );
    await page.click(".nav-expand-btn >> nth=1"); // collapse all
    await page.waitForTimeout(300);
    const allHidden = await page.$$eval("[data-chart]", (els) =>
      els.every((el) => !el.checkVisibility())
    );
    check("expand-all", allVisible, "20/20 visible");
    check("collapse-all", allHidden, "20/20 hidden");

    check("zero-console-errors", errors.length === 0, errors.slice(0, 3).join(" | ") || "clean");

    await page.screenshot({ path: join(artifactDir, "nav-groups.png"), fullPage: false });
    await browser.close();

    await fs.writeFile(join(artifactDir, "results.json"), JSON.stringify({ checks }, null, 2));

    const failed = checks.filter((c) => !c.ok);
    console.log(`\n=== Nav QA: ${checks.length - failed.length}/${checks.length} PASS ===`);
    return failed.length === 0;
  } finally {
    server.kill();
  }
}

runQA()
  .then((ok) => process.exit(ok ? 0 : 1))
  .catch((err) => {
    console.error("Nav QA failed:", err);
    process.exit(1);
  });
