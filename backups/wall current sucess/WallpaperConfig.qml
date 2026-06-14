import QtQuick

QtObject {
    id: config

    property string wallpaperDirectory: "/home/grey/Pictures/Wallpapers"
    property int    scanDepth:          2
    property var    applyCommand:       ["awww", "img"]

    // Layout — col-major honeycomb, 7 cols × 5 rows
    property int  cols:           7
    property int  rows:           5
    property int  tileSize:       128     // tileWidth; height auto from geometry
    property int  tileGap:        6

    // Derived (used by WallpaperSelector for panel sizing)
    // gridW = (cols-1)*(tileSize+tileGap) + tileSize = 6*134+128 = 932
    // gridH = (rows-1)*rowStep + tileH + colOffset ≈ 4*111+148+74 = 666
    property int  panelWidth:     980     // gridW + 48 margin
    property int  panelHeight:    700     // gridH + 34 margin

    // Timing
    property int  openDuration:  240
    property int  hoverDuration: 130
    property real hoverScale:    1.09

    // Colours
    property color textColor:           "#f6f7f2"
    property color selectedBorderColor: "#7df7c3"
    property color hoverBorderColor:    "#ffffff"
    property color shadowColor:         "#44000000"
}
