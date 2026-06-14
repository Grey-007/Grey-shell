import QtQuick
import Quickshell
import Quickshell.Hyprland

// Workspace dots — sepia theme, clicking switches workspace
Row {
    id: root

    spacing: 0

    readonly property int minimumWorkspaces:  5
    readonly property int prewarmWorkspaces:  5
    readonly property int activeWorkspaceId:  Hyprland.focusedWorkspace?.id ?? 1
    property int visibleWorkspaceCount: minimumWorkspaces + prewarmWorkspaces

    // Sepia palette
    readonly property color accent:      "#d4a45a"
    readonly property color activeInk:   "#1c1510"
    readonly property color inactiveInk: "#c8a87a"
    readonly property color emptyInk:    "#5a4030"

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
            visibleWorkspaceCount,
            minimumWorkspaces + prewarmWorkspaces,
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
            readonly property bool shouldShow: exists || isActive || wsId <= root.minimumWorkspaces

            // active pill is wider; invisible workspaces collapse
            width:   shouldShow ? (isActive ? 28 : 12) : 0
            height:  10
            opacity: shouldShow ? 1 : 0

            Behavior on width   { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

            // The visible dot/pill — sits left-aligned so gaps stay clean
            Rectangle {
                anchors {
                    left:           parent.left
                    verticalCenter: parent.verticalCenter
                }
                width:  wsDot.isActive ? 24 : 8
                height: 8
                radius: height / 2
                color:  wsDot.isActive
                            ? root.accent
                            : wsDot.exists
                                ? root.inactiveInk
                                : root.emptyInk
                antialiasing: true

                Behavior on width { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation  { duration: 160; easing.type: Easing.OutCubic } }

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

            // Click target — fills the full Item so tiny dots are still easy to hit
            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                // Switch workspace via hyprctl — this is the fix for point 1
                onClicked: Quickshell.execDetached([
                    "hyprctl", "dispatch", "workspace", wsDot.wsId.toString()
                ])
            }
        }
    }
}
