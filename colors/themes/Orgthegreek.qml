import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#d0d0c8"
    readonly property color surface:         "#c9c9c1"
    readonly property color surfaceHigh:     "#c2c2ba"
    readonly property color surfaceTop:      "#bbbbb4"
    
    readonly property color accent:          "#DE6A41"
    readonly property color accentSoft:      "#e88b5f"
    readonly property color border:          "#b6b6af"
    readonly property color accentDim:       "#DE6A41"

    readonly property color fg:              "#242424"
    readonly property color fgMid:           "#383835"
    readonly property color fgDim:           "#494a42"
    readonly property color fgInverted:      "#d0d0c8"

    readonly property color error:           "#db0030"
    readonly property color errorText:       "#ef597a"
    readonly property color errorSoft:       "#db0030"
    readonly property color warning:         "#51573b"
    readonly property color success:         "#2e3125"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#DE6A41"
    readonly property color primary: "#DE6A41"
    readonly property color primaryFg: "#d0d0c8"
    readonly property color primaryContainer: "#DE6A41"
    readonly property color primaryContainerFg: "#242424"
    readonly property color secondary: "#363a34"
    readonly property color secondaryFg: "#d0d0c8"
    readonly property color secondaryContainer: "#777b6f"
    readonly property color secondaryContainerFg: "#242424"
    readonly property color tertiary: "#43432b"
    readonly property color tertiaryFg: "#d0d0c8"
    readonly property color errorContainer: "#db0030"
    readonly property color errorContainerFg: "#242424"
    readonly property color errorFg: "#d0d0c8"
    
    readonly property color surfaceDim: "#d0d0c8"
    readonly property color surfaceBright: "#c2c2ba"
    readonly property color surfaceContainerLowest: "#d0d0c8"
    readonly property color surfaceContainerLow: "#d0d0c8"
    readonly property color surfaceContainer: "#c9c9c1"
    readonly property color surfaceContainerHigh: "#c2c2ba"
    readonly property color surfaceContainerHighest: "#bbbbb4"
    readonly property color surfaceFg: "#242424"
    readonly property color surfaceVariantFg: "#383835"
    readonly property color outline: "#b6b6af"
    readonly property color outlineVariant: "#c3c3bb"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
