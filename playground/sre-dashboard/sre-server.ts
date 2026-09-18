/**
 * sre-server.ts — Production SRE dashboard HTTP server.
 * Serves ANSI chart output as styled HTML with auto-refresh.
 *
 *   ./playground/sre-dashboard/sre-serve.sh
 *   → http://chitra-dashboard.test:4173
 */

import http from "node:http";
import { SRESim, warmup } from "./sre-sim.js";
import { renderFrame, renderCells } from "./sre-frame.js";

const PORT = 4173;
const REFRESH_MS = 2000;

const sim = new SRESim();
warmup(sim);

const PAGE = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>chitra · SRE Dashboard</title>
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>📊</text></svg>">
<style>
  :root {
    --bg: #0b0b12;
    --surface: #12121e;
    --border: #1e1e30;
    --text: #c6c6ce;
    --muted: #6a6a75;
    --violet: #8B7CF6;
    --green: #4ade80;
    --red: #f87171;
    --amber: #fbbf24;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body { height: 100%; overflow: hidden; }
  body {
    background: var(--bg);
    color: var(--text);
    font-family: "JetBrains Mono", "Cascadia Mono", "Fira Code", Menlo, Consolas, monospace;
    height: 100vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }
  header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 24px;
    border-bottom: 1px solid var(--border);
    background: var(--surface);
    position: sticky;
    top: 0;
    z-index: 100;
  }
  .brand {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .brand h1 {
    font-size: 15px;
    font-weight: 700;
    color: var(--violet);
    letter-spacing: 0.5px;
  }
  .brand span {
    font-size: 11px;
    color: var(--muted);
    border: 1px solid var(--border);
    padding: 2px 6px;
    border-radius: 4px;
  }
  .status-bar {
    display: flex;
    align-items: center;
    gap: 16px;
    font-size: 12px;
  }
  .status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    display: inline-block;
    margin-right: 4px;
    animation: pulse 2s infinite;
  }
  .status-dot.ok { background: var(--green); }
  .status-dot.err { background: var(--red); }
  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }
  .meta { color: var(--muted); }
  .meta b { color: var(--text); font-weight: 600; }
  #refresh-indicator {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--violet);
    opacity: 0;
    transition: opacity 0.15s;
  }
  #refresh-indicator.active { opacity: 1; }
  main {
    flex: 1;
    min-height: 0;
    padding: 8px 10px;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    grid-auto-rows: 1fr;
    grid-auto-flow: row;
    gap: 8px;
    overflow: hidden;
  }
  .cell {
    display: flex;
    flex-direction: column;
    min-height: 0;
    min-width: 0;
    overflow: hidden;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
  }
  .cell.span2 { grid-column: span 2; }
  .cell.span3 { grid-column: 1 / -1; }
  .cell h2 {
    font-size: 9px;
    font-weight: 700;
    letter-spacing: 1.5px;
    color: var(--violet);
    padding: 3px 10px 3px;
    border-bottom: 1px solid var(--border);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    flex: none;
  }
  .cell pre {
    flex: 1;
    min-height: 0;
    overflow: hidden;
    margin: 0;
    padding: 3px 8px;
    font-family: inherit;
    font-size: clamp(9px, 0.62vw, 11px);
    line-height: 1.25;
    color: var(--text);
    white-space: pre;
    tab-size: 4;
  }
  .braille { font-size: 0.85em; opacity: 0.9; }
  #stale {
    position: fixed;
    top: 56px;
    right: 16px;
    background: #1a0a0a;
    border: 1px solid var(--red);
    color: var(--red);
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 11px;
    display: none;
    z-index: 200;
  }
  footer {
    padding: 8px 24px;
    border-top: 1px solid var(--border);
    background: var(--surface);
    font-size: 11px;
    color: var(--muted);
    display: flex;
    justify-content: space-between;
  }
</style>
</head>
<body>
<header>
  <div class="brand">
    <h1>CHITRA SRE</h1>
    <span>v0.1.0</span>
  </div>
  <div class="status-bar">
    <span id="status-text" class="meta">connecting…</span>
    <span class="meta">rps <b id="st-rps">–</b></span>
    <span class="meta">p99 <b id="st-p99">–</b></span>
    <span class="meta">err <b id="st-err">–</b></span>
    <span class="meta">apdex <b id="st-apdex">–</b></span>
    <span class="meta">cpu <b id="st-cpu">–</b></span>
    <span class="meta">mem <b id="st-mem">–</b></span>
    <span id="refresh-indicator"></span>
  </div>
</header>
<main id="grid"></main>
<div id="stale">connection lost — retrying…</div>
<footer>
  <span>mudra theme · 20 chart types · 2-column grid · <span id="foot-tiles">…</span> · auto-refresh ${REFRESH_MS / 1000}s</span>
  <span id="foot-up">chitra terminal charting library</span>
