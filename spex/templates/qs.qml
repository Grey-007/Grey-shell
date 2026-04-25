// roles.qml
pragma Singleton
import QtQuick

QtObject {

    /*
     * CORE THEME ROLES (stable, use everywhere)
     */
    readonly property color background: "{{colors.background.hex}}"
    readonly property color surface: "{{colors.surface.hex}}"
    readonly property color surfaceContainer: "{{colors.surface_container.hex}}"
    readonly property color surfaceHigh: "{{colors.surface_container_high.hex}}"

    readonly property color primary: "{{colors.primary.hex}}"
    readonly property color secondary: "{{colors.secondary.hex}}"
    readonly property color accent: "{{colors.primary.hex}}"
    readonly property color accent2: "{{colors.secondary.hex}}"

    readonly property color highlight: "{{colors.highlight.hex}}"
    readonly property color text: "{{colors.foreground.hex}}"


    /*
     * EXTENDED TOKENS (for advanced UI / compatibility)
     */

    // Foreground
    readonly property color foreground: "{{colors.foreground.hex}}"

    // Primary family
    readonly property color primaryContainer: "{{colors.primary_container.hex}}"
    readonly property color onPrimary: "{{colors.on_primary.hex}}"
    readonly property color onPrimaryContainer: "{{colors.on_primary_container.hex}}"

    // Secondary family
    readonly property color secondaryContainer: "{{colors.secondary_container.hex}}"
    readonly property color onSecondary: "{{colors.on_secondary.hex}}"
    readonly property color onSecondaryContainer: "{{colors.on_secondary_container.hex}}"

    // Tertiary family
    readonly property color tertiary: "{{colors.tertiary.hex}}"
    readonly property color tertiaryContainer: "{{colors.tertiary_container.hex}}"
    readonly property color onTertiary: "{{colors.on_tertiary.hex}}"
    readonly property color onTertiaryContainer: "{{colors.on_tertiary_container.hex}}"

    // Error states
    readonly property color error: "{{colors.error.hex}}"
    readonly property color errorContainer: "{{colors.error_container.hex}}"
    readonly property color onError: "{{colors.on_error.hex}}"
    readonly property color onErrorContainer: "{{colors.on_error_container.hex}}"


    /*
     * SURFACE SYSTEM (elevation layering)
     */
    readonly property color surfaceVariant: "{{colors.surface_variant.hex}}"
    readonly property color surfaceContainerLow: "{{colors.surface_container_low.hex}}"
    readonly property color surfaceContainerHigh: "{{colors.surface_container_high.hex}}"
    readonly property color surfaceContainerHighest: "{{colors.surface_container_highest.hex}}"


    /*
     * UI SUPPORT TOKENS
     */
    readonly property color outline: "{{colors.outline.hex}}"
    readonly property color outlineVariant: "{{colors.outline_variant.hex}}"
    readonly property color border: "{{colors.border.hex}}"
    readonly property color selection: "{{colors.selection.hex}}"


    /*
     * OPTIONAL: QUICK ACCESS GROUPS (ergonomic aliases)
     */

    readonly property QtObject textColors: QtObject {
        readonly property color primary: text
        readonly property color secondary: secondary
        readonly property color muted: outline
        readonly property color inverse: background
    }

    readonly property QtObject surfaces: QtObject {
        readonly property color base: background
        readonly property color raised: surface
        readonly property color container: surfaceContainer
        readonly property color elevated: surfaceHigh
    }

    readonly property QtObject accents: QtObject {
        readonly property color main: primary
        readonly property color alt: secondary
        readonly property color extra1: accent
        readonly property color extra2: accent2
    }
}