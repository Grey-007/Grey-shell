import "Bar"
import "Bar/modules" as BarModules
import "ControlCentre" as ControlCentreModule
import "launcher" as LauncherModule
import qs.Wallpaper as WallpaperModule
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
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

    // ── Wallpaper selector ────────────────────────────────────────────────
    WallpaperModule.WallpaperSelector {}

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
    IpcHandler {
        target: "wallpaper"
        function toggle() { WallpaperModule.WallpaperState.toggle(); }
        function open()   { WallpaperModule.WallpaperState.open();   }
        function close()  { WallpaperModule.WallpaperState.close();  }
    }
}
