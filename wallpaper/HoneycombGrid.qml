import QtQuick

Item {
    id: root

    property var wallpaperModel
    property var config

    signal wallpaperChosen(string path)

    // ── Layout — pointy-top hex, column-major honeycomb ───────────
    //
    //  Pointy-top hex bounding box: W × H where H = W * 2/sqrt(3)
    //  Columns pack horizontally with step = W + gap
    //  Rows interlock: rowStep = H * 0.75
    //  Odd columns shift DOWN by rowStep / 2   ← fixed (was tileH/2 = 74, correct is 55)
    //
    readonly property int    cols:      7
    readonly property int    rows:      5
    readonly property int    tileW:     128
    readonly property int    tileH:     148        // 128 * 2/sqrt(3) ≈ 147.8
    readonly property int    gap:       4
    readonly property int    colStep:   tileW + gap                // 132
    readonly property real   rowStep:   tileH * 0.75               // 111.0
    readonly property real   colOffset: rowStep * 0.5              // 55.5  ← FIX (was tileH*0.5=74)

    readonly property int    visibleCount: cols * rows              // 35

    implicitWidth:  (cols - 1) * colStep + tileW                   // 900
    implicitHeight: Math.round((rows - 1) * rowStep + tileH + colOffset)  // 647

    // ── Paging — scroll 1 column at a time ────────────────────────
    property int pageCol:    0
    property int pageToken:  0   // bumped on every page change → triggers animations
    property int pageDir:    1   // +1 = scroll right (new col from right), -1 = left

    // Which screen-column index is the "outgoing" (disappearing) one
    // Forward scroll: leftmost col (tCol=0) disappears
    // Backward scroll: rightmost col (tCol=cols-1) disappears
    property int outgoingTCol: -1   // set before pageToken bumps
    property int incomingTCol: -1   // the new col that pops in

    readonly property int itemsPerCol: rows
    readonly property int modelCols:   Math.ceil(wallpaperModel.count / itemsPerCol)

    function maxPageCol(): int {
        return Math.max(0, modelCols - cols)
    }

    // Scroll forward: old leftmost col exits left, new rightmost col pops in from right
    function nextPage(): void {
        if (pageCol >= maxPageCol()) return
        pageDir       = 1
        outgoingTCol  = 0          // leftmost screen col exits
        incomingTCol  = cols - 1   // rightmost screen col is the new one
        pageCol       = pageCol + 1
        pageToken++
    }

    // Scroll backward: old rightmost col exits right, new leftmost col pops in from left
    function previousPage(): void {
        if (pageCol <= 0) return
        pageDir       = -1
        outgoingTCol  = cols - 1   // rightmost screen col exits
        incomingTCol  = 0          // leftmost screen col is the new one
        pageCol       = pageCol - 1
        pageToken++
    }

    function clampPage(): void {
        pageCol = Math.max(0, Math.min(pageCol, maxPageCol()))
    }

    // ── Fixed Repeater — 35 delegates, never destroyed ────────────
    Repeater {
        id: rep
        model: root.visibleCount

        delegate: HexTile {
            id: tile

            required property int index

            // Column-major: each screen column holds `rows` tiles stacked
            readonly property int tCol: index % root.cols
            readonly property int tRow: Math.floor(index / root.cols)

            // Model index for this screen slot
            readonly property int modelIdx: (root.pageCol + tCol) * root.itemsPerCol + tRow

            readonly property var entry: (modelIdx >= 0 && modelIdx < root.wallpaperModel.count)
                ? root.wallpaperModel.get(modelIdx)
                : null

            // ── Position — correct honeycomb geometry ──────────────
            // Odd columns shift down by colOffset = rowStep/2
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

            // ── Per-tile animation state ───────────────────────────
            // _entX / _entOp / _entSc drive the tile's visual position/look.
            // These are NOT Behavior-animated — only SequentialAnimation touches them.
            property real _entX:  0.0
            property real _entOp: 1.0
            property real _entSc: 1.0

            // Item-level translate + opacity (for slide in/out)
            transform: Translate { x: tile._entX }
            opacity:   tile._entOp

            // ── POP-IN animation (new incoming column) ─────────────
            // Tiles in the incoming column pop in one-by-one, staggered by row.
            // Each tile: scale 0→1.12→1.0, opacity 0→1, no X slide.
            SequentialAnimation {
                id: popIn
                running: false

                // Row stagger: tRow × 55ms so top tile first, bottom last
                PauseAnimation { duration: tile.tRow * 55 }

                ParallelAnimation {
                    NumberAnimation {
                        target: tile; property: "_entOp"
                        from: 0.0; to: 1.0
                        duration: 160; easing.type: Easing.OutCubic
                    }
                    SequentialAnimation {
                        // Overshoot pop: start small, overshoot, settle
                        NumberAnimation {
                            target: tile; property: "_entSc"
                            from: 0.55; to: 1.14
                            duration: 170; easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: tile; property: "_entSc"
                            to: 0.95
                            duration: 80; easing.type: Easing.InCubic
                        }
                        NumberAnimation {
                            target: tile; property: "_entSc"
                            to: 1.0
                            duration: 70; easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // ── POP-OUT animation (old outgoing column) ────────────
            // Tiles in the outgoing column shrink + fade, staggered bottom-to-top
            // (reverse row order so they vanish sequentially downward or upward).
            SequentialAnimation {
                id: popOut
                running: false

                // Reverse stagger for exit: bottom row exits first for forward scroll
                PauseAnimation {
                    duration: root.pageDir > 0
                        ? (root.rows - 1 - tile.tRow) * 40
                        : tile.tRow * 40
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: tile; property: "_entOp"
                        to: 0.0
                        duration: 130; easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: tile; property: "_entSc"
                        to: 0.45
                        duration: 150; easing.type: Easing.InBack
                        easing.overshoot: 0.6
                    }
                }
            }

            // ── React to page changes ──────────────────────────────
            Connections {
                target: root

                function onPageTokenChanged(): void {
                    var isIncoming = (tile.tCol === root.incomingTCol)
                    var isOutgoing = (tile.tCol === root.outgoingTCol)
                    // outgoingTCol is the screen column BEFORE data swap
                    // But pageCol already changed, so outgoing tiles now show new data.
                    // We need to animate OUT before data is used visually —
                    // tiles currently visible at outgoingTCol already have old data
                    // painted on their canvas. We pop them out (they shrink/fade),
                    // then they'll show new data next repaint at scale 0 (invisible).
                    // The incoming column pops in fresh.

                    if (isOutgoing) {
                        // Stop any in-progress pop-in
                        popIn.stop()
                        // Run pop-out; tile shrinks to nothing
                        tile._entOp = 1.0
                        tile._entSc = 1.0
                        tile._entX  = 0.0
                        popOut.restart()
                    } else if (isIncoming) {
                        // Stop any in-progress pop-out
                        popOut.stop()
                        // Start invisible + small, then pop in staggered by row
                        tile._entOp = 0.0
                        tile._entSc = 0.55
                        tile._entX  = 0.0
                        popIn.restart()
                    } else {
                        // Middle columns — stay put, no animation
                        popIn.stop()
                        popOut.stop()
                        tile._entX  = 0.0
                        tile._entOp = 1.0
                        tile._entSc = 1.0
                    }
                }
            }
        }
    }

    onWallpaperModelChanged: clampPage()

    Connections {
        target: wallpaperModel
        function onCountChanged(): void { root.clampPage() }
    }

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
