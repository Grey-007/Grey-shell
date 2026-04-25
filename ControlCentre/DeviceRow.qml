import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string glyph: ""
    property bool active: false
    property string actionText: active ? "On" : "Connect"

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 52

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.active ? "#e8efff" : "#f8f5f1"
        border.color: "#0000000d"
        border.width: 1
        antialiasing: true
    }

    RowLayout {
        spacing: 10

        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 10
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.glyph
            color: root.active ? "#2f5fae" : "#5f5a54"
            font.pixelSize: 14
            font.weight: 600
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.title
                color: "#2b2825"
                font.pixelSize: 12
                font.weight: 600
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: "#77706a"
                font.pixelSize: 11
                elide: Text.ElideRight
                visible: text !== ""
            }

        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: Math.max(58, actionLabel.implicitWidth + 22)
            height: 30
            radius: 15
            color: root.active ? "#2f5fae" : "#ebe5df"

            Text {
                id: actionLabel

                anchors.centerIn: parent
                text: root.actionText
                color: root.active ? "#ffffff" : "#413d38"
                font.pixelSize: 11
                font.weight: Font.Medium
            }

        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

}
