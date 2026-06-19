import QtQuick
import "../components"
import "../../colors"

// SignalView.qml
//
// A dedicated analysis view for media playback.
// Displays a dominant waveform with technical metadata.
Rectangle {
    id: root
    // The service instances passed in from MediaDeck.qml
    property var mprisService
    property var realAudioSource
    property var mediaState    // injected by MediaDeck for pin toggle

    anchors.fill: parent
    color: "transparent"

    // -- Waveform Background --
    WaveformLayer {
        id: waveform
        anchors.fill: parent
        audioSource: root.realAudioSource
        active: root.mprisService && root.mprisService.playbackStatus === "Playing" && root.realAudioSource && root.realAudioSource.hasSignal
        opacity: 0.8
        z: 1
    }

    // -- Pin Button (top-right corner) --
    Rectangle {
        id: pinButton
        width: 20
        height: 20
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6
        z: 10
        color: pinMa.containsMouse ? ThemeManager.surfaceHigh : "transparent"
        border.color: (root.mediaState && root.mediaState.isPinned) ? ThemeManager.accent : ThemeManager.border
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: (root.mediaState && root.mediaState.isPinned) ? "📌" : "◈"
            font.pixelSize: 11
            color: (root.mediaState && root.mediaState.isPinned) ? ThemeManager.accent : ThemeManager.fgDim
        }

        MouseArea {
            id: pinMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: function(mouse) {
                if (root.mediaState) root.mediaState.togglePin()
                mouse.accepted = true
            }
        }
    }

    // --- Fallback View ---
    Text {
        visible: !mprisService || !mprisService.hasPlayer
        anchors.centerIn: parent
        text: "NO ACTIVE SIGNAL"
        color: ThemeManager.accent
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
            color: ThemeManager.fg
            font.family: "monospace"
            font.pixelSize: 20
            font.bold: true
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: mprisService.artist
            color: ThemeManager.accent
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
                Text { text: "PLAYER:"; color: ThemeManager.fgDim; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: "CODEC:";  color: ThemeManager.fgDim; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: "BITRATE:";color: ThemeManager.fgDim; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: "LATENCY:";color: ThemeManager.fgDim; font.family: "monospace"; font.pixelSize: 10; }
            }

            // Values
            Column {
                spacing: 6
                Text { text: mprisService.playerName; color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 10; elide: Text.ElideRight; }
                Text { text: mprisService.codec;      color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: mprisService.bitrate;    color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 10; }
                Text { text: mprisService.latency;    color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 10; }
            }
        }
    }
}
