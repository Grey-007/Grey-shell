import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"
import "../Models"

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: 36
    
    color: ThemeManager.surfaceTop
    border.color: ThemeManager.border
    border.width: 1
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8
        
        Text {
            text: "🔍"
            color: ThemeManager.fgMid
            font.pixelSize: 14
        }
        
        TextInput {
            Layout.fillWidth: true
            text: SettingsManager.searchQuery
            color: ThemeManager.fg
            font.pixelSize: 13
            font.family: "monospace"
            onTextEdited: SettingsManager.searchQuery = text
            
            Text {
                text: "Search..."
                color: ThemeManager.fgDim
                font.pixelSize: 13
                font.family: "monospace"
                visible: parent.text === ""
            }
        }
    }
}
