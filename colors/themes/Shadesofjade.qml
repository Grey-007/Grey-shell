import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#00110b"
    readonly property color surface:         "#091a14"
    readonly property color surfaceHigh:     "#12231d"
    readonly property color surfaceTop:      "#1b2c26"
    
    readonly property color accent:          "#a9f970"
    readonly property color accentSoft:      "#006540"
    readonly property color border:          "#22332d"
    readonly property color accentDim:       "#006540"

    readonly property color fg:              "#e6f6f0"
    readonly property color fgMid:           "#e6f6f0"
    readonly property color fgDim:           "#87ae83"
    readonly property color fgInverted:      "#00110b"

    readonly property color error:           "#ff3370"
    readonly property color errorText:       "#ff3370"
    readonly property color errorSoft:       "#ff3370"
    readonly property color warning:         "#D1FFb0"
    readonly property color success:         "#00a86b"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#a9f970"
    readonly property color primary: "#a9f970"
    readonly property color primaryFg: "#00110b"
    readonly property color primaryContainer: "#006540"
    readonly property color primaryContainerFg: "#e6f6f0"
    readonly property color secondary: "#80d4b5"
    readonly property color secondaryFg: "#00110b"
    readonly property color secondaryContainer: "#80d4b5"
    readonly property color secondaryContainerFg: "#e6f6f0"
    readonly property color tertiary: "#8fc85c"
    readonly property color tertiaryFg: "#00110b"
    readonly property color errorContainer: "#ff3370"
    readonly property color errorContainerFg: "#e6f6f0"
    readonly property color errorFg: "#00110b"
    
    readonly property color surfaceDim: "#00110b"
    readonly property color surfaceBright: "#12231d"
    readonly property color surfaceContainerLowest: "#00110b"
    readonly property color surfaceContainerLow: "#00110b"
    readonly property color surfaceContainer: "#091a14"
    readonly property color surfaceContainerHigh: "#12231d"
    readonly property color surfaceContainerHighest: "#1b2c26"
    readonly property color surfaceFg: "#e6f6f0"
    readonly property color surfaceVariantFg: "#e6f6f0"
    readonly property color outline: "#22332d"
    readonly property color outlineVariant: "#11221c"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
