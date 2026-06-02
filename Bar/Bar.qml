import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "modules"

// Bar.qml — floating top panel for Hyprland
PanelWindow {
    id: bar

    signal mediaClicked()
    signal powerClicked()
    signal calendarClicked()

    readonly property int barHeight: 36
    readonly property int topInset: 2
    readonly property int edgeInset: 20
    readonly property int contentInset: 4
    readonly property int modulePadding: 10
    readonly property int sectionGap: Math.max(10, Math.round((screen?.width ?? 1360) * 0.01))
    readonly property color bg: "#071006"
    readonly property color bgRaised: "#101a0c"
    readonly property color bgInset: "#172512"
    readonly property color accent: "#b7ff3c"
    readonly property color accentSoft: "#7ee022"
    readonly property color fg: "#eef8de"
    readonly property color muted: "#a9b99a"
    readonly property color border: "#b7ff3c"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: topInset
        left: edgeInset
        right: edgeInset
    }

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: topInset + barHeight - 10

    implicitHeight: barHeight
    color: "transparent"

    Rectangle {
        anchors {
            fill: panelBackground
            topMargin: 5
            leftMargin: 2
            rightMargin: 2
            bottomMargin: -3
        }
        radius: panelBackground.radius
        color: "#7ee022"
        opacity: 0.18
        antialiasing: true
    }

    Rectangle {
        anchors {
            fill: panelBackground
            topMargin: 2
            leftMargin: 1
            rightMargin: 1
            bottomMargin: -1
        }
        radius: panelBackground.radius
        color: "#ffffff"
        opacity: 0.28
        antialiasing: true
    }

    Rectangle {
        id: panelBackground

        anchors.fill: parent
        radius: 11
        color: bar.bg
        border.color: bar.accent
        border.width: 2
        antialiasing: true
        border.pixelAligned: false

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 2
            }
            height: 1
            radius: 1
            color: bar.accent
            opacity: 0.32
        }
    }

    Item {
        id: barLayout

        anchors {
            fill: parent
            leftMargin: bar.contentInset
            rightMargin: bar.contentInset
        }

        Rectangle {
            id: leftGroup

            x: 0
            anchors.verticalCenter: parent.verticalCenter
            width: leftRow.implicitWidth + bar.modulePadding * 2
            height: 28
            radius: 14
            color: bar.bgRaised
            border.color: Qt.rgba(0.72, 1, 0.24, 0.28)
            border.width: 1
            antialiasing: true

            Behavior on width {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            RowLayout {
                id: leftRow

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: bar.modulePadding
                    rightMargin: bar.modulePadding
                }
                spacing: 12

                Item {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18

                    Text {
                        anchors.centerIn: parent
                        text: "◊"
                        color: bar.accent
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                    }
                }

                Workspaces {}
            }
        }

        Rectangle {
            id: clockGroup

            readonly property real idealX: (barLayout.width - width) / 2
            readonly property real minX: leftGroup.x + leftGroup.width + bar.sectionGap
            readonly property real maxX: rightGroup.x - bar.sectionGap - width

            x: Math.max(minX, Math.min(idealX, maxX))
            anchors.verticalCenter: parent.verticalCenter
            width: clock.implicitWidth + 20
            height: 28
            radius: 14
            color: bar.bgInset
            border.color: Qt.rgba(0.72, 1, 0.24, 0.22)
            border.width: 1
            antialiasing: true

            Behavior on x {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            Clock {
                id: clock
                anchors.centerIn: parent
                color: bar.fg
                accentColor: bar.accent
                onClicked: bar.calendarClicked()
            }
        }

        Rectangle {
            id: rightGroup

            x: barLayout.width - width
            anchors.verticalCenter: parent.verticalCenter
            width: rightRow.implicitWidth + bar.modulePadding * 2
            height: 28
            radius: 14
            color: bar.bgRaised
            border.color: Qt.rgba(0.72, 1, 0.24, 0.28)
            border.width: 1
            antialiasing: true

            Behavior on x {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            Behavior on width {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            RowLayout {
                id: rightRow

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: bar.modulePadding
                    rightMargin: bar.modulePadding
                }
                spacing: 5

                Tray {}
                Cpu {}
                Ram {}
                Volume {}
                Battery {}
                PowerButton {
                    onClicked: bar.powerClicked()
                }
            }
        }
    }
}
