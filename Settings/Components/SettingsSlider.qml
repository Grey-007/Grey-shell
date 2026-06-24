import QtQuick
import "../../colors"
import "../Models"

Rectangle {
    id: root
    property real value: 0
    property real from: 0
    property real to: 100
    signal moved(real val)

    height: 24
    color: ThemeManager.surfaceTop
    border.color: ThemeManager.border
    border.width: 1
    
    Rectangle {
        height: parent.height
        width: parent.width * ((root.value - root.from) / (root.to - root.from))
        color: ThemeManager.accentSoft
        
        Rectangle {
            width: 2; height: parent.height
            anchors.right: parent.right
            color: ThemeManager.accent
        }
    }
    
    MouseArea {
        anchors.fill: parent
        function updateVal(mouse) {
            var p = Math.max(0, Math.min(1, mouse.x / width))
            var v = root.from + p * (root.to - root.from)
            root.moved(v)
        }
        onPositionChanged: (mouse) => { if (pressed) updateVal(mouse) }
        onPressed: (mouse) => updateVal(mouse)
    }
}
