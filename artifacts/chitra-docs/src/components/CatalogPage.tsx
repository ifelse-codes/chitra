import { useState, useRef, useCallback, useEffect } from "react";
import { Panel, PanelGroup, PanelResizeHandle } from "react-resizable-panels";
import { ansiToHtml } from "../ansi";
import * as chitraCore from "@chitra/core";
import type { ChartDef } from "../data/charts";

type TabName = "example.ts" | "data.ts" | "output.txt";
type VimMode = "NORMAL" | "INSERT";
type RunStatus = "Ready" | "Running…" | "Error";
type RendererChoice = "braille" | "blocks" | "ascii";
type ThemeChoice =
  | "default"
  | "nord"
  | "dracula"
  | "github-dark"
  | "tokyo-night"
  | "solarized"
  | "monochrome";

const RENDERERS: RendererChoice[] = ["braille", "blocks", "ascii"];
const THEMES: ThemeChoice[] = [
  "default", "nord", "dracula", "github-dark", "tokyo-night", "solarized", "monochrome",
];

const LINE_H = 20; // px — must match CSS var(--vim-lh)
const VIM_PAD = 10; // px — must match CSS var(--vim-pad)

// ── Tokenizer ──────────────────────────────────────────────────────────────

const KEYWORDS =
  /^(?:import|from|export|const|let|var|function|return|if|else|for|of|in|async|await|true|false|null|undefined|type|interface|new|typeof)$/;

