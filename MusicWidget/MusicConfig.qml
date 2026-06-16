pragma Singleton
import QtQuick
import "../Animation/AnimationConfig.qml" as AnimationConfig
import "./Theme.qml" as MusicTheme

QtObject {
    id: musicConfig

    // Widget Dimensions and Positioning
    readonly property int widgetWidth: 340
    readonly property int widgetHeight: 420
    readonly property int marginRight: 10
    readonly property int widgetRadius: 20 // Soft geometry from GEMINI.md

    // Animation Settings (referencing global AnimationConfig)
    readonly property int animationDurationShort: AnimationConfig.durationShort
    readonly property int animationDurationNormal: AnimationConfig.durationNormal
    readonly property int animationDurationLong: AnimationConfig.durationLong
    readonly property easing easingDefault: AnimationConfig.easingDefault
    readonly property easing easingSmooth: AnimationConfig.easingSmooth
    readonly property easing easingPop: AnimationConfig.easingPop

    // Visualizer Settings
    readonly property bool visualizerEnabled: true
    readonly property real visualizerOpacity: 0.6 // Subtle, blend into background

    // GIF Settings
    readonly property string defaultGif: "" // No default GIF initially

    // Opacity Values
    readonly property real defaultOpacity: 1.0
    readonly property real mutedOpacity: 0.7

    // Theme Values (referencing MusicTheme)
    readonly property color backgroundColor: MusicTheme.backgroundColor
    readonly property color surfaceColor: MusicTheme.surfaceColor
    readonly property color raisedSurfaceColor: MusicTheme.raisedSurfaceColor
    readonly property color accentColorPrimary: MusicTheme.accentColorPrimary
    readonly property color accentColorSecondary: MusicTheme.accentColorSecondary
    readonly property color textColor: MusicTheme.textColor
    readonly property color mutedTextColor: MusicTheme.mutedTextColor
}