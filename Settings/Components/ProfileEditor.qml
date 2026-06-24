import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"

Modal {
    id: root
    
    title: "Edit Profile"
    property string initialName: ""
    property string currentName: ""
    
    signal profileSaved(string newName)
    
    onOpened: {
        currentName = initialName
        nameInput.text = currentName
        nameInput.forceActiveFocus()
    }
    
    content: ColumnLayout {
        width: parent.width
        spacing: 24
        
        Text {
            text: "Profile Name:"
            color: ThemeManager.fg
            font.pixelSize: 13
            font.family: "monospace"
        }
        
        TextField {
            id: nameInput
            Layout.fillWidth: true
            text: root.currentName
            color: ThemeManager.fg
            font.family: "monospace"
            font.pixelSize: 14
            background: Rectangle {
                color: ThemeManager.surfaceTop
                border.color: ThemeManager.border
                border.width: 1
            }
            onTextEdited: root.currentName = text
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Item { Layout.fillWidth: true }
            
            Rectangle {
                width: 100; height: 36
                color: "transparent"
                border.color: ThemeManager.border
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: ThemeManager.fgMid
                    font.family: "monospace"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.close()
                }
            }
            
            Rectangle {
                width: 100; height: 36
                color: root.currentName.trim() === "" ? ThemeManager.surfaceTop : ThemeManager.accentSoft
                border.color: root.currentName.trim() === "" ? ThemeManager.border : ThemeManager.accent
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "Save"
                    color: root.currentName.trim() === "" ? ThemeManager.fgMid : ThemeManager.fgInverted
                    font.family: "monospace"
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: root.currentName.trim() !== ""
                    onClicked: {
                        root.profileSaved(root.currentName.trim())
                        root.close()
                    }
                }
            }
        }
    }
}
