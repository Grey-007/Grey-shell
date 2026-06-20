import QtQuick
// Sepia.qml — default theme, the original warm sepia/parchment palette
QtObject {
    // ── System theming ─────────────────────────────────────────────
    readonly property string gtkTheme:    "Adwaita-dark"
    readonly property string kvTheme:     ""
    readonly property string colorScheme: "prefer-dark"

    // ── Surface hierarchy ──────────────────────────────────────────
    readonly property color bg:              "#1c1510"
    readonly property color surface:         "#241D18"
    readonly property color surfaceHigh:     "#2C241D"
    readonly property color surfaceTop:      "#3A2E26"

    // ── Accents ────────────────────────────────────────────────────
    readonly property color accent:          "#d4a45a"
    readonly property color accentSoft:      "#a0784a"
    readonly property color border:          "#5A4736"
    readonly property color accentDim:       "#4a3828"

    // ── Text ───────────────────────────────────────────────────────
    readonly property color fg:              "#f0e0c0"
    readonly property color fgMid:           "#8a7055"
    readonly property color fgDim:           "#5a4030"
    readonly property color fgInverted:      "#1c1510"

    // ── Semantic ───────────────────────────────────────────────────
    readonly property color error:           "#e04a4a"
    readonly property color errorText:       "#E8906A"
    readonly property color errorSoft:       "#a04a4a"
    readonly property color warning:         "#e87a52"
    readonly property color success:         "#BFD395"

    // ── Lockscreen Material 3 tokens ───────────────────────────────
    readonly property color seed:                       "#A1764A"
    readonly property color primary:                    "#E4C29B"
    readonly property color primaryFg:                  "#43290B"
    readonly property color primaryContainer:            "#5E4119"
    readonly property color primaryContainerFg:          "#FFDDB8"
    readonly property color secondary:                  "#D8C3AC"
    readonly property color secondaryFg:                "#3B2E1F"
    readonly property color secondaryContainer:          "#534434"
    readonly property color secondaryContainerFg:        "#F5E4D2"
    readonly property color tertiary:                   "#E6B8A2"
    readonly property color tertiaryFg:                 "#48261A"
    readonly property color errorContainer:              "#8C2C1C"
    readonly property color errorContainerFg:            "#FFDAD2"
    readonly property color errorFg:                    "#680E04"
    readonly property color surfaceDim:                 "#15100B"
    readonly property color surfaceBright:              "#3C332B"
    readonly property color surfaceContainerLowest:      "#0F0B07"
    readonly property color surfaceContainerLow:         "#1D1611"
    readonly property color surfaceContainer:            "#241B15"
    readonly property color surfaceContainerHigh:        "#2F251D"
    readonly property color surfaceContainerHighest:     "#3A2F26"
    readonly property color surfaceFg:                  "#EDE1D4"
    readonly property color surfaceVariantFg:            "#D6C3B0"
    readonly property color outline:                    "#9F8E7C"
    readonly property color outlineVariant:             "#4F4338"
    readonly property color scrimTop:                   "#2E1D0C"
    readonly property color scrimBottom:                "#0C0805"
    readonly property real  scrimOpacity:               0.60
}
