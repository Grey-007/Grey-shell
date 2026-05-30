import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string glyph: ""
    property bool active: false
    property string actionText: active ? "On" : "Connect"

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 54

    readonly property color surface: "#242C1E"
    readonly property color surfaceActive: "#2F3A24"
    readonly property color primary: "#C5E87A"
    readonly property color onSurface: "#E8F0DC"
    readonly property color onSurfaceVariant: "#A8B598"

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.active ? root.surfaceActive : root.surface
        scale: pressArea.pressed ? 0.985 : 1

        Behavior on color {
            ColorAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
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
            color: root.active ? root.primary : root.onSurfaceVariant
            font.pixelSize: 14
            font.weight: Font.Medium
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.onSurface
                font.pixelSize: 12
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: root.onSurfaceVariant
                font.pixelSize: 11
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: Math.max(56, actionLabel.implicitWidth + 20)
            height: 28
            radius: 14
            color: root.active ? root.primary : "#1E2518"

            Text {
                id: actionLabel

                anchors.centerIn: parent
                text: root.actionText
                color: root.active ? "#1A2214" : root.onSurface
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }
    }

    MouseArea {
        id: pressArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
