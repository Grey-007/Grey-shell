import QtQuick
import Quickshell.Io

Item {
    id: root

    width: 36
    height: 36
    implicitWidth: width
    implicitHeight: height

    property real usage: 0
    property real lastTotal: 0
    property real lastIdle: 0

    function poll() {
        cpuProcess.exec(["sh", "-c", "awk '/^cpu / {print $2,$3,$4,$5,$6,$7,$8}' /proc/stat"])
    }

    function parseCpu(text) {
        const parts = text.trim().split(/\s+/).map(Number)
        if (parts.length < 4) return

        const idle = parts[3] + (parts[4] || 0)
        const total = parts.reduce((sum, value) => sum + value, 0)

        if (lastTotal > 0) {
            const totalDelta = total - lastTotal
            const idleDelta = idle - lastIdle
            if (totalDelta > 0) {
                usage = Math.max(0, Math.min(100, Math.round((1 - idleDelta / totalDelta) * 100)))
            }
        }

        lastTotal = total
        lastIdle = idle
    }

    Component.onCompleted: poll()

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.poll()
    }

    Process {
        id: cpuProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseCpu(this.text)
        }
    }

    MetricRing {
        iconXOffset: -2
        anchors.centerIn: parent
        icon: ""
        value: root.usage
        valueText: Math.round(root.usage).toString()
        acceptedButtons: Qt.NoButton
    }
}
