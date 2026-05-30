import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string glyph: ""
    property bool active: false
    property bool expanded: false

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 58

    readonly property color surfaceLow: "#222A1C"
    readonly property color surfaceHigh: "#2E3824"
    readonly property color primary: "#C5E87A"
    readonly property color onSurface: "#E8F0DC"
    readonly property color onSurfaceVariant: "#A8B598"

    Rectangle {
        id: bg

        anchors.fill: parent
        radius: 16
        color: root.active ? root.primary : (root.expanded ? root.surfaceHigh : root.surfaceLow)
        scale: pressArea.pressed ? 0.97 : 1

        Behavior on color {
            ColorAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    RowLayout {
        spacing: 10

        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 34
            height: 34
            radius: 17
            color: root.active ? "#1A2214" : "#1A2116"

            Text {
                anchors.centerIn: parent
                text: root.glyph
                color: root.active ? root.primary : root.onSurfaceVariant
                font.pixelSize: 15
                font.weight: Font.Medium
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.active ? "#1A2214" : root.onSurface
                font.pixelSize: 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: root.active ? "#2A3820" : root.onSurfaceVariant
                font.pixelSize: 11
                elide: Text.ElideRight
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
