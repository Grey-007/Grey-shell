import QtQuick

// Material You chip-style small button
Item {
    id: root

    property string text: ""
    property bool active: false

    signal clicked()

    implicitWidth: Math.max(64, label.implicitWidth + 28)
    implicitHeight: 32

    readonly property color bgOff:    "#2E3228"
    readonly property color bgOn:     "#A8D368"
    readonly property color textOff:  "#CAD5B5"
    readonly property color textOn:   "#1A2510"

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.active ? root.bgOn : root.bgOff
        scale: pressArea.containsPress ? 0.94 : 1.0

        Behavior on color {
            ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutBack
                easing.overshoot: 1.3
            }
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.active ? root.textOn : root.textOff
        font.pixelSize: 11
        font.weight: Font.Medium

        Behavior on color {
            ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
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
