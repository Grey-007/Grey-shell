import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"
import "../Models"

Rectangle {
    id: root
    property bool checked: false
    signal toggled(bool newState)
    
    width: 44
    height: 24
    color: checked ? ThemeManager.accentSoft : ThemeManager.surfaceTop
    border.color: checked ? ThemeManager.accent : ThemeManager.border
    border.width: 1
    
    Rectangle {
        width: 16
        height: 16
        x: checked ? parent.width - width - 4 : 4
        y: 3
        color: checked ? ThemeManager.fgInverted : ThemeManager.fgMid
        Behavior on x { NumberAnimation { duration: SettingsManager.animDuration; easing.type: Easing.OutCubic } }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.toggled(!root.checked)
        }
    }
}
