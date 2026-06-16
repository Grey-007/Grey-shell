pragma Singleton
import QtQuick

QtObject {
    id: animationConfig

    // Durations in milliseconds
    readonly property int durationShort: 150
    readonly property int durationNormal: 250
    readonly property int durationLong: 300

    // Easing curves
    readonly property easing easingDefault: Easing.OutCubic
    readonly property easing easingSmooth: Easing.InOutQuad
    readonly property easing easingPop: Easing.OutBack
}