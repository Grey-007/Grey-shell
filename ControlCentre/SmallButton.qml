import QtQuick

// SepiaShell – chip-style small action button
Item {
    id: root

    property string text:   ""
    property bool   active: false

    signal clicked()

    implicitWidth:  Math.max(64, label.implicitWidth + 28)
    implicitHeight: 30

    // ── SepiaShell colour tokens ─────────────────────────────────────
    readonly property color bgOff:   "#3A2E26"
    readonly property color bgOn:    "#A67C52"
    readonly property color textOff: "#A67C52"
    readonly property color textOn:  "#1A1410"

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: root.active ? root.bgOn : root.bgOff
        scale: pressArea.containsPress ? 0.93 : 1.0
        border.color: root.active ? "transparent" : "#5A4736"
        border.width: 1

        Behavior on color  { ColorAnimation  { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on scale  { NumberAnimation { duration: 130; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
        Behavior on border.color { ColorAnimation { duration: 180 } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text:           root.text
        color:          root.active ? root.textOn : root.textOff
        font.pixelSize: 11
        font.family:    "monospace"
        font.weight:    Font.Medium

        Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
