import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris
import "./MusicConfig.qml" as Config
import "./Theme.qml" as MusicTheme

Item {
    id: progressBarRoot
    height: 30

    // Access MPRIS player
    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    
    // Progress calculation
    readonly property real progress: (player && player.length > 0) ? (player.position / player.length) : 0

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var playedWidth = width * progress;

            // Draw played section (Wave)
            ctx.beginPath();
            ctx.strokeStyle = MusicTheme.accentColorPrimary;
            ctx.lineWidth = 2;
            
            for (var x = 0; x <= playedWidth; x++) {
                var y = height / 2 + Math.sin(x * 0.1) * 5;
                if (x === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
            ctx.stroke();

            // Draw unplayed section (Straight line)
            ctx.beginPath();
            ctx.strokeStyle = MusicTheme.raisedSurfaceColor;
            ctx.lineWidth = 1;
            ctx.moveTo(playedWidth, height / 2);
            ctx.lineTo(width, height / 2);
            ctx.stroke();
        }
    }

    // Update canvas on position change
    Connections {
        target: player
        function onPositionChanged() {
            canvas.requestPaint();
        }
    }
}