import QtQuick
import QtQuick.Layouts
import "../colors"

// SepiaShell – device / network row inside expanded menu panels
Item {
    id: root

    property string title:      ""
    property string subtitle:   ""
    property string glyph:      ""
    property bool   active:     false
    property string actionText: active ? "Active" : "Connect"

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 54

    // ── SepiaShell colour tokens ─────────────────────────────────────
                                    
    // ── Row background ───────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 0
        color: root.active ? root.ThemeManager.surfaceTop : root.ThemeManager.surfaceHigh
        scale: pressArea.containsPress ? 0.985 : 1.0
        border.color: root.active ? "#5A4736" : "transparent"
        border.width: 1

        Behavior on color  { ColorAnimation  { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on scale  { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: 180 } }
    }

    RowLayout {
        spacing: 10
        anchors {
            fill: parent
            leftMargin:  12
            rightMargin: 10
        }

        // Glyph
        Text {
            Layout.alignment: Qt.AlignVCenter
            text:           root.glyph
            color:          root.active ? root.ThemeManager.accent : root.ThemeManager.fgMid
            font.pixelSize: 15
            font.family:    "monospace"

            Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }

        // Title + subtitle
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text:           root.title
                color:          root.ThemeManager.fg
                font.pixelSize: 12
                font.family:    "monospace"
                font.weight:    Font.DemiBold
                elide:          Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text:           root.subtitle
                color:          root.ThemeManager.fgMid
                font.pixelSize: 11
                font.family:    "monospace"
                elide:          Text.ElideRight
                visible:        text !== ""
            }
        }

        // Action chip
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width:  Math.max(52, actionLabel.implicitWidth + 20)
            height: 26
            radius: 0
            color:  root.active ? ThemeManager.accent : ThemeManager.bg
            border.color: root.active ? "transparent" : "#5A4736"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Text {
                id: actionLabel
                anchors.centerIn: parent
                text:           root.actionText
                color:          root.active ? root.ThemeManager.fgInverted : root.ThemeManager.accent
                font.pixelSize: 11
                font.family:    "monospace"
                font.weight:    Font.Medium

                Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
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
