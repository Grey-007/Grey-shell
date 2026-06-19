import QtQuick
// CatppuccinLatte.qml — Catppuccin Latte (light) theme
QtObject {
    // ── Surface hierarchy ──────────────────────────────────────────
    readonly property color bg:              "#eff1f5"
    readonly property color surface:         "#e6e9ef"
    readonly property color surfaceHigh:     "#ccd0da"
    readonly property color surfaceTop:      "#bcc0cc"

    // ── Accents ────────────────────────────────────────────────────
    readonly property color accent:          "#8839ef"
    readonly property color accentSoft:      "#7287fd"
    readonly property color border:          "#bcc0cc"
    readonly property color accentDim:       "#ccd0da"

    // ── Text ───────────────────────────────────────────────────────
    readonly property color fg:              "#4c4f69"
    readonly property color fgMid:           "#5c5f77"
    readonly property color fgDim:           "#8c8fa1"
    readonly property color fgInverted:      "#eff1f5"

    // ── Semantic ───────────────────────────────────────────────────
    readonly property color error:           "#d20f39"
    readonly property color errorText:       "#e64553"
    readonly property color errorSoft:       "#a50f2e"
    readonly property color warning:         "#fe640b"
    readonly property color success:         "#40a02b"

    // ── Lockscreen Material 3 tokens ───────────────────────────────
    readonly property color seed:                       "#8839ef"
    readonly property color primary:                    "#8839ef"
    readonly property color primaryFg:                  "#ffffff"
    readonly property color primaryContainer:            "#e8d5fc"
    readonly property color primaryContainerFg:          "#4a0098"
    readonly property color secondary:                  "#1e66f5"
    readonly property color secondaryFg:                "#ffffff"
    readonly property color secondaryContainer:          "#d0e0fc"
    readonly property color secondaryContainerFg:        "#0a2870"
    readonly property color tertiary:                   "#179299"
    readonly property color tertiaryFg:                 "#ffffff"
    readonly property color errorContainer:             "#ffe0e5"
    readonly property color errorContainerFg:           "#6e0014"
    readonly property color errorFg:                   "#6e0014"
    readonly property color surfaceDim:                "#dce0e8"
    readonly property color surfaceBright:             "#eff1f5"
    readonly property color surfaceContainerLowest:     "#ffffff"
    readonly property color surfaceContainerLow:        "#f5f5f9"
    readonly property color surfaceContainer:           "#eff1f5"
    readonly property color surfaceContainerHigh:       "#e6e9ef"
    readonly property color surfaceContainerHighest:    "#ccd0da"
    readonly property color surfaceFg:                 "#4c4f69"
    readonly property color surfaceVariantFg:           "#5c5f77"
    readonly property color outline:                   "#8c8fa1"
    readonly property color outlineVariant:            "#bcc0cc"
    readonly property color scrimTop:                  "#4c4f69"
    readonly property color scrimBottom:               "#313244"
    readonly property real  scrimOpacity:              0.40
}
