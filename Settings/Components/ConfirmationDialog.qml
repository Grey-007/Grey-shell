import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"

Modal {
    id: root
    
    property string message: "Are you sure?"
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property bool isDestructive: false
    
    signal confirmed()
    signal cancelled()
    
    content: ColumnLayout {
        width: parent.width
        spacing: 24
        
        Text {
            Layout.fillWidth: true
            text: root.message
            color: ThemeManager.fg
            font.pixelSize: 14
            font.family: "monospace"
            wrapMode: Text.WordWrap
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Item { Layout.fillWidth: true } // Spacer
            
            Rectangle {
                width: 100; height: 36
                color: "transparent"
                border.color: ThemeManager.border
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: root.cancelText
                    color: ThemeManager.fgMid
                    font.family: "monospace"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.cancelled()
                        root.close()
                    }
                }
            }
            
            Rectangle {
                width: 100; height: 36
                color: root.isDestructive ? "#e06c75" : ThemeManager.accentSoft
                border.color: root.isDestructive ? "#e06c75" : ThemeManager.accent
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: root.confirmText
                    color: root.isDestructive ? "#ffffff" : ThemeManager.fgInverted
                    font.family: "monospace"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.confirmed()
                        root.close()
                    }
                }
            }
        }
    }
}
