import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// Tray.qml — System tray with sepia hover effects
Item {
    id: root

    height:         28
    width:          SystemTray.items.values.length > 0 ? trayRow.implicitWidth : 0
    implicitWidth:  width
    implicitHeight: height
    visible:        SystemTray.items.values.length > 0

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: ScriptModel { values: SystemTray.items.values }

            delegate: MouseArea {
                id: trayButton

                required property SystemTrayItem modelData

                width:           24
                height:          24
                hoverEnabled:    true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                cursorShape:     Qt.PointingHandCursor
                scale: pressed ? 0.88 : containsMouse ? 1.10 : 1

                Behavior on scale {
                    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }

                // Sepia hover glow
                Rectangle {
                    anchors.fill: parent
                    radius:       width / 2
                    color:        "#d4a45a"
                    opacity:      trayButton.containsMouse ? 0.18 : 0
                    antialiasing: true

                    Behavior on opacity {
                        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                    }
                }

                IconImage {
                    anchors.centerIn: parent
                    width:        16; height: 16
                    implicitSize: 16
                    source:       trayButton.modelData.icon
                    asynchronous: true
                }

                function openMenu() {
                    if (!modelData.hasMenu) return
                    const point = mapToItem(null, 0, height + 5)
                    modelData.display(QsWindow.window, Math.round(point.x), Math.round(point.y))
                }

                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton || modelData.onlyMenu) {
                        openMenu()
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate()
                    } else {
                        modelData.activate()
                    }
                    mouse.accepted = true
                }

                onWheel: function(wheel) {
                    modelData.scroll(wheel.angleDelta.y, false)
                    wheel.accepted = true
                }
            }
        }
    }
}
