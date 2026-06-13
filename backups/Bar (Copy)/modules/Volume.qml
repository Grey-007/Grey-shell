import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    width: volumeRing.implicitWidth
    height: 36
    implicitWidth: width
    implicitHeight: height

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink?.audio ?? null
    readonly property bool hasSink: audio !== null
    readonly property real safeVolume: Math.max(0, Math.min(1, audio?.volume ?? 0))
    readonly property int volume: Math.round(safeVolume * 100)
    readonly property bool muted: audio?.muted ?? false
    readonly property string volumeIcon: !hasSink || muted || volume === 0 ? "🔇" : volume < 45 ? "🔈" : "🔊"

    property bool scrollReveal: false

    function adjustVolume(delta) {
        if (!audio) return

        audio.volume = Math.max(0, Math.min(1, audio.volume + delta))
        if (audio.muted && delta > 0) audio.muted = false

        scrollReveal = true
        scrollRevealTimer.restart()
    }

    function toggleMute() {
        if (audio) audio.muted = !audio.muted
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Timer {
        id: scrollRevealTimer

        interval: 900
        onTriggered: root.scrollReveal = false
    }

    MetricRing {
        id: volumeRing

        anchors.centerIn: parent
        icon: root.volumeIcon
        value: root.volume
        valueText: root.muted ? "M" : root.volume.toString()
        valueVisible: containsMouse || root.scrollReveal || root.muted
        active: root.hasSink
        dimmed: root.muted
        acceptsWheel: true
        onClicked: root.toggleMute()
        onWheelMoved: function(delta) {
            root.adjustVolume(delta > 0 ? 0.05 : -0.05)
        }
    }
}
