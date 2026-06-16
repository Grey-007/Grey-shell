import QtQuick
import QtQuick.Controls
import "./AnimationConfig.qml" as AnimationConfig

QtObject {
    id: animationManager

    // Reusable PropertyAnimation for opacity
    Component {
        id: opacityAnimator
        PropertyAnimation {
            duration: AnimationConfig.durationNormal
            easing.type: AnimationConfig.easingSmooth
            property: "opacity"
        }
    }

    // Reusable PropertyAnimation for sliding X position
    Component {
        id: slideXAnimator
        PropertyAnimation {
            duration: AnimationConfig.durationNormal
            easing.type: AnimationConfig.easingSmooth
            property: "x"
        }
    }

    // Add more reusable animators as needed
    // Example: scaleAnimator, rotationAnimator, etc.
}