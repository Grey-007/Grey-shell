import QtQuick

QtObject {
    id: config

    property string wallpaperDirectory: "/home/grey/Pictures/Wallpapers"
    property int    scanDepth:          2
    property var    applyCommand:       ["awww", "img"]

    // Tile layout — slightly larger tiles, tighter gap for better density
    property int  visibleTileCount: 36       // 4 cols × 9 rows
    property int  pageStride:       16       // half page stride for context
    property int  tileSize:         136      // a bit larger for quality
    property int  tileGap:          36       // tighter gap
    property int  panelWidth:       1040
    property int  panelHeight:      640      // slightly taller for 9 rows

    // Timing
    property int  openDuration:  260
    property int  pageDuration:  300
    property int  hoverDuration: 120
    property real hoverScale:    1.09

    // Colours (unchanged from original)
    property color textColor:          "#f6f7f2"
    property color selectedBorderColor:"#7df7c3"
    property color hoverBorderColor:   "#ffffff"
    property color shadowColor:        "#66000000"
}
