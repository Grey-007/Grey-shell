import QtQuick
import QtQuick.Controls

// Material You style horizontal slider
// icon shown on the left, percentage on the right
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

    // Sync external value → slider when not being dragged
    onExternalValueChanged: {
        if (!control.pressed)
            control.value = externalValue;
    }

    // Material You – dark surface token palette
    readonly property color trackInactive: "#3A3D32"      // surfaceContainerHighest
    readonly property color trackActive:   "#A8D368"      // primary-ish tint
    readonly property color handleColor:   "#D4ED8A"      // on-primary-container
    readonly property color labelColor:    "#CAD5B5"      // onSurfaceVariant

    implicitHeight: 56

    // Icon
    Text {
        id: iconLabel
        anchors {
            left: parent.left
            leftMargin: 2
            verticalCenter: parent.verticalCenter
        }
        text: root.icon
        color: root.labelColor
        font.pixelSize: 17
        opacity: root.enabled ? 1.0 : 0.4

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // Percentage label
    Text {
        id: valueLabel
        anchors {
            right: parent.right
            rightMargin: 2
            verticalCenter: parent.verticalCenter
        }
        text: root.displayValue + "%"
        color: root.labelColor
        font.pixelSize: 11
        font.weight: Font.Medium
        opacity: root.enabled ? 0.9 : 0.3

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    Slider {
        id: control

        anchors {
            left: iconLabel.right
            right: valueLabel.left
            leftMargin: 8
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        height: parent.height
        from: 0
        to: 100
        stepSize: 1
        live: true
        padding: 0
        topPadding: 14
        bottomPadding: 14

        Component.onCompleted: value = root.externalValue

        onMoved: root.moved(value)

        onPressedChanged: {
            if (!pressed)
                root.moved(value);
        }

        background: Item {
            x: control.leftPadding
            y: control.topPadding + (control.availableHeight - trackH) / 2
            width: control.availableWidth
            height: trackH

            readonly property int trackH: control.pressed ? 6 : 4

            // Inactive track
            Rectangle {
                anchors.fill: parent
                radius: parent.height / 2
                color: root.trackInactive

                Behavior on color {
                    ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
            }

            // Active fill
            Rectangle {
                width: Math.max(parent.height, control.visualPosition * parent.width)
                height: parent.height
                radius: parent.height / 2
                color: root.trackActive

                Behavior on width {
                    enabled: !control.pressed
                    NumberAnimation { duration: 100; easing.type: Easing.OutQuart }
                }

                Behavior on color {
                    ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
            }

            Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }

        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + (control.availableHeight - height) / 2
            width: control.pressed ? 24 : 20
            height: width
            radius: width / 2
            color: root.handleColor
            opacity: root.enabled ? 1 : 0.35

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.4
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }
    }
}
