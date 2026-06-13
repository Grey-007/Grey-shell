import QtQuick

Item {
    id: root

    property var wallpaperModel
    property var config

    signal wallpaperChosen(string path)

    // ── Layout constants (pointy-top hex, col-major) ───────────────
    // Pointy-top: width = sqrt(3)*R, height = 2*R
    // Col spacing: tileWidth + gap  (cols move horizontally)
    // Row spacing: tileHeight * 0.75  (rows interlock vertically)
    // Odd columns shift DOWN by tileHeight/2

    readonly property int    cols:       7
    readonly property int    rows:       5
    readonly property int    tileW:      128
    readonly property int    tileH:      148    // ≈ tileW * 2/sqrt(3)
    readonly property int    gap:        6
    readonly property int    colStep:    tileW + gap          // 134
    readonly property real   rowStep:    tileH * 0.75         // 111
    readonly property real   colOffset:  rowStep * 0.5        // 55  (odd col shift) 

    readonly property int    visibleCount: cols * rows         // 35

    implicitWidth:  (cols - 1) * colStep + tileW
    implicitHeight: Math.round((rows - 1) * rowStep + tileH + colOffset)

    // ── Paging (column-based, left↔right) ─────────────────────────
    // pageCol = index of the leftmost visible column in the model
    property int pageCol:   0
    property int pageToken: 0    // bumped each page change to trigger animations
    property int pageDir:   1    // +1 = forward (new cols from right), -1 = backward

    // How many model items per logical column
    readonly property int itemsPerCol: rows

    // Total columns in the model
    readonly property int modelCols: Math.ceil(wallpaperModel.count / itemsPerCol)

    function maxPageCol(): int {
        return Math.max(0, modelCols - cols)
    }

    function nextPage(): void {
        var next = Math.min(maxPageCol(), pageCol + cols)
        if (next === pageCol) return
        pageDir = 1
        pageCol = next
        pageToken++
    }

    function previousPage(): void {
        var prev = Math.max(0, pageCol - cols)
        if (prev === pageCol) return
        pageDir = -1
        pageCol = prev
        pageToken++
    }

    function clampPage(): void {
        pageCol = Math.max(0, Math.min(pageCol, maxPageCol()))
    }

    // ── Fixed-count Repeater — delegates NEVER destroyed on page change ──
    // This is the core fix: model is always `visibleCount` (35).
    // Only the path/name bindings update when pageCol changes.
    // Tiles stay alive → no flicker, no disappearing grid.
    Repeater {
        id: rep
        model: root.visibleCount

        delegate: HexTile {
            id: tile

            required property int index

            // Column-major layout: index = col*rows + row
            readonly property int tCol: index % root.cols   // tile column (0..cols-1)
            readonly property int tRow: Math.floor(index / root.cols)  // tile row (0..rows-1)

            // Map tile (col, row) → model index
            readonly property int modelIdx: (root.pageCol + tCol) * root.itemsPerCol + tRow

            readonly property var entry: (modelIdx >= 0 && modelIdx < root.wallpaperModel.count)
                ? root.wallpaperModel.get(modelIdx)
                : null

            // Position: pointy-top honeycomb, col-major
            // Odd columns shift down by colOffset
            x: tCol * root.colStep
            y: Math.round(tRow * root.rowStep + (tCol % 2 === 1 ? root.colOffset : 0))

            width:  root.tileW
            height: root.tileH

            path:     entry ? entry.path : ""
            name:     entry ? entry.name : ""
            selected: path !== "" && path === root.wallpaperModel.selectedPath

            selectedBorderColor: root.config.selectedBorderColor
            hoverBorderColor:    root.config.hoverBorderColor
            shadowColor:         root.config.shadowColor
            labelColor:          root.config.textColor
            hoverDuration:       root.config.hoverDuration
            hoverScale:          root.config.hoverScale

            onChosen: function(p) { root.wallpaperChosen(p) }

            // ── Entrance animation — only new columns animate in ───
            // isNewTile tracks whether this tile's column is "new" in
            // this page turn (only the newly revealed cols slide in).
            isNewTile: false

            // Forward page: new cols are on the right (tCol >= cols - newColCount)
            // Backward page: new cols are on the left (tCol < newColCount)
            // We animate with X translate + opacity + scale pop

            property real _entX:  0.0
            property real _entOp: 1.0
            property real _entSc: 1.0

            // Override hexBody entrance via these — wired in HexTile
            // We animate the tile Item itself here for the slide
            transform: Translate { x: tile._entX }
            opacity:   tile._entOp

            SequentialAnimation {
                id: slideAnim
                running: false

                PauseAnimation {
                    // Stagger: col position within the new block × 40ms
                    duration: tile.isNewTile
                        ? (root.pageDir > 0
                            ? (tile.tCol - (root.cols - newColCount)) * 40
                            : (newColCount - 1 - tile.tCol) * 40)
                        : 0
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: tile; property: "_entX"
                        to: 0
                        duration: 320; easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: tile; property: "_entOp"
                        to: 1.0
                        duration: 240; easing.type: Easing.OutCubic
                    }
                    SequentialAnimation {
                        NumberAnimation {
                            target: tile; property: "_entSc"
                            to: 1.06
                            duration: 160; easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: tile; property: "_entSc"
                            to: 1.0
                            duration: 180; easing.type: Easing.OutBack
                            easing.overshoot: 0.8
                        }
                    }
                }
            }

            Connections {
                target: root

                function onPageTokenChanged(): void {
                    // Determine how many new columns were revealed
                    var nc = newColCount

                    // Is this tile in a newly-revealed column?
                    var isNew = root.pageDir > 0
                        ? tile.tCol >= (root.cols - nc)   // new cols on right
                        : tile.tCol < nc                  // new cols on left

                    tile.isNewTile = isNew

                    if (isNew) {
                        // Start offscreen in scroll direction
                        tile._entX  = root.pageDir > 0 ? (root.tileW + root.gap) * nc
                                                        : -((root.tileW + root.gap) * nc)
                        tile._entOp = 0.0
                        tile._entSc = 0.88
                        slideAnim.restart()
                    } else {
                        // Already-visible tiles: just stay put, no animation
                        tile._entX  = 0
                        tile._entOp = 1.0
                        tile._entSc = 1.0
                        slideAnim.stop()
                    }
                }
            }
        }
    }

    // How many new columns are revealed per page turn
    readonly property int newColCount: cols   // full page swap for now

    onWallpaperModelChanged:  clampPage()

    Connections {
        target: wallpaperModel
        function onCountChanged(): void { root.clampPage() }
    }

    // Called by WallpaperSelector after apply — plays grow animation on the tile
    function animateTile(path): void {
        for (var i = 0; i < rep.count; i++) {
            var t = rep.itemAt(i)
            if (t && t.path === path) {
                t.playApplyAnim()
                break
            }
        }
    }
}
