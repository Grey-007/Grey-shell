import QtQuick
import Quickshell
import Quickshell.Io

// RealAudioSource.qml
//
// This service generates dual-channel audio data for visualization
// by running CAVA and parsing its stdout.
QtObject {
    id: root

    readonly property int dataPoints: 128 // Target number of points for the waveform
    
    // -- API for WaveformLayer --
    property var leftChannelData: []
    property var rightChannelData: []
    property bool hasSignal: false

    // -- Internal State --
    property string _cavaConfigPath: Quickshell.shellDir + "/mediadeck/assets/cava_config"

    // -- Initialization --
    Component.onCompleted: {
        var initLeft = [];
        var initRight = [];
        for (var i = 0; i < root.dataPoints; i++) {
            initLeft.push(0.0);
            initRight.push(0.0);
        }
        leftChannelData = initLeft;
        rightChannelData = initRight;
        
        cavaProcess.running = true;
    }

    // -- Process Management --
    property list<QtObject> resources: [
        Process {
            id: cavaProcess
            command: ["cava", "-p", root._cavaConfigPath]
            
            onRunningChanged: {
                root.hasSignal = running;
                console.log("RealAudioSource: CAVA process running: " + running);
            }
            
            onExited: (exitCode, exitStatus) => {
                root.hasSignal = false;
                console.log("RealAudioSource: CAVA process exited with code " + exitCode + ", status: " + exitStatus);
            }

            stdout: SplitParser {
                splitMarker: "\n"
                onRead: (data) => {
                    // CAVA ascii output is a string of numbers separated by semicolons: "12;45;23;...\n"
                    const line = data.toString().trim();
                    if (line.length === 0) return;

                    const values = line.split(';').map(val => parseInt(val, 10) || 0);
                    
                    if (values.length < 2) return; // Need at least some data

                    // CAVA mixes channels in the output if set to stereo, or just gives one array if mono.
                    // Assuming config gives 256 bars. We'll split it roughly in half for pseudo-left/right
                    // if it's returning a single block, or if it's interleaved, we'd process differently.
                    // The simplest robust approach for a generic visualizer is to take the first half 
                    // for the left channel and the second half (reversed) for the right.

                    const halfLength = Math.floor(values.length / 2);
                    const leftRaw = values.slice(0, halfLength);
                    const rightRaw = values.slice(halfLength, values.length).reverse();

                    // Downsample/Average to dataPoints (128)
                    root.leftChannelData = downsample(leftRaw, root.dataPoints);
                    root.rightChannelData = downsample(rightRaw, root.dataPoints);
                }
            }
            
            stderr: StdioCollector {
                onStreamFinished: {
                    console.error("RealAudioSource CAVA Error: " + text);
                }
            }
        }
    ]

    function downsample(inputArray, targetLength) {
        if (inputArray.length === 0) return Array(targetLength).fill(0.0);
        
        const result = [];
        const factor = inputArray.length / targetLength;

        for (let i = 0; i < targetLength; i++) {
            const startIndex = Math.floor(i * factor);
            const endIndex = Math.floor((i + 1) * factor);
            let sum = 0;
            let count = 0;

            for (let j = startIndex; j < endIndex && j < inputArray.length; j++) {
                sum += inputArray[j];
                count++;
            }

            // Normalize assuming 8-bit output (0-255) to a -1.0 to 1.0 range
            // We'll normalize to 0.0 to 1.0 for the amplitude calculation in WaveformLayer
            const avg = count > 0 ? (sum / count) : 0;
            result.push(avg / 255.0); 
        }

        return result;
    }
}
