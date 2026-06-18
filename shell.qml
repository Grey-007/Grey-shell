import "Bar"
import "Bar/modules/calendar" as CalendarModule
import "ControlCentre" as ControlCentreModule
import "powermenu" as PowerMenuModule
import "MusicWidget"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "launcher" as LauncherModule
import "lockscreen" as LockScreenModule
import "mediadeck"
import "wallpaper" as WallpaperModule

ShellRoot {
    function lockSession() {
        unlockReleaseTimer.stop();
        if (!sessionLock.locked)
            sessionLock.locked = true;

    }

    Bar {
        id: theBar

        onCalendarClicked: calendarPopup.toggle()
    }

    LauncherModule.Launcher {
        id: launcher

        visible: false
    }
    
    WallpaperModule.WallpaperSelector {
        id: wallpaperSelector
        
        visible: false
    }

    PowerMenuModule.PowerMenuWindow {
        id: powerMenu
    }

    CalendarModule.CalendarPopup {
        id: calendarPopup
    }

    ControlCentreModule.ControlCentre {
        id: controlCentre
    }

    ControlCentreModule.NotificationToasts {
    }

    WlSessionLock {
        id: sessionLock

        locked: false

        WlSessionLockSurface {
            LockScreenModule.LockScreen {
                anchors.fill: parent
            }

        }

    }

    Timer {
        id: unlockReleaseTimer

        interval: LockScreenModule.Config.unlockExitDuration
        repeat: false
        onTriggered: sessionLock.locked = false
    }

    MediaDeck {
        id: mediadeck 
    }

    Connections {
        function onUnlocked() {
            unlockReleaseTimer.stop();
            unlockReleaseTimer.start();
        }

        target: LockScreenModule.Auth
    }

    // ── IPC: launcher ─────────────────────────────────────────────────
    IpcHandler {
        function toggle() {
            launcher.visible = !launcher.visible;
            if (launcher.visible)
                launcher.focusOnOpen();

        }

        function open() {
            launcher.visible = true;
            launcher.focusOnOpen();
        }

        function close() {
            launcher.visible = false;
        }

        target: "launcher"
    }

    // ── IPC: control centre ───────────────────────────────────────────
    IpcHandler {
        function toggle() {
            controlCentre.toggle();
        }

        function open() {
            controlCentre.open();
        }

        function close() {
            controlCentre.close();
        }

        target: "controlcentre"
    }

    // ── IPC: calendar ─────────────────────────────────────────────────
    IpcHandler {
        function toggle() {
            calendarPopup.toggle();
        }

        function open() {
            calendarPopup.open();
        }

        function close() {
            calendarPopup.close();
        }

        target: "calendar"
    }

    // ── IPC: lock screen ──────────────────────────────────────────────
    IpcHandler {
        function toggle() {
            lockSession();
        }

        function open() {
            lockSession();
        }

        function lock() {
            lockSession();
        }

        target: "lockscreen"
    }

    // ── IPC: music widget ─────────────────────────────────────────────
    IpcHandler {
        function toggle() {
            musicWidget.toggle();
        }

        function open() {
            musicWidget.show();
        }

        function close() {
            musicWidget.hide();
        }

        target: "musicwidget"
    }

    // ── IPC: media deck ───────────────────────────────────────────────
    IpcHandler {
        function toggle() {
            mediadeck.toggle();
        }

        function open() {
            mediadeck.show();
        }

        function close() {
            mediadeck.hide();
        }

        target: "mediadeck"
    }

    // ── IPC: wallpaper selector ───────────────────────────────────────
    IpcHandler {
        function toggle() {
            wallpaperSelector.visible = !wallpaperSelector.visible;
        }

        function open() {
            wallpaperSelector.visible = true;
        }

        function close() {
            wallpaperSelector.visible = false;
        }

        target: "wallpaper"
    }

    // ── IPC: power menu ───────────────────────────────────────────────
    IpcHandler {
        function toggle() {
            powerMenu.toggle();
        }

        function open() {
            powerMenu.open();
        }

        function close() {
            powerMenu.close();
        }

        target: "powermenu"
    }

}
