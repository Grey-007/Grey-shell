import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#262A2C"
    readonly property color surface:         "#2d3133"
    readonly property color surfaceHigh:     "#35393b"
    readonly property color surfaceTop:      "#3d4142"
    
    readonly property color accent:          "#BEBEBE"
    readonly property color accentSoft:      "#DCDCDC"
    readonly property color border:          "#434648"
    readonly property color accentDim:       "#CFCFCF"

    readonly property color fg:              "#EAEAEA"
    readonly property color fgMid:           "#F2F2F2"
    readonly property color fgDim:           "#1F2224"
    readonly property color fgInverted:      "#262A2C"

    readonly property color error:           "#6B6C6D"
    readonly property color errorText:       "#8A8C8D"
    readonly property color errorSoft:       "#6B6C6D"
    readonly property color warning:         "#E0E0E0"
    readonly property color success:         "#BEBEBE"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#BEBEBE"
    readonly property color primary: "#BEBEBE"
    readonly property color primaryFg: "#262A2C"
    readonly property color primaryContainer: "#CFCFCF"
    readonly property color primaryContainerFg: "#EAEAEA"
    readonly property color secondary: "#E0E0E0"
    readonly property color secondaryFg: "#262A2C"
    readonly property color secondaryContainer: "#F5F5F5"
    readonly property color secondaryContainerFg: "#EAEAEA"
    readonly property color tertiary: "#D6D6D6"
    readonly property color tertiaryFg: "#262A2C"
    readonly property color errorContainer: "#6B6C6D"
    readonly property color errorContainerFg: "#EAEAEA"
    readonly property color errorFg: "#262A2C"
    
    readonly property color surfaceDim: "#262A2C"
    readonly property color surfaceBright: "#35393b"
    readonly property color surfaceContainerLowest: "#262A2C"
    readonly property color surfaceContainerLow: "#262A2C"
    readonly property color surfaceContainer: "#2d3133"
    readonly property color surfaceContainerHigh: "#35393b"
    readonly property color surfaceContainerHighest: "#3d4142"
    readonly property color surfaceFg: "#EAEAEA"
    readonly property color surfaceVariantFg: "#F2F2F2"
    readonly property color outline: "#434648"
    readonly property color outlineVariant: "#34383a"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
