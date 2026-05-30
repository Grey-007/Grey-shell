import "."
import Qt5Compat.GraphicalEffects
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

    readonly property color surface: "#222A1C"
    readonly property color onSurface: "#E8F0DC"
    readonly property color onSurfaceVariant: "#A8B598"
    readonly property color primary: "#C5E87A"

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
            rightMargin: 14
            topMargin: 62
        }

        Repeater {
            model: ControlCentreState.toastNotifications

            delegate: Item {
                id: toast

                required property var modelData
                property real slideX: 380
                property real progress: 1

                width: 336
                height: card.height
                opacity: slideX < 20 ? 1 : 0

                Component.onCompleted: {
                    slideAnim.start();
                    progressAnim.start();
                    hideTimer.start();
                }

                NumberAnimation {
                    id: slideAnim

                    target: toast
                    property: "slideX"
                    from: 380
                    to: 0
                    duration: 340
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

                DropShadow {
                    anchors.fill: card
                    horizontalOffset: 0
                    verticalOffset: 6
                    radius: 22
                    samples: 32
                    color: "#00000055"
                    source: card
                    transparentBorder: true
                }

                Rectangle {
                    id: card

                    width: parent.width
                    height: toastContent.implicitHeight + 24
                    radius: 20
                    color: root.surface
                    clip: true

                    ColumnLayout {
                        id: toastContent

                        spacing: 3

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 14
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.appName || "Notification"
                            color: root.primary
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.summary || ""
                            color: root.onSurface
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.body || ""
                            color: root.onSurfaceVariant
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
                        color: root.primary

                        anchors {
                            left: parent.left
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
