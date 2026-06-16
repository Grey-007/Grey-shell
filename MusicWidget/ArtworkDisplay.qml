import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris
import "../Animation" as Animation
import "../Animation/AnimationConfig.qml" as AnimationConfig
import "./MusicConfig.qml" as Config
import "./Theme.qml" as MusicTheme

Item {
    id: artworkRoot
    width: 300
    height: 300

    // MPRIS player
    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    
    // View state: 0 for Album Art, 1 for GIF
    property int currentView: 0
    property string gifSource: ""

    // View Container
    StackLayout {
        id: stackLayout
        anchors.fill: parent
        currentIndex: currentView

        // Album Art View
        Image {
            source: player ? (player.artUrl || "") : ""
            fillMode: Image.PreserveAspectCrop
        }

        // GIF View
        AnimatedImage {
            source: gifSource
            fillMode: Image.PreserveAspectCrop
            playing: currentView === 1
        }
    }

    // Gesture handler for switching views
    MouseArea {
        anchors.fill: parent
        onClicked: {
            currentView = (currentView === 0) ? 1 : 0
        }
    }
}// recovery temp
