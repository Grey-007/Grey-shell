import QtQuick
import qs.Animation

// AnimationManager: reusable animation component definitions.
// Import this file and use the Component IDs via Loader or inline.
QtObject {
    id: root

    readonly property int durationShort: AnimationConfig.durationShort
    readonly property int durationNormal: AnimationConfig.durationNormal
    readonly property int durationLong: AnimationConfig.durationLong
    readonly property int easingSmooth: AnimationConfig.easingSmooth
    readonly property int easingDefault: AnimationConfig.easingDefault
    readonly property int easingPop: AnimationConfig.easingPop
}
