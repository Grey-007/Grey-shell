import QtQuick
import QtQuick.Controls
import "../colors"

// SepiaShell – Android 17-style horizontal slider.
// Track is a tall rounded pill; fill grows leftward from the thumb.
// Thumb grows on press. Vertical track height pulses on interaction.
Item {
    id: root

    // Public API
    property string icon: ""
    property real   externalValue: 0
    property alias  value:   control.value
    property alias  from:    control.from
    property alias  to:      control.to
    property alias  enabled: control.enabled

    signal moved(real value)

    // ── SepiaShell colour tokens ─────────────────────────────────────
                    
    // Track height: taller when pressed (Android 17 expanding pill)
    readonly property int trackHeight: control.pressed ? 22 : 14

    implicitHeight: 52

    // Sync external → slider only when the user is not dragging
    onExternalValueChanged: {
        if (!control.pressed)
            control.value = externalValue
    }

    // ── Left icon ───────────────────────────────────────────────────
    Text {
        id: iconLabel
        anchors {
            left: parent.left
            leftMargin: 2
            verticalCenter: parent.verticalCenter
        }
        text: root.icon
        color: root.ThemeManager.accent
        font.pixelSize: 18
        opacity: root.enabled ? 1.0 : 0.35

        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    // ── Right value label ────────────────────────────────────────────
    Text {
        id: valueLabel
        anchors {
            right: parent.right
            rightMargin: 2
            verticalCenter: parent.verticalCenter
        }
        text: Math.round(control.value) + "%"
        color: root.ThemeManager.fgMid
        font.pixelSize: 11
        font.weight: Font.Medium
        opacity: root.enabled ? 0.9 : 0.3

        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    // ── Slider control ───────────────────────────────────────────────
    Slider {
        id: control

        anchors {
            left:  iconLabel.right
            right: valueLabel.left
            leftMargin:  10
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: parent.height

        from: 0; to: 100
        stepSize: 1
        live: true
        padding: 0
        topPadding: 0
        bottomPadding: 0

        Component.onCompleted: value = root.externalValue

        onMoved: root.moved(value)
        onPressedChanged: { if (!pressed) root.moved(value) }

        // ── Track (pill background + coloured fill) ──────────────────
        background: Item {
            x: control.leftPadding
            y: (control.height - height) / 2
            width:  control.availableWidth
            height: root.trackHeight

            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            // Groove
            Rectangle {
                anchors.fill: parent
                radius: 0
                color: root.ThemeManager.surfaceTop
            }

            // Filled portion (left of thumb)
            Rectangle {
                width: Math.max(height, control.visualPosition * parent.width)
                height: parent.height
                radius: 0
                color: root.ThemeManager.accent

                Behavior on width {
                    enabled: !control.pressed
                    NumberAnimation { duration: 80; easing.type: Easing.OutQuart }
                }
            }
        }

        // ── Thumb ────────────────────────────────────────────────────
        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: (control.height - height) / 2
            width:  control.pressed ? 28 : 22
            height: control.pressed ? root.trackHeight : root.trackHeight
            radius: 0
            color:  root.ThemeManager.fg
            opacity: root.enabled ? 1.0 : 0.3

            // Glow on press
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 6
                height: parent.height + 6
                radius: 0
                color: ThemeManager.alpha(ThemeManager.accent, 0.19)
                visible: control.pressed
            }

            Behavior on width  { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }
    }
}
