import "."
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string title: ""
    property bool busy: false
    property bool showScan: true
    property string errorText: ""
    default property alias menuData: panelContent.data

    signal scanClicked()

    implicitHeight: Math.min(panelContent.implicitHeight + 28, 300)
    opacity: 0

    readonly property color surface: "#1E2518"
    readonly property color onSurface: "#E8F0DC"
    readonly property color onSurfaceVariant: "#A8B598"
    readonly property color errorColor: "#FFB4AB"

    NumberAnimation on opacity {
        from: 0
        to: 1
        duration: 260
        easing.type: Easing.OutCubic
        running: true
    }

    transform: Translate {
        y: (1 - root.opacity) * -12
    }

    DropShadow {
        anchors.fill: panel
        horizontalOffset: 0
        verticalOffset: 6
        radius: 20
        samples: 32
        color: "#00000055"
        source: panel
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
                    color: root.onSurface
                    font.pixelSize: 14
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
