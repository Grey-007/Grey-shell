import QtQuick

QtObject {
    id: config

    property string wallpaperDirectory: "/home/grey/Pictures/Wallpapers"
    property int scanDepth: 2
    property var applyCommand: ["awww", "img"]

    property int visibleTileCount: 16
    property int pageStride: 9
    property int tileSize: 128
    property int tileGap: 40
    property int panelWidth: 1040
    property int panelHeight: 560

    property int openDuration: 220
    property int pageDuration: 260
    property int hoverDuration: 130
    property real hoverScale: 1.08

    property color textColor: "#f6f7f2"
    property color selectedBorderColor: "#7df7c3"
    property color hoverBorderColor: "#ffffff"
    property color shadowColor: "#66000000"
}
