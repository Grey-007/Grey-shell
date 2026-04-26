import QtQuick
import Quickshell
import Quickshell.Io

// Colors.qml — Quickshell Singleton
// Watches theme/colors.json written by spex after wallpaper changes.
// All properties are reactive — bindings update automatically, no reload needed.
Singleton {
    id: root

    // ── Core roles ────────────────────────────────────────────────
    property color background:              "#1e1e2e"
    property color surface:                 "#181825"
    property color surfaceContainer:        "#313244"
    property color surfaceHigh:             "#45475a"

    property color primary:                 "#cba6f7"
    property color secondary:              "#89b4fa"
    property color accent:                  "#cba6f7"
    property color accent2:                 "#89b4fa"
    property color highlight:               "#f38ba8"
    property color text:                    "#cdd6f4"
    property color foreground:              "#cdd6f4"

    // ── Primary family ────────────────────────────────────────────
    property color primaryContainer:        "#6c3483"
    property color onPrimary:               "#ffffff"
    property color onPrimaryContainer:      "#ead5f9"

    // ── Secondary family ──────────────────────────────────────────
    property color secondaryContainer:      "#1a4a7a"
    property color onSecondary:             "#ffffff"
    property color onSecondaryContainer:    "#dbeafe"

    // ── Tertiary family ───────────────────────────────────────────
    property color tertiary:                "#94e2d5"
    property color tertiaryContainer:       "#0d4f47"
    property color onTertiary:              "#ffffff"
    property color onTertiaryContainer:     "#ccfbf1"

    // ── Error states ──────────────────────────────────────────────
    property color error:                   "#f38ba8"
    property color errorContainer:          "#7a1c2e"
    property color onError:                 "#ffffff"
    property color onErrorContainer:        "#fde8ec"

    // ── Surface system ────────────────────────────────────────────
    property color surfaceVariant:          "#313244"
    property color surfaceContainerLow:     "#1e1e2e"
    property color surfaceContainerHighest: "#585b70"

    // ── UI support ────────────────────────────────────────────────
    property color outline:                 "#6c7086"
    property color outlineVariant:          "#45475a"
    property color border:                  "#45475a"
    property color selection:               "#cba6f7"

    // ── Watch the generated JSON file ─────────────────────────────
    // Spex writes to this path after every wallpaper change.
    // FileView detects the change and we parse + apply new colors.
    FileView {
        id: colorFile
        // Adjust this path to wherever spex outputs colors.json
        path: Qt.resolvedUrl("colors.json")
        // Watch for external changes (spex writing new colors)
        watchChanges: true
        onTextChanged: root.applyColors(colorFile.text)
    }

    // Apply colors from parsed JSON — only update properties that exist
    function applyColors(raw) {
        try {
            const c = JSON.parse(raw)
            if (c.background)              background              = c.background
            if (c.surface)                 surface                 = c.surface
            if (c.surfaceContainer)        surfaceContainer        = c.surfaceContainer
            if (c.surfaceHigh)             surfaceHigh             = c.surfaceHigh
            if (c.primary)                 primary                 = c.primary
            if (c.secondary)               secondary               = c.secondary
            if (c.highlight)               highlight               = c.highlight
            if (c.text)                    text                    = c.text
            if (c.foreground)              foreground              = c.foreground
            if (c.primaryContainer)        primaryContainer        = c.primaryContainer
            if (c.onPrimary)               onPrimary               = c.onPrimary
            if (c.onPrimaryContainer)      onPrimaryContainer      = c.onPrimaryContainer
            if (c.secondaryContainer)      secondaryContainer      = c.secondaryContainer
            if (c.onSecondary)             onSecondary             = c.onSecondary
            if (c.onSecondaryContainer)    onSecondaryContainer    = c.onSecondaryContainer
            if (c.tertiary)                tertiary                = c.tertiary
            if (c.tertiaryContainer)       tertiaryContainer       = c.tertiaryContainer
            if (c.onTertiary)              onTertiary              = c.onTertiary
            if (c.onTertiaryContainer)     onTertiaryContainer     = c.onTertiaryContainer
            if (c.error)                   error                   = c.error
            if (c.errorContainer)          errorContainer          = c.errorContainer
            if (c.onError)                 onError                 = c.onError
            if (c.onErrorContainer)        onErrorContainer        = c.onErrorContainer
            if (c.surfaceVariant)          surfaceVariant          = c.surfaceVariant
            if (c.surfaceContainerLow)     surfaceContainerLow     = c.surfaceContainerLow
            if (c.surfaceContainerHighest) surfaceContainerHighest = c.surfaceContainerHighest
            if (c.outline)                 outline                 = c.outline
            if (c.outlineVariant)          outlineVariant          = c.outlineVariant
            if (c.border)                  border                  = c.border
            if (c.selection)               selection               = c.selection
        } catch (e) {
            console.warn("Colors: failed to parse colors.json:", e)
        }
    }
}
