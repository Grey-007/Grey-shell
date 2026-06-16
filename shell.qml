import "Bar"
import "Bar/modules" as BarModules
import "ControlCentre" as ControlCentreModule
import "launcher" as LauncherModule
import "lockscreen" as LockScreenModule
import "wallpaper" as WallpaperModule
import "./MusicWidget" as MusicWidgetModule // New import for Music Widget
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    // ... (existing functions) ...

    // ── Music Widget ──────────────────────────────────────────────────────
    Loader {
        id: musicWidgetLoader
        active: true // Always active to keep state for pinning
        source: "MusicWidget/MusicWidget.qml"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        // Initial position off-screen, will be animated in/out
        x: parent.width

        // Detect clicks outside the widget when unpinned to hide it
        MouseArea {
            anchors.fill: parent
            enabled: musicWidgetLoader.item && !musicWidgetLoader.item.pinned && musicWidgetLoader.item._isVisible
            onClicked: musicWidgetLoader.item.hide()
        }
    }

    // ── IPC: music widget ─────────────────────────────────────────────────
    /*
    IpcHandler {
        target: "musicwidget"
        function toggle() {
            if (musicWidgetLoader.item._isVisible) {
                musicWidgetLoader.item.hide()
            } else {
                musicWidgetLoader.item.show()
            }
        }
        function open() { musicWidgetLoader.item.show() }
        function close() { musicWidgetLoader.item.hide() }
    }
    */

    // ... (rest of the shell.qml content) ...


