import QtQuick
import "../components"

// SignalView.qml
//
// A dedicated analysis view for media playback.
// Displays a dominant waveform with technical metadata.
Rectangle {
    id: root
    // The service instances passed in from MediaDeck.qml
    property var mprisService
    property var fakeAudioSource

    anchors.fill: parent
    color: "transparent"

    // -- Waveform Background --
    WaveformLayer {
        id: waveform
        anchors.fill: parent
        audioSource: root.fakeAudioSource
        active: root.mprisService && root.mprisService.playbackStatus === "Playing"
        opacity: 0.8
        z: 1
    }

    // --- Fallback View ---
    Text {
        visible: !mprisService || !mprisService.hasPlayer
        anchors.centerIn: parent
        text: "NO ACTIVE SIGNAL"
        color: "#A67C52"
        font.family: "monospace"
        font.pixelSize: 14
        font.letterSpacing: 2
        z: 2
    }
    
    // --- Metadata Overlay ---
    Column {
        visible: mprisService && mprisService.hasPlayer
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8
        z: 2
        
        // -- Track Info --
        Text {
            width: parent.width
            text: mprisService.title
            color: "#F2E0C8"
            font.family: "monospace"
            font.pixelSize: 20
            font.bold: true
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: mprisService.artist
            color: "#A67C52"
            font.family: "monospace"
            font.pixelSize: 16
            elide: Text.ElideRight
        }

        // -- Spacer --
        Item { width: 1; height: 10 }

        // -- Technical Details --
        Grid {
            columns: 2
            columnSpacing: 24
            rowSpacing: 6
            
            // Labels
            Column {
                spacing: 6
                Text { text: "PLAYER:"; color: "#8C6F56"; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: "CODEC:";  color: "#8C6F56"; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: "BITRATE:";color: "#8C6F56"; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: "LATENCY:";color: "#8C6F56"; font.family: "monospace"; font.pixelSize: 10; }
            }

            // Values
            Column {
                spacing: 6
                Text { text: mprisService.playerName; color: "#F2E0C8"; font.family: "monospace"; font.pixelSize: 10; elide: Text.ElideRight; }
                Text { text: mprisService.codec;      color: "#F2E0C8"; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: mprisService.bitrate;    color: "#F2E0C8"; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: mprisService.latency;    color: "#F2E0C8"; font.family: "monospace"; font.pixelSize: 10; }
            }
        }
    }
}
