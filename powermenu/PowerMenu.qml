import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// PowerMenu.qml — simple power menu list
Rectangle {
    id: root
    
    signal closeRequested()

    width: 260
    implicitHeight: layout.implicitHeight + 32
    radius: 12
    color: "#2e2118"
    border.color: "#a0784a"
    border.width: 1

    ColumnLayout {
        id: layout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 16
        }
        spacing: 8

        Text {
            text: "Power Menu"
            color: "#d4a45a"
            font.pixelSize: 14
            font.family: "monospace"
            font.weight: Font.DemiBold
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 8
        }

        ListModel {
            id: powerActions
            ListElement { name: "Lock"; icon: "\uf023"; cmd: "loginctl lock-session" }
            ListElement { name: "Suspend"; icon: "\uf186"; cmd: "systemctl suspend" }
            ListElement { name: "Reboot"; icon: "\uf0e2"; cmd: "systemctl reboot" }
            ListElement { name: "Shutdown"; icon: "\uf011"; cmd: "systemctl poweroff" }
        }

        Repeater {
            model: powerActions
            delegate: Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 6
                color: mouseArea.containsMouse ? "#d4a45a" : "#1c1510"
                border.color: "#a0784a"
                border.width: 1
                
                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Text {
                        text: model.icon
                        color: mouseArea.containsMouse ? "#1c1510" : "#d4a45a"
                        font.pixelSize: 14
                        font.family: "monospace"
                    }
                    Text {
                        text: model.name
                        color: mouseArea.containsMouse ? "#1c1510" : "#f0e0c0"
                        font.pixelSize: 14
                        font.family: "monospace"
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.closeRequested()
                        Quickshell.execDetached(["sh", "-c", model.cmd])
                    }
                }
            }
        }
    }
}
