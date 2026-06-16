import QtQuick
import "./MusicConfig.qml" as Config
import "./Theme.qml" as MusicTheme

Item {
    id: visualizerRoot
    opacity: Config.visualizerOpacity

    // Subtle, animated path
    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.beginPath();
            ctx.strokeStyle = MusicTheme.accentColorPrimary;
            ctx.lineWidth = 1;
            
            var time = Date.now() * 0.005;
            for (var x = 0; x < width; x++) {
                var y = height / 2 + Math.sin(x * 0.05 + time) * 10;
                if (x === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
            ctx.stroke();
        }
    }
    
    // Timer to animate the visualizer
    Timer {
        interval: 30
        running: true
        repeat: true
        onTriggered: canvas.requestPaint()
    }
}