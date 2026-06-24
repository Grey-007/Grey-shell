import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#0a0a0a"
    readonly property color surface:         "#111212"
    readonly property color surfaceHigh:     "#191a1a"
    readonly property color surfaceTop:      "#202323"
    
    readonly property color accent:          "#ADF0E9"
    readonly property color accentSoft:      "#ADF0E9"
    readonly property color border:          "#262929"
    readonly property color accentDim:       "#ADF0E9"

    readonly property color fg:              "#c8dcdc"
    readonly property color fgMid:           "#c4d8e2"
    readonly property color fgDim:           "#322F3B"
    readonly property color fgInverted:      "#0a0a0a"

    readonly property color error:           "#D35F5F"
    readonly property color errorText:       "#D35F5F"
    readonly property color errorSoft:       "#D35F5F"
    readonly property color warning:         "#A9D1D7"
    readonly property color success:         "#8FECD5"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#ADF0E9"
    readonly property color primary: "#ADF0E9"
    readonly property color primaryFg: "#0a0a0a"
    readonly property color primaryContainer: "#ADF0E9"
    readonly property color primaryContainerFg: "#c8dcdc"
    readonly property color secondary: "#5a676b"
    readonly property color secondaryFg: "#0a0a0a"
    readonly property color secondaryContainer: "#5a676b"
    readonly property color secondaryContainerFg: "#c8dcdc"
    readonly property color tertiary: "#485362"
    readonly property color tertiaryFg: "#0a0a0a"
    readonly property color errorContainer: "#D35F5F"
    readonly property color errorContainerFg: "#c8dcdc"
    readonly property color errorFg: "#0a0a0a"
    
    readonly property color surfaceDim: "#0a0a0a"
    readonly property color surfaceBright: "#191a1a"
    readonly property color surfaceContainerLowest: "#0a0a0a"
    readonly property color surfaceContainerLow: "#0a0a0a"
    readonly property color surfaceContainer: "#111212"
    readonly property color surfaceContainerHigh: "#191a1a"
    readonly property color surfaceContainerHighest: "#202323"
    readonly property color surfaceFg: "#c8dcdc"
    readonly property color surfaceVariantFg: "#c4d8e2"
    readonly property color outline: "#262929"
    readonly property color outlineVariant: "#181919"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
