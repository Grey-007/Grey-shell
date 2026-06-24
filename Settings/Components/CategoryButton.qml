import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"

Rectangle {
    id: root
    
    property string text: ""
    property bool active: false
    signal clicked()
    
    Layout.fillWidth: true
    implicitHeight: 36
    
    color: {
        if (active) return ThemeManager.accentSoft
        if (mouseArea.containsMouse) return ThemeManager.surfaceHigh
        return "transparent"
    }
    
    border.color: active ? ThemeManager.accent : (mouseArea.containsMouse ? ThemeManager.border : "transparent")
    border.width: 1
    
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        
        Text {
            Layout.fillWidth: true
            text: root.text
            color: root.active ? ThemeManager.fgInverted : ThemeManager.fg
            font.pixelSize: 13
            font.family: "monospace"
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
