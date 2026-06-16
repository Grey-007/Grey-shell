import "."
import QtQuick
import Quickshell
import Quickshell.Wayland

// Material You Control Centre – outer PanelWindow
PanelWindow {
    id: win

    readonly property int screenWidth:  screen != null ? screen.width  : 1366
    readonly property int screenHeight: screen != null ? screen.height : 768
    readonly property int panelWidth:   Math.min(400, Math.max(340, screenWidth - 32))

    function toggle()  { ControlCentreState.toggle();     }
    function open()    { ControlCentreState.openPanel();  }
    function close()   { ControlCentreState.close();      }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ControlCentreState.open
                                 ? WlrKeyboardFocus.OnDemand
                                 : WlrKeyboardFocus.None

    visible: ControlCentreState.open
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // The card itself
    ControlCentreCard {
        id: card

        panelWidth:  win.panelWidth
        panelHeight: win.screenHeight - 80

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            topMargin:    64
            leftMargin:  14
            bottomMargin: 14
        }

        x: ControlCentreState.open ? 14 : -card.panelWidth

        Behavior on x {
            NumberAnimation {
                duration: 250 // Using 250ms for consistent animation speed
                easing.type: Easing.OutCubic
            }
        }
    }
}
