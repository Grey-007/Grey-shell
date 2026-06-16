pragma Singleton
import QtQuick

QtObject {
    id: musicTheme

    // Base Colors (adapted from GEMINI.md for pure black background and high contrast)
    readonly property color backgroundColor: "#000000" // Pure black
    readonly property color surfaceColor: "#1A1A1A"    // Slightly lighter for card backgrounds if needed
    readonly property color raisedSurfaceColor: "#333333" // Even lighter for raised elements

    // Accent Colors
    readonly property color accentColorPrimary: "#A67C52"  // Primary Accent from GEMINI.md
    readonly property color accentColorSecondary: "#C8A77A" // Secondary Accent from GEMINI.md

    // Text Colors
    readonly property color textColor: "#F5E6D3"       // High contrast text from GEMINI.md
    readonly property color mutedTextColor: "#D2B89C"    // Muted Text from GEMINI.md

    // Status Colors (from GEMINI.md, can be used for visualizer feedback, etc.)
    readonly property color successColor: "#8FBC8F"
    readonly property color warningColor: "#DDA15E"
    readonly property color dangerColor: "#BC6C25"
}