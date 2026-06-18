import QtQuick

// ProgressBar.qml
//
// A cyberdeck-style progress bar for the Media Deck.
// Features hard edges, no rounded corners, and no animations.
Item {
    id: root

    property var mprisService
    height: 24
    width: parent.width

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

    Column {
        anchors.fill: parent
        spacing: 2

        // -- Progress Bar Track --
        Rectangle {
            width: parent.width
            height: 6
            color: "transparent"
            border.color: "#A67C52"
            border.width: 1

            // -- Progress Fill --
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 1
                
                // Calculate width based on position and length
                width: {
                    if (!root.mprisService || root.mprisService.length <= 0) return 0;
                    const maxWidth = parent.width - 2;
                    const progress = root.mprisService.position / root.mprisService.length;
                    return Math.max(0, Math.min(maxWidth, maxWidth * progress));
                }
                
                color: "#F2E0C8"
            }
        }

        // -- Time Display --
        Text {
            anchors.right: parent.right
            text: {
                if (!root.mprisService) return "00:00 / 00:00";
                return formatTime(root.mprisService.position) + " / " + formatTime(root.mprisService.length);
            }
            color: "#A67C52"
            font.family: "monospace"
            font.pixelSize: 10
        }
    }
}
