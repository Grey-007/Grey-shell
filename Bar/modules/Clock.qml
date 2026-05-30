import QtQuick

Item {
    id: root

    signal clicked()

    height: 36
    width: 80
    implicitWidth: width
    implicitHeight: height

    property string timeString: ""
    property color color: "#eef8de"
    property color accentColor: "#b7ff3c"

    function updateTime() {
        const now = new Date()

        let hours = now.getHours()
        let minutes = now.getMinutes()

        let suffix = hours >= 12 ? "PM" : "AM"
        hours = hours % 12
        if (hours === 0) hours = 12

        let h = hours.toString()
        let m = minutes < 10 ? "0" + minutes : minutes

        root.timeString = h + ":" + m + " " + suffix
    }

    FontLoader {
        id: customFont
        source: "../fonts/Prism-Regular.otf"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: root.updateTime()
    }

    Component.onCompleted: updateTime()

    Text {
        anchors.centerIn: parent

        text: root.timeString

        font.pixelSize: 20

        color: root.color
        renderType: Text.NativeRendering
        verticalAlignment: Text.AlignVCenter

        antialiasing: true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
