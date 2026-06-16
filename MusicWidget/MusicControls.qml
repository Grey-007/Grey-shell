import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "./MusicConfig.qml" as Config
import "./Theme.qml" as MusicTheme

Item {
    id: musicControlsRoot

    // Access MPRIS players
    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Metadata
        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true

            Label {
                text: player ? (player.title || "Unknown Title") : "No Track"
                font.pixelSize: 18
                color: MusicTheme.textColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Label {
                text: player ? (player.artist || "Unknown Artist") : ""
                font.pixelSize: 14
                color: MusicTheme.mutedTextColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Button {
                text: "Previous"
                enabled: player && player.canGoPrevious
                onClicked: player.previous()
            }
            Button {
                text: (player && player.playbackState === MprisPlaybackState.Playing) ? "Pause" : "Play"
                enabled: player && (player.canPlay || player.canPause)
                onClicked: {
                    if (player.playbackState === MprisPlaybackState.Playing) {
                        player.pause()
                    } else {
                        player.play()
                    }
                }
            }
            Button {
                text: "Next"
                enabled: player && player.canGoNext
                onClicked: player.next()
            }
        }
    }
}