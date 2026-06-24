import QtQuick

QtObject {
    property string name: "Custom Theme"

    readonly property color bg:              "#0f0f0f"
    readonly property color surface:         "#171716"
    readonly property color surfaceHigh:     "#201f1e"
    readonly property color surfaceTop:      "#292725"
    
    readonly property color accent:          "#e2be8a"
    readonly property color accentSoft:      "#eacea7"
    readonly property color border:          "#2f2d2b"
    readonly property color accentDim:       "#e2be8a"

    readonly property color fg:              "#eadccc"
    readonly property color fgMid:           "#e6caab"
    readonly property color fgDim:           "#706a6a"
    readonly property color fgInverted:      "#0f0f0f"

    readonly property color error:           "#e25d6c"
    readonly property color errorText:       "#e9838f"
    readonly property color errorSoft:       "#e25d6c"
    readonly property color warning:         "#f4bb54"
    readonly property color success:         "#cea37f"

    // Material 3 placeholders mapping to base colors
    readonly property color seed: "#e2be8a"
    readonly property color primary: "#e2be8a"
    readonly property color primaryFg: "#0f0f0f"
    readonly property color primaryContainer: "#e2be8a"
    readonly property color primaryContainerFg: "#eadccc"
    readonly property color secondary: "#e8ab3b"
    readonly property color secondaryFg: "#0f0f0f"
    readonly property color secondaryContainer: "#ecb95c"
    readonly property color secondaryContainerFg: "#eadccc"
    readonly property color tertiary: "#ede4c8"
    readonly property color tertiaryFg: "#0f0f0f"
    readonly property color errorContainer: "#e25d6c"
    readonly property color errorContainerFg: "#eadccc"
    readonly property color errorFg: "#0f0f0f"
    
    readonly property color surfaceDim: "#0f0f0f"
    readonly property color surfaceBright: "#201f1e"
    readonly property color surfaceContainerLowest: "#0f0f0f"
    readonly property color surfaceContainerLow: "#0f0f0f"
    readonly property color surfaceContainer: "#171716"
    readonly property color surfaceContainerHigh: "#201f1e"
    readonly property color surfaceContainerHighest: "#292725"
    readonly property color surfaceFg: "#eadccc"
    readonly property color surfaceVariantFg: "#e6caab"
    readonly property color outline: "#2f2d2b"
    readonly property color outlineVariant: "#1f1e1d"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