function esc(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// Single pass: emitted markup is never re-scanned, so a class name like "tok-kw"
// can no longer be picked up by a later string/keyword rule and rendered as text.
const TOKEN_RE =
  /(\/\/[^\n]*|\/\*[\s\S]*?\*\/)|("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|`(?:[^`\\]|\\.)*`)|(\b\d+(?:\.\d+)?\b)|([A-Za-z_$][A-Za-z0-9_$]*)/g;

function hlTs(code: string): string {
  let out = "";
  let last = 0;
  let m: RegExpExecArray | null;
  TOKEN_RE.lastIndex = 0;
  while ((m = TOKEN_RE.exec(code)) !== null) {
    out += esc(code.slice(last, m.index));
    last = m.index + m[0].length;
    const [raw, comment, str, num, word] = m;
    if (comment) out += `<span class="tok-comment">${esc(comment)}</span>`;
    else if (str) out += `<span class="tok-str">${esc(str)}</span>`;
    else if (num) out += `<span class="tok-num">${num}</span>`;
    else if (word) {
      const isCall = /^\s*\(/.test(code.slice(last));
      const cls = KEYWORDS.test(word)
        ? "tok-kw"
        : isCall
          ? "tok-fn"
          : /^[A-Z]/.test(word)
            ? "tok-type"
            : null;
      out += cls ? `<span class="${cls}">${esc(word)}</span>` : esc(word);
    } else out += esc(raw);
  }
  return out + esc(code.slice(last));
}

// ── Helpers ─────────────────────────────────────────────────────────────────

function stripAnsi(s: string): string {
  return s.replace(/\[[^m]*m/g, "");
}

function genDataTab(code: string, chartId: string): string {
  const m = code.match(/data:\s*(\[[\s\S]*?\](?:\s*,)?)/m);
  const arr = m ? m[1].replace(/,$/, "").trim() : "[]";
  return `// Data used by the ${chartId} example\nexport const data = ${arr};\n`;
}

function offsetToLineCol(text: string, offset: number): { line: number; col: number } {
  const before = text.substring(0, offset);
  const lines = before.split("\n");
  return { line: lines.length, col: lines[lines.length - 1].length + 1 };
}

// ── Code transformer ─────────────────────────────────────────────────────────

// Options object of a chart call — the closing `}` is only accepted when it is
// followed by `).render(` / `).toString(`, so nested object literals are skipped.
const CALL_OPTS_RE = /\{([\s\S]*?)\}(\s*\)\s*\.(?:render|toString)\s*\()/g;

// Set `key` on EVERY chart call in the source: replace it in calls that already
// declare it, insert it INSIDE the braces for calls that do not. The previous
// version re-emitted the captured `}` before the inserted key, which closed the
// options object early and produced `fn({...}, key: "v"})` — a syntax error
// ("missing ) after argument list") on every example lacking a renderer/theme key.
function injectOpt(code: string, key: string, value: string): string {
  const existing = new RegExp(`\\b${key}\\s*:\\s*["'][^"']*["']`);
  return code.replace(CALL_OPTS_RE, (_m, body: string, tail: string) => {
    const next = existing.test(body)
      ? body.replace(existing, `${key}: "${value}"`)
      : `${body.replace(/\s*,?\s*$/, "")},\n  ${key}: "${value}"\n`;
    return `{${next}}${tail}`;
  });
}

// Exported so the check suite can assert the REWRITE itself, not only that the
// result ran. Output-differs is weak evidence: many chitra charts legitimately
// render identically across renderers, so a no-op could hide behind them.
export function applyOverrides(code: string, renderer: RendererChoice, theme: ThemeChoice): string {
  return injectOpt(injectOpt(code, "renderer", renderer), "theme", theme);
}

function stripImports(code: string): string {
  return code.replace(/^import\s+[^\n]*(\n|$)/gm, "");
}

// Run the example as STATEMENTS and capture what `.render()` writes to the mocked
// process.stdout. The previous version wrapped the whole program in `return ( … )`,
// which is only valid for a single expression — any multi-statement example (e.g.
// sparkline's three calls) died with "Unexpected token ';'".
function buildFnBody(code: string, renderer: RendererChoice, theme: ThemeChoice): string {
  return `"use strict";\n${stripImports(applyOverrides(code, renderer, theme))}`;
}

// Fallback for code that ends in an expression (e.g. `…toString()`) and therefore
// writes nothing to stdout.
function buildReturnBody(code: string, renderer: RendererChoice, theme: ThemeChoice): string {
  const src = stripImports(applyOverrides(code, renderer, theme)).trimEnd().replace(/;$/, "");
  return `"use strict";\nreturn (\n${src}\n);`;
}

// ── Evaluator ────────────────────────────────────────────────────────────────

interface RunResult {
  ansi: string;
  plain: string;
  ms: number;
  exitCode: number;
  error: string | null;
}

// Exported so `scripts/check-catalog-examples.ts` can execute the REAL evaluator
// against every catalog example — a grep for `new Function` proves nothing.
export function evalCode(
  code: string,
  renderer: RendererChoice,
  theme: ThemeChoice,
): RunResult {
  const t0 = performance.now();
  // Mock process.stdout so any stray .render() calls are captured
  const captured: string[] = [];
  const origProcess = (globalThis as Record<string, unknown>).process;
  (globalThis as Record<string, unknown>).process = {
    stdout: {
      write: (s: string) => { captured.push(s); return true; },
      columns: 80,
      isTTY: true,
    },
    env: {},
  };

  try {
    const api = chitraCore as Record<string, unknown>;
    const keys = Object.keys(api);
    const vals = Object.values(api);
    let result = new Function(...keys, buildFnBody(code, renderer, theme))(...vals);

    // Code that ends in a bare expression writes nothing to stdout — re-run it
    // in expression position and take its value.
    if (captured.length === 0 && typeof result !== "string") {
      result = new Function(...keys, buildReturnBody(code, renderer, theme))(...vals);
    }
    const ms = Math.round(performance.now() - t0);

    // Prefer captured stdout (statement form); fall back to the returned value
    let ansi: string;
    if (captured.length > 0) {
      ansi = captured.join("").replace(/\n$/, "");
    } else if (typeof result === "string" && result.length > 0) {
      ansi = result;
    } else {
      throw new Error(
        "Chart returned no output. Ensure code calls a chart function like line({...}).render().",
      );
    }

    return { ansi, plain: stripAnsi(ansi), ms, exitCode: 0, error: null };
  } catch (err) {
    const ms = Math.round(performance.now() - t0);
    const msg = err instanceof Error ? err.message : String(err);
    return { ansi: "", plain: "", ms, exitCode: 1, error: msg };
  } finally {
    (globalThis as Record<string, unknown>).process = origProcess;
  }
}

// ── CatalogPage ──────────────────────────────────────────────────────────────

export function CatalogPage({ chart }: { chart: ChartDef }) {
  const pristine = useRef(chart.code);

  const [buffer, setBuffer] = useState(chart.code);
  const [activeTab, setActiveTab] = useState<TabName>("example.ts");
  const [mode, setMode] = useState<VimMode>("NORMAL");
  const [curLine, setCurLine] = useState(1);
  const [curCol, setCurCol] = useState(1);
  const [renderer, setRenderer] = useState<RendererChoice>("braille");
  const [theme, setTheme] = useState<ThemeChoice>("default");
  const [runStatus, setRunStatus] = useState<RunStatus>("Ready");
  const [ansiOut, setAnsiOut] = useState("");
  const [plainOut, setPlainOut] = useState("");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [runMs, setRunMs] = useState(0);
  const [exitCode, setExitCode] = useState(0);
  const [copied, setCopied] = useState<"code" | "out" | null>(null);

  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const preRef = useRef<HTMLPreElement>(null);
  const gutterRef = useRef<HTMLDivElement>(null);
  const [scrollTop, setScrollTop] = useState(0);
  const [scrollLeft, setScrollLeft] = useState(0);
  // Track latest values for the evaluator without stale closures
  const bufRef = useRef(buffer);
  const rendRef = useRef(renderer);
  const themeRef = useRef(theme);
  bufRef.current = buffer;
  rendRef.current = renderer;
  themeRef.current = theme;

  // Reset when navigating to a different chart
  useEffect(() => {
    pristine.current = chart.code;
    setBuffer(chart.code);
    setActiveTab("example.ts");
    setAnsiOut("");
    setPlainOut("");
    setErrorMsg(null);
    setExitCode(0);
    setRunStatus("Ready");
    setCurLine(1);
    setCurCol(1);
    setMode("NORMAL");
  }, [chart.id]);

  // Core run function — reads from refs for freshness
  const run = useCallback(
    (codeOverride?: string, rendOverride?: RendererChoice, themeOverride?: ThemeChoice) => {
      const c = codeOverride ?? bufRef.current;
      const r = rendOverride ?? rendRef.current;
      const t = themeOverride ?? themeRef.current;
      setRunStatus("Running…");
      // Yield to React to update status UI before synchronous eval
      setTimeout(() => {
        const res = evalCode(c, r, t);
        setAnsiOut(res.ansi);
        setPlainOut(res.plain);
        setRunMs(res.ms);
        setExitCode(res.exitCode);
        setErrorMsg(res.error);
        setRunStatus(res.error ? "Error" : "Ready");
      }, 0);
    },
    [],
  );

  // Auto-run on mount / chart navigation
  useEffect(() => {
    run(chart.code, "braille", "default");
  }, [chart.id]); // eslint-disable-line react-hooks/exhaustive-deps

  // Tab content helpers
  const tabContent = (tab: TabName): string => {
    if (tab === "example.ts") return buffer;
    if (tab === "data.ts") return genDataTab(chart.code, chart.id);
    if (tab === "output.txt") return plainOut || stripAnsi(chart.preview);
    return "";
  };

  // Scroll-sync: the highlight pre, the gutter and the current-line stripe all
  // have to follow the textarea. Mirroring only the pre left the line numbers,
  // the `~` markers and the stripe frozen in place as soon as the buffer scrolled.
  const syncScroll = useCallback(() => {
    const ta = textareaRef.current;
    if (!ta) return;
    if (preRef.current) {
      preRef.current.scrollTop = ta.scrollTop;
      preRef.current.scrollLeft = ta.scrollLeft;
    }
    if (gutterRef.current) gutterRef.current.scrollTop = ta.scrollTop;
    setScrollTop(ta.scrollTop);
    setScrollLeft(ta.scrollLeft);
  }, []);

  // Cursor tracking
  const trackCursor = useCallback(() => {
    const ta = textareaRef.current;
    if (!ta) return;
    const { line, col } = offsetToLineCol(bufRef.current, ta.selectionStart);
    setCurLine(line);
    setCurCol(col);
  }, []);

  // Keyboard handler
  const onKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === "Escape") {
        setMode("NORMAL");
        textareaRef.current?.blur();
        return;
      }
      if ((e.metaKey || e.ctrlKey) && e.key === "Enter") {
        e.preventDefault();
        run();
        return;
      }
    },
    [run],
  );

  // Toolbar handlers
  const handleRendererChange = (r: RendererChoice) => {
    setRenderer(r);
    run(undefined, r, themeRef.current);
  };
  const handleThemeChange = (t: ThemeChoice) => {
    setTheme(t);
    run(undefined, rendRef.current, t);
  };

  const copy = (what: "code" | "out") => {
    navigator.clipboard.writeText(what === "code" ? buffer : plainOut);
    setCopied(what);
    setTimeout(() => setCopied(null), 1600);
  };

  const download = (what: "ts" | "txt") => {
    const content = what === "ts" ? buffer : plainOut;
    const name = `${chart.id}-example.${what === "ts" ? "ts" : "txt"}`;
    const blob = new Blob([content], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = name;
    a.click();
    URL.revokeObjectURL(url);
  };

  const reset = () => {
    setBuffer(pristine.current);
    setActiveTab("example.ts");
    setMode("NORMAL");
    // Restore the preview too — resetting the buffer while leaving a stale (or
    // errored) preview on screen misreports the state of the code being shown.
    run(pristine.current);
  };

  // Computed layout values
  const lines = buffer.split("\n");
  const totalLines = lines.length;
  const gutterW = String(Math.max(totalLines, 10)).length;
  const pct = Math.round((curLine / totalLines) * 100);
  const statusClass =
    runStatus === "Ready" ? "ready" : runStatus === "Running…" ? "running" : "error";

  return (
    <div className="catalog-page">
      {/* ── Toolbar ─────────────────────────────────────────── */}
      <div className="ct-bar">
        <div className="ct-left">
          <button
            className={`ct-run ${runStatus === "Running…" ? "ct-run-busy" : ""}`}
            onClick={() => run()}
            title="Run (⌘+Enter)"
            disabled={runStatus === "Running…"}
          >
            <span>{runStatus === "Running…" ? "⟳" : "▶"}</span>
            <span>{runStatus === "Running…" ? "Running…" : "Run"}</span>
          </button>
          <span className={`ct-pill ct-pill-${statusClass}`}>{runStatus}</span>
        </div>

        <div className="ct-center">
          <label className="ct-label">Renderer</label>
          <select
            className="ct-select"
            value={renderer}
            onChange={(e) => handleRendererChange(e.target.value as RendererChoice)}
          >
            {RENDERERS.map((r) => (
              <option key={r} value={r}>{r}</option>
            ))}
          </select>

          <label className="ct-label">Theme</label>
          <select
            className="ct-select"
            value={theme}
            onChange={(e) => handleThemeChange(e.target.value as ThemeChoice)}
          >
            {THEMES.map((t) => (
              <option key={t} value={t}>{t}</option>
            ))}
          </select>
        </div>

        <div className="ct-right">
          <button className="ct-btn" onClick={() => copy("code")}>
            {copied === "code" ? "✓ Copied!" : "⧉ Code"}
          </button>
          <button className="ct-btn" onClick={() => copy("out")}>
            {copied === "out" ? "✓ Copied!" : "⧉ Output"}
          </button>
          <button className="ct-btn" onClick={() => download("ts")}>⇩ .ts</button>
          <button className="ct-btn" onClick={() => download("txt")}>⇩ .txt</button>
          <button className="ct-btn ct-reset" onClick={reset}>↺ Reset</button>
        </div>
      </div>

      {/* ── Two-panel split ──────────────────────────────────── */}
      <PanelGroup direction="horizontal" className="catalog-panels">
        {/* LEFT — vim editor */}
        <Panel defaultSize={50} minSize={20} className="vim-panel">
          <div className="vim-editor">
            {/* Tab bar */}
            <div className="vim-tabs">
              <span className="vim-breadcrumb" aria-label="breadcrumb">
                ▸ catalog/{chart.id}/
              </span>
              {(["example.ts", "data.ts", "output.txt"] as TabName[]).map((tab) => (
                <button
                  key={tab}
                  className={`vim-tab${activeTab === tab ? " vim-tab-active" : ""}`}
                  onClick={() => setActiveTab(tab)}
                >
                  {tab}
                </button>
              ))}
            </div>

            {/* Buffer */}
            <div className="vim-buffer">
              {/* Line number gutter */}
              <div
                ref={gutterRef}
                className="vim-gutter"
                aria-hidden="true"
                style={{ minWidth: `${gutterW + 2}ch` }}
              >
                {lines.map((_, i) => (
                  <div
                    key={i}
                    className={`vim-ln${i + 1 === curLine && activeTab === "example.ts" ? " vim-ln-cur" : ""}`}
                  >
                    {i + 1}
                  </div>
                ))}
                {/* ~ tilde markers past EOF */}
                {Array.from({ length: 8 }, (_, i) => (
                  <div key={`tilde-${i}`} className="vim-tilde">~</div>
                ))}
              </div>

              {/* Content area */}
              <div className="vim-content-wrap">
                {activeTab === "example.ts" ? (
                  <>
                    {/* Current-line highlight — VIM_PAD must be added, the text
                        layers are padded and the stripe is not; without it the
                        stripe sat half a line above the line it highlights. */}
                    <div
                      className="vim-curline-hl"
                      style={{ top: VIM_PAD + (curLine - 1) * LINE_H - scrollTop }}
                    />
                    {/* Block cursor — a real filled cell, not a coloured caret.
                        The buffer font is monospace, so `ch` is the exact advance
                        width and Ln/Col place the block without measuring. */}
                    <div
                      className="vim-block-cursor"
                      style={{
                        top: VIM_PAD + (curLine - 1) * LINE_H - scrollTop,
                        left: `calc(${VIM_PAD}px + ${curCol - 1}ch - ${scrollLeft}px)`,
                      }}
                      data-mode={mode}
                    />
                    {/* Syntax-highlighted background pre */}
                    <pre
                      ref={preRef}
                      className="vim-hl"
                      aria-hidden="true"
                      dangerouslySetInnerHTML={{ __html: hlTs(buffer) }}
                    />
                    {/* Transparent textarea overlay — receives input */}
                    <textarea
                      ref={textareaRef}
                      className="vim-ta"
                      value={buffer}
                      onChange={(e) => {
                        setBuffer(e.target.value);
                        bufRef.current = e.target.value;
                        syncScroll();
                        trackCursor();
                      }}
                      onFocus={() => setMode("INSERT")}
                      onBlur={() => setMode("NORMAL")}
                      onKeyDown={onKeyDown}
                      onScroll={syncScroll}
                      onSelect={trackCursor}
                      onClick={trackCursor}
                      onKeyUp={trackCursor}
                      spellCheck={false}
                      autoCorrect="off"
                      autoCapitalize="off"
                      data-gramm="false"
                    />
                  </>
                ) : (
                  <pre className="vim-hl vim-readonly">{tabContent(activeTab)}</pre>
                )}
              </div>
            </div>

            {/* Modeline */}
            <div className="vim-modeline">
              <span className={`vim-mode-badge vim-mode-${mode === "NORMAL" ? "normal" : "insert"}`}>
                -- {mode} --
              </span>
              <span className="vim-ml-path"> catalog/{chart.id}/{activeTab}</span>
              <span className="vim-ml-spacer" />
              <span className="vim-ml-item">typescript</span>
              <span className="vim-ml-sep"> │ </span>
              <span className="vim-ml-item">Ln {curLine}, Col {curCol}</span>
              <span className="vim-ml-sep"> │ </span>
              <span className="vim-ml-item">{pct}%</span>
            </div>
          </div>
        </Panel>

        {/* Resize handle */}
        <PanelResizeHandle className="catalog-resize-handle">
          <div className="catalog-resize-bar" />
        </PanelResizeHandle>

        {/* RIGHT — terminal preview */}
        <Panel defaultSize={50} minSize={20} className="term-panel">
          <div className="term-preview">
            {/* Title bar */}
            <div className="term-titlebar">
              <div className="term-dots">
                <span className="term-dot term-dot-r" />
                <span className="term-dot term-dot-y" />
                <span className="term-dot term-dot-g" />
              </div>
              <span className="term-title">{chart.name}</span>
              <span className={`term-pill term-pill-${statusClass}`}>{runStatus}</span>
            </div>

            {/* Body */}
            <div className="term-body">
              <div className="term-prompt">
                <span className="term-prompt-dollar">$</span>
                <span> tsx example.ts</span>
              </div>

              {errorMsg ? (
                <div className="term-error-block">
                  <pre className="term-error-msg">{errorMsg}</pre>
                </div>
              ) : ansiOut ? (
                <pre
                  className="term-output"
                  dangerouslySetInnerHTML={{ __html: ansiToHtml(ansiOut) }}
                />
              ) : (
                <pre className="term-output term-output-placeholder">{chart.preview}</pre>
              )}
            </div>

            {/* Footer */}
            <div className="term-footer">
              <span className={exitCode !== 0 ? "term-exit-err" : "term-exit-ok"}>
                exit {exitCode}
              </span>
              <span className="term-sep"> · </span>
              <span>{runMs}ms</span>
              <span className="term-sep"> · </span>
              <span>renderer={renderer}</span>
              <span className="term-sep"> · </span>
              <span>theme={theme}</span>
            </div>
          </div>
        </Panel>
      </PanelGroup>
    </div>
  );
}
