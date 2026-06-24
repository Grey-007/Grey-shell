import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"

Rectangle {
    id: root
    
    property string currentCategory: "Appearance"
    signal categoryChanged(string category)
    
    width: 200
    color: ThemeManager.surface
    border.color: ThemeManager.border
    border.width: 1
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6
        
        Text {
            text: "Settings"
            color: ThemeManager.accent
            font.pixelSize: 16
            font.family: "monospace"
            font.weight: Font.Bold
            font.letterSpacing: 1
            Layout.margins: 8
            Layout.bottomMargin: 8
        }
        
        SearchBar {
            Layout.fillWidth: true
            Layout.bottomMargin: 8
        }
        

        Repeater {
            model: [
                { icon: "🎨", name: "Appearance" },
                { icon: "🧩", name: "Widgets" },
                { icon: "⌨", name: "Keybinds" },
                { icon: "📏", name: "Bar" },
                { icon: "🎭", name: "Profiles" },
                { icon: "💾", name: "Backup" },
                { icon: "ℹ", name: "About" }
            ]
            
            CategoryButton {
                text: modelData.name
                active: root.currentCategory === modelData.name
                onClicked: {
                    root.currentCategory = modelData.name
                    root.categoryChanged(modelData.name)
                }
            }
        }
        
        Item {
            Layout.fillHeight: true // spacer
        }
    }
}
