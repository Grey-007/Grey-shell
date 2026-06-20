import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#171717"
    readonly property color surface:         "#1e1e1e"
    readonly property color surfaceHigh:     "#252525"
    readonly property color surfaceTop:      "#2c2d2d"
    
    readonly property color accent:          "#F25623"
    readonly property color accentSoft:      "#88A57D"
    readonly property color border:          "#323232"
    readonly property color accentDim:       "#88A57D"

    readonly property color fg:              "#CCD0CF"
    readonly property color fgMid:           "#bcbfbc"
    readonly property color fgDim:           "#333333"
    readonly property color fgInverted:      "#171717"

    readonly property color error:           "#aeab94"
    readonly property color errorText:       "#aeab94"
    readonly property color errorSoft:       "#aeab94"
    readonly property color warning:         "#4D4D4D"
    readonly property color success:         "#F25623"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#F25623"
    readonly property color primary: "#F25623"
    readonly property color primaryFg: "#171717"
    readonly property color primaryContainer: "#88A57D"
    readonly property color primaryContainerFg: "#CCD0CF"
    readonly property color secondary: "#8A8A8A"
    readonly property color secondaryFg: "#171717"
    readonly property color secondaryContainer: "#8A8A8A"
    readonly property color secondaryContainerFg: "#CCD0CF"
    readonly property color tertiary: "#F56E0F"
    readonly property color tertiaryFg: "#171717"
    readonly property color errorContainer: "#aeab94"
    readonly property color errorContainerFg: "#CCD0CF"
    readonly property color errorFg: "#171717"
    
    readonly property color surfaceDim: "#171717"
    readonly property color surfaceBright: "#252525"
    readonly property color surfaceContainerLowest: "#171717"
    readonly property color surfaceContainerLow: "#171717"
    readonly property color surfaceContainer: "#1e1e1e"
    readonly property color surfaceContainerHigh: "#252525"
    readonly property color surfaceContainerHighest: "#2c2d2d"
    readonly property color surfaceFg: "#CCD0CF"
    readonly property color surfaceVariantFg: "#bcbfbc"
    readonly property color outline: "#323232"
    readonly property color outlineVariant: "#242424"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
