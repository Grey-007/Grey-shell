import QtQuick
import QtQuick.Shapes

// MetricRing.qml — sepia theme ring widget
Item {
    id: root

    width:  valueVisible ? 48 : 36
    height: 36
    implicitWidth:  width
    implicitHeight: height

    property real   value:        0
    property real   iconXOffset:  0
    property string icon:         ""
    property string valueText:    Math.round(value).toString()
    property bool   valueVisible: hoverArea.containsMouse
    property bool   active:       true
    property bool   dimmed:       false

    // Sepia ink/paper
    property color  ink:   "#d4a45a"
    property color  paper: "#2e2118"
    property color  track: Qt.rgba(0.83, 0.64, 0.35, 0.18)

    property string iconFontFamily: "Noto Sans Symbols 2"
    property int    iconSize:   13
    property int    valueSize:  10
    property int    acceptedButtons: Qt.LeftButton
    property bool   acceptsWheel:   false

    readonly property bool containsMouse: hoverArea.containsMouse
    readonly property bool pressed:       hoverArea.pressed

    property real animatedValue: Math.max(0, Math.min(100, value))
    property real pulse:         0
    property real startAngle:    hoverArea.containsMouse ? -54 : -90

    signal clicked(var mouse)
    signal wheelMoved(int delta)

    onValueChanged: pulseAnimation.restart()

    Behavior on width {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    Behavior on animatedValue {
        NumberAnimation { duration: 380; easing.type: Easing.OutCubic }
    }
    Behavior on startAngle {
        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: pulseAnimation
        NumberAnimation {
            target: root; property: "pulse"
            to: 1; duration: 110; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root; property: "pulse"
            to: 0; duration: 480; easing.type: Easing.OutCubic
        }
    }

    Item {
        id: dial
        anchors.centerIn: parent
        width:  31
        height: 31
        scale: hoverArea.pressed        ? 0.91
             : hoverArea.containsMouse  ? 1.07
             : 1

        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        // Pulse glow ring
        Rectangle {
            anchors.centerIn: parent
            width:   28 + root.pulse * 9
            height:  width
            radius:  width / 2
            color:   root.ink
            opacity: root.pulse * 0.10
            antialiasing: true
        }

        // Track + value arc
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            // background track
            ShapePath {
                fillColor:   "transparent"
                strokeColor: root.active
                    ? root.track
                    : Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.08)
                strokeWidth: 3
                capStyle:    ShapePath.RoundCap

                PathAngleArc {
                    centerX: dial.width / 2; centerY: dial.height / 2
                    radiusX: 12.5; radiusY: 12.5
                    startAngle: -90; sweepAngle: 360
                }
            }

            // value arc
            ShapePath {
                fillColor:   "transparent"
                strokeColor: Qt.rgba(
                    root.ink.r, root.ink.g, root.ink.b,
                    root.active ? (root.dimmed ? 0.32 : 1) : 0)
                strokeWidth: 3.2
                capStyle:    ShapePath.RoundCap

                PathAngleArc {
                    centerX: dial.width / 2; centerY: dial.height / 2
                    radiusX: 12.5; radiusY: 12.5
                    startAngle:  root.startAngle
                    sweepAngle:  Math.max(0, Math.min(359.5, root.animatedValue * 3.6))
                }
            }
        }

        // Inner face
        Rectangle {
            anchors.centerIn: parent
            width:   21; height: 21
            radius:  width / 2
            color:   root.paper
            border.color: root.ink
            border.width: 1
            opacity: root.active ? 1 : 0.40
            antialiasing: true
        }

        // Icon
        Text {
            anchors.horizontalCenter:       parent.horizontalCenter
            anchors.verticalCenter:         parent.verticalCenter
            anchors.horizontalCenterOffset: root.iconXOffset
            width:  parent.width; height: parent.height
            text:   root.icon
            color:  root.ink
            opacity: root.valueVisible ? 0
                   : root.active ? (root.dimmed ? 0.50 : 1) : 0.30
            font.family:    root.iconFontFamily
            font.pixelSize: root.iconSize
            renderType:       Text.NativeRendering
            verticalAlignment:   Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }

        // Value text
        Text {
            anchors.centerIn: parent
            width:  23; height: 21
            text:   root.valueText
            color:  root.ink
            opacity: root.valueVisible ? 1 : 0
            font.pixelSize:  root.valueSize
            font.weight:     Font.DemiBold
            renderType:      Text.NativeRendering
            verticalAlignment:   Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill:     parent
        hoverEnabled:     true
        acceptedButtons:  root.acceptedButtons
        cursorShape: root.acceptedButtons === Qt.NoButton
            ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: function(mouse) { root.clicked(mouse) }
        onWheel:   function(wheel) {
            if (root.acceptsWheel) {
                root.wheelMoved(wheel.angleDelta.y)
                wheel.accepted = true
            } else {
                wheel.accepted = false
            }
        }
    }
}
