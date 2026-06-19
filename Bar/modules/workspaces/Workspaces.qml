import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../../colors"

// Workspaces.qml — sepia theme workspace switcher with improved animations
Row {
    id: root
    spacing: 6

    readonly property int minimumWorkspaces:  5
    readonly property int prewarmWorkspaces:  2
    readonly property int activeWorkspaceId:  Hyprland.focusedWorkspace?.id ?? 1
    property int visibleWorkspaceCount: minimumWorkspaces

    // Sepia palette
                
    onActiveWorkspaceIdChanged: syncWorkspaceCount()
    Component.onCompleted:      syncWorkspaceCount()

    function highestWorkspaceId() {
        var highest = 0
        const workspaces = Hyprland.workspaces.values || []
        for (const ws of workspaces) {
            if (ws.id > highest) highest = ws.id
        }
        return highest
    }

    function workspaceById(id) {
        const workspaces = Hyprland.workspaces.values || []
        for (const ws of workspaces) {
            if (ws.id === id) return ws
        }
        return null
    }

    function syncWorkspaceCount() {
        visibleWorkspaceCount = Math.max(
            minimumWorkspaces,
            highestWorkspaceId() + prewarmWorkspaces,
            activeWorkspaceId  + prewarmWorkspaces
        )
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { root.syncWorkspaceCount() }
    }

    Repeater {
        model: root.visibleWorkspaceCount

        delegate: Item {
            id: wsDot

            required property int index

            readonly property int  wsId:       index + 1
            readonly property var  workspace:  root.workspaceById(wsId)
            readonly property bool isActive:   root.activeWorkspaceId === wsId
            readonly property bool exists:     workspace !== null
            readonly property bool hasClients: exists && workspace.clients > 0
            readonly property bool shouldShow: exists || isActive || wsId <= root.minimumWorkspaces

            // active pill is wider; invisible workspaces collapse
            width:   shouldShow ? (isActive ? 24 : 10) : 0
            height:  8
            opacity: shouldShow ? 1 : 0

            Behavior on width   { NumberAnimation { duration: 350; easing.type: Easing.OutQuint } }
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }

            // The visible dot/pill — sits left-aligned so gaps stay clean
            Rectangle {
                anchors {
                    left:           parent.left
                    verticalCenter: parent.verticalCenter
                }
                width:  wsDot.isActive ? 20 : 6
                height: 6
                radius: height / 2
                color:  wsDot.isActive
                            ? root.ThemeManager.accent
                            : wsDot.exists
                                ? root.ThemeManager.fgMid
                                : root.ThemeManager.fgDim
                antialiasing: true

                Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutQuint } }
                Behavior on color { ColorAnimation  { duration: 250; easing.type: Easing.OutQuint } }

                // Gleam stripe on active pill
                Rectangle {
                    visible: wsDot.isActive
                    anchors {
                        top:         parent.top
                        left:        parent.left
                        right:       parent.right
                        topMargin:   1
                        leftMargin:  3
                        rightMargin: 3
                    }
                    height:  1
                    radius:  1
                    color:   "#ffffff"
                    opacity: 0.35
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "workspace", wsDot.wsId.toString()])
            }
        }
    }
}
