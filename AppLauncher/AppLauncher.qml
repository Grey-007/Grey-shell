import "."
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: win

    readonly property int screenWidth: screen != null ? screen.width : 790
    readonly property int screenHeight: screen != null ? screen.height : 462
    readonly property int cardW: Math.min(450, Math.max(360, screenWidth - 44))
    readonly property int cardH: Math.min(434, Math.max(370, screenHeight - 28))
    readonly property int flareW: 36
    readonly property int flareH: 50

    function toggle() {
        LauncherState.toggle();
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: LauncherState.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    visible: LauncherState.open || launcherCard.openProgress > 0.01
    implicitHeight: screenHeight
    color: "transparent"

    anchors {
        bottom: true
        left: true
        right: true
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        enabled: LauncherState.open
        onClicked: LauncherState.close()
    }

    LauncherCard {
        id: launcherCard

        cardWidth: win.cardW
        cardHeight: win.cardH
        flareWidth: win.flareW
        flareHeight: win.flareH
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        z: 1
    }

}
