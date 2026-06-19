// Launcher.qml
// Place alongside shell.qml at: ~/.config/quickshell/launcher/Launcher.qml

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../colors"

// ─── PanelWindow: fullscreen overlay, keyboard-focusable ─────────────────────
PanelWindow {
    id: root

    // Fill the screen so we can center the box and capture outside-clicks
    anchors {
        top:    true
        bottom: true
        left:   true
        right:  true
    }

    // Transparent overlay — the cream box is drawn inside
    color: "transparent"

    // Accept keyboard focus so the search field works immediately
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.layer:         WlrLayer.Overlay
    exclusionMode:               ExclusionMode.Ignore

    // ── Palette ────────────────────────────────────────────────────────────────
                            
    LauncherState {
        id: launcherState
    }

    AppSearchModel {
        id: appSearch
        query: searchField.text
        state: launcherState
    }

    // ── Expose function called by IpcHandler after making visible ──────────────
    function focusOnOpen(): void {
        searchField.text = "";
        searchField.forceActiveFocus();
    }

    // ── Dim overlay (closes launcher on outside click) ─────────────────────────
    Rectangle {
        anchors.fill: parent
        color: ThemeManager.alpha(ThemeManager.bg, 0.33)

        // Click outside the box → close
        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }
    }

    // ── Centre box ─────────────────────────────────────────────────────────────
    Rectangle {
        id:     box
        width:  520
        height: 380
        anchors.centerIn: parent

        color:  ThemeManager.bg
        border.color: ThemeManager.accentSoft
        border.width: 2
        radius: 0          // sharp corners — no curves per spec

        // Eat clicks inside the box so the dim overlay doesn't fire
        MouseArea {
            anchors.fill: parent
            onClicked: {}  // absorb
        }

        // ── Entrance animation ─────────────────────────────────────────────────
        opacity: root.visible ? 1.0 : 0.0
        scale:   root.visible ? 1.0 : 0.94

        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutQuint } }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Title bar ──────────────────────────────────────────────────────
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 48
                color: ThemeManager.surfaceHigh
                border.color: ThemeManager.accentSoft
                border.width: 0

                // Bottom border only — drawn as a thin Rectangle
                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left:   parent.left
                        right:  parent.right
                    }
                    height: 2
                    color:  ThemeManager.accentSoft
                }

                Text {
                    anchors.centerIn: parent
                    text:  "Applications"
                    color: ThemeManager.fg
                    font {
                        family:    "monospace"
                        pixelSize: 15
                        weight:    Font.Medium
                        letterSpacing: 3
                    }
                }
            }

            // ── Search field ───────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 44
                color: ThemeManager.bg

                // Bottom border
                Rectangle {
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: 2
                    color:  ThemeManager.accentSoft
                }

                // Left "search" label
                Text {
                    anchors {
                        left:           parent.left
                        leftMargin:     16
                        verticalCenter: parent.verticalCenter
                    }
                    text:  "⌕"
                    color: ThemeManager.fgMid
                    font.pixelSize: 18
                }

                TextField {
                    id: searchField
                    anchors {
                        left:           parent.left
                        right:          parent.right
                        leftMargin:     40
                        rightMargin:    12
                        verticalCenter: parent.verticalCenter
                    }
                    height: 30
                    placeholderText: "Search applications…"
                    color:            ThemeManager.fg
                    font.family:      "monospace"
                    font.pixelSize:   13

                    background: Item {}   // no default Qt background

                    Keys.onEscapePressed: root.visible = false
                    Keys.onUpPressed: {
                        if (appList.currentIndex > 0)
                            appList.currentIndex--;
                    }
                    Keys.onDownPressed: {
                        if (appList.currentIndex < appList.count - 1)
                            appList.currentIndex++;
                    }
                    Keys.onReturnPressed: {
                        appList.launchCurrent();
                    }
                }
            }

            // ── App list ───────────────────────────────────────────────────────
            AppList {
                id: appList
                Layout.fillWidth:  true
                Layout.fillHeight: true
                appSearch: appSearch
                state: launcherState
                border: ThemeManager.accentSoft
                fg: ThemeManager.fg
                fgMid: ThemeManager.fgMid
                fillColor: ThemeManager.accent
                fillText: ThemeManager.fgInverted
                onAppLaunched: root.visible = false
            }

            Connections {
                target: root
                function onVisibleChanged(): void {
                    if (root.visible) {
                        appSearch.rebuild();
                    }
                }
            }

            // ── Footer ─────────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 32
                color:  ThemeManager.surfaceHigh

                // Top border
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 2
                    color:  ThemeManager.accentSoft
                }

                Text {
                    anchors {
                        left:           parent.left
                        leftMargin:     16
                        verticalCenter: parent.verticalCenter
                    }
                    text:  "↑↓ navigate  ↵ launch  Esc close"
                    color: ThemeManager.fgMid
                    font {
                        family:    "monospace"
                        pixelSize: 10
                        letterSpacing: 1
                    }
                }

                Text {
                    anchors {
                        right:          parent.right
                        rightMargin:    16
                        verticalCenter: parent.verticalCenter
                    }
                    text:  appList.count > 0 ? appList.count + " apps" : ""
                    color: ThemeManager.fgMid
                    font  {
                        family:    "monospace"
                        pixelSize: 10
                        letterSpacing: 1
                    }
                }
            }
        } // ColumnLayout
    } // centre box
} // PanelWindow
