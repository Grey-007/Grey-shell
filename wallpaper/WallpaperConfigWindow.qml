// WallpaperConfigWindow.qml
// Separate floating window for AWWW settings.
// Toggled by the gear icon in WallpaperSelector.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../colors"

PanelWindow {
    id: root

    // The shared config object — must be set by the parent (WallpaperSelector)
    property var config: null

    // Size
    implicitWidth: 480
    implicitHeight: 280

    // Centered on screen
    anchors {
        top: false
        bottom: false
        left: false
        right: false
    }

    color: "transparent"

    // Not a full overlay — sits on top without blocking everything
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    // Main card
    Rectangle {
        width: 480
        height: 280
        anchors.centerIn: parent

        color: ThemeManager.bg
        border.color: ThemeManager.border
        border.width: 2

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Title bar
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "⚙  WALLPAPER SETTINGS"
                    color: ThemeManager.accent
                    font.family: "monospace"
                    font.pixelSize: 13
                    font.letterSpacing: 1.5
                    Layout.fillWidth: true
                }

                // Close button
                Rectangle {
                    width: 24
                    height: 24
                    color: closeMa.containsMouse ? ThemeManager.surfaceTop : "transparent"
                    border.color: ThemeManager.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: ThemeManager.fg
                        font.pixelSize: 12
                        font.family: "monospace"
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.visible = false
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: ThemeManager.border
            }

            // Directory row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "Directory"
                    color: ThemeManager.accent
                    font.family: "monospace"
                    font.pixelSize: 12
                    Layout.preferredWidth: 72
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    color: ThemeManager.surface
                    border.color: dirInput.activeFocus ? ThemeManager.accent : ThemeManager.border
                    border.width: 2

                    TextInput {
                        id: dirInput
                        anchors.fill: parent
                        anchors.margins: 8
                        color: ThemeManager.fg
                        font.family: "monospace"
                        font.pixelSize: 13
                        clip: true
                        text: root.config ? root.config.wallpaperDirectory : ""

                        onEditingFinished: {
                            if (root.config) {
                                root.config.wallpaperDirectory = text
                                root.config.save()
                            }
                        }
                    }
                }
            }

            // Sync dirInput when config loads
            Connections {
                target: root.config
                function onIsLoadedChanged() {
                    if (root.config && root.config.isLoaded) {
                        dirInput.text = root.config.wallpaperDirectory
                    }
                }
            }

            // Animation type row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "Animation"
                    color: ThemeManager.accent
                    font.family: "monospace"
                    font.pixelSize: 12
                    Layout.preferredWidth: 72
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: ["fade", "grow", "left", "right", "top", "bottom", "center", "random"]

                        Rectangle {
                            width: Math.max(52, animText.implicitWidth + 14)
                            height: 28
                            color: (root.config && root.config.awwwAnimation === modelData) ? ThemeManager.accent : "transparent"
                            border.color: ThemeManager.border
                            border.width: 2

                            Text {
                                id: animText
                                anchors.centerIn: parent
                                text: modelData
                                color: (root.config && root.config.awwwAnimation === modelData) ? ThemeManager.surface : ThemeManager.fg
                                font.family: "monospace"
                                font.pixelSize: 11
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.config) {
                                        root.config.awwwAnimation = modelData
                                        root.config.save()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Duration row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "Duration"
                    color: ThemeManager.accent
                    font.family: "monospace"
                    font.pixelSize: 12
                    Layout.preferredWidth: 72
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: [500, 1000, 1500, 2000, 3000]

                        Rectangle {
                            width: 64
                            height: 28
                            color: (root.config && root.config.animationDuration === modelData) ? ThemeManager.accent : "transparent"
                            border.color: ThemeManager.border
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: modelData + "ms"
                                color: (root.config && root.config.animationDuration === modelData) ? ThemeManager.surface : ThemeManager.fg
                                font.family: "monospace"
                                font.pixelSize: 11
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.config) {
                                        root.config.animationDuration = modelData
                                        root.config.save()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Spacer
            Item { Layout.fillHeight: true }
        }
    }
}
