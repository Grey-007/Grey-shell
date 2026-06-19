import QtQuick
// GruvboxLight.qml — Gruvbox Light (hard) theme
QtObject {
    // ── Surface hierarchy ──────────────────────────────────────────
    readonly property color bg:              "#f9f5d7"
    readonly property color surface:         "#fbf1c7"
    readonly property color surfaceHigh:     "#ebdbb2"
    readonly property color surfaceTop:      "#d5c4a1"

    // ── Accents ────────────────────────────────────────────────────
    readonly property color accent:          "#b57614"
    readonly property color accentSoft:      "#af3a03"
    readonly property color border:          "#d5c4a1"
    readonly property color accentDim:       "#ebdbb2"

    // ── Text ───────────────────────────────────────────────────────
    readonly property color fg:              "#3c3836"
    readonly property color fgMid:           "#7c6f64"
    readonly property color fgDim:           "#a89984"
    readonly property color fgInverted:      "#fbf1c7"

    // ── Semantic ───────────────────────────────────────────────────
    readonly property color error:           "#9d0006"
    readonly property color errorText:       "#cc241d"
    readonly property color errorSoft:       "#cc241d"
    readonly property color warning:         "#b57614"
    readonly property color success:         "#79740e"

    // ── Lockscreen Material 3 tokens ───────────────────────────────
    readonly property color seed:                       "#b57614"
    readonly property color primary:                    "#b57614"
    readonly property color primaryFg:                  "#fbf1c7"
    readonly property color primaryContainer:            "#ffe0a0"
    readonly property color primaryContainerFg:          "#5a3a00"
    readonly property color secondary:                  "#427b58"
    readonly property color secondaryFg:                "#fbf1c7"
    readonly property color secondaryContainer:          "#c8e8d0"
    readonly property color secondaryContainerFg:        "#1a3a28"
    readonly property color tertiary:                   "#076678"
    readonly property color tertiaryFg:                 "#fbf1c7"
    readonly property color errorContainer:             "#ffd8d8"
    readonly property color errorContainerFg:           "#5c0000"
    readonly property color errorFg:                   "#5c0000"
    readonly property color surfaceDim:                "#e8e4c6"
    readonly property color surfaceBright:             "#fbf1c7"
    readonly property color surfaceContainerLowest:     "#ffffff"
    readonly property color surfaceContainerLow:        "#f9f5d7"
    readonly property color surfaceContainer:           "#fbf1c7"
    readonly property color surfaceContainerHigh:       "#ebdbb2"
    readonly property color surfaceContainerHighest:    "#d5c4a1"
    readonly property color surfaceFg:                 "#3c3836"
    readonly property color surfaceVariantFg:           "#7c6f64"
    readonly property color outline:                   "#a89984"
    readonly property color outlineVariant:            "#d5c4a1"
    readonly property color scrimTop:                  "#3c3836"
    readonly property color scrimBottom:               "#282828"
    readonly property real  scrimOpacity:              0.40
}
