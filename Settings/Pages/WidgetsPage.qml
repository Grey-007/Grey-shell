import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"
import "../Components"
import "../Models"

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
                text: "Widgets"
                color: ThemeManager.fg
                font.pixelSize: 22
                font.family: "monospace"
                font.weight: Font.Bold
                visible: SettingsManager.searchQuery === ""
            }
            
            SettingsSection {
                title: "Music Widget"
                description: "Show now playing information and media controls."
                
                SettingsToggle {
                    checked: SettingsManager.store.musicWidgetEnabled
                    onToggled: (val) => { SettingsManager.store.musicWidgetEnabled = val }
                }
            }
            
            SettingsSection {
                title: "Utility Notch"
                description: "Enable the top screen utility drop-down."
                
                SettingsToggle {
                    checked: SettingsManager.store.utilityNotchEnabled
                    onToggled: (val) => { SettingsManager.store.utilityNotchEnabled = val }
                }
            }
            
            SettingsSection {
                title: "Clock Widget"
                description: "Display time and date on the desktop."
                
                SettingsToggle {
                    checked: SettingsManager.store.clockWidgetEnabled
                    onToggled: (val) => { SettingsManager.store.clockWidgetEnabled = val }
                }
            }
            
            SettingsSection {
                title: "Weather Widget"
                description: "Show current weather conditions and forecast."
                
                SettingsToggle {
                    checked: SettingsManager.store.weatherWidgetEnabled
                    onToggled: (val) => { SettingsManager.store.weatherWidgetEnabled = val }
                }
            }
            
            Item { Layout.fillHeight: true; implicitHeight: 20 }
        }
    }
}
