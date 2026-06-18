import QtQuick

// GifPanel.qml
//
// A track-reactive animated image panel.
// Designed to fit as an "album art" style element.
Item {
    id: root

    property var gifManager
    
    implicitWidth: 100
    implicitHeight: 100

    // -- Border & Background --
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#A67C52"
        border.width: 1
        opacity: 0.5
    }

    // -- GIF Display --
    AnimatedImage {
        id: gifImage
        anchors.fill: parent
        anchors.margins: 1
        source: root.gifManager ? root.gifManager.currentGifPath : "" // Directly bind to currentGifPath
        fillMode: AnimatedImage.PreserveAspectCrop
        playing: true
        smooth: true
        visible: root.gifManager && root.gifManager.hasGifs

        onSourceChanged: {
            console.log("GifPanel: AnimatedImage source changed to: " + gifImage.source);
        }

        // Placeholder when no art is available or during loading
        Rectangle {
            anchors.fill: parent
            color:        "#241D18" // Match background color
            visible:      gifImage.status === AnimatedImage.Loading || gifImage.status === AnimatedImage.Error
            Text {
                visible: gifImage.status === AnimatedImage.Error
                anchors.centerIn: parent
                text: "ERROR"
                color: "#A67C52"
                font.family: "monospace"
                font.pixelSize: 10
            }
        }
    }


    // -- Placeholder / Fallback for no GIFs in directory --
    Rectangle {
        visible: !root.gifManager || !root.gifManager.hasGifs
        anchors.fill: parent
        color: "transparent"
        
        Column {
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: "NO"
                color: "#A67C52"
                font.family: "monospace"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "VISUAL"
                color: "#A67C52"
                font.family: "monospace"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
