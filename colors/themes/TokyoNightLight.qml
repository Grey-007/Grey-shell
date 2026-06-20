import QtQuick
// TokyoNightLight.qml — Tokyo Night Light (Day) theme
QtObject {
    // ── System theming ─────────────────────────────────────────────
    readonly property string gtkTheme:    "Tokyonight-Light"
    readonly property string kvTheme:     ""
    readonly property string colorScheme: "default"

    // ── Surface hierarchy ──────────────────────────────────────────
    readonly property color bg:              "#d5d6db"
    readonly property color surface:         "#cbccd1"
    readonly property color surfaceHigh:     "#c5c6cc"
    readonly property color surfaceTop:      "#b3b4ba"

    // ── Accents ────────────────────────────────────────────────────
    readonly property color accent:          "#2e7de9"
    readonly property color accentSoft:      "#4a5080"
    readonly property color border:          "#9699a3"
    readonly property color accentDim:       "#b8b9bf"

    // ── Text ───────────────────────────────────────────────────────
    readonly property color fg:              "#3760bf"
    readonly property color fgMid:           "#68709a"
    readonly property color fgDim:           "#9699a3"
    readonly property color fgInverted:      "#d5d6db"

    // ── Semantic ───────────────────────────────────────────────────
    readonly property color error:           "#f52a65"
    readonly property color errorText:       "#b15c00"
    readonly property color errorSoft:       "#c24a6e"
    readonly property color warning:         "#8f5e15"
    readonly property color success:         "#485e30"

    // ── Lockscreen Material 3 tokens ───────────────────────────────
    readonly property color seed:                       "#2e7de9"
    readonly property color primary:                    "#2e7de9"
    readonly property color primaryFg:                  "#ffffff"
    readonly property color primaryContainer:            "#c5d6f8"
    readonly property color primaryContainerFg:          "#1a3f7a"
    readonly property color secondary:                  "#7847bd"
    readonly property color secondaryFg:                "#ffffff"
    readonly property color secondaryContainer:          "#e0d0ff"
    readonly property color secondaryContainerFg:        "#4a2e8a"
    readonly property color tertiary:                   "#007197"
    readonly property color tertiaryFg:                 "#ffffff"
    readonly property color errorContainer:              "#fce0e5"
    readonly property color errorContainerFg:            "#8b0020"
    readonly property color errorFg:                    "#8b0020"
    readonly property color surfaceDim:                 "#c8c9cf"
    readonly property color surfaceBright:              "#e5e6ec"
    readonly property color surfaceContainerLowest:      "#e8e9ef"
    readonly property color surfaceContainerLow:         "#d5d6db"
    readonly property color surfaceContainer:            "#cbccd1"
    readonly property color surfaceContainerHigh:        "#c2c3c9"
    readonly property color surfaceContainerHighest:     "#b8b9bf"
    readonly property color surfaceFg:                  "#3760bf"
    readonly property color surfaceVariantFg:            "#68709a"
    readonly property color outline:                    "#9699a3"
    readonly property color outlineVariant:             "#b8b9bf"
    readonly property color scrimTop:                   "#3760bf"
    readonly property color scrimBottom:                "#2e3674"
    readonly property real  scrimOpacity:               0.45
}
