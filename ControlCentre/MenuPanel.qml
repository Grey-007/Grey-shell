import "."
import QtQuick
import QtQuick.Layouts

// SepiaShell – expandable sub-panel (wifi networks, BT devices, audio outputs)
Item {
    id: root

    property string title:     ""
    property bool   busy:      false
    property bool   showScan:  true
    property string errorText: ""
    default property alias menuData: panelContent.data

    signal scanClicked()

    implicitHeight: Math.min(panelContent.implicitHeight + 28, 320)

    // ── SepiaShell colour tokens ─────────────────────────────────────
    readonly property color surface:    "#241D18"
    readonly property color onSurf:     "#F2E0C8"
    readonly property color onSurfV:    "#8C6F56"
    readonly property color errorColor: "#E8906A"
    readonly property color borderCol:  "#5A4736"

    // Slide-in + fade on appear
    opacity: 0
    NumberAnimation on opacity {
        from: 0; to: 1
        duration: 260
        easing.type: Easing.OutCubic
        running: true
    }

    transform: Translate {
        y: (1 - root.opacity) * -12
    }

    // Card
    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 0
        color: root.surface
        border.color: root.borderCol
        border.width: 1
        clip: true
    }

    Flickable {
        anchors {
            fill:          parent
            margins:       14
        }
        contentHeight: panelContent.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: panelContent
            width: parent.width
            spacing: 8

            // Header row
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text:           root.title
                    color:          root.onSurf
                    font.pixelSize: 12
                    font.family:    "monospace"
                    font.weight:    Font.DemiBold
                    font.letterSpacing: 1
                }

                SmallButton {
                    Layout.fillWidth: false
                    text:    root.busy ? "Scanning…" : "Scan"
                    visible: root.showScan
                    onClicked: root.scanClicked()
                }
            }

            // Error text
            Text {
                Layout.fillWidth: true
                text:       root.errorText
                color:      root.errorColor
                font.pixelSize: 11
                font.family:    "monospace"
                wrapMode:   Text.WordWrap
                visible:    text !== ""
            }
        }
    }
}
