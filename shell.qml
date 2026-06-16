import "Bar"
import "Bar/modules" as BarModules
import "ControlCentre" as ControlCentreModule
import "launcher" as LauncherModule
import "lockscreen" as LockScreenModule
import "wallpaper" as WallpaperModule
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    function ensureWallpaperSelector() {
        if (!wallpaperSelectorLoader.active)
            wallpaperSelectorLoader.active = true;

        return wallpaperSelectorLoader.item;
    }

    function lockSession() {
        unlockReleaseTimer.stop();

        if (!sessionLock.locked)
            sessionLock.locked = true;
    }

    Bar {
        id: theBar
        onPowerClicked:    powerMenu.open()
        onCalendarClicked: calendarPopup.toggle()
    }

    LauncherModule.Launcher {
        id: launcher
        visible: false
    }

    BarModules.PowerMenu    { id: powerMenu    }
    BarModules.CalendarPopup { id: calendarPopup }

    ControlCentreModule.ControlCentre    { id: controlCentre }
    ControlCentreModule.NotificationToasts {}

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

    Connections {
        target: LockScreenModule.Auth
        function onUnlocked() {
            unlockReleaseTimer.stop();
            unlockReleaseTimer.start();
        }
    }

    // ── Wallpaper selector ────────────────────────────────────────────────
 //   Component {
   //     id: wallpaperSelectorComponent

   //     WallpaperModule.WallpaperSelector {}
   // }

    Loader {
        id: wallpaperSelectorLoader
        active: false
        sourceComponent: wallpaperSelectorComponent
    }

    // ── IPC: launcher ─────────────────────────────────────────────────────
    IpcHandler {
        target: "launcher"
        function toggle() { launcher.visible = !launcher.visible; if (launcher.visible) launcher.focusOnOpen(); }
        function open()   { launcher.visible = true;  launcher.focusOnOpen(); }
        function close()  { launcher.visible = false; }
    }

    // ── IPC: control centre ───────────────────────────────────────────────
    IpcHandler {
        target: "controlcentre"
        function toggle() { controlCentre.toggle(); }
        function open()   { controlCentre.open();   }
        function close()  { controlCentre.close();  }
    }

    // ── IPC: calendar ─────────────────────────────────────────────────────
    IpcHandler {
        target: "calendar"
        function toggle() { calendarPopup.toggle(); }
        function open()   { calendarPopup.open();   }
        function close()  { calendarPopup.close();  }
    }

    // ── IPC: wallpaper ────────────────────────────────────────────────────
    // qs ipc call wallpaper toggle
    // qs ipc call wallpaper open
    // qs ipc call wallpaper close
  //  IpcHandler {
   //     target: "wallpaper"
   //     function toggle() { ensureWallpaperSelector().toggle(); }
   //     function open()   { ensureWallpaperSelector().open();   }
   //     function close()  {
   //         if (wallpaperSelectorLoader.item)
     //           wallpaperSelectorLoader.item.close();
     //   }
   // }

    // ── IPC: lock screen ───────────────────────────────────────────────────
    // qs ipc call lockscreen lock
    // qs ipc call lockscreen open
    // qs ipc call lockscreen toggle
    IpcHandler {
        target: "lockscreen"
        function toggle() { lockSession(); }
        function open()   { lockSession(); }
        function lock()   { lockSession(); }
    }
}


