pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Base Colors — reader-shell sepia palette
    readonly property color backgroundColor:  "#1C1410"
    readonly property color surfaceColor:     "#2A1F15"
    readonly property color raisedSurfaceColor: "#3D2E1E"

    // Accent Colors
    readonly property color accentColorPrimary:   "#A67C52"
    readonly property color accentColorSecondary: "#C8A77A"

    // Text Colors
    readonly property color textColor:      "#F5E6D3"
    readonly property color mutedTextColor: "#D2B89C"

    // Status Colors
    readonly property color successColor: "#8FBC8F"
    readonly property color warningColor: "#DDA15E"
    readonly property color dangerColor:  "#BC6C25"
}
