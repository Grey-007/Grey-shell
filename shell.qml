import "AppLauncher" as LauncherModule
import "Bar"
import "Bar/modules" as BarModules
import "ControlCentre" as ControlCentreModule
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Bar {
        id: theBar

        onPowerClicked: powerMenu.open()
    }

    LauncherModule.AppLauncher {
        id: launcher
    }

    BarModules.PowerMenu {
        id: powerMenu
    }

    ControlCentreModule.ControlCentre {
        id: controlCentre
    }

    ControlCentreModule.NotificationToasts {
    }

    IpcHandler {
        function toggle() {
            launcher.toggle();
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

}
