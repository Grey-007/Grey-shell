import QtQuick
import QtQuick.Layouts
import "../colors"

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · ReadingCard
//
// The signature widget for "reader-shell" — shows the book you're
// currently reading, your progress, and a small quote in a serif font.
// All content is configured in Config.qml (readingTitle, readingAuthor,
// readingProgress, readingQuote).
// ─────────────────────────────────────────────────────────────────────────
Card {
    id: root

    implicitHeight: content.implicitHeight + Config.spacingMedium * 2

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Config.spacingMedium
        spacing: Config.spacingMedium

        // Book "spine" accent
        Rectangle {
            Layout.preferredWidth: 5
            Layout.fillHeight: true
            radius: 3
            color: ThemeManager.tertiary
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Config.spacingSmall

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "Now reading"
                    color: ThemeManager.tertiary
                    font.family: Config.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.5
                    Layout.fillWidth: true
                }
                Text {
                    text: Math.round(Config.readingProgress * 100) + "%"
                    color: ThemeManager.surfaceVariantFg
                    font.family: Config.fontFamily
                    font.pixelSize: 11
                }
            }

            Text {
                Layout.fillWidth: true
                text: Config.readingTitle
                color: ThemeManager.surfaceFg
                font.family: Config.fontFamily
                font.pixelSize: 17
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: Config.readingAuthor
                color: ThemeManager.surfaceVariantFg
                font.family: Config.fontFamily
                font.pixelSize: 13
            }

            // Progress bar
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 2
                height: 4
                radius: 2
                color: ThemeManager.surfaceContainerHighest

                Rectangle {
                    height: parent.height
                    radius: 2
                    color: ThemeManager.tertiary
                    width: parent.width * Config.readingProgress

                    Behavior on width {
                        NumberAnimation { duration: Config.durationSlow; easing.type: Easing.OutCubic }
                    }
                }
            }

            // Quote, serif italic — the "reader" touch
            Text {
                Layout.fillWidth: true
                Layout.topMargin: 4
                text: "“" + Config.readingQuote + "”"
                color: ThemeManager.surfaceVariantFg
                font.family: Config.serifFontFamily
                font.italic: true
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                visible: Config.readingQuote !== ""
            }
        }
    }
}
