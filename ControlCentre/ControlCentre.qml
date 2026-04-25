import "."
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: win

    readonly property int screenWidth: screen != null ? screen.width : 1366
    readonly property int screenHeight: screen != null ? screen.height : 768
    readonly property int panelWidth: Math.min(396, Math.max(340, screenWidth - 32))

    function toggle() {
        ControlCentreState.toggle();
    }

    function open() {
        ControlCentreState.openPanel();
    }

    function close() {
        ControlCentreState.close();
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ControlCentreState.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    visible: ControlCentreState.open || card.openProgress > 0.01
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    MouseArea {
        anchors.fill: parent
        enabled: ControlCentreState.open
        onClicked: ControlCentreState.close()
    }

    ControlCentreCard {
        id: card

        panelWidth: win.panelWidth
        panelHeight: win.screenHeight - 24

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 12
        }

    }

}
