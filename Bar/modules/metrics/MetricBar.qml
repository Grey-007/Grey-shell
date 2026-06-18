import QtQuick

// MetricBar.qml — sepia waveform-bar metric widget
// Shows a compact label + animated bar columns instead of a ring.
// Clicking triggers an optional popup via the clicked() signal.
Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────
    property real   value:       0          // 0-100
    property string icon:        ""         // nerd font glyph
    property string label:       ""         // short label e.g. "CPU"
    property bool   active:      true
    property bool   clickable:   false
    signal clicked()

    // ── Sepia palette ─────────────────────────────────────────────────
    property color  inkColor:    "#d4a45a"
    property color  paperColor:  "#2e2118"
    property color  trackColor:  Qt.rgba(0.83, 0.64, 0.35, 0.15)
    property color  fillColor:   "#d4a45a"
    property color  dimColor:    "#5a4030"

    // ── Sizing ────────────────────────────────────────────────────────
    readonly property int  barCount:  6
    readonly property int  barW:      3
    readonly property int  barGap:    2
    readonly property int  barMaxH:   16
    readonly property int  barsWidth: barCount * barW + (barCount - 1) * barGap

    implicitWidth:  iconLabel.implicitWidth + 4 + barsWidth + 4 + valueLabel.implicitWidth
    implicitHeight: 28

    // Animated smoothed value
    property real animValue: Math.max(0, Math.min(100, value))
    Behavior on animValue {
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }

    // Hover / press
    readonly property bool hovered: hoverArea.containsMouse
    readonly property bool pressed: hoverArea.pressed

    // ── Icon ──────────────────────────────────────────────────────────
    Text {
        id: iconLabel
        anchors {
            left:           parent.left
            verticalCenter: parent.verticalCenter
        }
        text:           root.icon
        color:          root.active ? root.inkColor : root.dimColor
        font.pixelSize: 14
        font.family:    "monospace"
        opacity:        root.active ? 1 : 0.4

        Behavior on color   { ColorAnimation  { duration: 200 } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // ── Waveform bars ─────────────────────────────────────────────────
    Row {
        id: barsRow
        anchors {
            left:           iconLabel.right
            leftMargin:     4
            verticalCenter: parent.verticalCenter
        }
        spacing: barGap

        Repeater {
            model: root.barCount
            delegate: Item {
                id: barSlot
                width:  root.barW
                height: root.barMaxH

                // Each bar represents a band of the value range
                // bar 0 = 0-16%, bar 5 = 83-100%
                readonly property real threshold: ((index + 1) / root.barCount) * 100
                readonly property bool lit:       root.animValue >= threshold - (100 / root.barCount)
                readonly property real fillH:     lit
                    ? Math.min(root.barMaxH, Math.max(2,
                          (root.animValue - (threshold - 100 / root.barCount)) / (100 / root.barCount) * root.barMaxH))
                    : 2

                // Track (always visible at minimum height)
                Rectangle {
                    anchors {
                        bottom:       parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    width:  root.barW
                    height: root.barMaxH
                    radius: root.barW / 2
                    color:  root.trackColor
                    antialiasing: true
                }

                // Fill bar — rises from bottom
                Rectangle {
                    anchors {
                        bottom:           parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    width:  root.barW
                    height: barSlot.fillH
                    radius: root.barW / 2
                    color:  root.active
                        ? (root.value >= 85 && barSlot.index >= root.barCount - 1
                           ? "#e87a52"   // hot amber-red when near max
                           : root.fillColor)
                        : root.dimColor
                    opacity: root.active ? 1 : 0.3
                    antialiasing: true

                    Behavior on height { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }
                    Behavior on color  { ColorAnimation  { duration: 200 } }
                }
            }
        }
    }

    // ── Value label ───────────────────────────────────────────────────
    Text {
        id: valueLabel
        anchors {
            left:           barsRow.right
            leftMargin:     4
            verticalCenter: parent.verticalCenter
        }
        text:           Math.round(root.value) + "%"
        color:          root.hovered ? root.inkColor : Qt.rgba(root.inkColor.r, root.inkColor.g, root.inkColor.b, 0.55)
        font.pixelSize: 9
        font.family:    "monospace"
        opacity:        root.active ? 1 : 0.3

        Behavior on color   { ColorAnimation  { duration: 160 } }
        Behavior on opacity { NumberAnimation { duration: 160 } }
    }

    // Hover glow under the whole widget
    Rectangle {
        anchors.fill: parent
        radius: 4
        color:  root.inkColor
        opacity: root.hovered && root.clickable ? 0.08 : 0
        antialiasing: true
        Behavior on opacity { NumberAnimation { duration: 140 } }
    }

    // ── Mouse ─────────────────────────────────────────────────────────
    MouseArea {
        id: hoverArea
        anchors.fill:    parent
        hoverEnabled:    true
        cursorShape:     root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked:       if (root.clickable) root.clicked()
    }
}
