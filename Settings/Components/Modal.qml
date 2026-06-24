import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"

Popup {
    id: root
    
    property alias content: contentContainer.data
    property string title: "Modal"
    
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    
    width: 400
    height: Math.min(implicitHeight, parent.height - 100)
    
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    Overlay.modal: Rectangle {
        color: ThemeManager.bg
        opacity: 0.7
    }
    
    background: Rectangle {
        color: ThemeManager.surface
        border.color: ThemeManager.border
        border.width: 1
    }
    
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "scale"; from: 0.95; to: 1; duration: 200; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
        NumberAnimation { property: "scale"; from: 1; to: 0.95; duration: 200; easing.type: Easing.InCubic }
    }
    
    contentItem: ColumnLayout {
        spacing: 0
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 48
            color: ThemeManager.surfaceTop
            border.color: ThemeManager.border
            border.width: 1
            
            Text {
                text: root.title
                color: ThemeManager.fg
                font.pixelSize: 16
                font.family: "monospace"
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 24
            }
            
            Rectangle {
                width: 32; height: 32
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 12
                color: "transparent"
                Text {
                    text: "✕"
                    color: ThemeManager.fgMid
                    font.pixelSize: 14
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.close()
                }
            }
        }
        
        // Body
        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            Layout.margins: 24
            
            // Consumer content goes here
        }
    }
}
