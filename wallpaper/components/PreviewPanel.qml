// PreviewPanel.qml
import QtQuick

Item {
    id: root

    property string source: ""

    // Hard edges, clean layout
    Rectangle {
        anchors.fill: parent
        color: "#241D18" // SepiaShell Background
        border.color: "#5A4736" // SepiaShell Borders
        border.width: 2

        Image {
            anchors.fill: parent
            anchors.margins: 2 // Keep within border
            source: root.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
        }

        Text {
            anchors.centerIn: parent
            text: "NO WALLPAPERS FOUND"
            color: "#F2E0C8"
            font.family: "monospace"
            font.pixelSize: 24
            visible: root.source === ""
        }
    }
}
