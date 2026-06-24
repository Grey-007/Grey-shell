import QtQuick
import QtQuick.Effects
import "../colors"

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · AvatarRing
//
// Circular profile picture (masked via MultiEffect, no extra Qt modules
// needed) with a sepia accent ring. Falls back to a tonal circle with the
// user's initial if the image can't be loaded.
// ─────────────────────────────────────────────────────────────────────────
Item {
    id: root

    implicitWidth: 84
    implicitHeight: 84

    property string source: Config.avatarPath
    property string initial: Config.userName.length > 0
        ? Config.userName.charAt(0).toUpperCase()
        : "?"

    // Circular mask shape used by MultiEffect
    Rectangle {
        id: maskShape
        anchors.fill: parent
        radius: width / 2
        visible: false
        layer.enabled: true
    }

    Image {
        id: avatarImg
        anchors.fill: parent
        source: root.source !== "" ? "file://" + root.source : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: avatarImg
        maskEnabled: true
        maskSource: maskShape
        visible: avatarImg.status === Image.Ready
    }

    // Fallback: tonal circle with initial letter
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: ThemeManager.primaryContainer
        visible: avatarImg.status !== Image.Ready

        Text {
            anchors.centerIn: parent
            text: root.initial
            color: ThemeManager.primaryContainerFg
            font.family: Config.fontFamily
            font.pixelSize: Math.max(1, parent.width > 0 ? parent.width * 0.42 : 12)
            font.weight: Font.Medium
        }
    }

    // Accent ring
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: ThemeManager.primary
    }
}
