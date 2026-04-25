import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

// Workspaces.qml
// Dots that morph into a short pill for the active workspace.
// Inactive = small circle dot, active = rounded rect line.
Row {
    id: root
    spacing: 6

    // Show workspace slots 1–10
    Repeater {
        model: 10

        delegate: Item {
            id: wsDot
            required property int index

            readonly property int wsId: index + 1
            readonly property bool isActive: (Hyprland.focusedWorkspace?.id ?? -1) === wsId
            readonly property bool hasWindows: {
                for (const ws of Hyprland.workspaces) {
                    if (ws.id === wsId && ws.windowCount > 0) return true
                }
                return false
            }
            readonly property bool shouldShow: wsId <= 5 || isActive || hasWindows

            visible: shouldShow
            width: isActive ? 30 : 8
            height: 8

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 100
                color: isActive ? "#000000" : "#000000"

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsId)
            }
        }
    }
}
