import QtQuick
import "../colors"

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · Card
//
// The base "tile" every widget sits in. Keeping radius/colour/border and
// the entrance animation in one place is what makes the whole lock screen
// feel uniform — every widget below just fills in its own content.
//
//   Card {
//       revealDelay: 150          // stagger entrance animations
//       Layout.fillWidth: true
//       implicitHeight: Config.pillHeight
//       ... your content ...
//   }
// ─────────────────────────────────────────────────────────────────────────
Rectangle {
    id: root

    radius: Config.radiusMedium
    color: ThemeManager.surfaceContainer
    border.width: 1
    border.color: ThemeManager.outlineVariant
    antialiasing: true
    transformOrigin: Item.Center

    // Delay (ms) before this card animates in — lets a stack of widgets
    // cascade in nicely instead of popping in all at once.
    property int revealDelay: 0
    property bool revealed: false
    property real visibilityFactor: 1.0
    property real scaleFactor: 1.0

    opacity: (revealed ? 1 : 0) * visibilityFactor
    scale: (revealed ? 1 : 0.965) * scaleFactor
    y: revealed ? 0 : 18

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
    Behavior on y {
        NumberAnimation {
            duration: Config.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeEmphasizedDecel
        }
    }

    Timer {
        interval: root.revealDelay
        running: !root.revealed
        onTriggered: root.revealed = true
    }
}
