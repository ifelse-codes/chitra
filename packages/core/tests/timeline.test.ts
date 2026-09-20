import { describe, it, expect } from "vitest";
import { timeline } from "../src/charts/timeline.js";
import { stripAnsi } from "../src/ansi.js";
import { resolveTheme, GREY_TONES } from "../src/themes/index.js";

const EVENTS = [
  { label: "Design", start: 0, end: 2 },
  { label: "Build", start: 2, end: 6 },
  { label: "Test", start: 5, end: 7 },
  { label: "Deploy", start: 7, end: 8 },
];

function plainLines(opts: Parameters<typeof timeline>[0]): string[] {
  return stripAnsi(timeline(opts).toString()).split("\n");
}

// A timeline event bar is a run of shade-ramp glyphs (░▒▓█); the `─` track is
// scale, not fill. The peak bar is the solid `█` run in the accent hue.
const RAMP = /[░▒▓█]/;

/** Count coloured RAMP segments by category: how many carry the accent code vs
 *  a grey-ramp code vs anything else. This is the S17 raw-ANSI census method —
 *  the accent must be spent on EXACTLY one event bar (one segment), and every
 *  other bar must be a documented grey tone (never a `theme.colors[i % n]`
 *  rainbow). The `─` track (axis colour) and labels are excluded. */
function accentCensus(opts: Parameters<typeof timeline>[0]): {
  accent: number;
  grey: number;
  other: number;
} {
  const theme = resolveTheme(opts.theme);
  const acc = theme.accent!;
  const out = timeline(opts).toString();
  const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
  let accent = 0;
  let grey = 0;
  let other = 0;
  for (const seg of segs) {
    const code = seg[1]!;
    const body = seg[2]!;
    if (!RAMP.test(body)) continue; // count bar segments only, not track/labels/footer
    if (code === acc) accent++;
    else if (GREY_TONES.includes(code)) grey++;
    else other++;
  }
  return { accent, grey, other };
}

