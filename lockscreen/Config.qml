pragma Singleton
import QtQuick
import Quickshell

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · configuration
//
// Everything you'd want to tweak that ISN'T a colour lives here:
// user/avatar/wallpaper paths, fonts, sizing, animation curves and the
// "Now Reading" widget content. Colours live in Colours.qml.
// ─────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    // ── User ──────────────────────────────────────────────────────────
    readonly property string homeDir:  Quickshell.env("HOME") || "/home/user"
    readonly property string userName: Quickshell.env("USER") || "user"

    // Circular avatar image. Falls back to an initial-letter avatar if this
    // file doesn't exist or fails to load. Common defaults: ~/.face or a
    // path to any square-ish image.
    property string avatarPath: homeDir + "/.face"

    // ── Background ───────────────────────────────────────────────────
    // Path to your current Hyprland wallpaper. If it can't be loaded, a
    // sepia gradient is used instead — the lock screen still looks right.
    property string wallpaperPath: homeDir + "/Pictures/Wallpapers/current.jpg"
    property real   wallpaperBlur: 1.0      // 0.0 - 1.0
    property int    wallpaperBlurMax: 72    // px

    // ── Typography ───────────────────────────────────────────────────
    // "Inter" gives the cleanest Material 3 look. Falls back to the
    // system sans-serif if not installed.
    property string fontFamily: "Inter"
    // Used for the lock clock to give it a more editorial, display feel.
    property string clockFontFamily: "Noto Serif Display"
    // Used for the "Now Reading" quote — a small serif touch for the
    // reading theme.
    property string serifFontFamily: "Georgia"

    // ── Shape & spacing (Material 3 Expressive — generous radii) ───────
    property int radiusLarge:  28
    property int radiusMedium: 20
    property int radiusSmall:  14
    property int radiusPill:   999

    property int spacingSmall:  8
    property int spacingMedium: 16
    property int spacingLarge:  28

    property int widgetWidth: 600
    property int readingCardWidth: 360
    property int mediaCardWidth: 220
    property int passwordWidth: 380
    property int pillHeight:  64

    // ── Motion ───────────────────────────────────────────────────────
    // Material 3 "emphasized" easing curves, expressed as bezierCurve
    // arrays for Easing.BezierSpline.
    readonly property var easeEmphasizedDecel: [0.05, 0.7, 0.1, 1.0]
    readonly property var easeEmphasizedAccel: [0.3, 0.0, 0.8, 0.15]
    // Slight "expressive" overshoot for entrances/presses.
    readonly property var easeExpressive: [0.34, 1.56, 0.64, 1.0]

    property int durationFast:   150
    property int durationMedium: 320
    property int durationSlow:   600
    property int durationExtraSlow: 900
    property int unlockExitDuration: 260

    property real backgroundIntroScale: 1.07
    property real backgroundRestScale: 1.02
    property real backgroundBlurFloor: 0.42

    // ── Weather ─────────────────────────────────────────────────────
    // Leave empty to auto-detect location by IP (wttr.in default).
    property string weatherLocation: ""
    property int weatherIntervalMin: 30

    // ── "Now Reading" widget ───────────────────────────────────────────
    property string readingTitle:    "Atomic Habits"
    property string readingAuthor:   "James Clear"
    property real   readingProgress: 0.64
    property string readingQuote:
        "You do not rise to the level of your goals. You fall to the level of your systems."
}
