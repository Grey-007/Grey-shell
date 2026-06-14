pragma Singleton
import QtQuick
import Quickshell

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · sepia palette
//
// This is the ONLY file that should contain colour values. Every widget
// pulls its colours from here so the whole lock screen stays visually
// uniform. Based on a warm sepia/parchment seed colour, arranged using
// Material 3 tonal-role naming (primary / surface / outline / etc.)
// ─────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    // Seed colour — the warm sepia/leather tone everything is built from
    readonly property color seed: "#A1764A"

    // ── Primary (sepia gold-brown — accents, clock highlight, focus ring) ──
    readonly property color primary:            "#E4C29B"
    readonly property color primaryForeground:          "#43290B"
    readonly property color primaryContainer:   "#5E4119"
    readonly property color primaryContainerForeground: "#FFDDB8"

    // ── Secondary (muted parchment — supporting text, pills) ──
    readonly property color secondary:            "#D8C3AC"
    readonly property color secondaryForeground:          "#3B2E1F"
    readonly property color secondaryContainer:   "#534434"
    readonly property color secondaryContainerForeground: "#F5E4D2"

    // ── Tertiary (soft terracotta — small highlights / book widget) ──
    readonly property color tertiary:   "#E6B8A2"
    readonly property color tertiaryForeground: "#48261A"

    // ── Error (failed unlock) ──
    readonly property color error:            "#FFB4A8"
    readonly property color errorForeground:          "#680E04"
    readonly property color errorContainer:   "#8C2C1C"
    readonly property color errorContainerForeground: "#FFDAD2"

    // ── Success (charging / positive states) ──
    readonly property color success: "#BFD395"

    // ── Surfaces (warm near-black browns, dark theme) ──
    readonly property color surfaceDim:             "#15100B"
    readonly property color surface:                "#15100B"
    readonly property color surfaceBright:          "#3C332B"
    readonly property color surfaceContainerLowest: "#0F0B07"
    readonly property color surfaceContainerLow:    "#1D1611"
    readonly property color surfaceContainer:       "#241B15"
    readonly property color surfaceContainerHigh:   "#2F251D"
    readonly property color surfaceContainerHighest:"#3A2F26"

    readonly property color surfaceForeground:        "#EDE1D4"
    readonly property color surfaceVariantForeground: "#D6C3B0"
    readonly property color outline:          "#9F8E7C"
    readonly property color outlineVariant:   "#4F4338"

    // ── Wallpaper scrim (gives the blurred wallpaper its sepia tone) ──
    readonly property color scrimTop:    "#2E1D0C"
    readonly property color scrimBottom: "#0C0805"
    readonly property real  scrimOpacity: 0.60

    // Convenience: any colour with custom alpha
    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }
}
