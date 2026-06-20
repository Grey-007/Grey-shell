import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#f3e4cb"
    readonly property color surface:         "#ecdcc3"
    readonly property color surfaceHigh:     "#e5d5bc"
    readonly property color surfaceTop:      "#dfceb5"
    
    readonly property color accent:          "#a32f1a"
    readonly property color accentSoft:      "#e84d31"
    readonly property color border:          "#dac8b0"
    readonly property color accentDim:       "#a32f1a"

    readonly property color fg:              "#4d2e1a"
    readonly property color fgMid:           "#080503"
    readonly property color fgDim:           "#9f8253"
    readonly property color fgInverted:      "#f3e4cb"

    readonly property color error:           "#a4373c"
    readonly property color errorText:       "#d2656a"
    readonly property color errorSoft:       "#a4373c"
    readonly property color warning:         "#a8611f"
    readonly property color success:         "#a46d2d"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#a32f1a"
    readonly property color primary: "#a32f1a"
    readonly property color primaryFg: "#f3e4cb"
    readonly property color primaryContainer: "#a32f1a"
    readonly property color primaryContainerFg: "#4d2e1a"
    readonly property color secondary: "#755833"
    readonly property color secondaryFg: "#f3e4cb"
    readonly property color secondaryContainer: "#b8884c"
    readonly property color secondaryContainerFg: "#4d2e1a"
    readonly property color tertiary: "#9c3521"
    readonly property color tertiaryFg: "#f3e4cb"
    readonly property color errorContainer: "#a4373c"
    readonly property color errorContainerFg: "#4d2e1a"
    readonly property color errorFg: "#f3e4cb"
    
    readonly property color surfaceDim: "#f3e4cb"
    readonly property color surfaceBright: "#e5d5bc"
    readonly property color surfaceContainerLowest: "#f3e4cb"
    readonly property color surfaceContainerLow: "#f3e4cb"
    readonly property color surfaceContainer: "#ecdcc3"
    readonly property color surfaceContainerHigh: "#e5d5bc"
    readonly property color surfaceContainerHighest: "#dfceb5"
    readonly property color surfaceFg: "#4d2e1a"
    readonly property color surfaceVariantFg: "#080503"
    readonly property color outline: "#dac8b0"
    readonly property color outlineVariant: "#e6d6bd"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
