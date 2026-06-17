import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Animation
import qs.MusicWidget

PopupWindow {
    id: root

    // Set this from shell.qml: MusicWidget { parentWindow: theBar }
    property var parentWindow

    width:   MusicConfig.widgetWidth
    height:  MusicConfig.widgetHeight
    visible: false

    anchor.window: parentWindow
    anchor.rect.x: parentWindow ? parentWindow.width - root.width - MusicConfig.marginRight : 0
    anchor.rect.y: parentWindow ? parentWindow.height : 0

    // ── Public API ────────────────────────────────────────────────────
    function show()   { root.visible = true }
    function hide()   { if (!WidgetState.pinned) root.visible = false }
    function toggle() { if (root.visible) hide(); else show() }

    // ── Visual shell ──────────────────────────────────────────────────
    Rectangle {
        id: shell
        anchors.fill: parent
        color:        Theme.backgroundColor
        radius:       MusicConfig.widgetRadius

        // Subtle accent border
        Rectangle {
            anchors.fill: parent
            color:        "transparent"
            radius:       MusicConfig.widgetRadius
            border.color: Theme.accentColorPrimary
            border.width: 1
            opacity:      0.5
        }

        // Ambient visualizer behind content
        MusicVisualizer {
            anchors.fill: parent
            z: -1
        }

        // ── Content layout ────────────────────────────────────────────
        ColumnLayout {
            anchors.fill:    parent
            anchors.margins: 14
            spacing: 10

            ArtworkDisplay {
                id: artwork
                Layout.fillWidth:       true
                Layout.preferredHeight: 200
            }

            // GIF picker trigger
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 110; height: 30
                radius: 15
                color: gifBtnArea.containsMouse ? Theme.raisedSurfaceColor : Theme.surfaceColor
                border.color: Theme.accentColorPrimary
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text:  "🎞  Switch GIF"
                    color: Theme.textColor
                    font.pixelSize: 12
                }
                MouseArea {
                    id: gifBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: gifModal.open()
                }
            }

            MusicControls {
                Layout.fillWidth: true
            }

            MusicProgressBar {
                Layout.fillWidth: true
            }

            // Pin toggle
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 90; height: 28
                radius: 14
                color: pinArea.containsMouse ? Theme.raisedSurfaceColor : Theme.surfaceColor
                border.color: WidgetState.pinned ? Theme.accentColorPrimary : Theme.mutedTextColor
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text:  WidgetState.pinned ? "📌 Pinned" : "📌 Pin"
                    color: WidgetState.pinned ? Theme.accentColorPrimary : Theme.mutedTextColor
                    font.pixelSize: 11
                }
                MouseArea {
                    id: pinArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: WidgetState.pinned = !WidgetState.pinned
                }
            }
        }

        // GIF picker modal
        GifPickerModal {
            id: gifModal
            onGifApplied: (src) => { artwork.gifSource = src }
        }
    }
}