describe("timeline chart — locked S21 design", () => {
  // ── Panel chrome ──────────────────────────────────────────────
  it("has dashed panel frame top (┌╌)", () => {
    expect(plainLines({ events: EVENTS })[0]).toMatch(/^┌╌/);
  });

  it("has dashed panel frame bottom (└╌)", () => {
    const lines = plainLines({ events: EVENTS });
    expect(lines[lines.length - 1]).toMatch(/^└╌/);
  });

  it("has one frame rule separator (│ ╌)", () => {
    const rules = plainLines({ events: EVENTS }).filter((l) => /^│ ╌/.test(l));
    expect(rules.length).toBe(1);
  });

  it("has the uppercase eyebrow row (SPAN)", () => {
    expect(stripAnsi(timeline({ events: EVENTS }).toString())).toMatch(/SPAN/);
  });

  it("keeps the ─ scale track so spans read against the full range", () => {
    // The event past its span shows the dim scale track, never SPACE fill —
    // the track IS the shared time scale (v2 rule: keep the visible scale).
    const rows = plainLines({ events: EVENTS }).filter((l) => /^│ +\S+ +[░▒▓█─]/.test(l));
    expect(rows.length).toBe(EVENTS.length);
    expect(rows.some((l) => /[░▒▓█]─/.test(l) || /─[░▒▓█]/.test(l))).toBe(true);
  });

  it("retires the ▶/◀ markers — no glyph outside the locked vocabulary", () => {
    const plain = stripAnsi(timeline({ events: EVENTS }).toString());
    expect(plain).not.toMatch(/[▶◀]/);
  });

  it("shows the title in the frame when passed", () => {
    const plain = stripAnsi(timeline({ events: EVENTS, title: "Sprint Timeline" }).toString());
    expect(plain).toMatch(/Sprint Timeline/);
  });

  it("carries the +╌…╌+ guide and a min..max scale row under the events", () => {
    const plain = stripAnsi(timeline({ events: EVENTS }).toString());
    expect(plain).toMatch(/\+╌+\+/);
    expect(plain).toMatch(/0\s+8/);
  });

  // ── Summary footer ────────────────────────────────────────────
  it("footer reports N events · longest <label>", () => {
    const plain = stripAnsi(timeline({ events: EVENTS }).toString());
    expect(plain).toMatch(/4 events · longest Build/);
  });

  // ── Intensity IS the shade ramp (the heatmap texture language) ──
  it("encodes span length as the shade ramp, light → dark (░▒▓)", () => {
    // spans: Deploy 1 (lightest ░), Design/Test 2 (▒), Build 4 = peak (solid █
    // in accent). The ramp ordering must survive noColor / toPlain.
    const plain = stripAnsi(timeline({ events: EVENTS }).toString());
    const rowFor = (label: string) => plain.split("\n").find((l) => l.includes(label))!;
    expect(rowFor("Deploy")).toMatch(/░/);
    expect(rowFor("Deploy")).not.toMatch(/[▒▓█]/);
    expect(rowFor("Design")).toMatch(/▒/);
    expect(rowFor("Test")).toMatch(/▒/);
    expect(rowFor("Design")).not.toMatch(/[░▓█]/);
    expect(rowFor("Build")).toMatch(/█/); // peak = solid accent block
  });

  it("uses ONLY documented ramp glyphs as bar fill — no phantom texture", () => {
    const ANSI = /\x1b\[[0-9;]*m|\x1b\[0m/g;
    const out = timeline({ events: EVENTS }).toString();
    for (const row of out.split("\n").filter((l) => RAMP.test(l))) {
      const residue = row.replace(ANSI, "").replace(/[A-Za-z0-9 +.,_…\-│┌┐└┘╌─]/g, "");
      expect(residue).toMatch(/^[░▒▓█]*$/);
    }
  });

  // ── The one accent, spent once on the longest span (S17 RGB method) ─
  it("spends the accent hue EXACTLY once — on one event bar, no rainbow leak", () => {
    const c = accentCensus({ events: EVENTS });
    expect(c.accent).toBe(1);
    expect(c.other).toBe(0); // every non-accent bar is a documented grey tone
    expect(c.grey).toBeGreaterThan(0);
  });

  it("every bar colour is the accent or a documented grey tone", () => {
    const acc = resolveTheme(undefined).accent!;
    const out = timeline({ events: EVENTS }).toString();
    const segs = [...out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g)];
    const barCodes = new Set(
      segs.filter((s) => RAMP.test(s[2]!)).map((s) => s[1]!)
    );
    for (const code of barCodes) {
      expect(code === acc || GREY_TONES.includes(code)).toBe(true);
    }
  });

  it("the accent lands on the LONGEST span (ties → first in event order)", () => {
    // Build (4) is the longest span; a tie between two 3-spans resolves to the first.
    const plain = stripAnsi(timeline({ events: EVENTS }).toString());
    expect(plain).toMatch(/longest Build/);
    const tie = [
      { label: "first", start: 0, end: 3 },
      { label: "second", start: 1, end: 4 },
      { label: "short", start: 0, end: 1 },
    ];
    const tiePlain = stripAnsi(timeline({ events: tie }).toString());
    expect(tiePlain).toMatch(/longest first/);
    expect(accentCensus({ events: tie }).accent).toBe(1);
  });

  it("an explicit event.color stays a user override (not a theme rainbow)", () => {
    const out = timeline({
      events: [
        { label: "a", start: 0, end: 2, color: "\x1b[38;5;208m" },
        { label: "b", start: 1, end: 4 },
      ],
    }).toString();
    expect(out).toMatch(/\x1b\[38;5;208m/); // the user's colour is honoured
    expect(accentCensus({
      events: [
        { label: "a", start: 0, end: 2 },
        { label: "b", start: 1, end: 4 },
      ],
    }).accent).toBe(1); // the DEFAULT path stays accent-once
  });

  // ── Degenerate data is safe ───────────────────────────────────
  it("empty events render a framed 0 events panel with no Infinity/NaN", () => {
    const plain = stripAnsi(timeline({ events: [] }).toString());
    expect(plain).toMatch(/0 events · \(no data\)/);
    expect(plain).not.toMatch(/Infinity|NaN/);
    expect(plain).toMatch(/^┌╌/m);
    expect(plain).toMatch(/^└╌/m);
  });

  it("a collapsed range (all events at one instant) renders honestly", () => {
    const same = [
      { label: "a", start: 5 },
      { label: "b", start: 5 },
    ];
    const plain = stripAnsi(timeline({ events: same }).toString());
    expect(plain).toMatch(/longest a/); // tie → first event takes the accent
    expect(plain).not.toMatch(/NaN|Infinity/);
    expect(accentCensus({ events: same }).accent).toBe(1);
  });

  it("a point event (no end) renders exactly one lightest-shade glyph", () => {
    const plain = stripAnsi(timeline({
      events: [
        { label: "milestone", start: 3 },
        { label: "phase", start: 0, end: 6 },
      ],
    }).toString());
    const row = plain.split("\n").find((l) => l.includes("milestone"))!;
    const glyphs = row.match(/[░▒▓█]/g) ?? [];
    expect(glyphs.length).toBe(1);
    expect(glyphs[0]).toBe("░"); // honestly zero-length → lightest ramp step
    expect(accentCensus({ events: [
      { label: "milestone", start: 3 },
      { label: "phase", start: 0, end: 6 },
    ] }).accent).toBe(1); // the 6-span phase takes the accent
  });

  it("an end before start is honestly zero-length (one glyph, no crash)", () => {
    const events = [
      { label: "backwards", start: 4, end: 1 },
      { label: "normal", start: 0, end: 6 },
    ];
    const plain = stripAnsi(timeline({ events }).toString());
    expect(plain).not.toMatch(/NaN|Infinity/);
    const row = plain.split("\n").find((l) => l.includes("backwards"))!;
    const glyphs = row.match(/[░▒▓█]/g) ?? [];
    expect(glyphs.length).toBe(1);
    expect(glyphs[0]).toBe("░");
  });

  it("a single event renders safely with its own longest label", () => {
    const plain = stripAnsi(timeline({ events: [{ label: "solo", start: 2, end: 5 }] }).toString());
    expect(plain).toMatch(/1 events · longest solo/);
    expect(accentCensus({ events: [{ label: "solo", start: 2, end: 5 }] }).accent).toBe(1);
  });

  it("honours explicit min/max scale overrides", () => {
    const plain = stripAnsi(timeline({ events: EVENTS, min: -2, max: 10 }).toString());
    expect(plain).toMatch(/-2\s+10/);
  });

  it("noColor renders plain shade glyphs and no escape codes", () => {
    const out = timeline({ events: EVENTS, noColor: true }).toString();
    expect(out).not.toMatch(/\x1b\[/);
    expect(out).toMatch(/█/); // the peak, solid
    expect(out).toMatch(/[░▒]/); // the ramp steps for the rest
    expect(out).toMatch(/─/);
  });

  // ── Agent output surface ──────────────────────────────────────
  it("toJSON carries type/events/min/max/peak/plain", () => {
    const json = timeline({ events: EVENTS }).toJSON() as Record<string, unknown>;
    expect(json.type).toBe("timeline");
    expect(json.min).toBe(0);
    expect(json.max).toBe(8);
    expect(json.peak).toEqual({ index: 1, label: "Build", span: 4 });
    expect(typeof json.plain).toBe("string");
    expect(stripAnsi(json.plain as string)).toBe(json.plain);
  });
});
