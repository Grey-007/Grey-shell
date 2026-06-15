import QtQuick

// WallpaperGrid — pure sliding strip, no per-tile animation
// One wide Item ("strip") contains ALL tiles side by side in pages.
// Sliding strip.x with a Behavior = smooth, instant, zero complexity.
Item {
    id: root

    property var wallpaperModel
    property var config

    signal wallpaperChosen(string path)

    readonly property int cols:    config.cols     // 6
    readonly property int rows:    config.rows     // 3
    readonly property int tileW:   config.tileW    // 200
    readonly property int tileH:   config.tileH    // 126
    readonly property int gap:     config.gap      // 8
    readonly property int perPage: cols * rows     // 18

    readonly property int pageW:   cols * tileW + (cols - 1) * gap
    readonly property int pageH:   rows * tileH + (rows - 1) * gap

    implicitWidth:  pageW
    implicitHeight: pageH

    // How many full pages of tiles
    readonly property int totalItems: wallpaperModel.count
    readonly property int totalPages: Math.max(1, Math.ceil(totalItems / perPage))
    readonly property int currentPage: pageIndex

    property int pageIndex: 0

    function maxPage():      int  { return Math.max(0, totalPages - 1) }
    function nextPage():     void { if (pageIndex < maxPage()) pageIndex++ }
    function previousPage(): void { if (pageIndex > 0)        pageIndex-- }
    function goToPage(p):    void { pageIndex = Math.max(0, Math.min(p, maxPage())) }
    // Keep compat with old callers that used pageCol / maxPageCol
    function maxPageCol():   int  { return maxPage() }
    property int pageCol: pageIndex
    onPageIndexChanged: pageCol = pageIndex

    function clampPage(): void {
        if (pageIndex > maxPage()) pageIndex = maxPage()
    }

    // Clip so tiles outside viewport are invisible during slide
    clip: true

    // ── Sliding strip ──────────────────────────────────────────────
    // Strip width = totalPages × pageW + (totalPages-1) × gap
    // Strip x = -pageIndex × (pageW + gap)  → slides left on next page
    Item {
        id: strip
        width:  root.totalPages * (root.pageW + root.gap)
        height: root.pageH

        // THE slide — one Behavior, silky smooth
        x: -(root.pageIndex * (root.pageW + root.gap))
        Behavior on x {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutCubic
            }
        }

        // All tiles — fixed Repeater over ALL model items
        Repeater {
            id: rep
            model: root.totalItems

            delegate: WallpaperTile {
                required property int index

                // Which page and position within page
                readonly property int page:  Math.floor(index / root.perPage)
                readonly property int pos:   index % root.perPage
                readonly property int pCol:  pos % root.cols
                readonly property int pRow:  Math.floor(pos / root.cols)

                readonly property var entry: root.wallpaperModel.get(index)

                // Absolute position in strip
                x: page * (root.pageW + root.gap) + pCol * (root.tileW + root.gap)
                y: pRow * (root.tileH + root.gap)

                width:  root.tileW
                height: root.tileH

                path:     entry ? entry.path : ""
                name:     entry ? entry.name : ""
                selected: path !== "" && path === root.wallpaperModel.selectedPath
                accent:   root.config.accent

                onChosen: function(p) { root.wallpaperChosen(p) }
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
            if (t && t.path === path) { t.playApplyAnim(); break }
        }
    }
}
