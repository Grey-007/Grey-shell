import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"
import "../Components"

Item {
    id: root
    
    Flickable {
        anchors.fill: parent
        contentHeight: mainCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        
        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 24
            
            Text {
                text: "About"
                color: ThemeManager.fg
                font.pixelSize: 22
                font.family: "monospace"
                font.weight: Font.Bold
            }
            
            SettingsSection {
                title: "System Information"
                description: "Details about your current environment."
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    RowLayout {
                        Text { text: "Shell Name:"; color: ThemeManager.fgMid; font.family: "monospace"; font.pixelSize: 13; Layout.preferredWidth: 150 }
                        Text { text: "SepiaShell"; color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 13 }
                    }
                    RowLayout {
                        Text { text: "Version:"; color: ThemeManager.fgMid; font.family: "monospace"; font.pixelSize: 13; Layout.preferredWidth: 150 }
                        Text { text: "1.0.0-placeholder"; color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 13 }
                    }
                    RowLayout {
                        Text { text: "QuickShell Version:"; color: ThemeManager.fgMid; font.family: "monospace"; font.pixelSize: 13; Layout.preferredWidth: 150 }
                        Text { text: "0.3.0"; color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 13 }
                    }
                    RowLayout {
                        Text { text: "Hyprland Version:"; color: ThemeManager.fgMid; font.family: "monospace"; font.pixelSize: 13; Layout.preferredWidth: 150 }
                        Text { text: "0.40.0-placeholder"; color: ThemeManager.fg; font.family: "monospace"; font.pixelSize: 13 }
                    }
                }
            }
            
            Item { Layout.fillHeight: true; implicitHeight: 20 }
        }
    }
}
