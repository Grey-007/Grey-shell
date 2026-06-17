pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Durations in milliseconds
    readonly property int durationShort: 150
    readonly property int durationNormal: 250
    readonly property int durationLong: 300

    // Easing curves
    readonly property int easingDefault: Easing.OutCubic
    readonly property int easingSmooth: Easing.InOutQuad
    readonly property int easingPop: Easing.OutBack
}
