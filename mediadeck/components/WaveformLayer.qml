import QtQuick

// WaveformLayer.qml
//
// Renders dual-channel waveform data using Canvas.
// Designed to be a background visual element.
Item {
    id: root

    property var audioSource
    property bool active: false
    
    // Make opacity controllable from the parent view
    opacity: 1.0

    // -- Internal rendering timer --
    Timer {
        interval: 16 // ~60fps
        running: root.active // Only run when active
        repeat: true
        onTriggered: {
            canvas.requestPaint();
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            if (!root.active || !root.audioSource) return;

            var leftData = root.audioSource.leftChannelData;
            var rightData = root.audioSource.rightChannelData;

            if (leftData.length === 0 || rightData.length === 0) return;

            // Draw Left Channel (Top)
            drawChannel(ctx, leftData, height * 0.65, "#F2E0C8");

            // Draw Right Channel (Bottom)
            drawChannel(ctx, rightData, height * 0.85, "#A67C52");
        }

        function drawChannel(ctx, data, yCenter, color) {
            ctx.beginPath();
            ctx.strokeStyle = color;
            ctx.lineWidth = 1.5;

            const step = width / (data.length - 1);
            const amplitude = height * 0.15; // Slightly reduced to prevent clipping at the bottom

            ctx.moveTo(0, yCenter);

            for (var i = 0; i < data.length; i++) {
                const x = i * step;
                const y = yCenter - (data[i] * amplitude);
                ctx.lineTo(x, y);
            }
            
            ctx.stroke();
        }
    }
}
