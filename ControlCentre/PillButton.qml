import QtQuick
import QtQuick.Layouts

// Material You – Quick Settings toggle tile (2-column grid)
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string glyph: ""
    property bool active: false
    property bool expanded: false

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 64

    // Material You dark surface tokens
    readonly property color bgOff:       "#2B2F26"   // surfaceContainerHigh
    readonly property color bgOn:        "#A8D368"   // primary
    readonly property color bgExpanded:  "#323628"   // surfaceContainerHighest
    readonly property color iconBgOff:   "#1E2219"
    readonly property color iconBgOn:    "#4A6020"   // primaryContainer darker
    readonly property color iconColorOff:"#9DB88A"   // onSurfaceVariant
    readonly property color iconColorOn: "#A8D368"   // primary
    readonly property color titleOff:    "#DDE8CC"   // onSurface
    readonly property color titleOn:     "#1C2510"   // onPrimary
    readonly property color subtitleOff: "#8EA07E"   // onSurfaceVariant
    readonly property color subtitleOn:  "#283318"

    // Ripple state
    property real pressProgress: 0

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 18

        color: root.active ? root.bgOn
             : root.expanded ? root.bgExpanded
             : root.bgOff

        scale: pressArea.containsPress ? 0.96 : 1.0

        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }
    }

    // Ripple overlay
    Rectangle {
        anchors.fill: parent
        radius: 18
        color: root.active ? "#20000000" : "#20FFFFFF"
        opacity: pressArea.containsPress ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        spacing: 10
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
            topMargin: 10
            bottomMargin: 10
        }

        // Icon circle
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 36
            height: 36
            radius: 18
            color: root.active ? root.iconBgOn : root.iconBgOff

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: root.glyph
                color: root.active ? root.iconColorOn : root.iconColorOff
                font.pixelSize: 16
                font.weight: Font.Medium

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.active ? root.titleOn : root.titleOff
                font.pixelSize: 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: root.active ? root.subtitleOn : root.subtitleOff
                font.pixelSize: 11
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
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
