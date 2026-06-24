import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// PowerMenuWindow.qml — panel window wrapper for the simple power menu list
PanelWindow {
    id: win

    property bool popupOpen: false

    function toggle() { popupOpen = !popupOpen }
    function open()   { popupOpen = true  }
    function close()  { popupOpen = false }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: popupOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    property bool winVisible: false
    visible: winVisible
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    property bool animatingOut: false
    Timer {
        id: hideTimer
        interval: 220
        onTriggered: win.winVisible = false
    }

    onPopupOpenChanged: {
        if (popupOpen) {
            winVisible = true
        } else {
            hideTimer.restart()
        }
    }

    // Scrim
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        opacity: popupOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        MouseArea {
            anchors.fill: parent
            onClicked: win.close()
        }
    }

    PowerMenu {
        id: pm
        anchors.centerIn: parent
        opacity: popupOpen ? 1 : 0
        scale: popupOpen ? 1.0 : 0.95
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        onCloseRequested: win.close()
    }
}
