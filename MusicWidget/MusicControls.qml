import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.MusicWidget

Item {
    id: root
    property var mprisService

    readonly property var player: root.mprisService

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // ── Metadata ───────────────────────────────────────────────────
        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true

            Text {
                text:           player ? (player.trackTitle  || "Unknown Title")  : "No Track"
                font.pixelSize: 17
                font.bold:      true
                color:          Theme.textColor
                elide:          Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text:           player ? (player.trackArtists.join(", ") || "Unknown Artist") : ""
                font.pixelSize: 13
                color:          Theme.mutedTextColor
                elide:          Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text:           player ? (player.trackAlbum || "") : ""
                font.pixelSize: 11
                color:          Theme.mutedTextColor
                elide:          Text.ElideRight
                Layout.fillWidth: true
                visible:        text !== ""
            }
        }

        // ── Transport controls ─────────────────────────────────────────
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            // Previous
            Rectangle {
                width: 40; height: 40
                radius: 20
                color:   prevArea.containsMouse
                         ? Theme.raisedSurfaceColor
                         : Theme.surfaceColor
                opacity: player && player.canGoPrevious ? 1.0 : 0.35
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text:  "⏮"
                    color: Theme.textColor
                    font.pixelSize: 18
                }
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled:      player && player.canGoPrevious
                    onClicked:    player.previous()
                }
            }

            // Play / Pause
            Rectangle {
                width: 52; height: 52
                radius: 26
                color:  playArea.containsMouse
                        ? Theme.accentColorSecondary
                        : Theme.accentColorPrimary
                opacity: player ? 1.0 : 0.35
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (!player) return "▶";
                        return player.playbackState === MprisPlaybackState.Playing ? "⏸" : "▶";
                    }
                    color: Theme.backgroundColor
                    font.pixelSize: 20
                }
                MouseArea {
                    id: playArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: player !== null
                    onClicked: {
                        if (!player) return;
                        if (player.playbackState === MprisPlaybackState.Playing)
                            player.pause();
                        else
                            player.play();
                    }
                }
            }

            // Next
            Rectangle {
                width: 40; height: 40
                radius: 20
                color:   nextArea.containsMouse
                         ? Theme.raisedSurfaceColor
                         : Theme.surfaceColor
                opacity: player && player.canGoNext ? 1.0 : 0.35
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text:  "⏭"
                    color: Theme.textColor
                    font.pixelSize: 18
                }
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled:      player && player.canGoNext
                    onClicked:    player.next()
                }
            }
        }
    }
}
