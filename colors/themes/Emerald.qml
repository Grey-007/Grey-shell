import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#1c1c1c"
    readonly property color surface:         "#252525"
    readonly property color surfaceHigh:     "#2e2e2e"
    readonly property color surfaceTop:      "#373737"
    
    readonly property color accent:          "#4ade7f"
    readonly property color accentSoft:      "#4ade7f"
    readonly property color border:          "#3e3e3e"
    readonly property color accentDim:       "#4ade7f"

    readonly property color fg:              "#ffffff"
    readonly property color fgMid:           "#bababa"
    readonly property color fgDim:           "#8d8d8d"
    readonly property color fgInverted:      "#000000"

    readonly property color error:           "#ff0000"
    readonly property color errorText:       "#ff0000"
    readonly property color errorSoft:       "#ff0000"
    readonly property color warning:         "#ffaa00"
    readonly property color success:         "#00ff00"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#4ade7f"
    readonly property color primary: "#4ade7f"
    readonly property color primaryFg: "#1c1c1c"
    readonly property color primaryContainer: "#4ade7f"
    readonly property color primaryContainerFg: "#ffffff"
    readonly property color secondary: "#4ade7f"
    readonly property color secondaryFg: "#1c1c1c"
    readonly property color secondaryContainer: "#4ade7f"
    readonly property color secondaryContainerFg: "#ffffff"
    readonly property color tertiary: "#4ade7f"
    readonly property color tertiaryFg: "#1c1c1c"
    readonly property color errorContainer: "#ff0000"
    readonly property color errorContainerFg: "#ffffff"
    readonly property color errorFg: "#1c1c1c"
    
    readonly property color surfaceDim: "#1c1c1c"
    readonly property color surfaceBright: "#2e2e2e"
    readonly property color surfaceContainerLowest: "#1c1c1c"
    readonly property color surfaceContainerLow: "#1c1c1c"
    readonly property color surfaceContainer: "#252525"
    readonly property color surfaceContainerHigh: "#2e2e2e"
    readonly property color surfaceContainerHighest: "#373737"
    readonly property color surfaceFg: "#ffffff"
    readonly property color surfaceVariantFg: "#bababa"
    readonly property color outline: "#3e3e3e"
    readonly property color outlineVariant: "#2d2d2d"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
