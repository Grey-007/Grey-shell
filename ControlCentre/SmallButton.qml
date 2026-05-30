import QtQuick

Item {
    id: root

    property string text: ""
    property bool active: false

    signal clicked()

    implicitWidth: Math.max(72, label.implicitWidth + 24)
    implicitHeight: 32

    readonly property color primary: "#C5E87A"
    readonly property color surface: "#2A3124"
    readonly property color onSurface: "#E8F0DC"

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.active ? root.primary : root.surface
        scale: pressArea.pressed ? 0.96 : 1

        Behavior on color {
            ColorAnimation {
                duration: 160
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

    Text {
        id: label

        anchors.centerIn: parent
        text: root.text
        color: root.active ? "#1A2214" : root.onSurface
        font.pixelSize: 11
        font.weight: Font.Medium
    }

    MouseArea {
        id: pressArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
