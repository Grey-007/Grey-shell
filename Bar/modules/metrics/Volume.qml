import QtQuick
import Quickshell.Services.Pipewire

// Volume.qml — volume bar + scroll to adjust + click to mute
Item {
    id: root

    implicitWidth:  bar.implicitWidth
    implicitHeight: 28

    readonly property var  sink:       Pipewire.defaultAudioSink
    readonly property var  audio:      sink?.audio ?? null
    readonly property bool hasSink:    audio !== null
    readonly property real safeVol:    Math.max(0, Math.min(1, audio?.volume ?? 0))
    readonly property int  volume:     Math.round(safeVol * 100)
    readonly property bool muted:      audio?.muted ?? false

    signal barClicked()

    function adjustVolume(delta) {
        if (!audio) return
        audio.volume = Math.max(0, Math.min(1, audio.volume + delta))
        if (audio.muted && delta > 0) audio.muted = false
    }

    function toggleMute() { if (audio) audio.muted = !audio.muted }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    MetricBar {
        id: bar
        anchors.centerIn: parent
        // nf-fa-volume-high / nf-fa-volume-xmark / nf-fa-volume-low
        icon:      muted || volume === 0 ? "\udb81\udd7e"
                 : volume < 45          ? "\uf027"
                 :                        "\uf028"
        label:     "VOL"
        value:     root.muted ? 0 : root.volume
        active:    root.hasSink && !root.muted
        clickable: true
        onClicked: root.barClicked()
    }

    // Scroll over volume bar to adjust
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function(wheel) {
            root.adjustVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
            wheel.accepted = true
        }
    }
}
