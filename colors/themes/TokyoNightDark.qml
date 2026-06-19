import QtQuick
// TokyoNightDark.qml — Tokyo Night dark theme
QtObject {
    // ── Surface hierarchy ──────────────────────────────────────────
    readonly property color bg:              "#1a1b26"
    readonly property color surface:         "#24283b"
    readonly property color surfaceHigh:     "#292e42"
    readonly property color surfaceTop:      "#3b4261"

    // ── Accents ────────────────────────────────────────────────────
    readonly property color accent:          "#7aa2f7"
    readonly property color accentSoft:      "#3d59a1"
    readonly property color border:          "#3b4261"
    readonly property color accentDim:       "#2a2e4a"

    // ── Text ───────────────────────────────────────────────────────
    readonly property color fg:              "#c0caf5"
    readonly property color fgMid:           "#a9b1d6"
    readonly property color fgDim:           "#565f89"
    readonly property color fgInverted:      "#1a1b26"

    // ── Semantic ───────────────────────────────────────────────────
    readonly property color error:           "#f7768e"
    readonly property color errorText:       "#ff9e64"
    readonly property color errorSoft:       "#c0536a"
    readonly property color warning:         "#e0af68"
    readonly property color success:         "#9ece6a"

    // ── Lockscreen Material 3 tokens ───────────────────────────────
    readonly property color seed:                       "#7aa2f7"
    readonly property color primary:                    "#7aa2f7"
    readonly property color primaryFg:                  "#1a1b26"
    readonly property color primaryContainer:            "#3d59a1"
    readonly property color primaryContainerFg:          "#c0caf5"
    readonly property color secondary:                  "#bb9af7"
    readonly property color secondaryFg:                "#1a1b26"
    readonly property color secondaryContainer:          "#6a4b9a"
    readonly property color secondaryContainerFg:        "#e0d0ff"
    readonly property color tertiary:                   "#73daca"
    readonly property color tertiaryFg:                 "#1a2e28"
    readonly property color errorContainer:              "#6b2a37"
    readonly property color errorContainerFg:            "#ffb3c0"
    readonly property color errorFg:                    "#c0536a"
    readonly property color surfaceDim:                 "#16161e"
    readonly property color surfaceBright:              "#3b4261"
    readonly property color surfaceContainerLowest:      "#13131a"
    readonly property color surfaceContainerLow:         "#1a1b26"
    readonly property color surfaceContainer:            "#1f2335"
    readonly property color surfaceContainerHigh:        "#24283b"
    readonly property color surfaceContainerHighest:     "#292e42"
    readonly property color surfaceFg:                  "#c0caf5"
    readonly property color surfaceVariantFg:            "#a9b1d6"
    readonly property color outline:                    "#565f89"
    readonly property color outlineVariant:             "#414868"
    readonly property color scrimTop:                   "#13131a"
    readonly property color scrimBottom:                "#0d0e17"
    readonly property real  scrimOpacity:               0.65
}
