import QtQuick
import Quickshell.Services.Mpris
import qs.MusicWidget

// Wave-style progress bar.
// Played portion = animated sine wave; unplayed = flat line.
Item {
    id: root
    height: 32
    property var mprisService

    readonly property var player: root.mprisService

    // Guard against division by zero
    readonly property real progress: {
        if (!player) return 0;
        var len = player.length; // Use mprisService.length
        if (!len || len <= 0) return 0;
        return Math.min(1.0, player.position / len); // Use mprisService.position
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        property real waveOffset: 0

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var playedWidth = width * root.progress;

            // Played: sine wave
            if (playedWidth > 0) {
                ctx.beginPath();
                ctx.strokeStyle = Theme.accentColorPrimary;
                ctx.lineWidth   = 2;
                for (var x = 0; x <= playedWidth; x++) {
                    var y = height / 2 + Math.sin(x * 0.12 + waveOffset) * 4;
                    if (x === 0) ctx.moveTo(x, y);
                    else         ctx.lineTo(x, y);
                }
                ctx.stroke();
            }

            // Unplayed: flat line
            if (playedWidth < width) {
                ctx.beginPath();
                ctx.strokeStyle = Theme.raisedSurfaceColor;
                ctx.lineWidth   = 1;
                ctx.moveTo(playedWidth, height / 2);
                ctx.lineTo(width,       height / 2);
                ctx.stroke();
            }

            // Scrubber dot
            ctx.beginPath();
            ctx.fillStyle = Theme.accentColorSecondary;
            ctx.arc(playedWidth, height / 2, 4, 0, Math.PI * 2);
            ctx.fill();
        }
    }

    // Animate the wave offset for a live feel
    Timer {
        interval: 40
        running:  player !== null && player.playbackState === MprisPlaybackState.Playing
        repeat:   true
        onTriggered: {
            canvas.waveOffset += 0.15;
            canvas.requestPaint();
        }
    }

    // Redraw when position changes
    Connections {
        target:   root.player
        enabled:  root.player !== null
        onPositionChanged: canvas.requestPaint(); // Corrected signal handler
    }

    // Click-to-seek
    MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => {
            if (root.player && root.player.length > 0) { // Use mprisService.length
                var seekPos = (mouse.x / width) * root.player.length; // Use mprisService.length
                // TODO: Implement seek functionality if needed, currently not supported by mprisService
                // root.player.seek(seekPos);
            }
        }
    }
}
