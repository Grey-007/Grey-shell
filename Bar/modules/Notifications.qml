import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

// Notifications.qml
// PanelWindow anchored to left edge. Notifications slide in from the left.
// Monochrome: white bg, black text.
PanelWindow {
    id: notifPanel

    anchors {
        left: true
        bottom: true
    }

    // Window is always present but transparent/zero when empty
    // so the panel doesn't block input when idle
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    width: visible ? 360 : 0
    height: notifColumn.implicitHeight + 24
    color: "transparent"

    NotificationServer {
        id: server
        keepOnReload: false

        onNotification: (notif) => {
            // Auto-dismiss after 5s
            dismissTimer.createObject(notifPanel, { notification: notif })
        }
    }

    // Stack of toast cards
    Column {
        id: notifColumn
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 12
        }
        spacing: 8

        Repeater {
            model: server.notifications

            delegate: Item {
                id: toastWrapper
                required property Notification modelData

                width: 340
                height: card.height

                // Slide in from left: starts off-screen, animates to 0
                property real slideX: -360
                NumberAnimation on slideX {
                    from: -360
                    to: 0
                    duration: 320
                    easing.type: Easing.OutCubic
                    running: true
                }

                transform: Translate { x: toastWrapper.slideX }

                Rectangle {
                    id: card
                    width: parent.width
                    height: cardContent.implicitHeight + 20
                    radius: 12
                    color: "#ffffff"
                    // Subtle shadow via border
                    border.color: "#00000018"
                    border.width: 1

                    // Left urgency stripe
                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                            margins: 1
                        }
                        width: 3
                        radius: 2
                        color: toastWrapper.modelData.urgency === NotificationUrgency.Critical
                               ? "#000000"
                               : "#00000040"
                    }

                    ColumnLayout {
                        id: cardContent
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 14
                            leftMargin: 22
                        }
                        spacing: 2

                        // App name
                        Text {
                            text: toastWrapper.modelData.appName
                            color: "#00000070"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            visible: text !== ""
                        }

                        // Summary
                        Text {
                            Layout.fillWidth: true
                            text: toastWrapper.modelData.summary
                            color: "#000000"
                            font.pixelSize: 13
                            font.weight: Font.SemiBold
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        // Body
                        Text {
                            Layout.fillWidth: true
                            text: toastWrapper.modelData.body
                            color: "#000000cc"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                        }
                    }

                    // Dismiss on click
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: toastWrapper.modelData.dismiss()
                    }
                }
            }
        }
    }

    // Auto-dismiss timer component
    Component {
        id: dismissTimer
        Timer {
            property Notification notification
            interval: 5000
            running: true
            onTriggered: {
                notification.expire()
                destroy()
            }
        }
    }
}