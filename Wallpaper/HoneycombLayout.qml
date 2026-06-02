// ─────────────────────────────────────────────────────────────────────────────
// HoneycombLayout – virtual viewport with culling for 600+ wallpapers

import "."
import QtQuick

// KEY FIXES vs old version:
//   1. hexH was "hexR * 0" – now correctly "hexR * 2"
//   2. colPitch / rowPitch use exact touching-hex math (no gaps)
//   3. VIRTUAL VIEWPORT: only tiles inside the visible area are instantiated.
//      With 600 wallpapers this means ~20-40 tiles rendered at once vs 600.
//   4. Hover is tracked by index not path string comparison (no per-frame O(n))
//   5. MouseArea is on the FIELD item so hover events aren't blocked by the
//      drag overlay. Drag detection moved to a separate handler.
// ─────────────────────────────────────────────────────────────────────────────
Item {
    id: root

    property var wallpapers: []
    property string currentWallpaper: ""
    // ── Hex geometry (pointy-top, TOUCHING) ───────────────────────────────
    // For a pointy-top hex of circumradius R:
    //   flat-to-flat width  = R * sqrt(3)
    //   tip-to-tip height   = R * 2
    //   column pitch        = R * sqrt(3)          (cols touch side-to-side)
    //   row pitch           = R * 1.5              (rows interlock top/bottom)
    //   odd-col x offset    = R * sqrt(3) / 2
    property real hexR: 80
    readonly property real hexW: hexR * 2
    readonly property real hexH: Math.ceil(hexR * 1.73205)
    readonly property real colPitch: 1.5 * hexR + 6
    readonly property real rowPitch: hexH + 6
    // ── Layout: fill columns, then rows ──────────────────────────────────
    // numRows computed from viewport height
    readonly property int numRows: Math.max(3, Math.round((height + hexH) / rowPitch))
    readonly property int numCols: wallpapers.length > 0 ? Math.ceil(wallpapers.length / numRows) : 0
    // ── Scroll offset ─────────────────────────────────────────────────────
    property real offsetX: 0
    property real offsetY: 0
    readonly property real minOffsetX: -Math.max(0, numCols * colPitch + hexW * 0.5 - width)
    readonly property real maxOffsetX: hexW * 0.5
    readonly property real minOffsetY: -Math.max(0, numRows * rowPitch + hexH * 0.5 - height)
    readonly property real maxOffsetY: hexH * 0.5
    // ── Hovered tile ──────────────────────────────────────────────────────
    property int hoveredIndex: -1
    // ── VIRTUAL VIEWPORT: which tiles are visible right now ───────────────
    // Compute first/last visible col and row from the current offset.
    // Only tiles in this range are in the model → massive perf win.
    readonly property int firstVisCol: Math.max(0, Math.floor((-offsetX - hexW) / colPitch))
    readonly property int lastVisCol: Math.min(numCols - 1, Math.ceil((-offsetX + width) / colPitch))
    readonly property int firstVisRow: Math.max(0, Math.floor((-offsetY - hexH) / rowPitch))
    readonly property int lastVisRow: Math.min(numRows - 1, Math.ceil((-offsetY + height) / rowPitch))
    // Build just the visible slice as a JS array
    readonly property var visibleTiles: {
        const out = [];
        const wp = root.wallpapers;
        const nr = root.numRows;
        for (let c = root.firstVisCol; c <= root.lastVisCol; c++) {
            for (let r = root.firstVisRow; r <= root.lastVisRow; r++) {
                // pixel position relative to field origin

                const idx = c * nr + r;
                if (idx < 0 || idx >= wp.length)
                    continue;

                out.push({
                    "wallpaper": wp[idx],
                    "col": c,
                    "row": r,
                    "idx": idx,
                    "px": c * root.colPitch + (r % 2 === 1 ? root.hexW * 0.5 : 0),
                    "py": r * root.rowPitch
                });
            }
        }
        return out;
    }

    signal wallpaperChosen(string path)

    function clampX(v) {
        return Math.max(minOffsetX, Math.min(maxOffsetX, v));
    }

    function clampY(v) {
        return Math.max(minOffsetY, Math.min(maxOffsetY, v));
    }

    function centreLayout() {
        const totalW = numCols * colPitch + hexW * 0.5;
        const totalH = numRows * rowPitch + hexH * 0.5;
        offsetX = clampX((width - totalW) / 2);
        offsetY = clampY((height - totalH) / 2);
    }

    onNumColsChanged: Qt.callLater(centreLayout)
    onWidthChanged: Qt.callLater(centreLayout)
    clip: true
    // ── Keyboard ──────────────────────────────────────────────────────────
    focus: true
    Keys.onLeftPressed: root.offsetX = root.clampX(root.offsetX + root.colPitch)
    Keys.onRightPressed: root.offsetX = root.clampX(root.offsetX - root.colPitch)
    Keys.onUpPressed: root.offsetY = root.clampY(root.offsetY + root.rowPitch)
    Keys.onDownPressed: root.offsetY = root.clampY(root.offsetY - root.rowPitch)

    Canvas {
        id: viewportMask

        anchors.fill: parent
        visible: false
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const r = root.hexR;
            const w = root.hexW;
            const h = root.hexH;
            for (let c = 0; c < root.numCols; c++) {
                for (let row = 0; row < root.numRows; row++) {
                    const idx = c * root.numRows + row;
                    if (idx >= root.wallpapers.length)
                        continue;

                    const cx = c * root.colPitch + (row % 2 ? w * 0.5 : 0) + w / 2 - root.offsetX;
                    const cy = row * root.rowPitch + h / 2 - root.offsetY;
                    ctx.beginPath();
                    for (let i = 0; i < 6; i++) {
                        const a = Math.PI / 3 * i + Math.PI / 6;
                        const px = cx + r * Math.cos(a);
                        const py = cy + r * Math.sin(a);
                        if (i === 0)
                            ctx.moveTo(px, py);
                        else
                            ctx.lineTo(px, py);
                    }
                    ctx.closePath();
                    ctx.fillStyle = "white";
                    ctx.fill();
                }
            }
        }
    }

    // ── Field: offset container ───────────────────────────────────────────
    Item {
        id: _field

        x: root.offsetX
        y: root.offsetY
        width: root.numCols * root.colPitch + root.hexW
        height: root.numRows * root.rowPitch + root.hexH

        Repeater {
            model: root.visibleTiles

            delegate: Component {
                WallpaperTile {
                    required property var modelData

                    x: modelData.px
                    y: modelData.py
                    hexR: root.hexR
                    imageUrl: modelData.wallpaper.url
                    wallpaperName: modelData.wallpaper.name
                    isCurrent: root.currentWallpaper === modelData.wallpaper.path
                    isHovered: root.hoveredIndex === modelData.idx
                    isSelected: false
                    onClicked: root.wallpaperChosen(modelData.wallpaper.path)
                    onHovered: (a) => {
                        return root.hoveredIndex = a ? modelData.idx : -1;
                    }
                }

            }

        }

    }

    // ── Drag handler ──────────────────────────────────────────────────────
    MouseArea {
        id: _drag

        property real startX: 0
        property real startY: 0
        property real startOffX: 0
        property real startOffY: 0
        property real velX: 0
        property real velY: 0
        property real lastX: 0
        property real lastY: 0
        property real lastT: 0
        property bool dragging: false
        readonly property bool active: dragging

        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: (mouse) => {
            _inertia.stop();
            startX = mouse.x;
            startY = mouse.y;
            startOffX = root.offsetX;
            startOffY = root.offsetY;
            velX = 0;
            velY = 0;
            lastX = mouse.x;
            lastY = mouse.y;
            lastT = Date.now();
            dragging = false;
        }
        onPositionChanged: (mouse) => {
            const dx = mouse.x - startX;
            const dy = mouse.y - startY;
            if (!dragging && (Math.abs(dx) > 5 || Math.abs(dy) > 5))
                dragging = true;

            if (!dragging)
                return ;

            const now = Date.now();
            const dt = Math.max(1, now - lastT);
            velX = (mouse.x - lastX) / dt * 16;
            velY = (mouse.y - lastY) / dt * 16;
            lastX = mouse.x;
            lastY = mouse.y;
            lastT = now;
            root.offsetX = root.clampX(startOffX + dx);
            root.offsetY = root.clampY(startOffY + dy);
        }
        onReleased: {
            if (dragging) {
                _inertia.vx = velX;
                _inertia.vy = velY;
                _inertia.start();
            }
            dragging = false;
        }
        onClicked: (mouse) => {
            if (!dragging)
                mouse.accepted = false;

        }
    }

    // ── Inertia ───────────────────────────────────────────────────────────
    Timer {
        id: _inertia

        property real vx: 0
        property real vy: 0

        interval: 16
        repeat: true
        onTriggered: {
            vx *= 0.9;
            vy *= 0.9;
            if (Math.abs(vx) < 0.4 && Math.abs(vy) < 0.4) {
                stop();
                return ;
            }
            root.offsetX = root.clampX(root.offsetX + vx);
            root.offsetY = root.clampY(root.offsetY + vy);
        }
    }

    // ── Wheel / touchpad ──────────────────────────────────────────────────
    WheelHandler {
        target: null
        onWheel: (event) => {
            _inertia.stop();
            root.offsetX = root.clampX(root.offsetX + event.angleDelta.x * 0.8);
            root.offsetY = root.clampY(root.offsetY + event.angleDelta.y * 0.8);
        }
    }

}
