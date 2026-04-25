import QtQuick

Item {
    id: root

    height: 36
    width: 80

    property string timeString: ""

    FontLoader {
        id: customFont
        source: "../fonts/Prism-Regular.otf"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
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
    }

    Text {
        anchors.centerIn: parent

        text: root.timeString

        font.pixelSize: 20

        color: "#000000"
        renderType: Text.NativeRendering
        verticalAlignment: Text.AlignVCenter

        antialiasing: true
    }
}