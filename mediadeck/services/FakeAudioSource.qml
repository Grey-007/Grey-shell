import QtQuick

// FakeAudioSource.qml
//
// This service generates fake dual-channel audio data for visualization.
// It is designed to be replaced by a real audio source in the future.
QtObject {
    id: root

    readonly property int dataPoints: 256 // Number of points in the waveform
    
    // -- API for WaveformLayer --
    readonly property var leftChannelData: _leftData
    readonly property var rightChannelData: _rightData

    // -- Internal State --
    property var _leftData: []
    property var _rightData: []
    property real _phase: 0

    // -- Initialization --
    Component.onCompleted: {
        // Pre-fill data arrays
        for (var i = 0; i < root.dataPoints; i++) {
            _leftData.push(0);
            _rightData.push(0);
        }
    }

    // -- Data Generation Timer --
    Timer {
        interval: 16 // ~60fps
        running: true
        repeat: true
        onTriggered: {
            root._phase += 0.1;
            
            var tempLeft = [];
            var tempRight = [];

            for (var i = 0; i < root.dataPoints; i++) {
                // Left channel: simple sine wave
                var val1 = Math.sin(root._phase + (i / 20));

                // Right channel: composite sine wave for visual distinction
                var val2 = Math.sin(root._phase * 0.5 + (i / 15)) * 0.6 + Math.sin(root._phase * 1.5 + (i / 25)) * 0.4;
                
                tempLeft[i] = val1;
                tempRight[i] = val2;
            }

            // Atomically update the properties to ensure views get a complete array
            root._leftData = tempLeft;
            root._rightData = tempRight;
        }
    }
}
