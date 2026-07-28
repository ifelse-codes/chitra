import { sparkline } from "../packages/core/src/index.js";

const temps  = [12, 15, 11, 18, 22, 19, 25, 28, 24, 20, 16, 13];
const errors = [0,  2,  1,  0,  4,  8,  5,  3,  1,  0,  2,  1];
const load   = [0.3, 0.5, 0.6, 0.4, 0.8, 0.9, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2];

sparkline({ data: temps,  label: "Temp °C", showValue: true, renderer: "blocks"  }).render();
sparkline({ data: errors, label: "Errors ", showValue: true, renderer: "braille" }).render();
sparkline({ data: load,   label: "Load   ",                  renderer: "ascii"   }).render();
