import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

// Notifications — sepia theme, slide in from left
PanelWindow {
    id: notifPanel

    anchors { left: true; bottom: true }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    width:  visible ? 368 : 0
    height: notifColumn.implicitHeight + 24
    color:  "transparent"

    NotificationServer {
        id: server
        keepOnReload: false
        onNotification: (notif) => {
            dismissTimer.createObject(notifPanel, { notification: notif })
        }
    }

    Column {
        id: notifColumn
        anchors {
            left:   parent.left
            bottom: parent.bottom
            margins: 14
        }
        spacing: 8

        Repeater {
            model: server.notifications

            delegate: Item {
                id: toastWrapper
                required property Notification modelData

                width:  344
                height: card.height

                property real slideX: -380
                NumberAnimation on slideX {
                    from: -380; to: 0
                    duration: 300; easing.type: Easing.OutCubic; running: true
                }
                transform: Translate { x: toastWrapper.slideX }

                Rectangle {
                    id: card
                    width:  parent.width
                    height: cardContent.implicitHeight + 20
                    radius: 14
                    color:  "#241c14"
                    border.color: "#a0784a"
                    border.width: 1

                    // Urgency stripe
                    Rectangle {
                        anchors {
                            left: parent.left; top: parent.top; bottom: parent.bottom
                            margins: 1
                        }
                        width:  3; radius: 2
                        color:  toastWrapper.modelData.urgency === NotificationUrgency.Critical
                                ? "#e8856a" : "#a0784a"
                    }

                    ColumnLayout {
                        id: cardContent
                        anchors {
                            left: parent.left; right: parent.right; top: parent.top
                            margins: 14; leftMargin: 22
                        }
                        spacing: 2

                        Text {
                            text:  toastWrapper.modelData.appName
                            color: "#8a7055"
                            font.pixelSize: 10; font.weight: Font.Medium
                            visible: text !== ""
                        }

                        Text {
                            Layout.fillWidth: true
                            text:  toastWrapper.modelData.summary
                            color: "#f0e0c0"
                            font.pixelSize: 13; font.weight: Font.SemiBold
                            elide:   Text.ElideRight
                            visible: text !== ""
                        }

                        Text {
                            Layout.fillWidth: true
                            text:  toastWrapper.modelData.body
                            color: "#c8a87a"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            visible:  text !== ""
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    toastWrapper.modelData.dismiss()
                    }
                }
            }
        }
    }

    Component {
        id: dismissTimer
        Timer {
            property Notification notification
            interval: 5000; running: true
            onTriggered: { notification.expire(); destroy() }
        }
    }
}
