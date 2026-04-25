import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "modules"
import Qt5Compat.GraphicalEffects

// Bar.qml — minimal floating top panel bar for Hyprland
// Left: logo | divider | workspace dots
// Center: focused window title (click → MPRIS popup)
// Right: tray, system meters, volume, and power controls
PanelWindow {
    id: bar

    signal mediaClicked()
    signal powerClicked()

    readonly property int barHeight: 36
    readonly property int topInset: 10
    readonly property int sideInset: Math.max(24, Math.round((screen?.width ?? 1360) * 0.14))

    // Pin to the top edge while margins make it a smaller floating panel.
    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: topInset
        left: sideInset
        right: sideInset
    }

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: topInset + barHeight - 8

    implicitHeight: barHeight
    color: "transparent"

    // ── Background ─────────────────────────────────────────────────
    Item {
    anchors.fill: parent

    DropShadow {
        anchors.fill: panelBackground
        source: panelBackground

        horizontalOffset: 0
        verticalOffset: 2
        radius: 20
        samples: 40
        color: "#00000000"
        transparentBorder: true   // VERY important
    }

    Rectangle {
        id: panelBackground
        anchors.fill: parent
        anchors.margins: 1
        radius: height / 2 - 1
        color: "#f8f7f2"
        border.color: "#000000"
        border.width: 2
        antialiasing: true
        border.pixelAligned: false
    }
  }

    // ── Content layout ─────────────────────────────────────────────
    Item {
        anchors.fill: parent

        // LEFT: logo + divider + workspaces
        RowLayout {
            id: leftSection
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 15

            Image {
                id: logoImg
                source: Qt.resolvedUrl("assets/logo.svg")
                sourceSize.width: 14
                width: 18
                height: 18
                fillMode: Image.PreserveAspectFit
                smooth: true
                ColorOverlay {
                  source: logoImg
                  color: "black"
                  width: 14; height: 18
                }

                // Nerd Font fallback glyph if SVG missing
                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: "#ffffffaa"
                    font.pixelSize: 14
                    visible: logoImg.status !== Image.Ready
                }
            }

            Workspaces {}
        }

        // CENTER: focused window title
        Item{
            anchors.centerIn: parent
            height: parent.height

            width: 150

            Row {
                id: enterRow
                spacing: 8 
                
                //time
                Clock {}

            }

        }

        // RIGHT: compact system controls
        RowLayout {
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            Tray {}
            Cpu {}
            Ram {}
            Volume {}
            Battery {}
            PowerButton {
                onClicked: bar.powerClicked()
            }
        }
    }
}
