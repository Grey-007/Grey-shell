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
    readonly property int cardWidth: Math.min(560, Math.max(420, width - 32))

    // ── Sepia palette ──────────────────────────────────────────────
    readonly property color sepiaBase:     "#1c1510"   // darkest bg
    readonly property color sepiaSurface:  "#241c14"   // tile bg
    readonly property color sepiaPanel:    "#2e2118"   // clock tile bg
    readonly property color sepiaBorder:   "#a0784a"   // warm gold border
    readonly property color sepiaAccent:   "#d4a45a"   // warm amber accent
    readonly property color sepiaText:     "#f0e0c0"   // main text
    readonly property color sepiaMuted:    "#8a7055"   // muted text
    readonly property color sepiaDim:      "#4a3828"   // dim / out-of-month
    readonly property color sepiaToday:    "#d4a45a"   // today highlight
    readonly property color sepiaTodayFg:  "#1c1510"   // today text
    readonly property color sepiaHover:    "#3a2a1c"   // hover bg

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

    function clockHour() {
        let h = now.getHours() % 12
        return h === 0 ? "12" : h.toString()
    }

    function clockMinute() {
        return twoDigits(now.getMinutes())
    }

    function clockSecond() {
        return twoDigits(now.getSeconds())
    }

    function clockAmPm() {
        return now.getHours() >= 12 ? "PM" : "AM"
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

    // ── Timers (unchanged logic) ───────────────────────────────────
    Timer {
        interval: 1000
        running: root.visibleGate
        repeat: true
        onTriggered: root.now = new Date()
    }

    Timer {
        id: closeTimer
        interval: 220
        onTriggered: {
            if (!root.popupOpen) root.visibleGate = false
        }
    }

    Timer {
        id: focusTimer
        interval: 1
        onTriggered: keyboardHandler.forceActiveFocus()
    }

    // ── Backdrop click to close ────────────────────────────────────
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

    // ── Container that holds both tiles, centred on screen ─────────
    Item {
        id: tilesContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 62
        width: root.cardWidth
        // clock tile + 10px gap + calendar tile
        height: clockTile.height + 10 + calendarTile.height

        opacity: root.popupOpen ? 1 : 0
        scale:   root.popupOpen ? 1 : 0.94
        // slide from slightly above


        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 240; easing.type: Easing.OutBack; easing.overshoot: 0.5 }
        }
        Behavior on anchors.topMargin {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        // stop clicks from falling through to backdrop
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: function(mouse) { mouse.accepted = true }
            onWheel: function(wheel) { root.handleWheel(wheel) }
        }

        // ══════════════════════════════════════════════════════════
        //  TILE 1 — FANCY CLOCK
        // ══════════════════════════════════════════════════════════
        Rectangle {
            id: clockTile
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 130
            radius: 20
            color: root.sepiaPanel
            border.color: Qt.rgba(
                root.sepiaBorder.r, root.sepiaBorder.g, root.sepiaBorder.b, 0.45)
            border.width: 1
            clip: false

            // subtle inner glow at top
            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: 1
                    leftMargin: 1
                    rightMargin: 1
                }
                height: 2
                radius: 20
                color: Qt.rgba(
                    root.sepiaAccent.r, root.sepiaAccent.g, root.sepiaAccent.b, 0.18)
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 28
                    rightMargin: 28
                    topMargin: 0
                    bottomMargin: 0
                }
                spacing: 0

                // ── Big time display ────────────────────────────
                Row {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 0

                    // Hours
                    Text {
                        text: root.clockHour()
                        color: root.sepiaAccent
                        font.pixelSize: 68
                        font.weight: Font.Thin
                        font.letterSpacing: -2
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Blinking colon
                    Text {
                        id: colon1
                        text: ":"
                        color: root.sepiaAccent
                        font.pixelSize: 58
                        font.weight: Font.Thin
                        verticalAlignment: Text.AlignVCenter
                        opacity: 1
                        SequentialAnimation on opacity {
                            running: root.visibleGate
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.2; duration: 500; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1;   duration: 500; easing.type: Easing.InOutSine }
                        }
                    }

                    // Minutes
                    Text {
                        text: root.clockMinute()
                        color: root.sepiaAccent
                        font.pixelSize: 68
                        font.weight: Font.Thin
                        font.letterSpacing: -2
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Dimmed colon + seconds
                    Text {
                        text: ":"
                        color: root.sepiaMuted
                        font.pixelSize: 36
                        font.weight: Font.Thin
                        verticalAlignment: Text.AlignBottom
                        bottomPadding: 10
                    }

                    Text {
                        text: root.clockSecond()
                        color: root.sepiaMuted
                        font.pixelSize: 36
                        font.weight: Font.Thin
                        verticalAlignment: Text.AlignBottom
                        bottomPadding: 10
                    }
                }

                // ── Spacer ──────────────────────────────────────
                Item { Layout.fillWidth: true }

                // ── AM/PM + date stack ──────────────────────────
                Column {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    // AM / PM badge
                    Rectangle {
                        width: ampmText.implicitWidth + 16
                        height: 28
                        radius: 6
                        color: Qt.rgba(
                            root.sepiaAccent.r, root.sepiaAccent.g, root.sepiaAccent.b, 0.15)
                        border.color: Qt.rgba(
                            root.sepiaAccent.r, root.sepiaAccent.g, root.sepiaAccent.b, 0.4)
                        border.width: 1

                        Text {
                            id: ampmText
                            anchors.centerIn: parent
                            text: root.clockAmPm()
                            color: root.sepiaAccent
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            font.letterSpacing: 2
                        }
                    }

                    // Day name
                    Text {
                        text: root.longDayText().toUpperCase()
                        color: root.sepiaText
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.letterSpacing: 1.5
                    }

                    // Full date
                    Text {
                        text: root.longDateText()
                        color: root.sepiaMuted
                        font.pixelSize: 11
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════
        //  TILE 2 — CALENDAR
        // ══════════════════════════════════════════════════════════
        Rectangle {
            id: calendarTile
            anchors {
                top: clockTile.bottom
                topMargin: 10          // gap between tiles
                left: parent.left
                right: parent.right
            }
            height: 290
            radius: 20
            color: root.sepiaSurface
            border.color: Qt.rgba(
                root.sepiaBorder.r, root.sepiaBorder.g, root.sepiaBorder.b, 0.35)
            border.width: 1
            clip: false

            // subtle inner glow at top
            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: 1
                    leftMargin: 1
                    rightMargin: 1
                }
                height: 2
                radius: 20
                color: Qt.rgba(
                    root.sepiaBorder.r, root.sepiaBorder.g, root.sepiaBorder.b, 0.12)
            }

            Item {
                anchors {
                    fill: parent
                    margins: 20
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    // ── Month nav header ────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36

                        Text {
                            Layout.fillWidth: true
                            text: root.monthNames[root.shownMonth] + "  " + root.shownYear
                            color: root.sepiaText
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            font.letterSpacing: 0.5
                        }

                        Repeater {
                            model: [
                                { "label": "‹", "offset": -1 },
                                { "label": "›", "offset": 1 }
                            ]

                            Rectangle {
                                required property var modelData
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 10
                                color: arrowMouse.containsMouse
                                    ? Qt.rgba(root.sepiaBorder.r, root.sepiaBorder.g, root.sepiaBorder.b, 0.25)
                                    : "transparent"
                                border.color: arrowMouse.containsMouse
                                    ? Qt.rgba(root.sepiaBorder.r, root.sepiaBorder.g, root.sepiaBorder.b, 0.5)
                                    : "transparent"
                                border.width: 1

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: root.sepiaAccent
                                    font.pixelSize: 22
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

                    // ── Day-of-week headers ──────────────────────
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
                                Layout.preferredHeight: 20
                                text: modelData
                                color: root.sepiaMuted
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                font.letterSpacing: 0.8
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // ── Day cells ───────────────────────────────
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
                                    width: 30
                                    height: 30
                                    radius: 8
                                    color: parent.today
                                        ? root.sepiaToday
                                        : dayMouse.containsMouse
                                            ? root.sepiaHover
                                            : "transparent"
                                    border.color: parent.today
                                        ? "transparent"
                                        : dayMouse.containsMouse
                                            ? Qt.rgba(root.sepiaBorder.r, root.sepiaBorder.g, root.sepiaBorder.b, 0.35)
                                            : "transparent"
                                    border.width: 1

                                    Behavior on color {
                                        ColorAnimation { duration: 110 }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.cellDate.getDate()
                                    color: parent.today
                                        ? root.sepiaTodayFg
                                        : parent.inCurrentMonth
                                            ? root.sepiaText
                                            : root.sepiaDim
                                    font.pixelSize: 12
                                    font.weight: parent.today ? Font.DemiBold : Font.Normal
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

                    // ── Hint ────────────────────────────────────
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 14
                        text: "scroll to change month  ·  esc to close"
                        color: root.sepiaDim
                        font.pixelSize: 10
                        font.letterSpacing: 0.5
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
