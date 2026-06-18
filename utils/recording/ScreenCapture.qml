// ScreenCapture.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: win

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    property bool isOpen: false
    property var pill: null
    visible: win.isOpen || container.y < win.height

    function toggle() {
        isOpen = !isOpen
    }

    function open() {
        isOpen = true
    }

    function close() {
        isOpen = false
    }

    // Full screen mouse area to close on outside click
    MouseArea {
        anchors.fill: parent
        enabled: win.isOpen
        onClicked: win.close()
    }

    component CaptureButton: Rectangle {
        id: btnRoot
        property string icon: ""
        property color bgColor: "transparent"
        signal clicked()

        width: 44
        height: 44
        radius: 22
        color: bgColor

        scale: mouseArea.containsMouse ? 1.1 : 1.0
        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutQuint } }

        Text {
            anchors.centerIn: parent
            text: btnRoot.icon
            color: "#1c1510" // Dark text for contrast
            font.pixelSize: 20
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btnRoot.clicked()
        }
    }

    Item {
        id: container
        width: 460
        height: 70
        anchors.horizontalCenter: parent.horizontalCenter
        
        anchors.bottom: parent.bottom
        
        // Slide up from bottom using bottomMargin
        anchors.bottomMargin: win.isOpen ? 0 : -height

        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }

        // Eat clicks so they don't close the menu
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Shape {
            anchors.fill: parent
            
            ShapePath {
                fillColor: "#241D18"   // Sepia surface
                strokeColor: "#5A4736" // Sepia border
                strokeWidth: 2
                
                // Start bottom-left, flat against the bottom edge
                startX: 0
                startY: 71 
                
                // Bottom-left outward flare (merging into vertical side)
                PathQuad {
                    controlX: 20; controlY: 71
                    x: 20; y: 50
                }
                
                // Straight vertical left side
                PathLine { x: 20; y: 20 }
                
                // Top-left rounded corner
                PathQuad {
                    controlX: 20; controlY: 0
                    x: 40; y: 0
                }
                
                // Flat top plateau
                PathLine { x: 420; y: 0 }
                
                // Top-right rounded corner
                PathQuad {
                    controlX: 440; controlY: 0
                    x: 440; y: 20
                }
                
                // Straight vertical right side
                PathLine { x: 440; y: 50 }
                
                // Bottom-right outward flare
                PathQuad {
                    controlX: 440; controlY: 71
                    x: 460; y: 71
                }
                
                // Close the shape along the bottom edge
                PathLine { x: 0; y: 71 }
            }
        }

        RowLayout {
            anchors {
                top: parent.top
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 6 // Give visual weight to the bottom edge
            }
            spacing: 16

            // ── Screenshots (Hyprshot) ────────────────────────────────────
            CaptureButton {
                icon: "󰍹" // Fullscreen
                bgColor: "#d4a45a"
                onClicked: { Quickshell.execDetached(["hyprshot", "-m", "output"]); win.close() }
            }
            CaptureButton {
                icon: "󰖲" // Window
                bgColor: "#a0784a"
                onClicked: { Quickshell.execDetached(["hyprshot", "-m", "window"]); win.close() }
            }
            CaptureButton {
                icon: "󰒉" // Region
                bgColor: "#8a7055"
                onClicked: { Quickshell.execDetached(["hyprshot", "-m", "region"]); win.close() }
            }

            // Divider
            Rectangle {
                width: 2
                height: 32
                color: "#5A4736"
                radius: 1
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
                Layout.rightMargin: 8
            }

            // ── Screen Recording (wf-recorder) ─────────────────────────────
            CaptureButton {
                icon: "󰕧" // Video Fullscreen
                bgColor: "#d45a5a"
                onClicked: { if (win.pill) win.pill.startRecording("output"); win.close() }
            }
            CaptureButton {
                icon: "󰖲" // Video Window
                bgColor: "#a04a4a"
                onClicked: { if (win.pill) win.pill.startRecording("window"); win.close() }
            }
            CaptureButton {
                icon: "󰒉" // Video Region
                bgColor: "#8a3535"
                onClicked: { if (win.pill) win.pill.startRecording("region"); win.close() }
            }
        }
    }
}
