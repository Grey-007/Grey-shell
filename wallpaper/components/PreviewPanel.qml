// PreviewPanel.qml
import QtQuick
import "../../colors"

Item {
    id: root

    property string source: ""

    // Hard edges, clean layout
    Rectangle {
        anchors.fill: parent
        color: ThemeManager.surface
        border.color: ThemeManager.border
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
            color: ThemeManager.fg
            font.family: "monospace"
            font.pixelSize: 24
            visible: root.source === ""
        }
    }
}
