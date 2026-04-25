import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var entry: null
    property bool selected: false
    property int rowIndex: -1

    signal hovered()
    signal launched()

    width: ListView.view != null ? ListView.view.width : 0
    height: 46

    Rectangle {
        height: 38
        radius: 19
        color: root.selected || area.containsMouse ? "#eee6e1" : "transparent"
        opacity: root.selected || area.containsMouse ? 1 : 0
        antialiasing: true

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 2
            rightMargin: 0
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }

        }

    }

    RowLayout {
        spacing: 11

        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 18
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            width: 25
            height: 25

            Image {
                id: icon

                anchors.centerIn: parent
                width: 23
                height: 23
                source: root.entry != null && root.entry.icon !== "" ? Quickshell.iconPath(root.entry.icon, true) : ""
                sourceSize.width: 23
                sourceSize.height: 23
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
            }

            Rectangle {
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 11
                color: "#e8e2dd"
                visible: icon.status !== Image.Ready

                Text {
                    anchors.centerIn: parent
                    text: root.entry != null && root.entry.name !== "" ? root.entry.name.charAt(0).toUpperCase() : "?"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: "#817772"
                }

            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.entry != null ? root.entry.name : ""
                color: "#49423f"
                font.pixelSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                Layout.fillWidth: true
                text: LauncherState.description(root.entry)
                color: "#928984"
                font.pixelSize: 11
                elide: Text.ElideRight
                visible: text !== ""
                verticalAlignment: Text.AlignVCenter
            }

        }

    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onClicked: root.launched()
    }

}
