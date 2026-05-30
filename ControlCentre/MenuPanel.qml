import "."
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

// Material You – expandable sub-panel (wifi networks, BT devices, audio outputs)
Item {
    id: root

    property string title: ""
    property bool busy: false
    property bool showScan: true
    property string errorText: ""
    default property alias menuData: panelContent.data

    signal scanClicked()

    implicitHeight: Math.min(panelContent.implicitHeight + 28, 320)
    opacity: 0

    // Shared dark tokens
    readonly property color surface:    "#1E2319"
    readonly property color onSurf:     "#DDE8CC"
    readonly property color onSurfV:    "#9DB88A"
    readonly property color errorColor: "#FFB4AB"

    // Slide-in + fade-in on appear
    NumberAnimation on opacity {
        from: 0; to: 1
        duration: 280
        easing.type: Easing.OutCubic
        running: true
    }

    transform: Translate {
        y: (1 - root.opacity) * -14
    }

    // Card shadow
    DropShadow {
        anchors.fill: panel
        source: panel
        horizontalOffset: 0
        verticalOffset: 6
        radius: 20
        samples: 32
        color: "#55000000"
        transparentBorder: true
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 20
        color: root.surface
        clip: true
    }

    Flickable {
        anchors {
            fill: parent
            margins: 14
        }
        contentHeight: panelContent.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: panelContent
            width: parent.width
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: root.onSurf
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                SmallButton {
                    Layout.fillWidth: false
                    text: root.busy ? "Scanning…" : "Scan"
                    visible: root.showScan
                    onClicked: root.scanClicked()
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.errorText
                color: root.errorColor
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                visible: text !== ""
            }
        }
    }
}
