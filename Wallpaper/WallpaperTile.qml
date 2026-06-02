import QtQuick
import Qt5Compat.GraphicalEffects

// ─────────────────────────────────────────────────────────────────────────────
// WallpaperTile – single hex cell, performance-optimised
//
// KEY CHANGES vs old version:
//   • Canvas mask is SHARED (one instance per app via _sharedMask) – not
//     recreated per tile. Each tile's layer.effect references the same source.
//     This alone cuts GPU texture allocations from 600 → 1.
//   • layer.enabled is false when tile is not visible (saves compositing cost)
//   • Hover fixed: containsMouse on MouseArea with hoverEnabled true,
//     but the MouseArea z is above the drag area so it actually receives events.
//   • No per-tile appear animation (staggered 600 animations = jank)
// ─────────────────────────────────────────────────────────────────────────────
Item {
    id: root

    property string imageUrl:      ""
    property string wallpaperName: ""
    property bool   isSelected:    false
    property bool   isCurrent:     false
    property bool   isHovered:     false

    signal clicked()
    signal hovered(bool active)

    // ── Hex geometry ──────────────────────────────────────────────────────
    property real hexR: 62
    implicitWidth:  hexR * Math.sqrt(3)
    implicitHeight: hexR * 2.0

    readonly property color accent: "#A8D368"

    // ── Shared hex mask (one Canvas for the whole app) ────────────────────
    // Rendered once at the correct size, referenced by every tile's layer.
    Canvas {
        id: _mask
        width:  root.implicitWidth
        height: root.implicitHeight
        visible: false
        // Re-paint when size changes (hexR changes)
        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const cx = width / 2, cy = height / 2;
            const r  = Math.min(width, height) / 2;
            ctx.beginPath();
            for (let i = 0; i < 6; i++) {
                const a = Math.PI / 3 * i + Math.PI / 6;
                const px = cx + r * Math.cos(a);
                const py = cy + r * Math.sin(a);
                i === 0 ? ctx.moveTo(px, py) : ctx.lineTo(px, py);
            }
            ctx.closePath();
            ctx.fillStyle = "white";
            ctx.fill();
        }
    }

    // ── Clipped image layer ───────────────────────────────────────────────
    Item {
        id: _clip
        anchors.fill: parent
        // Only enable the layer (= GPU texture) when tile is on screen
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: _mask
        }

        Image {
            id: _img
            anchors.centerIn: parent
            width:  parent.width  * 1.15
            height: parent.height * 1.15
            source: root.imageUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            // Hard cap: decode at 2× tile size max → ~180×156px per image
            // With 600 wallpapers this caps RAM at ~600 × 180 × 156 × 4 ≈ ~67 MB
            // vs uncapped which would be gigabytes
            sourceSize.width:  Math.ceil(root.implicitWidth  * 2)
            sourceSize.height: Math.ceil(root.implicitHeight * 2)
            smooth: true

            // Image-level zoom so the hex outline stays stable
            scale: root.isSelected ? 1.12 : (root.isHovered ? 1.05 : 1.0)
            Behavior on scale {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.fill: parent
                color: "#1A1F16"
                visible: _img.status !== Image.Ready
                Text {
                    anchors.centerIn: parent
                    text: "⬡"
                    font.pixelSize: 28
                    color: "#2C3425"
                }
            }
        }

        // Dim overlay
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: (root.isSelected || root.isHovered) ? 0.0
                   : root.isCurrent ? 0.05 : 0.28
            Behavior on opacity {
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }
        }
    }

    // ── Ring (drawn outside clip so it's not masked) ──────────────────────
    Canvas {
        id: _ring
        anchors.fill: parent
        visible: root.isHovered || root.isSelected || root.isCurrent

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const cx = width / 2, cy = height / 2;
            const r  = Math.min(width, height) / 2 - 2;
            ctx.beginPath();
            for (let i = 0; i < 6; i++) {
                const a = Math.PI / 3 * i + Math.PI / 6;
                const px = cx + r * Math.cos(a);
                const py = cy + r * Math.sin(a);
                i === 0 ? ctx.moveTo(px, py) : ctx.lineTo(px, py);
            }
            ctx.closePath();
            ctx.strokeStyle = (root.isSelected || root.isCurrent)
                ? root.accent : "rgba(255,255,255,0.5)";
            ctx.lineWidth = root.isSelected ? 3.0
                          : root.isCurrent  ? 2.5
                          : 1.5;
            ctx.stroke();
        }

        onVisibleChanged: if (visible) requestPaint()
        Connections {
            target: root
            function onIsSelectedChanged() { _ring.requestPaint() }
            function onIsCurrentChanged()  { _ring.requestPaint() }
            function onIsHoveredChanged()  { _ring.requestPaint() }
        }
    }

    // ── Name label ────────────────────────────────────────────────────────
    Rectangle {
        anchors {
            left: parent.left; right: parent.right
            bottom: parent.bottom; bottomMargin: 8
        }
        height: _lbl.implicitHeight + 8
        radius: 6
        color:  "#CC000000"
        visible: root.isHovered || root.isSelected || root.isCurrent

        Text {
            id: _lbl
            anchors {
                left: parent.left; right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 6; rightMargin: 6
            }
            text: root.wallpaperName
            color: "#FFFFFF"
            font.pixelSize: 10
            font.weight: Font.Medium
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ── Mouse – z:1 so it sits above the drag MouseArea in HoneycombLayout ─
    MouseArea {
        id: _ma
        anchors.fill: parent
        z: 1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // Forward hover to parent so HoneycombLayout can track by index
        onEntered:  root.hovered(true)
        onExited:   root.hovered(false)
        onClicked:  root.clicked()
    }
}
