import QtQuick

Item {
    id: root

    property string text: ""
    property bool active: false

    signal clicked()

    implicitWidth: Math.max(76, label.implicitWidth + 24)
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.active ? "#2f5fae" : "#ebe5df"
        antialiasing: true
    }

    Text {
        id: label

        anchors.centerIn: parent
        text: root.text
        color: root.active ? "#ffffff" : "#413d38"
        font.pixelSize: 11
        font.weight: Font.Medium
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

}
