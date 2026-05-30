import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool popupOpen: false
    property bool visibleGate: false
    property date now: new Date()
    property int shownYear: now.getFullYear()
    property int shownMonth: now.getMonth()
    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    readonly property var dayNames: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    readonly property int cardWidth: Math.min(760, Math.max(600, width - 32))

    function open() {
        closeTimer.stop()
        now = new Date()
        shownYear = now.getFullYear()
        shownMonth = now.getMonth()
        visibleGate = true
        popupOpen = true
        focusTimer.restart()
    }

    function close() {
        popupOpen = false
        closeTimer.restart()
    }

    function toggle() {
        if (popupOpen) close()
        else open()
    }

    function changeMonth(offset) {
        const nextMonth = new Date(shownYear, shownMonth + offset, 1)
        shownYear = nextMonth.getFullYear()
        shownMonth = nextMonth.getMonth()
    }

    function handleWheel(wheel) {
        changeMonth(wheel.angleDelta.y > 0 ? -1 : 1)
        wheel.accepted = true
    }

    function dayForCell(index) {
        return new Date(shownYear, shownMonth, index - new Date(shownYear, shownMonth, 1).getDay() + 1)
    }

    function isToday(date) {
        return date.getFullYear() === now.getFullYear()
            && date.getMonth() === now.getMonth()
            && date.getDate() === now.getDate()
    }

    function twoDigits(value) {
        return value < 10 ? "0" + value : value.toString()
    }

    function clockText() {
        let hours = now.getHours()
        const suffix = hours >= 12 ? "PM" : "AM"
        hours = hours % 12
        if (hours === 0) hours = 12
        return hours + ":" + twoDigits(now.getMinutes()) + " " + suffix
    }

    function longDayText() {
        return Qt.formatDate(now, "dddd")
    }

    function longDateText() {
        return Qt.formatDate(now, "MMMM d, yyyy")
    }

    visible: visibleGate
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: popupOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Timer {
        interval: 1000
        running: root.visibleGate
        repeat: true
        onTriggered: root.now = new Date()
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: {
            if (!root.popupOpen) root.visibleGate = false
        }
    }

    Timer {
        id: focusTimer
        interval: 1
        onTriggered: keyboardHandler.forceActiveFocus()
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.popupOpen
        onClicked: root.close()
    }

    Item {
        id: keyboardHandler
        anchors.fill: parent
        focus: root.visibleGate

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.close()
                event.accepted = true
            } else if (event.key === Qt.Key_Left) {
                root.changeMonth(-1)
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                root.changeMonth(1)
                event.accepted = true
            }
        }
    }

    Rectangle {
        id: cardShadow
        anchors {
            horizontalCenter: calendarCard.horizontalCenter
            top: calendarCard.top
            topMargin: 7
        }
        width: calendarCard.width
        height: calendarCard.height
        radius: calendarCard.radius
        color: "#000000"
        opacity: root.popupOpen ? 0.32 : 0
    }

    Rectangle {
        id: calendarCard
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 62
        }
        width: root.cardWidth
        height: 414
        radius: 24
        color: "#111a0d"
        border.color: Qt.rgba(0.72, 1, 0.24, 0.34)
        border.width: 1
        opacity: root.popupOpen ? 1 : 0
        scale: root.popupOpen ? 1 : 0.96
        clip: true

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: function(mouse) {
                mouse.accepted = true
            }
            onWheel: function(wheel) { root.handleWheel(wheel) }
        }

        Rectangle {
            id: timePanel
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: parent.width * 0.25
            color: "#182610"

            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                width: 1
                color: Qt.rgba(0.72, 1, 0.24, 0.2)
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 18
                }
                spacing: 8

                Text {
                    width: parent.width
                    text: root.clockText()
                    color: "#b7ff3c"
                    font.pixelSize: 34
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                }

                Text {
                    width: parent.width
                    text: root.longDayText()
                    color: "#eef8de"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                }

                Text {
                    width: parent.width
                    text: root.longDateText()
                    color: "#a9b99a"
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }
            }
        }

        Item {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: timePanel.right
                right: parent.right
                margins: 22
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    Text {
                        Layout.fillWidth: true
                        text: root.monthNames[root.shownMonth] + "  " + root.shownYear
                        color: "#eef8de"
                        font.pixelSize: 21
                        font.weight: Font.DemiBold
                    }

                    Repeater {
                        model: [
                            { "label": "‹", "offset": -1 },
                            { "label": "›", "offset": 1 }
                        ]

                        Rectangle {
                            required property var modelData
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38
                            radius: 19
                            color: arrowMouse.containsMouse ? "#253817" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: "#b7ff3c"
                                font.pixelSize: 27
                            }

                            MouseArea {
                                id: arrowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.changeMonth(modelData.offset)
                                onWheel: function(wheel) { root.handleWheel(wheel) }
                            }
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 0
                    rowSpacing: 0

                    Repeater {
                        model: root.dayNames

                        Text {
                            required property string modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 22
                            text: modelData
                            color: "#7f9271"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    columnSpacing: 2
                    rowSpacing: 2

                    Repeater {
                        model: 42

                        Item {
                            required property int index
                            readonly property date cellDate: root.dayForCell(index)
                            readonly property bool inCurrentMonth: cellDate.getMonth() === root.shownMonth
                            readonly property bool today: root.isToday(cellDate)
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Rectangle {
                                anchors.centerIn: parent
                                width: 36
                                height: 36
                                radius: 18
                                color: parent.today ? "#b7ff3c"
                                    : dayMouse.containsMouse ? "#253817" : "transparent"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: parent.cellDate.getDate()
                                color: parent.today ? "#101a0c"
                                    : parent.inCurrentMonth ? "#eef8de" : "#617054"
                                font.pixelSize: 13
                                font.weight: parent.today ? Font.Bold : Font.Normal
                            }

                            MouseArea {
                                id: dayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onWheel: function(wheel) { root.handleWheel(wheel) }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 16
                    text: "Scroll to change month"
                    color: "#7f9271"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
