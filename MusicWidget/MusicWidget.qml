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

    // Column layout for content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        
        Label {
            text: "Music Widget"
            font.pixelSize: 24
            color: MusicTheme.textColor
            Layout.alignment: Qt.AlignHCenter
        }
        
        // Pinning button
        Button {
            text: pinned ? "Unpin" : "Pin"
            Layout.alignment: Qt.AlignHCenter
            onClicked: pinned = !pinned
        }
    }
}