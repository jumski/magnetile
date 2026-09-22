import { Workspace, config, QML } from "./core.mjs";

export function log(message, level = "info") {
  if (!config.enableDebugLogging) return;
  console.log(`[${level}] Magnetile jumski: ${message}`);
}

export function osd(text, icon = "preferences-desktop-virtual") {
  if (!config.showOsdMessages) return;
  QML.dbusCall.exec("org.kde.plasmashell", "/org/kde/osdService", "showText", [icon, text]);
}

export function isPointInside(x, y, geometry) {
  return x >= geometry.x && x <= geometry.x + geometry.width && y >= geometry.y && y <= geometry.y + geometry.height;
}

function bandMember(rect, seed, horizontal, tolerance) {
  if (horizontal)
    return Math.abs(rect.y - seed.y) <= tolerance && Math.abs(rect.y + rect.height - (seed.y + seed.height)) <= tolerance;
  return Math.abs(rect.x - seed.x) <= tolerance && Math.abs(rect.x + rect.width - (seed.x + seed.width)) <= tolerance;
}

export function spansTouch(a, b, horizontal, tolerance) {
  if (horizontal)
    return !(b.x - (a.x + a.width) > tolerance) && !(a.x - (b.x + b.width) > tolerance);
  return !(b.y - (a.y + a.height) > tolerance) && !(a.y - (b.y + b.height) > tolerance);
}

export function connectedBandIndices(rects, seed, horizontal, tolerance) {
  // Indices of rects in the seed's row band (horizontal: equal top and bottom
  // edges) or column band (equal left and right edges) that are transitively
  // connected to the seed through band rects touching or overlapping along
  // the other axis. Band members separated by non-band zones (e.g. a
  // full-height center tile between two half-height side tiles) are excluded,
  // so resizing one side of a layout never drags the other side along.
  const members = [];
  for (let i = 0; i < rects.length; i++) {
    const rect = rects[i];
    if (rect && bandMember(rect, seed, horizontal, tolerance))
      members.push(i);
  }

  const connected = {};
  const queue = [];
  for (let m = 0; m < members.length; m++) {
    const index = members[m];
    if (spansTouch(rects[index], seed, horizontal, tolerance)) {
      connected[index] = true;
      queue.push(index);
    }
  }
  while (queue.length > 0) {
    const current = queue.pop();
    for (let m = 0; m < members.length; m++) {
      const index = members[m];
      if (connected[index])
        continue;
      if (spansTouch(rects[index], rects[current], horizontal, tolerance)) {
        connected[index] = true;
        queue.push(index);
      }
    }
  }
  return connected;
}

export function isHovering(item) {
  const itemGlobal = item.mapToGlobal(Qt.point(0, 0));
  return isPointInside(Workspace.cursorPos.x, Workspace.cursorPos.y, {
    x: itemGlobal.x,
    y: itemGlobal.y,
    width: item.width * item.scale,
    height: item.height * item.scale,
  });
}
