import QtQuick
import qs.MusicWidget

// Ambient sine-wave visualizer drawn on a Canvas.
// Sits behind all other content (z: -1 set by parent).
Item {
    id: root

    opacity: MusicConfig.visualizerOpacity

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            ctx.beginPath();
            ctx.strokeStyle = Theme.accentColorPrimary;
            ctx.lineWidth = 1.5;

            var time = Date.now() * 0.004;
            for (var x = 0; x < width; x++) {
                var y = height / 2
                    + Math.sin(x * 0.04 + time) * 12
                    + Math.sin(x * 0.02 + time * 0.7) * 6;
                if (x === 0) ctx.moveTo(x, y);
                else         ctx.lineTo(x, y);
            }
            ctx.stroke();
        }
    }

    Timer {
        interval: 33   // ~30 fps
        running:  MusicConfig.visualizerEnabled
        repeat:   true
        onTriggered: canvas.requestPaint()
    }
}
