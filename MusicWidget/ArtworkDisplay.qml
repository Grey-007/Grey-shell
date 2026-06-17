import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.MusicWidget

// Displays album art OR an animated GIF.
// Tap to toggle between the two views.
Item {
    id: root
    width:  300
    height: 300

    readonly property var player: MprisController.currentPlayer

    // 0 = album art, 1 = GIF
    property int    currentView: 0
    property string gifSource:   ""

    StackLayout {
        anchors.fill:  parent
        currentIndex:  root.currentView

        // ── Album art ──────────────────────────────────────────────────
        Rectangle {
            color: Theme.surfaceColor

            Image {
                anchors.fill: parent
                source:       root.player ? (root.player.trackArtUrl || "") : ""
                fillMode:     Image.PreserveAspectCrop
                smooth:       true

                // Placeholder when no art is available
                Rectangle {
                    anchors.fill: parent
                    color:        Theme.raisedSurfaceColor
                    visible:      parent.status !== Image.Ready

                    Text {
                        anchors.centerIn: parent
                        text:  "♪"
                        color: Theme.mutedTextColor
                        font.pixelSize: 48
                    }
                }
            }
        }

        // ── GIF view ───────────────────────────────────────────────────
        Rectangle {
            color: Theme.surfaceColor

            AnimatedImage {
                anchors.fill: parent
                source:       root.gifSource
                fillMode:     Image.PreserveAspectCrop
                playing:      root.currentView === 1
            }
        }
    }

    // Tap to switch view (only if a GIF is loaded)
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.gifSource !== "")
                root.currentView = (root.currentView === 0) ? 1 : 0;
        }
    }
}
