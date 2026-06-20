import QtQuick
// GruvboxDark.qml — Gruvbox Dark (hard) theme
QtObject {
    // ── System theming ─────────────────────────────────────────────
    readonly property string gtkTheme:    "Gruvbox-Dark-Hard"
    readonly property string kvTheme:     "Gruvbox"
    readonly property string colorScheme: "prefer-dark"

    // ── Surface hierarchy ──────────────────────────────────────────
    readonly property color bg:              "#1d2021"
    readonly property color surface:         "#282828"
    readonly property color surfaceHigh:     "#3c3836"
    readonly property color surfaceTop:      "#504945"

    // ── Accents ────────────────────────────────────────────────────
    readonly property color accent:          "#d79921"
    readonly property color accentSoft:      "#b57614"
    readonly property color border:          "#504945"
    readonly property color accentDim:       "#3c3836"

    // ── Text ───────────────────────────────────────────────────────
    readonly property color fg:              "#ebdbb2"
    readonly property color fgMid:           "#a89984"
    readonly property color fgDim:           "#7c6f64"
    readonly property color fgInverted:      "#1d2021"

    // ── Semantic ───────────────────────────────────────────────────
    readonly property color error:           "#cc241d"
    readonly property color errorText:       "#fb4934"
    readonly property color errorSoft:       "#9d0006"
    readonly property color warning:         "#d65d0e"
    readonly property color success:         "#98971a"

    // ── Lockscreen Material 3 tokens ───────────────────────────────
    readonly property color seed:                       "#d79921"
    readonly property color primary:                    "#d79921"
    readonly property color primaryFg:                  "#1d2021"
    readonly property color primaryContainer:            "#b57614"
    readonly property color primaryContainerFg:          "#ebdbb2"
    readonly property color secondary:                  "#689d6a"
    readonly property color secondaryFg:                "#1d2021"
    readonly property color secondaryContainer:          "#427b58"
    readonly property color secondaryContainerFg:        "#d8e8d0"
    readonly property color tertiary:                   "#458588"
    readonly property color tertiaryFg:                 "#1d2021"
    readonly property color errorContainer:             "#7c1a17"
    readonly property color errorContainerFg:           "#ffb3ae"
    readonly property color errorFg:                   "#9d0006"
    readonly property color surfaceDim:                "#161616"
    readonly property color surfaceBright:             "#504945"
    readonly property color surfaceContainerLowest:     "#141414"
    readonly property color surfaceContainerLow:        "#1d2021"
    readonly property color surfaceContainer:           "#282828"
    readonly property color surfaceContainerHigh:       "#32302f"
    readonly property color surfaceContainerHighest:    "#3c3836"
    readonly property color surfaceFg:                 "#ebdbb2"
    readonly property color surfaceVariantFg:           "#a89984"
    readonly property color outline:                   "#7c6f64"
    readonly property color outlineVariant:            "#504945"
    readonly property color scrimTop:                  "#1d2021"
    readonly property color scrimBottom:               "#141414"
    readonly property real  scrimOpacity:              0.62
}
