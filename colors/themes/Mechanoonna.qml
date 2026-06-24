import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#1c1b19"
    readonly property color surface:         "#24231f"
    readonly property color surfaceHigh:     "#2c2b26"
    readonly property color surfaceTop:      "#35332d"
    
    readonly property color accent:          "#706e6b"
    readonly property color accentSoft:      "#aaa090"
    readonly property color border:          "#3b3932"
    readonly property color accentDim:       "#908d88"

    readonly property color fg:              "#f0e4c5"
    readonly property color fgMid:           "#fbf1c7"
    readonly property color fgDim:           "#6b655c"
    readonly property color fgInverted:      "#1c1b19"

    readonly property color error:           "#c5564a"
    readonly property color errorText:       "#d94e38"
    readonly property color errorSoft:       "#c5564a"
    readonly property color warning:         "#ebdbb2"
    readonly property color success:         "#a89984"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#706e6b"
    readonly property color primary: "#706e6b"
    readonly property color primaryFg: "#1c1b19"
    readonly property color primaryContainer: "#908d88"
    readonly property color primaryContainerFg: "#f0e4c5"
    readonly property color secondary: "#d4bd99"
    readonly property color secondaryFg: "#1c1b19"
    readonly property color secondaryContainer: "#e7c07c"
    readonly property color secondaryContainerFg: "#f0e4c5"
    readonly property color tertiary: "#afa499"
    readonly property color tertiaryFg: "#1c1b19"
    readonly property color errorContainer: "#c5564a"
    readonly property color errorContainerFg: "#f0e4c5"
    readonly property color errorFg: "#1c1b19"
    
    readonly property color surfaceDim: "#1c1b19"
    readonly property color surfaceBright: "#2c2b26"
    readonly property color surfaceContainerLowest: "#1c1b19"
    readonly property color surfaceContainerLow: "#1c1b19"
    readonly property color surfaceContainer: "#24231f"
    readonly property color surfaceContainerHigh: "#2c2b26"
    readonly property color surfaceContainerHighest: "#35332d"
    readonly property color surfaceFg: "#f0e4c5"
    readonly property color surfaceVariantFg: "#fbf1c7"
    readonly property color outline: "#3b3932"
    readonly property color outlineVariant: "#2b2a25"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
