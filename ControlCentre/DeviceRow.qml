import QtQuick
import QtQuick.Layouts

// Material You – device/network row inside expanded menu panels
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string glyph: ""
    property bool active: false
    property string actionText: active ? "Active" : "Connect"

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 56

    readonly property color bgOff:    "#252921"
    readonly property color bgOn:     "#2E3A22"
    readonly property color primary:  "#A8D368"
    readonly property color onSurf:   "#DDE8CC"
    readonly property color onSurfV:  "#9DB88A"
    readonly property color chipBgOn: "#A8D368"
    readonly property color chipBgOff:"#1E2219"

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.active ? root.bgOn : root.bgOff
        scale: pressArea.containsPress ? 0.985 : 1.0

        Behavior on color {
            ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        spacing: 10
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 10
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.glyph
            color: root.active ? root.primary : root.onSurfV
            font.pixelSize: 15
            font.weight: Font.Medium

            Behavior on color {
                ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.onSurf
                font.pixelSize: 12
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: root.onSurfV
                font.pixelSize: 11
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        // Action chip
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: Math.max(52, actionLabel.implicitWidth + 20)
            height: 28
            radius: 14
            color: root.active ? root.chipBgOn : root.chipBgOff

            Behavior on color {
                ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            Text {
                id: actionLabel
                anchors.centerIn: parent
                text: root.actionText
                color: root.active ? "#1A2510" : root.onSurf
                font.pixelSize: 11
                font.weight: Font.Medium

                Behavior on color {
                    ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
