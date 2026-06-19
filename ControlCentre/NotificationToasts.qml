import "."
import QtQuick
import QtQuick.Layouts
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../colors"

// Material You toast notifications
PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    implicitWidth:  368
    implicitHeight: toastCol.implicitHeight + 24
    visible: ControlCentreState.toastNotifications.length > 0
    color: "transparent"

    // Sepia tokens
                
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Column {
        id: toastCol
        spacing: 8
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: 14
            topMargin: 66
        }

        Repeater {
            model: ControlCentreState.toastNotifications

            delegate: Item {
                id: toast
                required property var modelData

                property real slideX: 400
                property real progress: 1.0

                width: 352
                height: toastCard.height

                // Only visible when fully slid in
                opacity: slideX < 16 ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
                }

                Component.onCompleted: {
                    slideAnim.start();
                    progressAnim.start();
                    hideTimer.start();
                }

                NumberAnimation {
                    id: slideAnim
                    target: toast
                    property: "slideX"
                    from: 400; to: 0
                    duration: 380
                    easing.type: Easing.OutQuint
                }

                NumberAnimation {
                    id: progressAnim
                    target: toast
                    property: "progress"
                    from: 1.0; to: 0.0
                    duration: 5400
                    easing.type: Easing.Linear
                }

                Timer {
                    id: hideTimer
                    interval: 5400
                    onTriggered: ControlCentreState.removeToast(toast.modelData.id)
                }

                transform: Translate {
                    x: toast.slideX
                }

                Rectangle {
                    id: toastCard
                    width: parent.width
                    height: toastContent.implicitHeight + 26
                    radius: 0
                    color: ThemeManager.surface
                    border.color: ThemeManager.border
                    border.width: 1
                    clip: true

                    ColumnLayout {
                        id: toastContent
                        spacing: 4
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 14
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.appName || "Notification"
                            color: root.ThemeManager.accent
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.summary || ""
                            color: root.ThemeManager.fg
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.notification.body || ""
                            color: root.ThemeManager.fgMid
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            visible: text !== ""
                        }
                    }

                    // Progress bar at bottom
                    Rectangle {
                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                        }
                        width: parent.width * toast.progress
                        height: 3
                        radius: 0
                        color: root.ThemeManager.accent
                        opacity: 0.7

                        Behavior on width {
                            enabled: false
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ControlCentreState.dismissNotification(
                                       toast.modelData.notification)
                    }
                }
            }
        }
    }
}
