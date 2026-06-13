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

    WallpaperConfig { id: cfg }

    WallpaperModel {
        id: model
        directory: cfg.wallpaperDirectory
        scanDepth: cfg.scanDepth
        onApplyRequested: function(path) {
            wallpaperSetter.exec(cfg.applyCommand.concat([path]))
        }
    }

    Process { id: wallpaperSetter }

    anchors { left: true; right: true; top: true }

    margins {
        top:   74
        left:  Math.max(16, Math.round(((screen != null ? screen.width : 1366) - cfg.panelWidth) / 2))
        right: Math.max(16, Math.round(((screen != null ? screen.width : 1366) - cfg.panelWidth) / 2))
    }

    height:  cfg.panelHeight
    // Keep visible while fade-out plays (opacity > 0.01)
    visible: openState || panelWrap.opacity > 0.01
    // TRANSPARENT — no background rectangle at all
    color:   "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: openState ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace:     "grey-shell-wallpaper"

    // ── Panel wrapper: open/close animation ───────────────────────
    Item {
        id: panelWrap
        anchors.centerIn: parent
        width:  grid.implicitWidth
        height: grid.implicitHeight

        opacity: root.openState ? 1.0 : 0.0
        scale:   root.openState ? 1.0 : 0.92

        transform: Translate {
            y: root.openState ? 0 : 22
            Behavior on y {
                NumberAnimation { duration: cfg.openDuration + 30; easing.type: Easing.OutCubic }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: cfg.openDuration; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation {
                duration: cfg.openDuration + 40
                easing.type: Easing.OutBack
                easing.overshoot: 0.35
            }
        }

        // Wheel scroll → left/right page
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function(wheel) {
                var d = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x
                if (d < 0) grid.nextPage()
                else       grid.previousPage()
            }
        }

        HoneycombGrid {
            id: grid
            anchors.centerIn: parent
            wallpaperModel: model
            config: cfg

            onWallpaperChosen: function(path) {
                model.apply(path)
                grid.animateTile(path)
            }
        }
    }

    // ── Page indicator dots ────────────────────────────────────────
    Row {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 10
        }
        spacing: 6
        visible: root.openState && grid.modelCols > grid.cols

        Repeater {
            model: Math.min(12, Math.ceil(grid.modelCols / grid.cols))
            delegate: Rectangle {
                required property int index
                readonly property bool active:
                    index === Math.floor(grid.pageCol / grid.cols)
                width:  active ? 18 : 6
                height: 6
                radius: 3
                color:  active ? "#7df7c3" : "#44ffffff"
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation  { duration: 150 } }
            }
        }
    }

    // ── Count / loading text ───────────────────────────────────────
    Text {
        anchors {
            bottom: parent.bottom
            right:  parent.right
            bottomMargin: 10
            rightMargin: 20
        }
        text:    model.loading
            ? "Scanning…"
            : model.count > 0 ? model.count + " wallpapers" : ""
        color:   "#66ffffff"
        font.pixelSize: 10
        visible: root.openState
    }

    // Keyboard navigation
    Keys.onEscapePressed: close()
    Keys.onLeftPressed:   grid.previousPage()
    Keys.onRightPressed:  grid.nextPage()
}
