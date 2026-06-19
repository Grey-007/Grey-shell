import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#0d0509"
    readonly property color surface:         "#0d0509"
    readonly property color surfaceHigh:     "#4a3c45"
    readonly property color surfaceTop:      "#0d0509"
    
    readonly property color accent:          "#e85f6f"
    readonly property color accentSoft:      "#ebb97e"
    readonly property color border:          "#4a3c45"
    readonly property color accentDim:       "#d96cb8"

    readonly property color fg:              "#f0eaed"
    readonly property color fgMid:           "#f0eaed"
    readonly property color fgDim:           "#4a3c45"
    readonly property color fgInverted:      "#0d0509"

    readonly property color error:           "#e85f6f"
    readonly property color errorText:       "#ff7a8a"
    readonly property color errorSoft:       "#e85f6f"
    readonly property color warning:         "#d482b3"
    readonly property color success:         "#f29b9a"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#e85f6f"
    readonly property color primary: "#e85f6f"
    readonly property color primaryFg: "#0d0509"
    readonly property color primaryContainer: "#d96cb8"
    readonly property color primaryContainerFg: "#f0eaed"
    readonly property color secondary: "#e8c099"
    readonly property color secondaryFg: "#0d0509"
    readonly property color secondaryContainer: "#fbd2ab"
    readonly property color secondaryContainerFg: "#f0eaed"
    readonly property color tertiary: "#d1b399"
    readonly property color tertiaryFg: "#0d0509"
    readonly property color errorContainer: "#e85f6f"
    readonly property color errorContainerFg: "#f0eaed"
    readonly property color errorFg: "#0d0509"
    
    readonly property color surfaceDim: "#0d0509"
    readonly property color surfaceBright: "#4a3c45"
    readonly property color surfaceContainerLowest: "#0d0509"
    readonly property color surfaceContainerLow: "#0d0509"
    readonly property color surfaceContainer: "#0d0509"
    readonly property color surfaceContainerHigh: "#4a3c45"
    readonly property color surfaceContainerHighest: "#4a3c45"
    readonly property color surfaceFg: "#f0eaed"
    readonly property color surfaceVariantFg: "#f0eaed"
    readonly property color outline: "#4a3c45"
    readonly property color outlineVariant: "#4a3c45"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
