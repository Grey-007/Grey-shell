import QtQuick
import Quickshell.Io

// Ram.qml — RAM usage bar with click-to-popup
Item {
    id: root

    implicitWidth:  bar.implicitWidth
    implicitHeight: 28

    property real usage: 0
    signal barClicked()

    function poll() {
        ramProc.exec(["sh", "-c",
            "awk '/^MemTotal:/{t=$2}/^MemAvailable:/{a=$2}END{if(t>0)printf \"%.0f\",((t-a)*100/t)}' /proc/meminfo"])
    }

    function parseRam(text) {
        const v = Number(text.trim())
        if (!isNaN(v)) usage = Math.max(0, Math.min(100, v))
    }

    Component.onCompleted: poll()
    Timer { interval: 3000; running: true; repeat: true; onTriggered: root.poll() }

    Process {
        id: ramProc
        stdout: StdioCollector { onStreamFinished: root.parseRam(this.text) }
    }

    MetricBar {
        id: bar
        anchors.centerIn: parent
        icon:      "\uf538"   // nf-fa-memory
        label:     "RAM"
        value:     root.usage
        clickable: true
        onClicked: root.barClicked()
    }
}
