// roles.qml
pragma Singleton
import QtQuick

QtObject {

    /*
     * CORE THEME ROLES (stable, use everywhere)
     */
    readonly property color background: "#060806"
    readonly property color surface: "#0E3030"
    readonly property color surfaceContainer: "#134040"
    readonly property color surfaceHigh: "#1A5858"

    readonly property color primary: "#7CF393"
    readonly property color secondary: "#27A161"
    readonly property color accent: "#7CF393"
    readonly property color accent2: "#27A161"

    readonly property color highlight: "#68C48B"
    readonly property color text: "#A8FCA5"


    /*
     * EXTENDED TOKENS (for advanced UI / compatibility)
     */

    // Foreground
    readonly property color foreground: "#A8FCA5"

    // Primary family
    readonly property color primaryContainer: "#3CE15C"
    readonly property color onPrimary: "#14171C"
    readonly property color onPrimaryContainer: "#14171C"

    // Secondary family
    readonly property color secondaryContainer: "#195334"
    readonly property color onSecondary: "#14171C"
    readonly property color onSecondaryContainer: "#F5F7FA"

    // Tertiary family
    readonly property color tertiary: "#4BDA7E"
    readonly property color tertiaryContainer: "#2B9F53"
    readonly property color onTertiary: "#14171C"
    readonly property color onTertiaryContainer: "#14171C"

    // Error states
    readonly property color error: "#EC7765"
    readonly property color errorContainer: "#CF3D26"
    readonly property color onError: "#14171C"
    readonly property color onErrorContainer: "#F5F7FA"


    /*
     * SURFACE SYSTEM (elevation layering)
     */
    readonly property color surfaceVariant: "#1B3838"
    readonly property color surfaceContainerLow: "#0E3030"
    readonly property color surfaceContainerHigh: "#1A5858"
    readonly property color surfaceContainerHighest: "#217070"


    /*
     * UI SUPPORT TOKENS
     */
    readonly property color outline: "#2B4747"
    readonly property color outlineVariant: "#233F3F"
    readonly property color border: "#244343"
    readonly property color selection: "#4AA56C"


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