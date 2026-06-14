import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Mpris

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · MediaCard
//
// Shows whatever is currently playing via MPRIS (Spotify, browsers,
// mpv, etc). Hides itself completely if nothing is playing, so it never
// leaves an empty gap on the lock screen.
// ─────────────────────────────────────────────────────────────────────────
Card {
    id: root

    implicitHeight: Config.pillHeight
    readonly property var player: Mpris.players.values.length > 0
        ? Mpris.players.values[0]
        : null
    readonly property bool shown: player !== null

    visible: shown || opacity > 0.01
    enabled: shown
    visibilityFactor: shown ? 1 : 0
    scaleFactor: shown ? 1 : 0.965
    height: shown ? implicitHeight : 0

    readonly property bool playing: shown
        && player.playbackState === MprisPlaybackState.Playing

    RowLayout {
        anchors.fill: parent
        anchors.margins: Config.spacingSmall
        spacing: Config.spacingMedium
        // Album art (rounded) with placeholder
        Item {
            id: artWrap
            Layout.preferredWidth: Config.pillHeight - Config.spacingSmall * 2
            Layout.preferredHeight: Config.pillHeight - Config.spacingSmall * 2

            Rectangle {
                id: artMask
                anchors.fill: parent
                radius: Config.radiusSmall
                visible: false
                layer.enabled: true
            }

            Image {
                id: art
                anchors.fill: parent
                source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                source: art
                maskEnabled: true
                maskSource: artMask
                visible: art.status === Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                radius: Config.radiusSmall
                color: Colours.surfaceContainerHighest
                visible: art.status !== Image.Ready

                Text {
                    anchors.centerIn: parent
                    text: "♪"
                    font.pixelSize: 22
                    color: Colours.surfaceVariantForeground
                }
            }
        }

        // Title / artist
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackTitle || "Unknown title") : ""
                color: Colours.surfaceForeground
                font.family: Config.fontFamily
                font.pixelSize: 15
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackArtist || "Unknown artist") : ""
                color: Colours.surfaceVariantForeground
                font.family: Config.fontFamily
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }

        // Play / pause
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: Colours.primaryContainer

            scale: playPause.pressed ? 0.9 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: Config.durationFast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Config.easeExpressive
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.playing ? "❙❙" : "▶"
                font.pixelSize: 13
                color: Colours.primaryContainerForeground
            }

            MouseArea {
                id: playPause
                anchors.fill: parent
                onClicked: root.player && root.player.togglePlaying()
            }
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: Config.durationMedium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeEmphasizedDecel
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Config.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeEmphasizedDecel
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Config.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeExpressive
        }
    }
}
