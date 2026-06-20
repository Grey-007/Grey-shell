import QtQuick

QtObject {
    property string name: "Custom Theme"

    // ── System theming ─────────────────────────────────────────────
    readonly property string gtkTheme:    "Adwaita-dark"
    readonly property string kvTheme:     ""
    readonly property string colorScheme: "prefer-dark"

    property color bg:              "#f3e4cb"
    property color surface:         "#f3e4cb"
    property color surfaceHigh:     "#9f8253"
    property color surfaceTop:      "#f3e4cb"
    
    property color accent:          "#a32f1a"
    property color accentSoft:      "#e84d31"
    property color border:          "#9f8253"
    property color accentDim:       "#a32f1a"

    property color fg:              "#4d2e1a"
    property color fgMid:           "#080503"
    property color fgDim:           "#9f8253"
    property color fgInverted:      "#f3e4cb"

    property color error:           "#a4373c"
    property color errorText:       "#d2656a"
    property color errorSoft:       "#a4373c"
    property color warning:         "#a8611f"
    property color success:         "#a46d2d"

    // Material 3 placeholders mapping to base colors
    property color seed: "#a32f1a"
    property color primary: "#a32f1a"
    property color primaryFg: "#f3e4cb"
    property color primaryContainer: "#a32f1a"
    property color primaryContainerFg: "#4d2e1a"
    property color secondary: "#755833"
    property color secondaryFg: "#f3e4cb"
    property color secondaryContainer: "#b8884c"
    property color secondaryContainerFg: "#4d2e1a"
    property color tertiary: "#9c3521"
    property color tertiaryFg: "#f3e4cb"
    property color errorContainer: "#a4373c"
    property color errorContainerFg: "#4d2e1a"
    property color errorFg: "#f3e4cb"
    
    property color surfaceDim: "#f3e4cb"
    property color surfaceBright: "#9f8253"
    property color surfaceContainerLowest: "#f3e4cb"
    property color surfaceContainerLow: "#f3e4cb"
    property color surfaceContainer: "#f3e4cb"
    property color surfaceContainerHigh: "#9f8253"
    property color surfaceContainerHighest: "#9f8253"
    property color surfaceFg: "#4d2e1a"
    property color surfaceVariantFg: "#080503"
    property color outline: "#9f8253"
    property color outlineVariant: "#9f8253"
    
    property color scrimTop: "transparent"
    property color scrimBottom: "#aa000000"
    property real scrimOpacity: 0.8
}
