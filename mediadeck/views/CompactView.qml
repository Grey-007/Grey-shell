import QtQuick

// CompactView.qml
//
// The UI for the Media Deck's compact state. It displays the most
// essential media information.
Rectangle {
    // The service instance passed in from MediaDeck.qml
    property var mprisService
    property var gifManager

    anchors.fill: parent
    color: "transparent"

    Column {
        anchors.centerIn: parent
        spacing: 8
        width: parent.width - 40 // Add some horizontal padding

        // --- Fallback Text ---
        // Shown only when no media player is active.
        Text {
            visible: !mprisService.hasPlayer
            anchors.horizontalCenter: parent.horizontalCenter
            text: "NO MEDIA"
            color: "#A67C52"
            font.family: "monospace"
            font.pixelSize: 14
            font.letterSpacing: 2
        }

        // --- Metadata Display ---
        // Shown when a media player is active.
        Column {
            visible: mprisService.hasPlayer
            width: parent.width
            spacing: 4

            Text {
                width: parent.width
                text: mprisService.title
                color: "#F2E0C8"
                font.family: "monospace"
                font.pixelSize: 16
                elide: Text.ElideRight // Truncate long titles
            }
            Text {
                width: parent.width
                text: mprisService.artist
                color: "#A67C52"
                font.family: "monospace"
                font.pixelSize: 12
                elide: Text.ElideRight // Truncate long artist names
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                padding: 10
                text: mprisService.playbackStatus.toUpperCase()
                color: "#A67C52"
                font.family: "monospace"
                font.pixelSize: 10
                font.letterSpacing: 1
            }
        }
    }
}
