import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Animation" as Animation
import "../Animation/AnimationConfig.qml" as AnimationConfig
import "./MusicConfig.qml" as Config
import "./Theme.qml" as MusicTheme
import "./WidgetState.qml" as WidgetState

Rectangle {
    id: musicWidgetRoot

    width: Config.widgetWidth
    height: Config.widgetHeight
    radius: Config.widgetRadius
    color: MusicTheme.backgroundColor

    // Target positions
    property real visibleX: parent.width - width - Config.marginRight
    property real hiddenX: parent.width

    // State for pinning, linked to WidgetState
    property alias pinned: WidgetState.pinned

    // Internal visibility state
    property bool _isVisible: true
    x: _isVisible ? visibleX : hiddenX

    // Animations using the shared Animation system
    Behavior on x {
        PropertyAnimation {
            duration: AnimationConfig.durationNormal
            easing.type: AnimationConfig.easingSmooth
        }
    }

    // Music Visualizer (behind other content)
    MusicVisualizer {
        anchors.fill: parent
        z: -1
    }

    // Function to show the widget
    function show() {
        _isVisible = true
    }

    // Function to hide the widget
    function hide() {
        if (!pinned) {
            _isVisible = false
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
    ...
        ArtworkDisplay {
            id: artwork
            Layout.fillWidth: true
            Layout.preferredHeight: 200
        }

        Button {
            text: "Switch GIF"
            Layout.alignment: Qt.AlignHCenter
            onClicked: modalLoader.active = true
        }

        MusicControls {
            Layout.fillWidth: true
        }

        MusicProgressBar {
            Layout.fillWidth: true
        }

        Button {
            text: pinned ? "Unpin" : "Pin"
            Layout.alignment: Qt.AlignHCenter
            onClicked: pinned = !pinned
        }
    }

    Loader {
        id: modalLoader
        active: false
        source: "GifPickerModal.qml"
        onLoaded: {
            item.gifApplied.connect(function(source) { artwork.gifSource = source })
            item.open()
        }
        // Ensure loader is deactivated when modal is closed
        onItemChanged: {
            if (item) {
                item.onClosed.connect(function() { modalLoader.active = false })
            }
        }
    }
}