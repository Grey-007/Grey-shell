import QtQuick
import QtQuick.Shapes

Item {
    id: root

    width: valueVisible ? 48 : 36
    height: 36
    implicitWidth: width
    implicitHeight: height

    property real value: 0
    property real iconXOffset: 0
    property string icon: ""
    property string valueText: Math.round(value).toString()
    property bool valueVisible: hoverArea.containsMouse
    property bool active: true
    property bool dimmed: false
    property color ink: "#b7ff3c"
    property color paper: "#101a0c"
    property color track: Qt.rgba(0.72, 1, 0.24, 0.18)
    property string iconFontFamily: "Noto Sans Symbols 2"
    property int iconSize: 13
    property int valueSize: 10
    property int acceptedButtons: Qt.LeftButton
    property bool acceptsWheel: false
    readonly property bool containsMouse: hoverArea.containsMouse
    readonly property bool pressed: hoverArea.pressed

    property real animatedValue: Math.max(0, Math.min(100, value))
    property real pulse: 0
    property real startAngle: hoverArea.containsMouse ? -54 : -90

    signal clicked(var mouse)
    signal wheelMoved(int delta)

    onValueChanged: pulseAnimation.restart()

    Behavior on width {
        NumberAnimation {
            duration: 240
            easing.type: Easing.OutCubic
        }
    }

    Behavior on animatedValue {
        NumberAnimation {
            duration: 420
            easing.type: Easing.OutCubic
        }
    }

    Behavior on startAngle {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: pulseAnimation

        NumberAnimation {
            target: root
            property: "pulse"
            to: 1
            duration: 120
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: root
            property: "pulse"
            to: 0
            duration: 520
            easing.type: Easing.OutCubic
        }
    }

    Item {
        id: dial

        anchors.centerIn: parent
        width: 31
        height: 31
        scale: hoverArea.pressed ? 0.92 : hoverArea.containsMouse ? 1.08 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 28 + root.pulse * 9
            height: width
            radius: width / 2
            color: root.ink
            opacity: root.pulse * 0.08
            antialiasing: true
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.active ? root.track : Qt.rgba(0.72, 1, 0.24, 0.08)
                strokeWidth: 3
                strokeStyle: ShapePath.SolidLine
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: dial.width / 2
                    centerY: dial.height / 2
                    radiusX: 12.5
                    radiusY: 12.5
                    startAngle: -90
                    sweepAngle: 360
                }
            }

            ShapePath {
                fillColor: "transparent"
                strokeColor: Qt.rgba(0.72, 1, 0.24, root.active ? (root.dimmed ? 0.34 : 1) : 0)
                strokeWidth: 3.4
                strokeStyle: ShapePath.SolidLine
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: dial.width / 2
                    centerY: dial.height / 2
                    radiusX: 12.5
                    radiusY: 12.5
                    startAngle: root.startAngle
                    sweepAngle: Math.max(0, Math.min(359.5, root.animatedValue * 3.6))
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 21
            height: 21
            radius: width / 2
            color: root.paper
            border.color: root.ink
            border.width: 1
            opacity: root.active ? 1 : 0.45
            antialiasing: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: root.iconXOffset
            width: parent.width
            height: parent.height
            text: root.icon
            color: root.ink
            opacity: root.valueVisible ? 0 : (root.active ? (root.dimmed ? 0.55 : 1) : 0.35)
            font.family: root.iconFontFamily
            font.pixelSize: root.iconSize
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            Behavior on opacity {
                NumberAnimation {
                    duration: 170
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            anchors.centerIn: parent
            width: 23
            height: 21
            text: root.valueText
            color: root.ink
            opacity: root.valueVisible ? 1 : 0
            font.pixelSize: root.valueSize
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            Behavior on opacity {
                NumberAnimation {
                    duration: 170
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: root.acceptedButtons
        cursorShape: root.acceptedButtons === Qt.NoButton ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: function(mouse) {
            root.clicked(mouse)
        }
        onWheel: function(wheel) {
            if (root.acceptsWheel) {
                root.wheelMoved(wheel.angleDelta.y)
                wheel.accepted = true
            } else {
                wheel.accepted = false
            }
        }
    }
}
