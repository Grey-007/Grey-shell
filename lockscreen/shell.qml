import Quickshell
import Quickshell.Wayland

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · shell.qml
//
// Locks the Wayland session immediately on launch using the wlr-session-lock
// protocol. A LockScreen is created on every connected monitor. Once Auth
// reports a successful PAM check, the lock is released and quickshell exits
// — never the other way around, so the compositor is never left unlockable.
//
// Run with:  quickshell -c reader-shell
// (see README.md for Hyprland / hypridle integration)
// ─────────────────────────────────────────────────────────────────────────
ShellRoot {
    WlSessionLock {
        id: lock

        // Lock the session the instant quickshell starts.
        locked: true

        WlSessionLockSurface {
            LockScreen {
                anchors.fill: parent
            }
        }
    }

    Connections {
        target: Auth
        function onUnlocked() {
            // Always unlock the session before quitting, or the
            // compositor falls back to an unresponsive secure lock.
            lock.locked = false;
            Qt.quit();
        }
    }
}
