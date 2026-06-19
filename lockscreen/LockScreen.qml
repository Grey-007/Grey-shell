import QtQuick
import QtQuick.Layouts
import "../colors"

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · LockScreen
//
// The full per-monitor lock surface. Layout, top to bottom:
//   • Background        — blurred wallpaper + sepia scrim
//   • ClockView          — big time + date, upper third
//   • Avatar + greeting  — "Good evening, you"
//   • ReadingCard        — Now Reading widget
//   • MediaCard          — MPRIS now playing (hides if nothing's playing)
//   • Battery / Weather  — side by side pills (hide if unavailable)
//   • PasswordField      — unlock input
// ─────────────────────────────────────────────────────────────────────────
Item {
    id: root

    property real stage: 0.0
    readonly property real stackWidth: Math.min(Config.widgetWidth, parent ? parent.width - 72 : Config.widgetWidth)
    readonly property real passwordWidth: Math.min(Config.passwordWidth, stackWidth)

    Behavior on stage {
        NumberAnimation {
            duration: Config.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeEmphasizedDecel
        }
    }

    Component.onCompleted: root.stage = 1.0

    Background {
        stage: root.stage
        anchors.fill: parent
    }

    ClockView {
        stage: root.stage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(56, parent.height * 0.10)
    }

    ColumnLayout {
        id: stack
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: passwordFieldWrap.top
        anchors.bottomMargin: Math.max(26, parent.height * 0.035)
        width: root.stackWidth
        spacing: Config.spacingMedium
        opacity: root.stage
        scale: 0.97 + root.stage * 0.03
        y: (1 - root.stage) * 18

        // ── Avatar + greeting ───────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: Config.spacingMedium
            spacing: Config.spacingMedium

            AvatarRing {}

            ColumnLayout {
                spacing: 2
                Text {
                    text: Time.greeting
                    color: ThemeManager.surfaceVariantFg
                    font.family: Config.fontFamily
                    font.pixelSize: 13
                }
                Text {
                    text: Config.userName
                    color: ThemeManager.surfaceFg
                    font.family: Config.fontFamily
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                }
            }

            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Config.spacingMedium

            MediaCard {
                Layout.preferredWidth: shown ? Config.mediaCardWidth : 0
                Layout.maximumWidth: Config.mediaCardWidth
                Layout.alignment: Qt.AlignTop
                revealDelay: 110
            }

            ReadingCard {
                Layout.fillWidth: true
                Layout.preferredWidth: Config.readingCardWidth
                Layout.leftMargin: Config.spacingSmall
                Layout.topMargin: Config.spacingSmall
                revealDelay: 60
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Config.spacingMedium

            BatteryPill {
                Layout.fillWidth: true
                revealDelay: 220
            }
            WeatherPill {
                Layout.fillWidth: true
                revealDelay: 260
            }
        }
    }

    Item {
        id: passwordFieldWrap
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.max(34, parent.height * 0.05)
        width: root.passwordWidth
        height: Config.pillHeight
        opacity: root.stage
        y: (1 - root.stage) * 26
        scale: 0.965 + root.stage * 0.035

        PasswordField {
            id: passwordField
            anchors.fill: parent
            revealDelay: 340
        }
    }

    Connections {
        target: Auth
        function onUnlocked() {
            root.stage = 0.0;
        }
    }
}
