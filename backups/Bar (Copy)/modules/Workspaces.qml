import QtQuick
import Quickshell
import Quickshell.Hyprland

// Dots expand with Hyprland's positive-numbered workspaces.
Row {
    id: root

    spacing: 0

    readonly property int minimumWorkspaces: 5
    readonly property int prewarmWorkspaces: 5
    readonly property int activeWorkspaceId: Hyprland.focusedWorkspace?.id ?? 1
    property int visibleWorkspaceCount: minimumWorkspaces + prewarmWorkspaces
    readonly property color accent: "#b7ff3c"
    readonly property color activeInk: "#071006"
    readonly property color inactiveInk: "#d9ffc2"
    readonly property color emptyInk: "#6d805e"

    onActiveWorkspaceIdChanged: syncWorkspaceCount()
    Component.onCompleted: syncWorkspaceCount()

    function highestWorkspaceId() {
        var highest = 0
        const workspaces = Hyprland.workspaces.values || []

        for (const workspace of workspaces) {
            if (workspace.id > highest)
                highest = workspace.id
        }

        return highest
    }

    function workspaceById(id) {
        const workspaces = Hyprland.workspaces.values || []

        for (const workspace of workspaces) {
            if (workspace.id === id)
                return workspace
        }

        return null
    }

    function syncWorkspaceCount() {
        visibleWorkspaceCount = Math.max(
            visibleWorkspaceCount,
            minimumWorkspaces + prewarmWorkspaces,
            highestWorkspaceId() + prewarmWorkspaces,
            activeWorkspaceId + prewarmWorkspaces
        )
    }

    Connections {
        target: Hyprland
        function onWorkspacesChanged() {
            root.syncWorkspaceCount()
        }
    }

    Repeater {
        model: root.visibleWorkspaceCount

        delegate: Item {
            id: wsDot

            required property int index

            readonly property int wsId: index + 1
            readonly property var workspace: root.workspaceById(wsId)
            readonly property bool isActive: root.activeWorkspaceId === wsId
            readonly property bool exists: workspace !== null
            readonly property bool shouldShow: exists || isActive || wsId <= root.minimumWorkspaces

            width: shouldShow ? (isActive ? 36 : 14) : 0
            height: 8
            opacity: shouldShow ? 1 : 0

            Behavior on width {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: wsDot.isActive ? 30 : 8
                height: 8
                radius: height / 2
                color: wsDot.isActive ? root.accent : wsDot.exists ? root.inactiveInk : root.emptyInk
                antialiasing: true

                Behavior on width {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "workspace", wsId.toString()])
            }
        }
    }
}
