import QtQuick

// MediaControls.qml
//
// Cyberdeck-style playback controls for the Media Deck.
// Buttons: Previous, Play/Pause, Next.
Item {
    id: root

    property var mprisService
    property var gifManager // Add gifManager property
    height: 30
    width: parent.width

    Row {
        anchors.centerIn: parent
        spacing: 16

        // -- Previous Button --
        ControlButton {
            text: "◄◄"
            enabled: root.mprisService && root.mprisService.hasPlayer && root.mprisService.canGoPrevious
            onClicked: root.mprisService.previous()
        }

        // -- GIF Switch Button --
        ControlButton {
            text: "GIF"
            width: 40
            enabled: root.gifManager && root.gifManager.hasGifs
            onClicked: {
                if (root.gifManager) {
                    root.gifManager.selectRandomGif();
                }
            }
        }

        // -- Play/Pause Button --
        ControlButton {
            width: 80
            text: root.mprisService && root.mprisService.playbackStatus === "Playing" ? "PAUSE" : "PLAY"
            enabled: root.mprisService && root.mprisService.hasPlayer && root.mprisService.canTogglePlaying
            onClicked: root.mprisService.togglePlaying()
        }

        // -- Next Button --
        ControlButton {
            text: "►►"
            enabled: root.mprisService && root.mprisService.hasPlayer && root.mprisService.canGoNext
            onClicked: root.mprisService.next()
        }
    }

    // -- Button Template --
    component ControlButton: Rectangle {
        property string text: ""
        property bool enabled: true
        signal clicked()

        width: 50
        height: 28
        color: "transparent"
        border.color: mouseArea.containsMouse && enabled ? "#F2E0C8" : "#A67C52"
        border.width: 1
        opacity: enabled ? 1.0 : 0.3

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: "#F2E0C8"
            font.family: "monospace"
            font.pixelSize: 12
            font.bold: true
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: if (parent.enabled) parent.clicked()
        }
    }
}
