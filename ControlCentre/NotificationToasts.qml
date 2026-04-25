import "."
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    implicitWidth: 360
    implicitHeight: toastColumn.implicitHeight + 24
    visible: ControlCentreState.toastNotifications.length > 0
    color: "transparent"

    anchors {
        top: true
        right: true
    }

    Column {
        id: toastColumn

        spacing: 8

        anchors {
            right: parent.right
            top: parent.top
            margins: 12
        }

        Repeater {
            model: ControlCentreState.toastNotifications

            delegate: Item {
                id: toast

                required property var modelData
                property real slideX: 360
                property real progress: 1

                width: 336
                height: card.height
                Component.onCompleted: {
                    slideAnim.start();
                    progressAnim.start();
                    hideTimer.start();
                }

                NumberAnimation {
                    id: slideAnim

                    target: toast
                    property: "slideX"
                    from: 360
                    to: 0
                    duration: 360
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    id: progressAnim

                    target: toast
                    property: "progress"
                    from: 1
                    to: 0
                    duration: 5200
                    easing.type: Easing.Linear
                }

                Timer {
                    id: hideTimer

                    interval: 5200
                    onTriggered: ControlCentreState.removeToast(toast.modelData.id)
                }

                Rectangle {
                    id: card

                    width: parent.width
                    height: toastContent.implicitHeight + 24
                    radius: 18
                    color: "#fffbf7"
                    border.color: "#00000012"
                    border.width: 1
                    antialiasing: true

                    ColumnLayout {
                        id: toastContent

                        spacing: 3

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 12
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.appName || "Notification"
                            color: "#827a73"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.summary || ""
                            color: "#2c2926"
                            font.pixelSize: 13
                            font.weight: 600
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.body || ""
                            color: "#625b55"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            visible: text !== ""
                        }

                    }

                    Rectangle {
                        width: parent.width * toast.progress
                        height: 3
                        radius: 2
                        color: "#2f5fae"

                        anchors {
                            right: parent.right
                            left: undefined
                            bottom: parent.bottom
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ControlCentreState.dismissNotification(toast.modelData.notification)
                    }

                }

                transform: Translate {
                    x: toast.slideX
                }

            }

        }

    }

}
