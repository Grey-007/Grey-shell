import QtQuick

Item {
    id: root

    property var wallpaperModel
    property var config
    property int pageStart: 0
    property int pageToken: 0

    signal wallpaperChosen(string path)

    readonly property int columns: 4
    readonly property int rows: 9
    readonly property int tileWidth: config.tileSize
    readonly property int tileHeight: Math.round(config.tileSize * 0.86)
    readonly property int cellWidth: config.tileSize + config.tileGap
    readonly property int rowStep: Math.round(tileHeight * 0.76)

    implicitWidth: columns * cellWidth + Math.round(cellWidth * 0.5)
    implicitHeight: tileHeight + rowStep

    function maxStart(): int {
        return Math.max(0, wallpaperModel.count - config.visibleTileCount);
    }

    function clampPage(): void {
        pageStart = Math.max(0, Math.min(pageStart, maxStart()));
    }

    function nextPage(): void {
        pageStart = Math.min(maxStart(), pageStart + config.pageStride);
        pageToken++;
    }

    function previousPage(): void {
        pageStart = Math.max(0, pageStart - config.pageStride);
        pageToken++;
    }

    Repeater {
        model: Math.min(config.visibleTileCount, Math.max(0, wallpaperModel.count - root.pageStart))

        delegate: HexTile {
            id: tile

            required property int index
            readonly property var entry: root.wallpaperModel.get(root.pageStart + index)
            readonly property int row: Math.floor(index / root.columns)
            readonly property int col: index % root.columns

            width: root.tileWidth
            height: root.tileHeight
            x: col * root.cellWidth + (row % 2 === 1 ? Math.round(root.cellWidth * 0.5) : 0)
            y: row * root.rowStep
            path: entry ? entry.path : ""
            name: entry ? entry.name : ""
            selected: path === root.wallpaperModel.selectedPath
            selectedBorderColor: root.config.selectedBorderColor
            hoverBorderColor: root.config.hoverBorderColor
            shadowColor: root.config.shadowColor
            labelColor: root.config.textColor
            hoverDuration: root.config.hoverDuration
            hoverScale: root.config.hoverScale
            pageScale: 1.0
            opacity: 1

            onChosen: root.wallpaperChosen(path)

            Behavior on x {
                NumberAnimation {
                    duration: root.config.pageDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.config.pageDuration
                    easing.type: Easing.OutCubic
                }
            }

            ParallelAnimation {
                id: pagePulse
                running: false
                NumberAnimation {
                    target: tile
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.config.pageDuration
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: tile
                    property: "pageScale"
                    from: 0.88
                    to: 1.0
                    duration: root.config.pageDuration
                    easing.type: Easing.OutBack
                }
            }

            Connections {
                target: root
                function onPageTokenChanged(): void {
                    pagePulse.restart();
                }
            }
        }
    }

    onPageStartChanged: clampPage()

    Connections {
        target: wallpaperModel
        function onScanned(): void {
            root.clampPage();
            root.pageToken++;
        }
    }
}
