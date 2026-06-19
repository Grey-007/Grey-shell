// ThemeSwitcher.qml
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

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

    color: "transparent"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.layer:         WlrLayer.Overlay
    exclusionMode:               ExclusionMode.Ignore

    function focusOnOpen(): void {
        listView.forceActiveFocus();
    }

    // ── Dim overlay (closes switcher on outside click) ─────────────────────────
    Rectangle {
        anchors.fill: parent
        color: ThemeManager.alpha(ThemeManager.bg, 0.33)

        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }
    }

    // ── Centre box ─────────────────────────────────────────────────────────────
    Rectangle {
        id:     box
        width:  400
        height: 380
        anchors.centerIn: parent

        color:  ThemeManager.bg
        border.color: ThemeManager.accentSoft
        border.width: 2
        radius: 0          // sharp corners — no curves per spec

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
                border.width: 0

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
                    text:  "Theme Switcher"
                    color: ThemeManager.fg
                    font {
                        family:    "monospace"
                        pixelSize: 15
                        weight:    Font.Medium
                        letterSpacing: 3
                    }
                }
            }

            // ── Theme list ───────────────────────────────────────────────────────
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                property var themesList: ["Sepia", "GruvboxDark", "GruvboxLight", "CatppuccinMocha", "CatppuccinLatte", "TokyoNightDark", "TokyoNightLight"]
                model: themesList

                delegate: Rectangle {
                    width: listView.width
                    height: 48
                    color: index === listView.currentIndex ? ThemeManager.accent : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: listView.currentIndex = index
                        onClicked: {
                            ThemeManager.setTheme(modelData)
                            root.visible = false
                        }
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 16
                            verticalCenter: parent.verticalCenter
                        }
                        text: modelData
                        color: index === listView.currentIndex ? ThemeManager.fgInverted : ThemeManager.fg
                        font.family: "monospace"
                        font.pixelSize: 14
                    }
                    
                    Text {
                        anchors {
                            right: parent.right
                            rightMargin: 16
                            verticalCenter: parent.verticalCenter
                        }
                        text: ThemeManager.activeTheme === modelData ? "Active" : ""
                        color: index === listView.currentIndex ? ThemeManager.fgInverted : ThemeManager.accent
                        font.family: "monospace"
                        font.pixelSize: 12
                    }
                }

                Keys.onEscapePressed: root.visible = false
                Keys.onReturnPressed: {
                    if (currentIndex >= 0 && currentIndex < count) {
                        ThemeManager.setTheme(model[currentIndex])
                        root.visible = false
                    }
                }

                footer: Rectangle {
                    width: listView.width
                    height: 48
                    color: addMa.containsMouse ? ThemeManager.surfaceTop : "transparent"

                    MouseArea {
                        id: addMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: importerWindow.visible = true
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 16
                            verticalCenter: parent.verticalCenter
                        }
                        text: "+ Add New Theme..."
                        color: addMa.containsMouse ? ThemeManager.accent : ThemeManager.fgMid
                        font.family: "monospace"
                        font.pixelSize: 14
                    }
                }
            }

            // ── Footer ─────────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 32
                color:  ThemeManager.surfaceHigh

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
                    text:  "↑↓ navigate  ↵ apply  Esc close"
                    color: ThemeManager.fgMid
                    font {
                        family:    "monospace"
                        pixelSize: 10
                        letterSpacing: 1
                    }
                }
            }
        }

        // ── Dim overlay for the ImporterWindow ─────────────────────────
        Rectangle {
            anchors.fill: parent
            color: ThemeManager.alpha(ThemeManager.bg, 0.5)
            visible: importerWindow.visible
            z: 9

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: importerWindow.visible = false
            }
        }

        ImporterWindow {
            id: importerWindow
            anchors.centerIn: parent
            width: 320
            height: 200
            visible: false
            z: 10

            onCanceled: visible = false
            onImported: function(themeName) {
                var newList = listView.themesList.slice()
                newList.push(themeName)
                listView.themesList = newList
                visible = false
                ThemeManager.setTheme(themeName)
                root.visible = false
            }
        }
    }
}
