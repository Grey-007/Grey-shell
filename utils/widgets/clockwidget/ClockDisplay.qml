import QtQuick
import "../../../colors"

Item {
    id: root

    // Bind to the config singleton
    property string fontFamily: ClockConfig.fontFamily
    property int fontSize: ClockConfig.fontSize
    
    // Time updating
    property string timeString: Qt.formatTime(new Date(), "hh:mm")
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.timeString = Qt.formatTime(new Date(), "hh:mm")
    }

    implicitWidth: textElement.implicitWidth + 40
    implicitHeight: textElement.implicitHeight + 40

    // Text with soft shadow for better visibility on wallpapers
    Text {
        id: shadowText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 2
        anchors.verticalCenterOffset: 2
        text: root.timeString
        color: ThemeManager.alpha(ThemeManager.bg, 0.4)
        font.family: root.fontFamily
        font.pixelSize: (root.fontSize > 0 ? root.fontSize : 12)
        font.weight: Font.Bold
        style: Text.Normal
    }

    Text {
        id: textElement
        anchors.centerIn: parent
        text: root.timeString
        color: ThemeManager.accent
        font.family: root.fontFamily
        font.pixelSize: (root.fontSize > 0 ? root.fontSize : 12)
        font.weight: Font.Bold
    }
}
