// WallpaperSelector.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "components"

PanelWindow {
    id: root

    // Full-screen overlay
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    // ── Shared objects ───────────────────────────────────────────────
    WallpaperConfig {
        id: appConfig
    }

    WallpaperStore {
        id: store
        config: appConfig
    }

    // ── Config window (toggled by gear icon) ─────────────────────────
    WallpaperConfigWindow {
        id: configWindow
        config: appConfig
        visible: false
    }

    // ── Dim overlay — click outside to close ─────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#55000000"

        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }
    }

    // ── Main UI card ─────────────────────────────────────────────────
    Rectangle {
        id: mainCard

        width: 660
        height: 520
        anchors.centerIn: parent

        color: "#1A1410"
        border.color: "#5A4736"
        border.width: 2

        // Absorb clicks so dim overlay doesn't close when clicking on card
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Return focus to keyboard handler when user clicks card background
                keyboardScope.forceActiveFocus()
            }
        }

        // ── Focus scope that owns keyboard events ────────────────────
        FocusScope {
            id: keyboardScope
            anchors.fill: parent
            focus: true

            Keys.onEscapePressed: function(event) {
                if (searchField.inputActive) {
                    searchField.text = ""
                    keyboardScope.forceActiveFocus()
                    event.accepted = true
                } else {
                    root.visible = false
                    event.accepted = true
                }
            }

            Keys.onLeftPressed: function(event) {
                if (!searchField.inputActive) {
                    if (store.selectedIndex > 0) {
                        store.selectedIndex--
                        filmStrip.scrollToSelected()
                    }
                    event.accepted = true
                }
            }

            Keys.onRightPressed: function(event) {
                if (!searchField.inputActive) {
                    if (store.selectedIndex < store.model.count - 1) {
                        store.selectedIndex++
                        filmStrip.scrollToSelected()
                    }
                    event.accepted = true
                }
            }

            Keys.onReturnPressed: function(event) {
                if (!searchField.inputActive) {
                    store.applyWallpaper()
                    event.accepted = true
                }
            }

            // ── Layout ───────────────────────────────────────────────
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // ── Title bar ─────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    height: 22

                    Text {
                        text: "WALLPAPER"
                        color: "#A67C52"
                        font.family: "monospace"
                        font.pixelSize: 12
                        font.letterSpacing: 2
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Gear icon — toggles WallpaperConfigWindow
                    Rectangle {
                        width: 28
                        height: 28
                        color: gearMa.containsMouse ? "#3A2E26" : "transparent"
                        border.color: configWindow.visible ? "#A67C52" : "#5A4736"
                        border.width: configWindow.visible ? 2 : 1

                        Text {
                            anchors.centerIn: parent
                            text: "⚙"
                            color: configWindow.visible ? "#A67C52" : "#F2E0C8"
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: gearMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                configWindow.visible = !configWindow.visible
                                // Keep keyboard focus on selector
                                keyboardScope.forceActiveFocus()
                            }
                        }
                    }
                }

                // ── Preview Panel (~45% of remaining space) ───────────
                PreviewPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: mainCard.height * 0.43
                    source: store.selectedWallpaper
                }

                // ── Film Strip (~35% of remaining space) ─────────────
                FilmStrip {
                    id: filmStrip
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainCard.height * 0.28
                    Layout.minimumHeight: 110

                    model: store.model
                    selectedIndex: store.selectedIndex

                    onThumbnailClicked: function(index) {
                        store.selectedIndex = index
                        keyboardScope.forceActiveFocus()
                    }

                    onThumbnailDoubleClicked: function(index) {
                        store.selectedIndex = index
                        store.applyWallpaper()
                        keyboardScope.forceActiveFocus()
                    }
                }

                // ── Search Bar (~8%) ──────────────────────────────────
                SearchBar {
                    id: searchField
                    Layout.fillWidth: true
                    // When search gains focus, keys go to search
                    // When not focused, keys go to keyboardScope
                    onSearchChanged: function(query) {
                        store.searchQuery = query
                    }
                }

                // ── Apply row (~7%) ───────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Wallpaper name display
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: {
                            if (store.selectedWallpaper === "") return "—"
                            var parts = store.selectedWallpaper.split("/")
                            return parts[parts.length - 1]
                        }
                        color: "#A67C52"
                        font.family: "monospace"
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                    }

                    // Apply button
                    Rectangle {
                        width: 90
                        height: 28
                        color: applyMa.containsMouse ? "#A67C52" : "#3A2E26"
                        border.color: "#A67C52"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "APPLY"
                            color: applyMa.containsMouse ? "#241D18" : "#F2E0C8"
                            font.family: "monospace"
                            font.pixelSize: 12
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            id: applyMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                store.applyWallpaper()
                                keyboardScope.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }

    // ── On visibility change: grab focus ─────────────────────────────
    onVisibleChanged: {
        if (visible) {
            keyboardScope.forceActiveFocus()
        } else {
            // Hide config window when selector closes
            configWindow.visible = false
        }
    }
}
