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
    implicitHeight: 62

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: root.active ? "#dce8ff" : "#f3f0ec"
        border.color: root.expanded ? "#6b87c8" : "#00000010"
        border.width: root.expanded ? 1 : 0
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: 160
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
            width: 32
            height: 32
            radius: 16
            color: root.active ? "#2f5fae" : "#e3ded8"

            Text {
                anchors.centerIn: parent
                text: root.glyph
                color: root.active ? "#ffffff" : "#5f5a54"
                font.pixelSize: 12
                font.weight: 600
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.title
                color: "#272522"
                font.pixelSize: 13
                font.weight: 600
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: "#716a63"
                font.pixelSize: 11
                elide: Text.ElideRight
            }

        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

}
