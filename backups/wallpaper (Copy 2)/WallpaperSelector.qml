import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    property bool openState: false

    function toggle(): void {
        openState = !openState
        if (openState) model.refresh()
    }

    function open(): void {
        openState = true
        model.refresh()
    }

    function close(): void {
        openState = false
    }

    WallpaperConfig {
        id: cfg
    }

    WallpaperModel {
        id: model
        directory: cfg.wallpaperDirectory
        scanDepth: cfg.scanDepth
        onApplyRequested: function(path) {
            wallpaperSetter.exec(cfg.applyCommand.concat([path]))
        }
    }

    Process {
        id: wallpaperSetter
    }

    anchors { left: true; right: true; top: true }

    margins {
        top:   74
        left:  Math.max(16, Math.round(((screen != null ? screen.width : 1366) - cfg.panelWidth) / 2))
        right: Math.max(16, Math.round(((screen != null ? screen.width : 1366) - cfg.panelWidth) / 2))
    }

    height:  cfg.panelHeight
    visible: openState || gridWrap.opacity > 0.01
    color:   "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: openState ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace:     "grey-shell-wallpaper"

    // ── Backdrop blur / dim ────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:   "#0d000000"
        opacity: root.openState ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: cfg.openDuration; easing.type: Easing.OutCubic }
        }
    }

    Item {
        id: gridWrap
        anchors.centerIn: parent
        width:  grid.implicitWidth
        height: grid.implicitHeight

        // Open: fade + scale up from slightly below
        opacity: root.openState ? 1.0 : 0.0
        scale:   root.openState ? 1.0 : 0.94

        // Vertical slide: slides up when opening, down when closing
        transform: Translate {
            y: root.openState ? 0 : 18
            Behavior on y {
                NumberAnimation { duration: cfg.openDuration + 40; easing.type: Easing.OutCubic }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: cfg.openDuration; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: cfg.openDuration + 30; easing.type: Easing.OutBack; easing.overshoot: 0.4 }
        }

        // Scroll to page
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function(wheel) {
                if (wheel.angleDelta.y < 0 || wheel.angleDelta.x < 0)
                    grid.nextPage()
                else
                    grid.previousPage()
            }
        }

        HoneycombGrid {
            id: grid
            anchors.centerIn: parent
            wallpaperModel: model
            config: cfg
            onWallpaperChosen: function(path) {
                model.apply(path)
            }
        }
    }

    // ── Loading indicator ──────────────────────────────────────────
    Text {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 10 }
        text:    model.loading ? "Scanning…" : (model.count > 0 ? model.count + " wallpapers" : "")
        color:   "#88ffffff"
        font.pixelSize: 11
        visible: root.openState
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Keys.onEscapePressed:  close()
    Keys.onLeftPressed:    grid.previousPage()
    Keys.onRightPressed:   grid.nextPage()
    Keys.onUpPressed:      grid.previousPage()
    Keys.onDownPressed:    grid.nextPage()
}
