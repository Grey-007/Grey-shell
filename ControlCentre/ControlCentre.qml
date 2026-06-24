import "."
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Settings/Models"

// SepiaShell Control Centre – outer PanelWindow
PanelWindow {
    id: win

    readonly property int screenWidth:  screen != null ? screen.width  : 1366
    readonly property int screenHeight: screen != null ? screen.height : 768
    readonly property int panelWidth:   Math.min(400, Math.max(340, screenWidth - 32))

    // RIGHT-side slide targets
    readonly property int openX:   screenWidth - panelWidth - 14
    readonly property int closedX: screenWidth + 20          // fully off-screen right

    // Animation duration uses SettingsManager to sync with user preferences
    readonly property int animDuration: SettingsManager.animDuration

    // ── Visibility gating ────────────────────────────────────────────────
    // panelVisible stays TRUE for the full slide-out animation after close,
    // then becomes false so the window releases mouse input from the screen.
    //
    // We use an explicit bool (not `open || timer.running`) to avoid the
    // one-frame race where both sides of the OR are false simultaneously,
    // which caused the flash.
    property bool panelVisible: false

    Connections {
        target: ControlCentreState
        function onOpenChanged() {
            if (ControlCentreState.open) {
                // Show immediately so the slide-in starts from frame 1
                win.panelVisible = true
            } else {
                // Keep visible while the slide-out plays, then hide
                hideTimer.restart()
            }
        }
    }

    Timer {
        id: hideTimer
        interval: win.animDuration + 30   // just past the animation end
        repeat:   false
        onTriggered: win.panelVisible = false
    }

    // ─────────────────────────────────────────────────────────────────────
    function toggle() { ControlCentreState.toggle();    }
    function open()   { ControlCentreState.openPanel(); }
    function close()  { ControlCentreState.close();     }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ControlCentreState.open
                                 ? WlrKeyboardFocus.OnDemand
                                 : WlrKeyboardFocus.None

    // Window is only visible while open OR while sliding out.
    // When fully hidden the input region vanishes → other windows work normally.
    visible: panelVisible
    color: "transparent"

    anchors {
        top:    true
        bottom: true
        left:   true
        right:  true
    }

    // ── Dim scrim (click outside → close) ────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:   "transparent"
        opacity: ControlCentreState.open ? 1 : 0
        enabled: ControlCentreState.open   // no input when faded

        Behavior on opacity {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: ControlCentreState.close()
        }
    }

    // ── Panel card ────────────────────────────────────────────────────────
    ControlCentreCard {
        id: card

        panelWidth:  win.panelWidth
        panelHeight: win.screenHeight - 78 - 300 - 10

        y: 64
        width:  win.panelWidth
        height: win.screenHeight - 78 - 300 - 10

        // Slide in from right → out to right
        x: ControlCentreState.open ? win.openX : win.closedX

        Behavior on x {
            NumberAnimation { duration: win.animDuration; easing.type: Easing.OutCubic }
        }
    }

    // ── The Notification card ─────────────────────────────────────────────
    NotificationPopupCard {
        id: notifCard
        y: 64 + (win.screenHeight - 78 - 300 - 10) + 10
        width: win.panelWidth
        height: 300
        x: ControlCentreState.open ? win.openX : win.closedX

        Behavior on x {
            NumberAnimation { duration: win.animDuration; easing.type: Easing.OutCubic }
        }
    }
}
