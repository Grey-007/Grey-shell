import QtQuick

// ExpandedView.qml
//
// The UI for the Media Deck's expanded state. It displays detailed
// metadata about the current track and player.
Rectangle {
    // The service instance passed in from MediaDeck.qml
    property var mprisService

    anchors.fill: parent
    color: "transparent"

    // -- Helper Functions --
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) {
            return "00:00";
        }
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        return (minutes < 10 ? "0" : "") + minutes + ":" +
               (remainingSeconds < 10 ? "0" : "") + remainingSeconds;
    }

    // --- Fallback View ---
    // Shown only when no media player is active.
    Text {
        visible: !mprisService.hasPlayer
        anchors.centerIn: parent
        text: "NO ACTIVE PLAYER"
        color: "#A67C52"
        font.family: "monospace"
        font.pixelSize: 14
        font.letterSpacing: 2
    }

    // --- Metadata View ---
    // Shown when a media player is active.
    Column {
        visible: mprisService.hasPlayer
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // -- Track Info --
        Column {
            width: parent.width
            spacing: 2
            Text {
                width: parent.width
                text: mprisService.title
                color: "#F2E0C8"
                font.family: "monospace"
                font.pixelSize: 22
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
            Text {
                width: parent.width
                text: mprisService.album
                color: "#8C6F56"
                font.family: "monospace"
                font.pixelSize: 14
                elide: Text.ElideRight
                padding: 10
            }
        }

        // -- Playback Details --
        Grid {
            width: parent.width
            columns: 2
            rowSpacing: 8
            columnSpacing: 16

            // Player Name
            Text { text: "PLAYER:"; color: "#A67C52"; font.family: "monospace"; font.pixelSize: 12; }
            Text { text: mprisService.playerName; color: "#F2E0C8"; font.family: "monospace"; font.pixelSize: 12; elide: Text.ElideRight; }

            // Playback State
            Text { text: "STATE:"; color: "#A67C52"; font.family: "monospace"; font.pixelSize: 12; }
            Text { text: mprisService.playbackStatus.toUpperCase(); color: "#F2E0C8"; font.family: "monospace"; font.pixelSize: 12; }

            // Position / Duration
            Text { text: "TIME:"; color: "#A67C52"; font.family: "monospace"; font.pixelSize: 12; }
            Text {
                color: "#F2E0C8"
                font.family: "monospace"
                font.pixelSize: 12
                text: formatTime(mprisService.position) + " / " + formatTime(mprisService.length)
            }
        }
    }
}
