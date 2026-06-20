import QtQuick
// CatppuccinMocha.qml — Catppuccin Mocha (dark) theme
QtObject {
    // ── System theming ─────────────────────────────────────────────
    readonly property string gtkTheme:    "catppuccin-mocha-standard+default"
    readonly property string kvTheme:     "Catppuccin-Mocha"
    readonly property string colorScheme: "prefer-dark"

    // ── Surface hierarchy ──────────────────────────────────────────
    readonly property color bg:              "#1e1e2e"
    readonly property color surface:         "#181825"
    readonly property color surfaceHigh:     "#313244"
    readonly property color surfaceTop:      "#45475a"

    // ── Accents ────────────────────────────────────────────────────
    readonly property color accent:          "#cba6f7"
    readonly property color accentSoft:      "#b4befe"
    readonly property color border:          "#45475a"
    readonly property color accentDim:       "#313244"

    // ── Text ───────────────────────────────────────────────────────
    readonly property color fg:              "#cdd6f4"
    readonly property color fgMid:           "#a6adc8"
    readonly property color fgDim:           "#6c7086"
    readonly property color fgInverted:      "#1e1e2e"

    // ── Semantic ───────────────────────────────────────────────────
    readonly property color error:           "#f38ba8"
    readonly property color errorText:       "#eba0ac"
    readonly property color errorSoft:       "#c06a7e"
    readonly property color warning:         "#fab387"
    readonly property color success:         "#a6e3a1"

    // ── Lockscreen Material 3 tokens ───────────────────────────────
    readonly property color seed:                       "#cba6f7"
    readonly property color primary:                    "#cba6f7"
    readonly property color primaryFg:                  "#1e1e2e"
    readonly property color primaryContainer:            "#6c4a96"
    readonly property color primaryContainerFg:          "#eddeff"
    readonly property color secondary:                  "#89b4fa"
    readonly property color secondaryFg:                "#1e1e2e"
    readonly property color secondaryContainer:          "#1e3a6a"
    readonly property color secondaryContainerFg:        "#c6dfff"
    readonly property color tertiary:                   "#94e2d5"
    readonly property color tertiaryFg:                 "#1e1e2e"
    readonly property color errorContainer:             "#6a1a2a"
    readonly property color errorContainerFg:           "#ffd8e0"
    readonly property color errorFg:                   "#c06a7e"
    readonly property color surfaceDim:                "#181825"
    readonly property color surfaceBright:             "#45475a"
    readonly property color surfaceContainerLowest:     "#11111b"
    readonly property color surfaceContainerLow:        "#1e1e2e"
    readonly property color surfaceContainer:           "#24273a"
    readonly property color surfaceContainerHigh:       "#313244"
    readonly property color surfaceContainerHighest:    "#45475a"
    readonly property color surfaceFg:                 "#cdd6f4"
    readonly property color surfaceVariantFg:           "#a6adc8"
    readonly property color outline:                   "#585b70"
    readonly property color outlineVariant:            "#45475a"
    readonly property color scrimTop:                  "#181825"
    readonly property color scrimBottom:               "#11111b"
    readonly property real  scrimOpacity:              0.65
}
