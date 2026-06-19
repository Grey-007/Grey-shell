// ClipboardManager.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../colors"

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
    visible: win.isOpen || container.x > -container.width

    function toggle() {
        isOpen = !isOpen
        if (isOpen) {
            cliphistListProcess.running = true;
        }
    }

    function open() {
        isOpen = true
        cliphistListProcess.running = true;
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

    ListModel {
        id: clipModel
    }

    Process {
        id: cliphistListProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                clipModel.clear();
                text.trim().split("\n").forEach(line => {
                    if (line.trim() === "") return;
                    var parts = line.split("\t");
                    if (parts.length >= 2) {
                        clipModel.append({ "itemId": parts[0], "content": parts[1] });
                    }
                });
            }
        }
    }

    function selectItem(itemId) {
        // decode and pipe to wl-copy
        Quickshell.execDetached(["bash", "-c", "cliphist decode " + itemId + " | wl-copy"]);
        win.close();
    }

    Item {
        id: container
        width: 380
        height: 640
        anchors.verticalCenter: parent.verticalCenter
        
        // Slide in from left
        x: win.isOpen ? 0 : -width

        Behavior on x {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }

        // Eat clicks so they don't close the menu
        MouseArea {
            anchors.fill: parent
            onClicked: {}
            onWheel: (wheel) => {
                // Pass scroll events to listview
                wheel.accepted = false;
            }
        }

        Shape {
            anchors.fill: parent
            
            ShapePath {
                fillColor: ThemeManager.surface   // Sepia surface
                strokeColor: ThemeManager.border // Sepia border
                strokeWidth: 2
                
                // Start top-left
                startX: 0
                startY: 0 
                
                // Top-left outward flare
                PathQuad {
                    controlX: 0; controlY: 20
                    x: 20; y: 20
                }
                
                // Straight horizontal top plateau
                PathLine { x: 360; y: 20 }
                
                // Top-right rounded corner
                PathQuad {
                    controlX: 380; controlY: 20
                    x: 380; y: 40
                }
                
                // Straight vertical right side
                PathLine { x: 380; y: 600 }
                
                // Bottom-right rounded corner
                PathQuad {
                    controlX: 380; controlY: 620
                    x: 360; y: 620
                }
                
                // Straight horizontal bottom plateau
                PathLine { x: 20; y: 620 }
                
                // Bottom-left outward flare
                PathQuad {
                    controlX: 0; controlY: 620
                    x: 0; y: 640
                }
                
                // Close shape along left edge
                PathLine { x: 0; y: 0 }
            }
        }

        Item {
            anchors {
                fill: parent
                topMargin: 20
                bottomMargin: 20
                leftMargin: 2
                rightMargin: 20
            }
            clip: true

            ListView {
                id: listView
                anchors.fill: parent
                anchors.margins: 16
                model: clipModel
                spacing: 8
                
                // Smooth scrolling
                boundsBehavior: Flickable.StopAtBounds
                
                header: Item {
                    width: listView.width
                    height: 40
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Clipboard History"
                        color: ThemeManager.accentSoft
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: ThemeManager.border
                    }
                }

                delegate: Rectangle {
                    width: listView.width
                    height: 50
                    radius: 8
                    color: itemMouseArea.containsMouse ? ThemeManager.border : "transparent"
                    border.color: itemMouseArea.containsMouse ? ThemeManager.accent : "transparent"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        text: model.content
                        color: ThemeManager.fg
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: selectItem(model.itemId)
                    }
                }
            }
        }
    }
}
