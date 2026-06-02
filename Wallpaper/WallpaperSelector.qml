import "."
import QtQuick
import Quickshell
import Quickshell.Wayland

// ─────────────────────────────────────────────────────────────────────────────
// WallpaperSelector – the main PanelWindow
//
// Design from reference screenshot:
//   • NO opaque background – the honeycomb floats directly over the desktop
//   • Only a very subtle screen-wide dim (25% black) so tiles pop
//   • Search bar + tag chips anchored near bottom-centre
//   • Escape / click on empty area closes
//   • Smooth scale+fade open/close animation
// ─────────────────────────────────────────────────────────────────────────────
PanelWindow {
    id: win

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WallpaperState.visible
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }

    // Keep window alive during close animation
    visible: WallpaperState.visible || _openProgress > 0.01

    // ── Open/close progress ───────────────────────────────────────────────
    property real _openProgress: 0.0

    Behavior on _openProgress {
        NumberAnimation { duration: 360; easing.type: Easing.OutQuint }
    }

    Connections {
        target: WallpaperState
        function onVisibleChanged() {
            win._openProgress = WallpaperState.visible ? 1.0 : 0.0;
        }
    }

    // ── Very subtle full-screen dim so hex tiles stand out ────────────────
    // (not opaque – just a 25% translucent wash)
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.25 * win._openProgress

        // Click empty space to close
        MouseArea {
            anchors.fill: parent
            onClicked: WallpaperState.close()
        }
    }

    Keys.onEscapePressed: WallpaperState.close()

    // ── Main content: honeycomb + search bar ──────────────────────────────
    Item {
        id: _content
        anchors.fill: parent
        opacity: win._openProgress
        // Zoom in from 90% on open
        scale: 0.90 + 0.10 * win._openProgress

        // ── Honeycomb field (fills whole screen minus search bar area) ────
        HoneycombLayout {
            id: _hex
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter
            anchors.verticalCenterOffset: -30   // shift up slightly to leave room for search bar
            width:  Math.min(parent.width  - 120, 860)
            height: Math.min(parent.height - 160, 420)

            wallpapers:       WallpaperState.filteredWallpapers
            currentWallpaper: WallpaperState.currentWallpaper

            onWallpaperChosen: (path) => {
                WallpaperState.applyWallpaper(path);
                WallpaperState.close();
            }
        }

        // ── Empty state ───────────────────────────────────────────────────
        Column {
            anchors.centerIn: _hex
            spacing: 14
            visible: WallpaperState.filteredWallpapers.length === 0
                     && !WallpaperState.scanning

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "⬡"
                font.pixelSize: 56
                color: "#1E2A18"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: WallpaperState.searchText !== ""
                      ? "No wallpapers match this filter"
                      : "No wallpapers in ~/Pictures/Wallpapers"
                color: "#3A4A30"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // ── Scanning pulse ────────────────────────────────────────────────
        Text {
            anchors.centerIn: _hex
            text: "Scanning…"
            color: "#6A8860"
            font.pixelSize: 15
            visible: WallpaperState.scanning

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: WallpaperState.scanning
                NumberAnimation { from: 1.0; to: 0.3; duration: 700; easing.type: Easing.InOutCubic }
                NumberAnimation { from: 0.3; to: 1.0; duration: 700; easing.type: Easing.InOutCubic }
            }
        }

        // ── Search + tag bar (floating near bottom centre) ────────────────
        Item {
            id: _searchArea
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 28
            }
            width:  Math.min(parent.width - 80, 660)
            height: _searchBar.implicitHeight

            SearchBar {
                id: _searchBar
                anchors.fill: parent
            }
        }

        // ── Error toast ───────────────────────────────────────────────────
        Rectangle {
            anchors {
                bottom: _searchArea.top
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 10
            }
            width:  _errText.implicitWidth + 28
            height: 32
            radius: 16
            color:  "#CC3A1010"
            visible: WallpaperState.errorText !== ""

            Text {
                id: _errText
                anchors.centerIn: parent
                text: WallpaperState.errorText
                color: "#FFB4AB"
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }
}
