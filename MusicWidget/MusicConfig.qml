pragma Singleton
import QtQuick
import Quickshell
import qs.Animation
import qs.MusicWidget

Singleton {
    id: root

    // Widget Dimensions and Positioning
    readonly property int widgetWidth:  340
    readonly property int widgetHeight: 420
    readonly property int marginRight:  10
    readonly property int widgetRadius: 20

    // Animation Settings — forwarded from AnimationConfig singleton
    readonly property int animationDurationShort:  AnimationConfig.durationShort
    readonly property int animationDurationNormal: AnimationConfig.durationNormal
    readonly property int animationDurationLong:   AnimationConfig.durationLong
    readonly property int easingDefault:           AnimationConfig.easingDefault
    readonly property int easingSmooth:            AnimationConfig.easingSmooth
    readonly property int easingPop:               AnimationConfig.easingPop

    // Visualizer
    readonly property bool visualizerEnabled: true
    readonly property real visualizerOpacity: 0.5

    // GIF
    readonly property string defaultGif: ""

    // Opacity values
    readonly property real defaultOpacity: 1.0
    readonly property real mutedOpacity:   0.7
}
