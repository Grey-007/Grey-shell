import QtQuick
import "../components"

// ExpandedView.qml
//
// The UI for the Media Deck's expanded state. It displays detailed
// metadata about the current track and player, along with playback controls.
Rectangle {
    id: root
    // The service instances passed in from MediaDeck.qml
    property var mprisService
    property var gifManager

    anchors.fill: parent
    color: "transparent"

    // --- Fallback View ---
    // Shown only when no media player is active.
    Text {
        visible: !mprisService || !mprisService.hasPlayer
        anchors.centerIn: parent
        text: "NO ACTIVE PLAYER"
        color: "#A67C52"
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
                    color: "#F2E0C8"
                    font.family: "monospace"
                    font.pixelSize: 18
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: mprisService.artist
                    color: "#A67C52"
                    font.family: "monospace"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: mprisService.album
                    color: "#8C6F56"
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
                    Text { text: "PLAYER:"; color: "#A67C52"; font.family: "monospace"; font.pixelSize: 10; }
                    Text { text: mprisService.playerName; color: "#F2E0C8"; font.family: "monospace"; font.pixelSize: 10; elide: Text.ElideRight; }

                    // Playback State
                    Text { text: "STATE:"; color: "#A67C52"; font.family: "monospace"; font.pixelSize: 10; }
                    Text { text: mprisService.playbackStatus.toUpperCase(); color: "#F2E0C8"; font.family: "monospace"; font.pixelSize: 10; }
                }
            }
        }

        // -- Separator --
        Rectangle {
            width: parent.width
            height: 1
            color: "#A67C52"
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
