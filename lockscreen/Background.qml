import QtQuick
import QtQuick.Effects
import "../colors"

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · Background
//
// Your current wallpaper, heavily blurred and tinted sepia. If the
// wallpaper can't be found, a plain sepia gradient is used instead so the
// lock screen still looks intentional.
//
// The blur is rendered once onto a texture; the only thing animating is a
// cheap GPU transform (scale), so this stays smooth even on integrated
// graphics.
// ─────────────────────────────────────────────────────────────────────────
Item {
    id: root

    property real stage: 1.0
    property real breatheScale: 1.0

    readonly property real blurStrength:
        Config.backgroundBlurFloor
        + (Config.wallpaperBlur - Config.backgroundBlurFloor) * root.stage
    readonly property real transitionScale:
        Config.backgroundRestScale
        + (Config.backgroundIntroScale - Config.backgroundRestScale) * (1 - root.stage)

    Image {
        id: wallpaper
        anchors.fill: parent
        source: Config.wallpaperPath !== "" ? "file://" + Config.wallpaperPath : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        visible: false
    }

    // Fallback when there's no wallpaper (or it failed to load)
    Rectangle {
        anchors.fill: parent
        visible: wallpaper.status !== Image.Ready
        opacity: 0.55 + root.stage * 0.45
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: ThemeManager.surfaceContainerHigh }
            GradientStop { position: 1.0; color: ThemeManager.surfaceContainerLowest }
        }
    }

    MultiEffect {
        id: blurred
        anchors.fill: parent
        source: wallpaper
        visible: wallpaper.status === Image.Ready

        blurEnabled: true
        blur: root.blurStrength
        blurMax: Config.wallpaperBlurMax
        autoPaddingEnabled: false
        opacity: 0.45 + root.stage * 0.55

        // Intro / outro motion plus a very slow "breathing" zoom so the
        // background never feels frozen.
        scale: root.transitionScale * root.breatheScale
        transformOrigin: Item.Center

        Behavior on blur {
            NumberAnimation {
                duration: Config.durationExtraSlow
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

        SequentialAnimation {
            loops: Animation.Infinite
            running: true
            NumberAnimation {
                target: root
                property: "breatheScale"
                from: 1.0
                to: 1.02
                duration: 28000
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: root
                property: "breatheScale"
                from: 1.02
                to: 1.0
                duration: 28000
                easing.type: Easing.InOutSine
            }
        }
    }

    // Sepia scrim — ties the wallpaper into the rest of the palette and
    // guarantees text contrast regardless of the wallpaper's own colours.
    Rectangle {
        anchors.fill: parent
        opacity: 0.78 + root.stage * 0.22
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: ThemeManager.alpha(
                    ThemeManager.scrimTop,
                    ThemeManager.scrimOpacity * (0.72 + root.stage * 0.28)
                )
            }
            GradientStop {
                position: 1.0
                color: ThemeManager.alpha(
                    ThemeManager.scrimBottom,
                    (ThemeManager.scrimOpacity + 0.18) * (0.72 + root.stage * 0.28)
                )
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Config.durationSlow
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Config.easeEmphasizedDecel
            }
        }
    }
}
