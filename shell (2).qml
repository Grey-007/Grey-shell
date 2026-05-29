// shell.qml
// Place at: ~/.config/quickshell/launcher/shell.qml
// Toggle with: qs ipc -c launcher call launcher toggle
//
// Hyprland keybind (add to your keybinds.lua):
//   hl.bind(mainMod .. " + Super_L", hl.dsp.exec_cmd("qs ipc -c launcher call launcher toggle"))

import Quickshell
import Quickshell.Io
import QtQuick
import qs.launcher

ShellRoot {
    // The launcher window — hidden by default
    Launcher {
        id: launcherWindow
        visible: false
    }

    // IPC target: "launcher"
    // Call with: qs ipc -c launcher call launcher toggle
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcherWindow.visible = !launcherWindow.visible;
            if (launcherWindow.visible) {
                launcherWindow.focusOnOpen();
            }
        }

        function open(): void {
            launcherWindow.visible = true;
            launcherWindow.focusOnOpen();
        }

        function close(): void {
            launcherWindow.visible = false;
        }
    }
}
