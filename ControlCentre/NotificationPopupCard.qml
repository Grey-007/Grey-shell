import QtQuick
import QtQuick.Layouts
import Quickshell

// NotificationPopupCard.qml — notification history card
Rectangle {
    id: root

    property int panelWidth: 400

    radius: 0
    color: "#241D18"
    border.color: "#5A4736"
    border.width: 1
    clip: true

    ColumnLayout {
        id: notifInner
        anchors {
            left:   parent.left
            right:  parent.right
            top:    parent.top
            bottom: parent.bottom
            margins: 14
        }
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text:           "Notifications"
                color:          "#A67C52"
                font.pixelSize: 13
                font.family:    "monospace"
                font.weight:    Font.DemiBold
                font.letterSpacing: 1
            }

            SmallButton {
                text:    "Clear all"
                visible: ControlCentreState.notifications.length > 0
                onClicked: ControlCentreState.clearNotifications()
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#5A4736"
            opacity: 0.5
        }

        // Empty state
        Text {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.bottomMargin: 16
            horizontalAlignment: Text.AlignHCenter
            text:           "No notifications"
            color:          "#8C6F56"
            font.pixelSize: 12
            font.family:    "monospace"
            visible: ControlCentreState.notifications.length === 0
        }

        // Notification list scrollable
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: notifList.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id: notifList
                width: parent.width
                spacing: 6
                visible: ControlCentreState.notifications.length > 0

                Repeater {
                    model: ControlCentreState.notifications

                    delegate: Item {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        implicitHeight: contentLayout.implicitHeight + 20

                        // Slide in from right when added
                        opacity: 1
                        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                        Rectangle {
                            id: notifBody
                            anchors.fill: parent
                            radius: 0
                            color: "#3A2E26"
                            border.color: "#5A4736"
                            border.width: 1
                            scale: pressArea.containsPress ? 0.985 : 1.0

                            Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                            // Amber left accent bar
                            Rectangle {
                                anchors {
                                    left:         parent.left
                                    top:          parent.top
                                    bottom:       parent.bottom
                                    topMargin:    6
                                    bottomMargin: 6
                                }
                                width:  3
                                radius: 0
                                color:  "#A67C52"
                                opacity: 0.8
                            }

                            ColumnLayout {
                                id: contentLayout
                                spacing: 3
                                anchors {
                                    left:       parent.left
                                    right:      parent.right
                                    top:        parent.top
                                    margins:    10
                                    leftMargin: 16
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text:           modelData.appName || "Notification"
                                    color:          "#A67C52"
                                    font.pixelSize: 10
                                    font.family:    "monospace"
                                    font.weight:    Font.DemiBold
                                    elide:          Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text:           modelData.summary || ""
                                    color:          "#F2E0C8"
                                    font.pixelSize: 12
                                    font.family:    "monospace"
                                    font.weight:    Font.DemiBold
                                    elide:          Text.ElideRight
                                    visible:        text !== ""
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text:            modelData.body || ""
                                    color:           "#8C6F56"
                                    font.pixelSize:  11
                                    font.family:     "monospace"
                                    wrapMode:        Text.WordWrap
                                    maximumLineCount: 3
                                    elide:           Text.ElideRight
                                    textFormat:      Text.PlainText
                                    visible:         text !== ""
                                }
                            }

                            MouseArea {
                                id: pressArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: ControlCentreState.dismissNotification(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
