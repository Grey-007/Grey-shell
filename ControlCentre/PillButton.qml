import QtQuick
import QtQuick.Layouts
import "../colors"

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
                                            
    // ── Background pill ──────────────────────────────────────────────
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 0

        color: root.active   ? ThemeManager.accent
             : root.expanded ? ThemeManager.surfaceTop
             : ThemeManager.surfaceHigh

        scale: pressArea.containsPress ? 0.95 : 1.0
        border.color: root.expanded && !root.active ? ThemeManager.border : "transparent"
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
            color: root.active ? ThemeManager.accentSoft : ThemeManager.bg

            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Text {
                anchors.centerIn: parent
                text:           root.glyph
                color:          root.active ? root.ThemeManager.fg : root.ThemeManager.fgMid
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
                color:          root.active ? root.ThemeManager.fgInverted : root.ThemeManager.fg
                font.pixelSize: 13
                font.family:    "monospace"
                font.weight:    Font.DemiBold
                elide:          Text.ElideRight

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
            }

            Text {
                Layout.fillWidth: true
                text:           root.subtitle
                color:          root.active ? root.ThemeManager.fgInverted : root.ThemeManager.fgMid
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
