/**
 * sre-dashboard.ts — CLI entry for the SRE dashboard.
 *
 *   ./playground/sre-dashboard/sre-test.sh --once       # single frame
 *   ./playground/sre-dashboard/sre-test.sh              # live, updates in place
 */

import { SRESim, warmup } from "./sre-sim.js";
import { renderFrame } from "./sre-frame.js";

const once = process.argv.includes("--once");

const sim = new SRESim();
warmup(sim);

if (once) {
  process.stdout.write(renderFrame(sim));
  process.exit(0);
}

// Live mode: write frame, then move cursor back up to overwrite on next tick
process.stdout.write("\x1b[?25l"); // hide cursor

let prevLines = 0;

function draw() {
  sim.tick();
  const frame = renderFrame(sim);
  const lines = frame.split("\n").length;

  // Move cursor up to start of previous frame, then write new frame
  let out = "";
  if (prevLines > 0) {
    out += `\x1b[${prevLines}A`; // move up
  }
  out += frame;
  // Clear any leftover lines from previous frame
  if (lines < prevLines) {
    for (let i = lines; i < prevLines; i++) {
      out += "\x1b[2K"; // clear line
      if (i < prevLines - 1) out += "\n";
    }
    out += `\x1b[${prevLines - lines}A`; // move back up
  }
  process.stdout.write(out);
  prevLines = lines;
}

draw();
const timer = setInterval(draw, 2000);

const cleanup = () => {
  clearInterval(timer);
  process.stdout.write("\x1b[?25h"); // show cursor
  process.exit(0);
};
process.on("SIGINT", cleanup);
process.on("SIGTERM", cleanup);
