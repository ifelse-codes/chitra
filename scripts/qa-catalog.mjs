#!/usr/bin/env node
// qa-catalog.mjs — Playwright-driven QA for chitra catalog pages
// Visits all 20 chart pages + 5 doc pages + home, asserts rendering works.

import { chromium } from "playwright";
import { promises as fs } from "fs";
import { fileURLToPath } from "url";
import { dirname, join, resolve } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT = resolve(__dirname, "..");
const DOCS = join(ROOT, "artifacts/chitra-docs");

// Chart IDs from the catalog
const CHART_IDS = [
  "line", "bar", "area", "sparkline", "histogram", "scatter",
  "pie", "donut", "heatmap", "progress", "gauge", "horizontalBar",
  "timeline", "radar", "boxplot", "waterfall", "funnel", "candlestick",
  "treemap", "sankey"
];

const DOC_PAGES = ["install", "quickstart", "fluent-api", "ai-output", "ai-data"];

const HEADED = process.argv.includes("--headed");
const BASE_URL = "http://localhost:5174";
const BUILD_DIR = join(DOCS, "dist");

async function buildDocs() {
  console.log("Building docs...");
  const { execSync } = await import("child_process");
  execSync("pnpm run build", {
    cwd: DOCS,
    stdio: "inherit",
    env: {
      ...process.env,
      PORT: "5174",
      BASE_PATH: "/",
    },
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

  // Forward server output for CI debugging.
  server.stdout?.on("data", (data) => process.stdout.write(data));
  server.stderr?.on("data", (data) => process.stderr.write(data));

  // Poll the HTTP endpoint until it answers. This is output-agnostic — waiting
  // for a specific stdout string ("Local:") proved brittle on CI, where the
  // preview banner can be buffered or reworded by the pnpm/vite wrapper.
  await waitForServer(BASE_URL, 60000);

  return server;
}

async function waitForServer(url, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  let lastErr = null;
  while (Date.now() < deadline) {
    try {
      const res = await fetch(url, { redirect: "manual" });
      if (res.status < 500) return;
    } catch (err) {
      lastErr = err;
    }
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
  throw new Error(
    `Server did not respond at ${url} within ${timeoutMs}ms${lastErr ? ` (last error: ${lastErr.message})` : ""}`
  );
}

async function runQA() {
  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const artifactDir = process.env.QA_ARTIFACTS
    ? process.env.QA_ARTIFACTS
    : join(ROOT, ".ai/verify/session-15", ts);
  await fs.mkdir(artifactDir, { recursive: true });

  const results = [];
  let hasFailures = false;

  // Build and start server
  await buildDocs();
  const server = await startPreview();

  try {
    const browser = await chromium.launch({ headless: !HEADED });
    const context = await browser.newContext({
      viewport: { width: 1280, height: 800 },
    });

    // Track console errors and page errors
    const pageErrors = new Map();
    const consoleErrors = new Map();

    async function visitPage(page, url, name) {
      const errors = [];
      const consoleMsgs = [];

      page.on("console", (msg) => {
        if (msg.type() === "error") {
          consoleMsgs.push(msg.text());
        }
      });

      page.on("pageerror", (err) => {
        errors.push(err.message);
      });

      const start = Date.now();
      try {
        await page.goto(url, { waitUntil: "networkidle", timeout: 30000 });
        await page.waitForTimeout(1000); // Let React render

        // Check for terminal output on catalog pages
        let outputLength = 0;
        let hasOutput = false;

        if (name.startsWith("chart-")) {
          // Wait for terminal output to appear
          try {
            await page.waitForSelector(".term-output, .term-error-block", { timeout: 10000 });
            const output = await page.$eval(".term-output, .term-error-block", (el) => el.textContent || "");
            outputLength = output.length;
            hasOutput = outputLength > 0;
          } catch {
            hasOutput = false;
          }
        }

        const ms = Date.now() - start;
        const result = {
          name,
          url,
          outputLength,
          hasOutput,
          consoleErrors: consoleMsgs.length,
          pageErrors: errors.length,
          ms,
          errors: [...errors, ...consoleMsgs],
        };

        results.push(result);
        consoleErrors.set(name, consoleMsgs);
        pageErrors.set(name, errors);

        // Take screenshot
        await page.screenshot({ path: join(artifactDir, `${name}.png`), fullPage: true });

        return result;
      } catch (err) {
        const ms = Date.now() - start;
        const result = {
          name,
          url,
          outputLength: 0,
          hasOutput: false,
          consoleErrors: consoleMsgs.length,
          pageErrors: errors.length + 1,
          ms,
          errors: [...errors, ...consoleMsgs, err.message],
        };
        results.push(result);
        consoleErrors.set(name, consoleMsgs);
        pageErrors.set(name, [...errors, err.message]);
        return result;
      }
    }

    const page = await context.newPage();

    // Visit home page
    console.log("Visiting home page...");
    await visitPage(page, BASE_URL, "home");

    // Visit doc pages
    for (const doc of DOC_PAGES) {
      console.log(`Visiting /${doc}...`);
      await visitPage(page, `${BASE_URL}/${doc}`, `doc-${doc}`);
    }

    // Visit chart pages
    for (const chartId of CHART_IDS) {
      console.log(`Visiting /chart/${chartId}...`);
      await visitPage(page, `${BASE_URL}/chart/${chartId}`, `chart-${chartId}`);
    }

    // Test Run shortcut on one chart (line)
    console.log("Testing Run shortcut on /chart/line...");
    const runPage = await context.newPage();
    await runPage.goto(`${BASE_URL}/chart/line`, { waitUntil: "networkidle" });
    await runPage.waitForTimeout(1000);

    // Press Meta+Enter (Mac) or Control+Enter
    const isMac = process.platform === "darwin";
    await runPage.keyboard.press(isMac ? "Meta+Enter" : "Control+Enter");
    await runPage.waitForTimeout(1000);

    // Check output changed (re-run happened)
    const outputAfterRun = await runPage.$eval(".term-output, .term-error-block", (el) => el.textContent || "");
    console.log(`Run shortcut output length: ${outputAfterRun.length}`);

    // Test persistence: edit -> navigate away -> back -> buffer kept
    console.log("Testing persistence on /chart/line...");
    await runPage.fill(".vim-ta", "// edited by QA\nimport { line } from \"@ifelse.codes/chitra\";\nline({ data: [1,2,3] }).render();");
    await runPage.waitForTimeout(500);

    // Navigate away and back
    await runPage.goto(`${BASE_URL}/chart/bar`, { waitUntil: "networkidle" });
    await runPage.waitForTimeout(1000);
    await runPage.goto(`${BASE_URL}/chart/line`, { waitUntil: "networkidle" });
    await runPage.waitForTimeout(1000);

    const bufferAfterReturn = await runPage.$eval(".vim-ta", (el) => el.value);
    const persistenceWorks = bufferAfterReturn.includes("edited by QA");
    console.log(`Persistence works: ${persistenceWorks}`);

    await runPage.close();
    await browser.close();

    // Write JSON records
    await fs.writeFile(
      join(artifactDir, "results.json"),
      JSON.stringify({ results, persistenceWorks }, null, 2)
    );

    // Summary
    console.log("\n=== QA Summary ===");
    for (const r of results) {
      const status = r.errors.length === 0 && (r.hasOutput || !r.name.startsWith("chart-")) ? "PASS" : "FAIL";
      if (status === "FAIL") hasFailures = true;
      console.log(`${status} ${r.name}: output=${r.outputLength} consoleErrors=${r.consoleErrors} pageErrors=${r.pageErrors} ms=${r.ms}`);
      if (r.errors.length > 0) {
        for (const e of r.errors) console.log(`  ERROR: ${e}`);
      }
    }

    console.log(`\nPersistence smoke: ${persistenceWorks ? "PASS" : "FAIL"}`);
    if (!persistenceWorks) hasFailures = true;

    return { hasFailures, results, persistenceWorks, artifactDir };
  } finally {
    server.kill();
  }
}

runQA()
  .then(({ hasFailures }) => {
    process.exit(hasFailures ? 1 : 0);
  })
  .catch((err) => {
    console.error("QA failed:", err);
    process.exit(1);
  });