import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../colors"

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · BatteryPill
//
// Simple battery readout. The battery glyph is drawn with plain
// rectangles (no icon font required) and fills proportionally to charge.
// Hides itself on desktops with no battery.
// ─────────────────────────────────────────────────────────────────────────
Card {
    id: root

    implicitHeight: Config.pillHeight
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery !== null && battery.isLaptopBattery
    readonly property bool shown: hasBattery
    readonly property bool charging: hasBattery
        && (battery.state === UPowerDeviceState.Charging
            || battery.state === UPowerDeviceState.PendingCharge)

    visible: shown || opacity > 0.01
    enabled: shown
    visibilityFactor: shown ? 1 : 0
    scaleFactor: shown ? 1 : 0.965
    height: shown ? implicitHeight : 0
    Layout.preferredWidth: shown ? implicitWidth : 0

    RowLayout {
        anchors.fill: parent
        anchors.margins: Config.spacingMedium
        spacing: Config.spacingMedium
        // Hand-drawn battery glyph
        Item {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 16

            Rectangle {
                id: shell
                anchors.fill: parent
                radius: 3
                color: "transparent"
                border.width: 2
                border.color: ThemeManager.surfaceVariantFg
            }
            // terminal nub
            Rectangle {
                anchors.left: shell.right
                anchors.verticalCenter: shell.verticalCenter
                width: 3
                height: 6
                radius: 1
                color: ThemeManager.surfaceVariantFg
            }
            // fill level
            Rectangle {
                anchors.left: shell.left
                anchors.top: shell.top
                anchors.bottom: shell.bottom
                anchors.margins: 3
                width: Math.max(2, (shell.width - 6) * (root.battery ? root.battery.percentage : 0))
                radius: 1.5
                color: root.charging ? ThemeManager.success : ThemeManager.primary

                Behavior on width {
                    NumberAnimation { duration: Config.durationMedium; easing.type: Easing.OutCubic }
                }
            }
        }

        ColumnLayout {
            spacing: 0
            Text {
                text: root.battery ? Math.round(root.battery.percentage * 100) + "%" : ""
                color: ThemeManager.surfaceFg
                font.family: Config.fontFamily
                font.pixelSize: 15
                font.weight: Font.Medium
            }
            Text {
                text: root.charging ? "Charging" : "Battery"
                color: ThemeManager.surfaceVariantFg
                font.family: Config.fontFamily
                font.pixelSize: 11
            }
        }

        Item { Layout.fillWidth: true }
    }

    Behavior on height {
        NumberAnimation {
            duration: Config.durationMedium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeEmphasizedDecel
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Config.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeEmphasizedDecel
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Config.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeExpressive
        }
    }
}
