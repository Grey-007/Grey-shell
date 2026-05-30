import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string icon: ""
    property int displayValue: Math.round(control.value)
    property real externalValue: 0
    property alias value: control.value
    property alias from: control.from
    property alias to: control.to
    property alias enabled: control.enabled

    signal moved(real value)

    onExternalValueChanged: {
        if (!control.pressed)
            control.value = externalValue;
    }

    readonly property color trackColor: "#2A3124"
    readonly property color activeColor: "#C5E87A"
    readonly property color handleColor: "#E8F5D6"
    readonly property color labelColor: "#DDE6CF"

    implicitHeight: 52

    Slider {
        id: control

        anchors.fill: parent
        from: 0
        to: 100
        stepSize: 1
        live: true
        padding: 0
        topPadding: 10
        bottomPadding: 10

        Component.onCompleted: value = root.externalValue

        onMoved: root.moved(value)

        onPressedChanged: {
            if (!pressed)
                root.moved(value);
        }

        background: Item {
            x: control.leftPadding
            y: control.topPadding + (control.availableHeight - 6) / 2
            width: control.availableWidth
            height: 6

            Rectangle {
                anchors.fill: parent
                radius: 3
                color: root.trackColor
            }

            Rectangle {
                width: Math.max(parent.height, control.visualPosition * parent.width)
                height: parent.height
                radius: 3
                color: root.activeColor

                Behavior on width {
                    enabled: !control.pressed
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + (control.availableHeight - height) / 2
            width: 20
            height: 20
            radius: 10
            color: root.handleColor
            opacity: control.enabled ? 1 : 0.45
            scale: control.pressed ? 1.12 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Text {
        anchors {
            left: parent.left
            leftMargin: 4
            verticalCenter: parent.verticalCenter
        }
        text: root.icon
        color: root.labelColor
        font.pixelSize: 16
    }

    Text {
        anchors {
            right: parent.right
            rightMargin: 4
            verticalCenter: parent.verticalCenter
        }
        text: root.displayValue + "%"
        color: root.labelColor
        font.pixelSize: 12
        font.weight: Font.Medium
        opacity: 0.88
    }
}
