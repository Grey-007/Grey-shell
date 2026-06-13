import QtQuick
import QtQuick.Layouts

// Clock.qml — fancy bar clock with time, seconds, and date
Item {
    id: root

    signal clicked()

    property color color:       "#f0e0c0"
    property color accentColor: "#d4a45a"
    property color mutedColor:  "#8a7055"

    // Internal state
    property int  _h:    12
    property int  _m:    0
    property int  _s:    0
    property bool _isPm: false
    property string _dayName:  ""
    property int  _dayNum: 1
    property string _monthAbbr: ""

    implicitWidth:  timeRow.implicitWidth + 8
    implicitHeight: 28

    function _update() {
        const now = new Date()
        let h = now.getHours()
        _isPm = h >= 12
        h = h % 12
        if (h === 0) h = 12
        _h = h
        _m = now.getMinutes()
        _s = now.getSeconds()
        _dayNum   = now.getDate()
        const days   = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        const months = ["Jan","Feb","Mar","Apr","May","Jun",
                        "Jul","Aug","Sep","Oct","Nov","Dec"]
        _dayName   = days[now.getDay()]
        _monthAbbr = months[now.getMonth()]
    }

    function _pad(n) { return n < 10 ? "0" + n : n.toString() }

    Timer {
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: root._update()
    }
    Component.onCompleted: _update()

    // ── Layout ─────────────────────────────────────────────────────
    Row {
        id: timeRow
        anchors.centerIn: parent
        spacing: 5

        // Date pill: "Mon 9 Jun"
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                text:              root._dayName
                color:             root.mutedColor
                font.pixelSize:    10
                font.weight:       Font.Medium
                font.letterSpacing: 0.6
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text:              root._dayNum.toString()
                color:             root.accentColor
                font.pixelSize:    11
                font.weight:       Font.DemiBold
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text:              root._monthAbbr
                color:             root.mutedColor
                font.pixelSize:    10
                font.weight:       Font.Medium
                font.letterSpacing: 0.6
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Thin separator
        Rectangle {
            width:  1
            height: 13
            color:  Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35)
            anchors.verticalCenter: parent.verticalCenter
        }

        // HH:MM — main time, large
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text:              root._h.toString()
                color:             root.color
                font.pixelSize:    16
                font.weight:       Font.Medium
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            // blinking colon
            Text {
                id: colonMain
                text:              ":"
                color:             root.accentColor
                font.pixelSize:    15
                font.weight:       Font.Light
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation on opacity {
                    running: true
                    loops:   Animation.Infinite
                    NumberAnimation { to: 0.25; duration: 500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 500; easing.type: Easing.InOutSine }
                }
            }

            Text {
                text:              root._pad(root._m)
                color:             root.color
                font.pixelSize:    16
                font.weight:       Font.Medium
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Seconds (small, muted) + AM/PM
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text:              root._pad(root._s)
                color:             root.mutedColor
                font.pixelSize:    9
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            // AM/PM badge
            Rectangle {
                width:  ampmText.implicitWidth + 5
                height: 13
                radius: 3
                color:  Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: ampmText
                    anchors.centerIn: parent
                    text:              root._isPm ? "PM" : "AM"
                    color:             root.accentColor
                    font.pixelSize:    8
                    font.weight:       Font.DemiBold
                    font.letterSpacing: 0.5
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.clicked()
    }
}
