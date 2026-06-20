import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#0A0A08"
    readonly property color surface:         "#131007"
    readonly property color surfaceHigh:     "#1d1707"
    readonly property color surfaceTop:      "#271d07"
    
    readonly property color accent:          "#4ade7f"
    readonly property color accentSoft:      "#FFBB00"
    readonly property color border:          "#2e2206"
    readonly property color accentDim:       "#CC9900"

    readonly property color fg:              "#FFB000"
    readonly property color fgMid:           "#D4AA00"
    readonly property color fgDim:           "#805500"
    readonly property color fgInverted:      "#0A0A08"

    readonly property color error:           "#FF8800"
    readonly property color errorText:       "#FFAA00"
    readonly property color errorSoft:       "#FF8800"
    readonly property color warning:         "#FFD700"
    readonly property color success:         "#FFCC00"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#4ade7f"
    readonly property color primary: "#4ade7f"
    readonly property color primaryFg: "#0A0A08"
    readonly property color primaryContainer: "#CC9900"
    readonly property color primaryContainerFg: "#FFB000"
    readonly property color secondary: "#CC9900"
    readonly property color secondaryFg: "#0A0A08"
    readonly property color secondaryContainer: "#FFB000"
    readonly property color secondaryContainerFg: "#FFB000"
    readonly property color tertiary: "#FF9900"
    readonly property color tertiaryFg: "#0A0A08"
    readonly property color errorContainer: "#FF8800"
    readonly property color errorContainerFg: "#FFB000"
    readonly property color errorFg: "#0A0A08"
    
    readonly property color surfaceDim: "#0A0A08"
    readonly property color surfaceBright: "#1d1707"
    readonly property color surfaceContainerLowest: "#0A0A08"
    readonly property color surfaceContainerLow: "#0A0A08"
    readonly property color surfaceContainer: "#131007"
    readonly property color surfaceContainerHigh: "#1d1707"
    readonly property color surfaceContainerHighest: "#271d07"
    readonly property color surfaceFg: "#FFB000"
    readonly property color surfaceVariantFg: "#D4AA00"
    readonly property color outline: "#2e2206"
    readonly property color outlineVariant: "#1c1607"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
