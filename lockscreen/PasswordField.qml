import QtQuick
import QtQuick.Layouts

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · PasswordField
//
// The unlock control. Pill-shaped to match Material 3 Expressive text
// fields. Typed characters are shown as dots; on failure the whole field
// shakes and briefly tints with the error colour, then resets.
// ─────────────────────────────────────────────────────────────────────────
Card {
    id: root

    readonly property bool engaged: input.activeFocus || input.text.length > 0 || Auth.unlocking
    readonly property int dotCount: Math.min(input.text.length, 12)
    readonly property real dotsShift: dotCount > 0 ? Math.min(dotCount * 2.6, 20) : 0
    readonly property real caretShift: dotCount > 0 ? Math.min(dotCount * 1.35, 10) : 0
    property bool failed: false

    radius: Config.radiusPill
    color: failed ? Colours.alpha(Colours.errorContainer, 0.35)
                   : engaged ? Colours.surfaceContainerHighest
                             : Colours.surfaceContainerHigh
    border.color: failed ? Colours.error
                         : engaged ? Colours.primary
                                   : Colours.outlineVariant
    border.width: engaged ? 2 : 1

    Behavior on color {
        ColorAnimation { duration: Config.durationFast }
    }
    Behavior on border.color {
        ColorAnimation { duration: Config.durationFast }
    }
    Behavior on border.width {
        NumberAnimation { duration: Config.durationFast; easing.type: Easing.OutCubic }
    }

    // Small horizontal shake, independent of layout anchors.
    property real shakeOffset: 0
    transform: [ Translate { x: root.shakeOffset } ]

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Config.spacingLarge
        anchors.rightMargin: Config.spacingSmall
        spacing: Config.spacingMedium

        // ── Text input + placeholder + dots ─────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextInput {
                id: input
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                color: "transparent" // we render dots ourselves
                font.pixelSize: 18
                echoMode: TextInput.Password
                passwordCharacter: "•"
                enabled: !Auth.unlocking
                focus: true
                selectByMouse: false
                cursorVisible: false

                Component.onCompleted: forceActiveFocus()

                onAccepted: root.submit()
                onTextChanged: root.failed = false
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: input.text.length === 0
                text: Auth.unlocking ? "Checking…" : "Enter password"
                color: Colours.surfaceVariantForeground
                font.family: Config.fontFamily
                font.pixelSize: 16
                x: root.engaged ? 4 : 0

                Behavior on x {
                    NumberAnimation {
                        duration: Config.durationFast
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Config.easeEmphasizedDecel
                    }
                }
            }

            // Trailing caret that lags slightly behind the dot cluster.
            Rectangle {
                id: caret
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: root.engaged ? 24 : 18
                radius: 1
                color: root.failed ? Colours.error : Colours.primary
                opacity: Auth.unlocking ? 0.45 : root.engaged ? 0.9 : 0.65
                visible: input.text.length > 0 || root.engaged
                x: root.caretShift

                Behavior on x {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Config.easeEmphasizedDecel
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: Config.durationFast
                        easing.type: Easing.OutCubic
                    }
                }

                SequentialAnimation on opacity {
                    running: root.engaged && input.text.length === 0 && !Auth.unlocking
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.35; to: 0.95; duration: 650; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.95; to: 0.35; duration: 650; easing.type: Easing.InOutSine }
                }
            }

            // Dot indicators standing in for the hidden password.
            Row {
                id: dotsRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                x: root.dotsShift

                Behavior on x {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Config.easeExpressive
                    }
                }

                Repeater {
                    model: root.dotCount
                    Rectangle {
                        id: dot
                        width: 9
                        height: 9
                        radius: 5
                        color: Colours.surfaceForeground
                        opacity: 0
                        scale: 0.2
                        y: 6

                        Component.onCompleted: dotReveal.start()

                        ParallelAnimation {
                            id: dotReveal
                            NumberAnimation {
                                target: dot
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 120
                            }
                            NumberAnimation {
                                target: dot
                                property: "scale"
                                from: 0.2
                                to: 1
                                duration: 180
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Config.easeExpressive
                            }
                            NumberAnimation {
                                target: dot
                                property: "y"
                                from: 6
                                to: 0
                                duration: 180
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Config.easeEmphasizedDecel
                            }
                        }
                    }
                }
            }
        }

        // ── Submit button (Material FAB-style) ──────────────────────
        Rectangle {
            id: submitBtn
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: 22
            color: input.text.length > 0 ? Colours.primary : Colours.surfaceContainerHighest

            scale: mouse.pressed ? 0.9 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: Config.durationFast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Config.easeExpressive
                }
            }
            Behavior on color {
                ColorAnimation { duration: Config.durationFast }
            }

            Text {
                anchors.centerIn: parent
                text: "→"
                font.pixelSize: 20
                color: input.text.length > 0 ? Colours.primaryForeground : Colours.surfaceVariantForeground
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                enabled: !Auth.unlocking
                onClicked: root.submit()
            }
        }
    }

    function submit() {
        if (input.text.length === 0)
            return;
        Auth.authenticate(input.text);
    }

    Connections {
        target: Auth
        function onFailed() {
            root.failed = true;
            input.text = "";
            input.forceActiveFocus();
            shake.start();
        }
    }

    SequentialAnimation {
        id: shake
        NumberAnimation { target: root; property: "shakeOffset"; to: -10; duration: 45 }
        NumberAnimation { target: root; property: "shakeOffset"; to: 10;  duration: 45 }
        NumberAnimation { target: root; property: "shakeOffset"; to: -6;  duration: 45 }
        NumberAnimation { target: root; property: "shakeOffset"; to: 6;   duration: 45 }
        NumberAnimation { target: root; property: "shakeOffset"; to: 0;   duration: 45 }
    }
}
