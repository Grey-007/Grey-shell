// FilmStrip.qml
import QtQuick

Item {
    id: root

    property alias model: listView.model
    property int selectedIndex: 0

    signal thumbnailClicked(int index)
    signal thumbnailDoubleClicked(int index)

    // Called by WallpaperSelector after keyboard nav so selected item stays visible
    function scrollToSelected() {
        if (root.selectedIndex >= 0) {
            listView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#241D18"
        border.color: "#5A4736"
        border.width: 2

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 8
            orientation: ListView.Horizontal
            spacing: 12
            clip: true

            flickableDirection: Flickable.HorizontalFlick
            boundsMovement: Flickable.StopAtBounds

            // Smooth momentum scrolling
            flickDeceleration: 1200
            maximumFlickVelocity: 2400

            delegate: FilmFrame {
                imageSource: fileUrl
                isSelected: index === root.selectedIndex
                onClicked: root.thumbnailClicked(index)
                onDoubleClicked: root.thumbnailDoubleClicked(index)
            }

            // Mouse wheel → horizontal scroll
            // WheelHandler placed inside the ListView so it sits in the
            // correct item hierarchy and receives events before Flickable flick.
            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                // Use vertical scroll delta, mapped to horizontal content movement
                onWheel: function(event) {
                    var delta = event.angleDelta.y !== 0
                                ? event.angleDelta.y
                                : event.angleDelta.x
                    var step = delta * 2.0
                    var newX = listView.contentX - step
                    newX = Math.max(0, Math.min(listView.contentWidth - listView.width, newX))
                    listView.contentX = newX
                    event.accepted = true
                }
            }
        }
    }

    // Auto-scroll whenever selectedIndex changes (keyboard or click from outside)
    onSelectedIndexChanged: {
        listView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    }
}
