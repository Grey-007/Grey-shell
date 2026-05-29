// Launcher.qml
// Place alongside shell.qml at: ~/.config/quickshell/launcher/Launcher.qml

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
    readonly property color cream:       "#F5F0E8"
    readonly property color creamDark:   "#EDE8DF"   // header bg
    readonly property color border:      "#2A2A2A"
    readonly property color fg:          "#1A1A1A"
    readonly property color fgMid:       "#555555"
    readonly property color fillColor:   "#2A2A2A"   // hover fill
    readonly property color fillText:    "#F5F0E8"   // inverted text on fill

    AppSearchModel {
        id: appSearch
        query: searchField.text
    }

    // ── Expose function called by IpcHandler after making visible ──────────────
    function focusOnOpen(): void {
        searchField.text = "";
        searchField.forceActiveFocus();
    }

    // ── Dim overlay (closes launcher on outside click) ─────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#55000000"

        // Click outside the box → close
        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }
    }

    // ── Centre box ─────────────────────────────────────────────────────────────
    Rectangle {
        id:     box
        width:  620
        height: 420
        anchors.centerIn: parent

        color:  root.cream
        border.color: root.border
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

        Behavior on opacity {
            NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Title bar ──────────────────────────────────────────────────────
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 48
                color: root.creamDark
                border.color: root.border
                border.width: 0

                // Bottom border only — drawn as a thin Rectangle
                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left:   parent.left
                        right:  parent.right
                    }
                    height: 2
                    color:  root.border
                }

                Text {
                    anchors.centerIn: parent
                    text:  "Applications"
                    color: root.fg
                    font {
                        family:    "monospace"
                        pixelSize: 15
                        weight:    Font.Medium
                        letterSpacing: 3
                    }
                }

                // ── Close button (top-right) ───────────────────────────────────
                Rectangle {
                    id: closeBtn
                    width:  48
                    height: parent.height
                    anchors.right: parent.right
                    color:  closeMa.containsMouse ? root.border : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text:  "✕"
                        color: closeMa.containsMouse ? root.cream : root.fg
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.visible = false
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // ── Search field ───────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 44
                color: root.cream

                // Bottom border
                Rectangle {
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: 2
                    color:  root.border
                }

                // Left "search" label
                Text {
                    anchors {
                        left:           parent.left
                        leftMargin:     16
                        verticalCenter: parent.verticalCenter
                    }
                    text:  "⌕"
                    color: root.fgMid
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
                    color:            root.fg
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
                border: root.border
                fg: root.fg
                fgMid: root.fgMid
                fillColor: root.fillColor
                fillText: root.fillText
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
                color:  root.creamDark

                // Top border
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 2
                    color:  root.border
                }

                Text {
                    anchors {
                        left:           parent.left
                        leftMargin:     16
                        verticalCenter: parent.verticalCenter
                    }
                    text:  "↑↓ navigate  ↵ launch  Esc close"
                    color: root.fgMid
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
                    color: root.fgMid
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
