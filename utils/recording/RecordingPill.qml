// RecordingPill.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: win

    property bool utilityOpen: false
    property bool isDragged: false
    
    // State of recording
    property bool isRecording: false
    property bool isPaused: false
    property int elapsedSeconds: 0
    property string currentMode: ""
    
    // Only visible when recording has been requested
    visible: isRecording || isPaused

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    implicitWidth: layout.width + 32
    implicitHeight: 44

    anchors {
        bottom: !isDragged
        left: isDragged
        top: isDragged
    }

    // Smooth movement when utility opens/closes
    property int currentBottomMargin: isDragged ? 0 : (utilityOpen ? 86 : 16)

    Behavior on currentBottomMargin {
        enabled: !isDragged && win.visible
        NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
    }

    margins.bottom: currentBottomMargin

    // Process handling wf-recorder
    Process {
        id: recorderProcess
        
        onRunningChanged: {
            if (!running && win.isRecording) {
                // If it crashed or stopped unexpectedly, or slurp was cancelled
                win.isRecording = false;
                win.isPaused = false;
                timer.stop();
            }
        }
    }

    function startRecording(mode) {
        currentMode = mode;
        elapsedSeconds = 0;
        isPaused = false;
        
        var cmd = "";
        if (mode === "output") {
            cmd = "mkdir -p ~/Videos; exec wf-recorder -f ~/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4";
        } else if (mode === "region") {
            cmd = "mkdir -p ~/Videos; geometry=$(slurp); if [ -n \"$geometry\" ]; then exec wf-recorder -g \"$geometry\" -f ~/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4; fi";
        } else if (mode === "window") {
            cmd = "mkdir -p ~/Videos; geometry=$(hyprctl clients -j | jq -r '.[] | select(.hidden==false and .mapped==true) | \"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"' | slurp); if [ -n \"$geometry\" ]; then exec wf-recorder -g \"$geometry\" -f ~/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4; fi";
        }
        
        recorderProcess.command = ["bash", "-c", cmd];
        recorderProcess.running = true;
        isRecording = true;
        timer.start();
    }

    function stopRecording() {
        Quickshell.execDetached(["pkill", "-INT", "wf-recorder"]);
        
        // Let the onRunningChanged handle the rest, but we can assume it stopped
        isRecording = false;
        isPaused = false;
        timer.stop();
        Quickshell.execDetached(["notify-send", "-t", "3000", "Recording Finished", "Saved to ~/Videos"]);
    }

    function togglePause() {
        if (!isRecording && !isPaused) return;
        
        if (isPaused) {
            Quickshell.execDetached(["pkill", "-CONT", "wf-recorder"]);
            isPaused = false;
        } else {
            Quickshell.execDetached(["pkill", "-TSTP", "wf-recorder"]);
            isPaused = true;
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        onTriggered: {
            if (!win.isPaused) win.elapsedSeconds++;
        }
    }

    // UI Pill
    Rectangle {
        anchors.fill: parent
        color: "#241D18"
        radius: 22
        border.color: "#5A4736"
        border.width: 2
        
        // Draggable Logic
        MouseArea {
            id: dragArea
            anchors.fill: parent
            property point startPos
            
            onPressed: (mouse) => {
                if (!win.isDragged) {
                    // Convert from bottom-anchored to absolute anchored
                    const globalPos = dragArea.mapToGlobal(0, 0);
                    win.margins.left = globalPos.x;
                    win.margins.top = globalPos.y;
                    win.isDragged = true;
                }
                startPos = Qt.point(mouse.x, mouse.y);
            }
            
            onPositionChanged: (mouse) => {
                if (!dragArea.pressed) return;
                win.margins.left += (mouse.x - startPos.x);
                win.margins.top += (mouse.y - startPos.y);
            }
        }

        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 12
            
            // Pulsing Red Dot
            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: "#e04a4a"
                
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: win.isRecording && !win.isPaused
                    NumberAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                }
                opacity: win.isPaused ? 0.3 : 1.0
            }
            
            // Timer text
            Text {
                text: {
                    var m = Math.floor(win.elapsedSeconds / 60);
                    var s = win.elapsedSeconds % 60;
                    return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
                }
                color: "#f0e0c0"
                font.family: "monospace"
                font.pixelSize: 15
                font.weight: Font.Bold
                Layout.minimumWidth: 40
            }
            
            Rectangle {
                width: 1
                height: 24
                color: "#5A4736"
            }
            
            // Pause / Resume Button
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: pauseHover.containsMouse ? "#5A4736" : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: win.isPaused ? "󰐊" : "󰏤" // Play/Pause icon
                    color: "#f0e0c0"
                    font.pixelSize: 14
                }
                
                MouseArea {
                    id: pauseHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: win.togglePause()
                }
            }
            
            // Stop Button
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: stopHover.containsMouse ? "#a04a4a" : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "󰓛" // Stop square
                    color: stopHover.containsMouse ? "#1c1510" : "#d45a5a"
                    font.pixelSize: 14
                }
                
                MouseArea {
                    id: stopHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: win.stopRecording()
                }
            }
        }
    }
}
