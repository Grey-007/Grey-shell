import QtQuick
import Quickshell.Io

// Battery.qml — battery level bar
Item {
    id: root

    implicitWidth:  bar.implicitWidth
    implicitHeight: 28

    property real percentage: 0
    property bool charging:   false
    property bool hasBattery: true

    function poll() {
        batCap.exec(["sh", "-c",
            "for b in /sys/class/power_supply/*; do " +
            "[ -r \"$b/type\" ] && [ \"$(cat \"$b/type\")\" = Battery ] && cat \"$b/capacity\" && exit; " +
            "done; echo -1"])
        batStat.exec(["sh", "-c",
            "for b in /sys/class/power_supply/*; do " +
            "[ -r \"$b/type\" ] && [ \"$(cat \"$b/type\")\" = Battery ] && cat \"$b/status\" && exit; " +
            "done; echo Unknown"])
    }

    Component.onCompleted: poll()
    Timer { interval: 15000; running: true; repeat: true; onTriggered: root.poll() }

    Process {
        id: batCap
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(this.text.trim())
                if (v < 0) { root.hasBattery = false }
                else        { root.hasBattery = true; root.percentage = v }
            }
        }
    }
    Process {
        id: batStat
        stdout: StdioCollector {
            onStreamFinished: {
                const s = this.text.trim()
                root.charging = (s === "Charging" || s === "Full")
            }
        }
    }

    MetricBar {
        id: bar
        anchors.centerIn: parent
        // nf-md-battery-charging / nf-md-battery levels
        icon:  root.charging          ? "\udb80\udc82"   // nf-md-battery_charging
             : root.percentage >= 90  ? "\udb80\udc80"   // nf-md-battery
             : root.percentage >= 60  ? "\udb80\udc7e"
             : root.percentage >= 30  ? "\udb80\udc7c"
             : root.percentage >= 10  ? "\udb80\udc7a"
             :                          "\udb80\udc79"   // nf-md-battery_alert
        label:     "BAT"
        value:     root.charging ? 100 : root.percentage
        active:    root.hasBattery
        clickable: false
        fillColor: root.percentage <= 15 && !root.charging ? "#e87a52" : "#d4a45a"
    }
}
