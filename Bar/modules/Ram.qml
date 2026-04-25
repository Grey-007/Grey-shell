import QtQuick
import Quickshell.Io

Item {
    id: root

    width: 36
    height: 36
    implicitWidth: width
    implicitHeight: height

    property real usage: 0

    function poll() {
        ramProcess.exec(["sh", "-c", "awk '/^MemTotal:/ {total=$2} /^MemAvailable:/ {avail=$2} END {if (total > 0) printf \"%.0f\", ((total - avail) * 100 / total)}' /proc/meminfo"])
    }

    function parseRam(text) {
        const value = Number(text.trim())
        if (!isNaN(value)) usage = Math.max(0, Math.min(100, value))
    }

    Component.onCompleted: poll()

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.poll()
    }

    Process {
        id: ramProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseRam(this.text)
        }
    }

    MetricRing {
        iconXOffset: -2
        anchors.centerIn: parent
        icon: ""
        value: root.usage
        valueText: Math.round(root.usage).toString()
        acceptedButtons: Qt.NoButton
    }
}
