pragma Singleton
import QtQuick
import Quickshell

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · Time
//
// A single shared ticking clock. Every screen's lock surface reads from
// this instead of running its own timer, so multi-monitor setups stay in
// sync and we only pay the cost of one Timer.
// ─────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    property var now: new Date()

    readonly property string hourMinute: Qt.formatTime(now, "hh:mm")
    readonly property string dayDate:    Qt.formatDate(now, "dddd, d MMMM")

    readonly property string greeting: {
        const h = now.getHours();
        if (h < 5)  return "Still up";
        if (h < 12) return "Good morning";
        if (h < 17) return "Good afternoon";
        if (h < 22) return "Good evening";
        return "Good night";
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }
}
