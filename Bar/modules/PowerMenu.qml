import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool menuOpen:    false
    property bool visibleGate: false
    readonly property bool narrow: width < 720

    readonly property var actions: [
        { "label": "Lock",     "description": "Secure",    "icon": "",   "command": ["loginctl", "lock-session"]        },
        { "label": "Sleep",    "description": "Suspend",   "icon": "󰒲",  "command": ["systemctl", "suspend"]            },
        { "label": "Log Out",  "description": "Hyprland",  "icon": "󰍃",  "command": ["hyprctl", "dispatch", "exit"]     },
        { "label": "Restart",  "description": "Reboot",    "icon": "󰜉",  "command": ["systemctl", "reboot"]             },
        { "label": "Power Off","description": "Shutdown",  "icon": "⏻",  "command": ["systemctl", "poweroff"]           },
        { "label": "Cancel",   "description": "Close",     "icon": "󰅖",  "command": []                                  }
    ]

    function open() {
        closeTimer.stop()
        visibleGate = true
        menuOpen    = true
        focusTimer.restart()
    }

    function close() {
        menuOpen = false
        closeTimer.restart()
    }

    function runAction(action) {
        close()
        if (action.command.length > 0)
            Quickshell.execDetached(action.command)
    }

    visible:       visibleGate
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"

    anchors { top: true; left: true; right: true; bottom: true }

    Timer {
        id: closeTimer
        interval: 280
        onTriggered: { if (!root.menuOpen) root.visibleGate = false }
    }

    Timer {
        id: focusTimer
        interval: 1
        onTriggered: content.forceActiveFocus()
    }

    // Sepia-tinted dark overlay
    Rectangle {
        anchors.fill: parent
        color:   "#1c1510"
        opacity: root.menuOpen ? 0.72 : 0
        Behavior on opacity {
            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked:    root.close()
    }

    Item {
        id: content
        anchors.fill: parent
        focus: root.visibleGate

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.close()
                event.accepted = true
            }
        }

        Item {
            id: stage
            anchors.centerIn: parent
            width:   Math.min(parent.width  * 0.78, 760)
            height:  Math.min(parent.height * 0.72, root.narrow ? 560 : 430)
            opacity: root.menuOpen ? 1 : 0
            scale:   root.menuOpen ? 1 : 0.93

            transform: Translate {
                y: root.menuOpen ? 0 : 28
                Behavior on y {
                    NumberAnimation { duration: 340; easing.type: Easing.OutCubic }
                }
            }

            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 340; easing.type: Easing.OutBack  } }

            // Card background — sepia parchment
            Rectangle {
                anchors.fill: parent
                radius:       30
                color:        "#241c14"
                border.color: "#a0784a"
                border.width: 1
                antialiasing: true

                // top gleam
                Rectangle {
                    anchors {
                        top: parent.top; left: parent.left; right: parent.right
                        margins: 2
                    }
                    height:  1; radius: 1
                    color:   "#d4a45a"; opacity: 0.20
                }
            }

            ColumnLayout {
                anchors {
                    fill:    parent
                    margins: root.narrow ? 22 : 28
                }
                spacing: 20

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text:  "Power"
                        color: "#f0e0c0"
                        font.pixelSize:  root.narrow ? 30 : 38
                        font.weight:     Font.Black
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }

                    Text {
                        Layout.fillWidth: true
                        text:  "choose what this machine does next"
                        color: "#8a7055"
                        font.pixelSize:  13
                        font.weight:     Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    columns:      root.narrow ? 2 : 3
                    columnSpacing: 12
                    rowSpacing:    12

                    Repeater {
                        model: root.actions

                        delegate: Rectangle {
                            id: actionCard

                            required property var modelData
                            required property int index

                            Layout.preferredWidth:  root.narrow ? 132 : 168
                            Layout.preferredHeight: root.narrow ? 112 : 124
                            radius:       22
                            color:        actionMouse.containsMouse ? "#d4a45a" : "#2e2118"
                            border.color: "#a0784a"
                            border.width: 1
                            antialiasing: true
                            scale: actionMouse.pressed         ? 0.95
                                 : actionMouse.containsMouse   ? 1.04 : 1

                            Behavior on color { ColorAnimation  { duration: 160; easing.type: Easing.OutCubic } }
                            Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 7

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text:  actionCard.modelData.icon
                                    color: actionMouse.containsMouse ? "#1c1510" : "#d4a45a"
                                    font.pixelSize:      root.narrow ? 24 : 30
                                    horizontalAlignment: Text.AlignHCenter
                                    renderType:          Text.NativeRendering
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text:  actionCard.modelData.label
                                    color: actionMouse.containsMouse ? "#1c1510" : "#f0e0c0"
                                    font.pixelSize: 13
                                    font.weight:    Font.Bold
                                    horizontalAlignment: Text.AlignHCenter
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text:  actionCard.modelData.description
                                    color: actionMouse.containsMouse ? "#1c151088" : "#8a7055"
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    renderType: Text.NativeRendering
                                }
                            }

                            MouseArea {
                                id: actionMouse
                                anchors.fill:  parent
                                hoverEnabled:  true
                                cursorShape:   Qt.PointingHandCursor
                                onClicked:     root.runAction(actionCard.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