</footer>
<script>
  const grid = document.getElementById("grid");
  const stale = document.getElementById("stale");
  const statusText = document.getElementById("status-text");
  const refreshIndicator = document.getElementById("refresh-indicator");
  const footUp = document.getElementById("foot-up");
  const el = (id) => document.getElementById(id);

  const escHtml = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  function ansiToHtml(text) {
    const re = /\\x1b\\[([0-9;]*)m/g;
    let out = "", last = 0, m;
    let color = null, bold = false, dim = false, open = false;
    const flushOpen = () => { if (open) { out += "</span>"; open = false; } };
    const apply = () => {
      flushOpen();
      let style = "";
      if (color) style += "color:" + color + ";";
      if (bold) style += "font-weight:700;";
      if (dim) style += "opacity:.5;";
      if (style) { out += '<span style="' + style + '">'; open = true; }
    };
    while ((m = re.exec(text))) {
      out += escHtml(text.slice(last, m.index));
      last = re.lastIndex;
      const codes = m[1].split(";").map((c) => parseInt(c || "0", 10));
      let i = 0;
      while (i < codes.length) {
        const c = codes[i];
        if (c === 0) { color = null; bold = false; dim = false; }
        else if (c === 1) bold = true;
        else if (c === 2) dim = true;
        else if (c === 22) { bold = false; dim = false; }
        else if (c === 38 && codes[i + 1] === 2) {
          color = "rgb(" + codes[i + 2] + "," + codes[i + 3] + "," + codes[i + 4] + ")";
          i += 4;
        }
        i++;
      }
      apply();
    }
    out += escHtml(text.slice(last));
    flushOpen();
    return out.replace(/[\u2800-\u28ff]+/g, (m) => '<span class="braille">' + m + '</span>');
  }

  // Measure how many monospace chars fit in a span-N cell, so the server
  // renders charts at exactly the width that fills the tile on any screen.
  const meas = document.createElement("canvas").getContext("2d");
  function colChars() {
    const gridW = grid.clientWidth || window.innerWidth;
    const cellW = (gridW - 8) / 2;
    const pre = grid.querySelector("pre");
    const fs = pre ? parseFloat(getComputedStyle(pre).fontSize) : 10;
    meas.font = fs + 'px "JetBrains Mono", Menlo, Consolas, monospace';
    const adv = meas.measureText("0000000000").width / 10 || fs * 0.6;
    return Math.max(24, Math.min(140, Math.floor((cellW - 20) / adv)));
  }

  async function poll() {
    refreshIndicator.classList.add("active");
    try {
      const s1 = colChars();
      document.getElementById("foot-tiles").textContent = "tiles " + s1 + "ch × 3 rows";
      const qs = "?single=" + s1 + "&wide=" + s1;
      const res = await fetch("/cells" + qs);
      if (!res.ok) throw new Error(res.status);
      const data = await res.json();
      const s = data.stats;
      statusText.innerHTML = s.incident
        ? '<span class="status-dot err"></span> ▲ ' + escHtml(s.incident)
        : '<span class="status-dot ok"></span> nominal';
      el("st-rps").textContent = s.rps.toLocaleString();
      el("st-p99").textContent = s.p99 + "ms";
      el("st-err").textContent = s.errRate + "%";
      el("st-apdex").textContent = s.apdex;
      el("st-cpu").textContent = s.cpu + "%";
      el("st-mem").textContent = s.mem + "%";
      footUp.textContent = "up " + s.up + " · chitra terminal charting library";
      grid.innerHTML = data.cells.map((c) =>
        '<section class="cell"><h2>' +
        escHtml(c.label) + "</h2><pre>" + ansiToHtml(c.output) + "</pre></section>"
      ).join("");
      stale.style.display = "none";
    } catch {
      stale.style.display = "block";
      statusText.innerHTML = '<span class="status-dot err"></span> disconnected';
    }
    setTimeout(() => refreshIndicator.classList.remove("active"), 200);
  }

  poll();
  setInterval(poll, ${REFRESH_MS});
  let rzT = null;
  window.addEventListener("resize", () => {
    clearTimeout(rzT);
    rzT = setTimeout(poll, 300);
  });
</script>
</body>
</html>`;

const server = http.createServer((req, res) => {
  if (req.url === "/frame") {
    sim.tick();
    const body = Buffer.from(renderFrame(sim), "utf8");
    res.writeHead(200, { "content-type": "text/plain; charset=utf-8", "cache-control": "no-store" });
    res.end(body);
    return;
  }
  if (req.url === "/cells" || req.url?.startsWith("/cells?")) {
    sim.tick();
    const u = new URL(req.url, "http://localhost");
    const clampN = (v: string | null, fb: number): number => {
      const n = v === null ? NaN : parseInt(v, 10);
      return Number.isFinite(n) ? Math.max(24, Math.min(160, n)) : fb;
    };
    const w = clampN(u.searchParams.get("single"), 34);
    const body = Buffer.from(JSON.stringify(renderCells(sim, w, w)), "utf8");
    res.writeHead(200, { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" });
    res.end(body);
    return;
  }
  if (req.url === "/" || req.url?.startsWith("/index")) {
    res.writeHead(200, { "content-type": "text/html; charset=utf-8", "cache-control": "no-store" });
    res.end(PAGE);
    return;
  }
  res.writeHead(404, { "content-type": "text/plain" });
  res.end("not found");
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`chitra · sre dashboard → http://localhost:${PORT}`);
  console.log(`  or: http://chitra-dashboard.test:${PORT}`);
});
