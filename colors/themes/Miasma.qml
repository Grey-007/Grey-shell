import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#222222"
    readonly property color surface:         "#282827"
    readonly property color surfaceHigh:     "#2e2e2d"
    readonly property color surfaceTop:      "#353533"
    
    readonly property color accent:          "#78824b"
    readonly property color accentSoft:      "#78824b"
    readonly property color border:          "#3a3a37"
    readonly property color accentDim:       "#78824b"

    readonly property color fg:              "#c2c2b0"
    readonly property color fgMid:           "#d7c483"
    readonly property color fgDim:           "#666666"
    readonly property color fgInverted:      "#222222"

    readonly property color error:           "#685742"
    readonly property color errorText:       "#685742"
    readonly property color errorSoft:       "#685742"
    readonly property color warning:         "#b36d43"
    readonly property color success:         "#5f875f"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#78824b"
    readonly property color primary: "#78824b"
    readonly property color primaryFg: "#222222"
    readonly property color primaryContainer: "#78824b"
    readonly property color primaryContainerFg: "#c2c2b0"
    readonly property color secondary: "#c9a554"
    readonly property color secondaryFg: "#222222"
    readonly property color secondaryContainer: "#c9a554"
    readonly property color secondaryContainerFg: "#c2c2b0"
    readonly property color tertiary: "#bb7744"
    readonly property color tertiaryFg: "#222222"
    readonly property color errorContainer: "#685742"
    readonly property color errorContainerFg: "#c2c2b0"
    readonly property color errorFg: "#222222"
    
    readonly property color surfaceDim: "#222222"
    readonly property color surfaceBright: "#2e2e2d"
    readonly property color surfaceContainerLowest: "#222222"
    readonly property color surfaceContainerLow: "#222222"
    readonly property color surfaceContainer: "#282827"
    readonly property color surfaceContainerHigh: "#2e2e2d"
    readonly property color surfaceContainerHighest: "#353533"
    readonly property color surfaceFg: "#c2c2b0"
    readonly property color surfaceVariantFg: "#d7c483"
    readonly property color outline: "#3a3a37"
    readonly property color outlineVariant: "#2e2e2c"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
