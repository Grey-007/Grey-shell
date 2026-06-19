import QtQuick
import "../components"
import "../../colors"

// ExpandedView.qml
//
// The UI for the Media Deck's expanded state. It displays detailed
// metadata about the current track and player, along with playback controls.
Rectangle {
    id: root
    // The service instances passed in from MediaDeck.qml
    property var mprisService
    property var gifManager
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
        opacity: 0.25
        z: -1
    }

    // -- Pin Button (top-right corner) --
    // Unpinned = floating above windows; Pinned = stuck to desktop layer.
    Rectangle {
        id: pinButton
        width: 20
        height: 20
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6
        z: 10
        color: pinMa.containsMouse ? ThemeManager.surfaceTop : "transparent"
        border.color: (root.mediaState && root.mediaState.isPinned) ? ThemeManager.accent : ThemeManager.border
        border.width: 1

        Text {
            anchors.centerIn: parent
            // 📌 filled = pinned to desktop  ◈ outline = floating
            text: (root.mediaState && root.mediaState.isPinned) ? "📌" : "◈"
            font.pixelSize: 11
            color: (root.mediaState && root.mediaState.isPinned) ? ThemeManager.accent : ThemeManager.fgMid
        }

        MouseArea {
            id: pinMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // Prevent drag-to-move from firing on pin button click
            onClicked: function(mouse) {
                if (root.mediaState) root.mediaState.togglePin()
                mouse.accepted = true
            }
        }
    }

    // --- Fallback View ---
    // Shown only when no media player is active.
    Text {
        visible: !mprisService || !mprisService.hasPlayer
        anchors.centerIn: parent
        text: "NO ACTIVE PLAYER"
        color: ThemeManager.accent
        font.family: "monospace"
        font.pixelSize: 14
        font.letterSpacing: 2
    }

    // --- Metadata and Controls View ---
    // Shown when a media player is active.
    Column {
        visible: mprisService && mprisService.hasPlayer
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12
        z: 1 // Ensure this is above the waveform

        // -- Main Content Area (GIF + Info) --
        Row {
            width: parent.width
            height: 110
            spacing: 16

            // -- Visual Element (Left) --
            GifPanel {
                id: gifPanel
                gifManager: root.gifManager
                width: 110
                height: 110
            }

            // -- Metadata (Right) --
            Column {
                width: parent.width - gifPanel.width - parent.spacing
                spacing: 4
                
                Text {
                    width: parent.width
                    text: mprisService.title
                    color: ThemeManager.fg
                    font.family: "monospace"
                    font.pixelSize: 18
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: mprisService.artist
                    color: ThemeManager.accent
                    font.family: "monospace"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: mprisService.album
                    color: ThemeManager.fgMid
                    font.family: "monospace"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    padding: 4
                }

                // -- Playback Details --
                Grid {
                    columns: 2
                    rowSpacing: 4
                    columnSpacing: 12
                    topPadding: 6

                    // Player Name
                    Text { text: "PLAYER:"; color: ThemeManager.accent; font.family: "monospace"; font.pixelSize: 10; }
                    Text { text: mprisService.playerName; color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 10; elide: Text.ElideRight; }

                    // Playback State
                    Text { text: "STATE:"; color: ThemeManager.accent; font.family: "monospace"; font.pixelSize: 10; }
                    Text { text: mprisService.playbackStatus.toUpperCase(); color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 10; }
                }
            }
        }

        // -- Separator --
        Rectangle {
            width: parent.width
            height: 1
            color: ThemeManager.accent
            opacity: 0.2
        }

        // -- Progress System --
        ProgressBar {
            mprisService: root.mprisService
        }

        // -- Playback Controls --
        MediaControls {
            mprisService: root.mprisService
            gifManager: root.gifManager
        }
    }
}
