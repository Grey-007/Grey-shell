import QtQuick
import QtQuick.Layouts

// SepiaShell – Quick Settings toggle tile
Item {
    id: root

    property string title:    ""
    property string subtitle: ""
    property string glyph:    ""
    property bool   active:   false
    property bool   expanded: false

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 64

    // ── SepiaShell colour tokens ─────────────────────────────────────
    readonly property color bgOff:        "#2C241D"
    readonly property color bgOn:         "#A67C52"
    readonly property color bgExpanded:   "#3A2E26"
    readonly property color iconBgOff:    "#1A1410"
    readonly property color iconBgOn:     "#7A5A3A"
    readonly property color iconColorOff: "#8C6F56"
    readonly property color iconColorOn:  "#F2E0C8"
    readonly property color titleOff:     "#F2E0C8"
    readonly property color titleOn:      "#1A1410"
    readonly property color subtitleOff:  "#8C6F56"
    readonly property color subtitleOn:   "#2C1A0E"

    // ── Background pill ──────────────────────────────────────────────
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 0

        color: root.active   ? root.bgOn
             : root.expanded ? root.bgExpanded
             : root.bgOff

        scale: pressArea.containsPress ? 0.95 : 1.0
        border.color: root.expanded && !root.active ? "#5A4736" : "transparent"
        border.width: 1

        Behavior on color  { ColorAnimation  { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on scale  { NumberAnimation { duration: 140; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    // Press ripple overlay
    Rectangle {
        anchors.fill: parent
        radius: 0
        color: root.active ? "#25000000" : "#25F2E0C8"
        opacity: pressArea.containsPress ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    // ── Content ──────────────────────────────────────────────────────
    RowLayout {
        spacing: 10
        anchors {
            fill: parent
            leftMargin:   12
            rightMargin:  12
            topMargin:    10
            bottomMargin: 10
        }

        // Icon circle
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 36; height: 36; radius: 0
            color: root.active ? root.iconBgOn : root.iconBgOff

            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Text {
                anchors.centerIn: parent
                text:           root.glyph
                color:          root.active ? root.iconColorOn : root.iconColorOff
                font.pixelSize: 16
                font.family:    "monospace"

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
            }
        }

        // Labels
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text:           root.title
                color:          root.active ? root.titleOn : root.titleOff
                font.pixelSize: 13
                font.family:    "monospace"
                font.weight:    Font.DemiBold
                elide:          Text.ElideRight

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
            }

            Text {
                Layout.fillWidth: true
                text:           root.subtitle
                color:          root.active ? root.subtitleOn : root.subtitleOff
                font.pixelSize: 11
                font.family:    "monospace"
                elide:          Text.ElideRight

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
            }
        }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
