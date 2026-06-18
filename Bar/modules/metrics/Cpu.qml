import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Cpu.qml — CPU usage bar with click-to-popup
Item {
    id: root

    implicitWidth:  bar.implicitWidth
    implicitHeight: 28

    property real usage:     0
    property real lastTotal: 0
    property real lastIdle:  0

    // Signal upward so Bar.qml or SystemPopup can react
    signal barClicked()

    function poll() {
        cpuProc.exec(["sh", "-c",
            "awk '/^cpu / {print $2,$3,$4,$5,$6,$7,$8}' /proc/stat"])
    }

    function parseCpu(text) {
        const parts = text.trim().split(/\s+/).map(Number)
        if (parts.length < 4) return
        const idle  = parts[3] + (parts[4] || 0)
        const total = parts.reduce((s, v) => s + v, 0)
        if (lastTotal > 0) {
            const dt = total - lastTotal
            const di = idle  - lastIdle
            if (dt > 0)
                usage = Math.max(0, Math.min(100, Math.round((1 - di / dt) * 100)))
        }
        lastTotal = total
        lastIdle  = idle
    }

    Component.onCompleted: poll()
    Timer { interval: 2000; running: true; repeat: true; onTriggered: root.poll() }

    Process {
        id: cpuProc
        stdout: StdioCollector { onStreamFinished: root.parseCpu(this.text) }
    }

    MetricBar {
        id: bar
        anchors.centerIn: parent
        icon:      "\uf4bc"   // nf-fa-microchip
        label:     "CPU"
        value:     root.usage
        clickable: true
        onClicked: root.barClicked()
    }
}
