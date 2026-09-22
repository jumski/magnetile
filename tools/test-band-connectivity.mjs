// Run: node tools/test-band-connectivity.mjs
// Checks the connected-resize band-follow rule: zones follow a dragged edge
// only when they share the edge band AND connect to the resized tile through
// touching band members (utils.connectedBandIndices).
import assert from "node:assert/strict";
import { connectedBandIndices } from "../src/contents/code/utils.mjs";

const zone = (x, y, w, h) => ({ x, y, width: w, height: h });

// Center + Satellites: split side columns around a full-height center tile.
const satellites = [
    zone(0, 0, 250, 500),      // 0 top-left
    zone(0, 500, 250, 500),    // 1 bottom-left
    zone(250, 0, 500, 1000),   // 2 center
    zone(750, 0, 250, 500),    // 3 top-right
    zone(750, 500, 250, 500),  // 4 bottom-right
];

// Dragging the top edge of bottom-left (1): bottom-right (4) shares the row
// band but the center tile separates them, so it must not follow.
const rowBand = connectedBandIndices(satellites, satellites[1], true, 3);
assert.equal(rowBand[1], true, "resized tile is in its own band");
assert.equal(rowBand[4], undefined, "bottom-right must not follow across the center tile");
assert.equal(rowBand[3], undefined, "top-right is not in the band");

// Dragging the right edge of bottom-left (1): top-left (0) is the stacked
// sibling and follows the shared column edge.
const columnBand = connectedBandIndices(satellites, satellites[1], false, 3);
assert.equal(columnBand[0], true, "stacked sibling follows the shared column edge");
assert.equal(columnBand[2], undefined, "center tile is not in the column band");

// Quadrant grid (default layout order tl, bl, br, tr): dragging the
// horizontal divider moves both bottom tiles.
const quadrants = [
    zone(0, 0, 500, 500),
    zone(0, 500, 500, 500),
    zone(500, 500, 500, 500),
    zone(500, 0, 500, 500),
];
const quadrantRowBand = connectedBandIndices(quadrants, quadrants[1], true, 3);
assert.equal(quadrantRowBand[1], true, "resized quadrant is in its own band");
assert.equal(quadrantRowBand[2], true, "touching bottom-right follows in a quadrant grid");

// Three-tile stack: the far sibling follows through the middle tile.
const stack = [
    zone(0, 0, 250, 400),
    zone(0, 400, 250, 200),
    zone(0, 600, 250, 400),
];
const stackBand = connectedBandIndices(stack, stack[2], false, 3);
assert.equal(stackBand[1], true, "middle sibling touches the resized tile");
assert.equal(stackBand[0], true, "far sibling follows through the middle tile");

// Padded layout: a padding-sized gap between band members stays connected
// with the padding-aware tolerance used by connectedResize.
const padded = [zone(0, 500, 445, 500), zone(455, 500, 445, 500)];
assert.equal(connectedBandIndices(padded, padded[0], true, 13)[1], true, "padding-sized gaps stay connected");
assert.equal(connectedBandIndices(padded, padded[0], true, 3)[1], undefined, "wider-than-tolerance gaps disconnect");

console.log("band connectivity: all checks passed");
