import QtQuick

QtObject {
    id: config

    property string wallpaperDirectory: "/home/grey/Pictures/Wallpapers"
    property int    scanDepth:          2
    property var    applyCommand:       ["awww", "img"]

    // Grid: 6 cols × 3 rows
    property int  cols:        6
    property int  rows:        3
    property int  tileW:       200
    property int  tileH:       126
    property int  gap:         8

    // Panel — sized to fit grid exactly with padding
    readonly property int gridW:     cols * tileW + (cols - 1) * gap   // 1240
    readonly property int gridH:     rows * tileH + (rows - 1) * gap   // 394
    property int  panelWidth:        gridW + 100   // 1340 (room for arrows)
    property int  panelHeight:       gridH + 80    // 474  (header + footer)

    property int  openDuration:  140   // fast open
    property int  hoverDuration: 120
    property real hoverScale:    1.05

    property color accent:              "#7df7c3"
    property color textColor:           '#00fe65'
    property color selectedBorderColor: '#7df7c2'
}
