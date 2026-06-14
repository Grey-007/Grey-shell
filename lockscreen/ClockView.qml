import QtQuick

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · ClockView
//
// Big, light-weight time + date, in the spirit of the Android lock screen
// clock. Reads from the shared Time singleton, so it costs nothing extra
// even with several of these on screen.
// ─────────────────────────────────────────────────────────────────────────
Column {
    id: root

    property real stage: 1.0

    spacing: 4
    opacity: root.stage
    y: (1 - root.stage) * 24
    scale: 0.975 + root.stage * 0.025

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Time.hourMinute
        color: Colours.surfaceForeground
        font.family: Config.clockFontFamily !== "" ? Config.clockFontFamily : Config.fontFamily
        font.pixelSize: 110
        font.weight: Font.Normal
        font.letterSpacing: 1.5
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Time.dayDate
        color: Colours.surfaceVariantForeground
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.weight: Font.Medium
        font.letterSpacing: 1.4
    }
}
