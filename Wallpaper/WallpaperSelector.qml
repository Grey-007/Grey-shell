// WallpaperSelector.qml — Floating wallpaper picker panel
// Quickshell 0.3 | aww backend | Transparent | 600+ wallpaper support
//
// IPC: qs ipc -c wallpaper-selector call wallpaperSelector toggle

import QtQuick
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: root

    // ── IPC handlers ─────────────────────────────────────────────────────
    IpcHandler {
        target: "wallpaperSelector"

        function toggle() { root.visible ? root.close() : root.open() }
        function show()   { root.open() }
        function hide()   { root.close() }
    }

    // ── Window setup ──────────────────────────────────────────────────────
    title:   "Wallpaper Selector"
    visible: false
    color:   "transparent"

    // Full-width strip at bottom of screen
    width:  Screen.width
    height: 310


    // ── Reveal state ──────────────────────────────────────────────────────
    property real revealProgress: 0.0   // 0 = hidden, 1 = fully shown

    // ── Center index (which card is focused) ──────────────────────────────
    property int centerIndex: 0

    // ── Open / Close ──────────────────────────────────────────────────────
    function open() {
        root.visible = true
        showAnim.stop()
        hideAnim.stop()
        showAnim.start()
        carousel.forceActiveFocus()
        // Jump to current wallpaper if set
        Qt.callLater(snapToCurrent)
    }

    function close() {
        hideAnim.stop()
        showAnim.stop()
        hideAnim.start()
    }

    function snapToCurrent() {
        const cur = WallpaperService.currentWallpaper
        if (!cur || cur === "") return
        const m = WallpaperService.model
        for (let i = 0; i < m.count; i++) {
            const url = m.get(i, "fileURL")
            if (!url) continue
            if (WallpaperService.toPlainPath(url.toString()) === cur) {
                root.centerIndex  = i
                carousel.currentIndex = i
                carousel.positionViewAtIndex(i, ListView.Center)
                return
            }
        }
    }

    NumberAnimation {
        id: showAnim
        target:   root
        property: "revealProgress"
        from: 0; to: 1
        duration: 380
        easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: hideAnim
        target:   root
        property: "revealProgress"
        from: 1; to: 0
        duration: 280
        easing.type: Easing.InCubic
        onFinished: root.visible = false
    }

    // ── Click-outside to dismiss ──────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.close()
    }

    // ── Panel background (semi-transparent frosted strip) ─────────────────
    Rectangle {
        id: panelBg
        anchors {
            left:   parent.left
            right:  parent.right
            top:    panelContent.top
            bottom: panelContent.bottom
            topMargin:    -12
            bottomMargin: -12
        }
        color:   Qt.rgba(0.04, 0.04, 0.06, 0.62)
        opacity: root.revealProgress

        // Top accent line
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0;  color: "transparent" }
                GradientStop { position: 0.25; color: "#FF6B35"     }
                GradientStop { position: 0.75; color: "#FF6B35"     }
                GradientStop { position: 1.0;  color: "transparent" }
            }
        }

        // Bottom accent line
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0;  color: "transparent" }
                GradientStop { position: 0.25; color: Qt.rgba(1,0.42,0.21,0.4) }
                GradientStop { position: 0.75; color: Qt.rgba(1,0.42,0.21,0.4) }
                GradientStop { position: 1.0;  color: "transparent" }
            }
        }
    }

    // ── Main content container ─────────────────────────────────────────────
    Item {
        id: panelContent
        anchors.fill: parent
        opacity: root.revealProgress

        // Slide-up entry
        transform: Translate {
            y: (1.0 - root.revealProgress) * 55
        }

        // ── Carousel ─────────────────────────────────────────────────────
        ListView {
            id: carousel
            anchors {
                left:  parent.left
                right: parent.right
                top:   parent.top
                topMargin: 20
            }
            height: 260

            orientation:   ListView.Horizontal
            focus:         true
            clip:          false    // allow center card to visually overflow
            spacing:       -34      // negative = overlapping skewed edges

            // Virtualisation — only renders visible cards + cacheBuffer on each side
            // This is the core reason 600+ wallpapers work without OOM
            cacheBuffer:           2    // keep 2 off-screen cards decoded each side
            displayMarginBeginning: 0
            displayMarginEnd:       0

            // Keep selected item centered
            preferredHighlightBegin: (width - 520) / 2
            preferredHighlightEnd:   (width + 520) / 2
            highlightRangeMode:      ListView.StrictlyEnforceRange
            highlightMoveDuration:   300

            model: WallpaperService.model

            // ── Delegate ─────────────────────────────────────────────────
            delegate: WallpaperCard {
                id: card

                // FolderListModel roles
                required property int    index
                required property url    fileURL
                required property string fileName  // unused (we derive it)

                readonly property string plainPath: WallpaperService.toPlainPath(fileURL.toString())

                // WallpaperCard inputs
                filePath: fileURL.toString()
                fileName: WallpaperService.basename(fileURL.toString())
                isCenter: root.centerIndex === index
                isActive: WallpaperService.currentWallpaper === plainPath

                height: carousel.height
                width:  isCenter ? 520 : 260

                onClicked: {
                    if (root.centerIndex === index) {
                        // Second click on already-centered card → apply + close
                        WallpaperService.setWallpaper(plainPath)
                        root.close()
                    } else {
                        // First click → navigate to this card
                        root.centerIndex      = index
                        carousel.currentIndex = index
                    }
                }
            }

            currentIndex: root.centerIndex

            onCurrentIndexChanged: {
                root.centerIndex = currentIndex
            }

            // ── Keyboard navigation ───────────────────────────────────────
            Keys.onLeftPressed: (event) => {
                event.accepted = true
                if (currentIndex > 0) {
                    currentIndex--
                    root.centerIndex = currentIndex
                }
            }
            Keys.onRightPressed: (event) => {
                event.accepted = true
                if (currentIndex < count - 1) {
                    currentIndex++
                    root.centerIndex = currentIndex
                }
            }
            Keys.onReturnPressed: (event) => {
                event.accepted = true
                applyCenter()
            }
            Keys.onSpacePressed: (event) => {
                event.accepted = true
                applyCenter()
            }
            Keys.onEscapePressed: (event) => {
                event.accepted = true
                root.close()
            }

            function applyCenter() {
                const item = itemAtIndex(currentIndex)
                if (item) {
                    WallpaperService.setWallpaper(item.plainPath)
                    root.close()
                }
            }

            // ── Mouse wheel navigation ────────────────────────────────────
            WheelHandler {
                onWheel: (event) => {
                    if (event.angleDelta.y < 0) {
                        if (carousel.currentIndex < carousel.count - 1) {
                            carousel.currentIndex++
                            root.centerIndex = carousel.currentIndex
                        }
                    } else {
                        if (carousel.currentIndex > 0) {
                            carousel.currentIndex--
                            root.centerIndex = carousel.currentIndex
                        }
                    }
                    event.accepted = true
                }
            }
        }

        // ── Mini scrollbar (position indicator for 600+ wallpapers) ───────
        Item {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top:              carousel.bottom
                topMargin:        8
            }
            width:  220
            height: 4

            Rectangle {
                anchors.fill: parent
                radius: 2
                color:  Qt.rgba(1, 1, 1, 0.12)
            }
            Rectangle {
                id: scrollThumb
                height: parent.height
                radius: parent.radius
                color:  "#FF6B35"
                width:  Math.max(16, parent.width * carousel.visibleArea.widthRatio)
                x:      carousel.visibleArea.xPosition * parent.width
                Behavior on x { NumberAnimation { duration: 100 } }
            }
        }

        // ── Counter label ─────────────────────────────────────────────────
        Text {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top:              carousel.bottom
                topMargin:        18
            }
            text: WallpaperService.model.count > 0
                ? (root.centerIndex + 1) + " / " + WallpaperService.model.count
                : "No wallpapers found — check Config.qml → wallpaperDir"
            color: Qt.rgba(1, 1, 1, 0.5)
            font.pixelSize: 11
        }

        // ── Key hint bar ──────────────────────────────────────────────────
        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom:           parent.bottom
                bottomMargin:     8
            }
            spacing: 18

            Repeater {
                model: [
                    { key: "← →",   hint: "Navigate"     },
                    { key: "↕ Wheel", hint: "Scroll"      },
                    { key: "Enter",  hint: "Apply"        },
                    { key: "Click",  hint: "Select/Apply" },
                    { key: "Esc",    hint: "Dismiss"      },
                ]

                delegate: Row {
                    required property var modelData
                    spacing: 5

                    Rectangle {
                        width:  keyTxt.implicitWidth + 10
                        height: 18; radius: 3
                        color:  Qt.rgba(1, 1, 1, 0.10)

                        Text {
                            id:     keyTxt
                            anchors.centerIn: parent
                            text:   modelData.key
                            color:  "white"
                            font  { pixelSize: 10; weight: Font.Medium }
                        }
                    }

                    Text {
                        text:  modelData.hint
                        color: Qt.rgba(1, 1, 1, 0.40)
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
