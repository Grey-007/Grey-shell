import QtQuick
import Quickshell.Io

Item {
    id: root

    width: 36
    height: 36
    implicitWidth: width
    implicitHeight: height

    property real percentage: 0
    property bool charging: false
    property bool hasBattery: true

    function poll() {
        batCapacity.exec(["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo -1"])
        batStatus.exec(["sh", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown"])
    }

    // Unicode battery levels
    readonly property string batIcon: {
        if (!hasBattery) return "?"
        if (charging) return "⚡"
        if (percentage >= 90) return "▓"
        if (percentage >= 60) return "▒"
        if (percentage >= 30) return "░"
        return "□"
    }

    Component.onCompleted: poll()

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.poll()
    }

    Process {
        id: batCapacity
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(this.text.trim())
                if (val < 0) {
                    root.hasBattery = false
                } else {
                    root.hasBattery = true
                    root.percentage = val
                }
            }
        }
    }

    Process {
        id: batStatus
        stdout: StdioCollector {
            onStreamFinished: {
                const s = this.text.trim()
                root.charging = (s === "Charging" || s === "Full")
            }
        }
    }

    MetricRing {
        anchors.centerIn: parent
        icon: root.batIcon
        value: root.charging ? 100 : root.percentage
        valueText: root.charging ? "⚡" : root.percentage.toString()
        active: root.hasBattery
        // pulse ring when critical
        dimmed: root.percentage <= 15 && !root.charging
        acceptedButtons: Qt.NoButton
        iconSize: root.charging ? 11 : 13
    }
}