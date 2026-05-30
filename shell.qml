import "Bar"
import "Bar/modules" as BarModules
import "ControlCentre" as ControlCentreModule
import "launcher" as LauncherModule
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Bar {
        id: theBar

        onPowerClicked: powerMenu.open()
        onCalendarClicked: calendarPopup.toggle()
    }

    LauncherModule.Launcher {
        id: launcher
        visible: false
    }

    BarModules.PowerMenu {
        id: powerMenu
    }

    BarModules.CalendarPopup {
        id: calendarPopup
    }

    ControlCentreModule.ControlCentre {
        id: controlCentre
    }

    ControlCentreModule.NotificationToasts {
    }

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

}
