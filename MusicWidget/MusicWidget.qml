import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Animation" as Animation
import "./MusicConfig.qml" as Config
import "./Theme.qml" as MusicTheme
import "./WidgetState.qml" as WidgetState

Rectangle {
    id: musicWidgetRoot

    width: Config.widgetWidth
    height: Config.widgetHeight
    radius: Config.widgetRadius
    color: MusicTheme.backgroundColor // Use theme background color

    // Initial position, will be controlled by animation and pinning logic
    property real targetX: parent.width - width - Config.marginRight
    x: targetX // Default to visible position

    // State for pinning, linked to WidgetState
    property alias pinned: WidgetState.pinned

    // Visibility controlled by external factors and pinning
    property bool _isVisible: false // Internal state for visibility

    // Function to show the widget
    function show() {
        _isVisible = true
        // Animation will handle the x property change from parent.width to targetX
    }

    // Function to hide the widget
    function hide() {
        _isVisible = false
        // Animation will handle the x property change from targetX to parent.width
    }

    // Dummy content for now
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        Label {
            text: "Music Widget"
            font.pixelSize: 24
            color: MusicTheme.textColor
            Layout.alignment: Qt.AlignHCenter
        }
        Label {
            text: "Content goes here..."
            font.pixelSize: 16
            color: MusicTheme.mutedTextColor
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Pinning button placeholder
    Button {
        text: pinned ? "Unpin" : "Pin"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: pinned = !pinned
    }
}