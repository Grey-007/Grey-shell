import QtQuick

Item {
    id: root

    property var wallpaperModel
    property var config
    property int pageStart: 0
    property int pageToken: 0

    // Direction hint: +1 = forward (tiles slide up), -1 = back (tiles slide down)
    property int pageDirection: 1

    signal wallpaperChosen(string path)

    readonly property int columns:    4
    readonly property int rows:       9
    readonly property int tileWidth:  config.tileSize
    readonly property int tileHeight: Math.round(config.tileSize * 0.86)
    readonly property int cellWidth:  config.tileSize + config.tileGap
    readonly property int rowStep:    Math.round(tileHeight * 0.76)

    implicitWidth:  columns * cellWidth + Math.round(cellWidth * 0.5)
    implicitHeight: tileHeight + rowStep * (rows - 1)

    function maxStart(): int {
        return Math.max(0, wallpaperModel.count - config.visibleTileCount)
    }

    function clampPage(): void {
        pageStart = Math.max(0, Math.min(pageStart, maxStart()))
    }

    function nextPage(): void {
        pageDirection = 1
        pageStart = Math.min(maxStart(), pageStart + config.pageStride)
        pageToken++
    }

    function previousPage(): void {
        pageDirection = -1
        pageStart = Math.max(0, pageStart - config.pageStride)
        pageToken++
    }

    Repeater {
        model: Math.min(config.visibleTileCount, Math.max(0, wallpaperModel.count - root.pageStart))

        delegate: HexTile {
            id: tile

            required property int index
            readonly property var entry: root.wallpaperModel.get(root.pageStart + index)
            readonly property int row:  Math.floor(index / root.columns)
            readonly property int col:  index % root.columns

            width:  root.tileWidth
            height: root.tileHeight

            // Hex honeycomb offset: odd rows shift right by half a cell
            x: col * root.cellWidth + (row % 2 === 1 ? Math.round(root.cellWidth * 0.5) : 0)
            y: row * root.rowStep

            path:  entry ? entry.path : ""
            name:  entry ? entry.name : ""
            selected: path !== "" && path === root.wallpaperModel.selectedPath
            selectedBorderColor: root.config.selectedBorderColor
            hoverBorderColor:    root.config.hoverBorderColor
            shadowColor:         root.config.shadowColor
            labelColor:          root.config.textColor
            hoverDuration:       root.config.hoverDuration
            hoverScale:          root.config.hoverScale
            pageScale:           1.0
            entranceOp:          1.0
            entranceY:           0.0

            onChosen: root.wallpaperChosen(path)

            // ── Staggered popup entrance animation ─────────────────
            // Each tile slides in from offset Y with a small delay based
            // on its index so tiles cascade in rather than all at once.
            SequentialAnimation {
                id: entranceAnim
                running: false

                // Stagger delay: row × 28ms + col × 14ms, max 220ms
                PauseAnimation {
                    duration: Math.min(220, tile.row * 28 + tile.col * 14)
                }

                ParallelAnimation {
                    NumberAnimation {
                        target:   tile
                        property: "entranceY"
                        to:       0
                        duration: 340
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.6
                    }
                    NumberAnimation {
                        target:   tile
                        property: "entranceOp"
                        to:       1.0
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target:   tile
                        property: "pageScale"
                        from:     0.82
                        to:       1.0
                        duration: 320
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }
            }

            // Trigger entrance whenever pageToken changes (new page)
            Connections {
                target: root
                function onPageTokenChanged(): void {
                    // Set initial offscreen position based on scroll direction
                    tile.entranceY  = root.pageDirection > 0 ? 30 : -30
                    tile.entranceOp = 0
                    tile.pageScale  = 0.82
                    entranceAnim.restart()
                }
            }
        }
    }

    onPageStartChanged: clampPage()

    Connections {
        target: wallpaperModel
        function onScanned(): void {
            root.clampPage()
            root.pageToken++
        }
    }
}
