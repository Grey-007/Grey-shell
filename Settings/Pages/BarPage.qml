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
                text: "Top Bar"
                color: ThemeManager.fg
                font.pixelSize: 22
                font.family: "monospace"
                font.weight: Font.Bold
                visible: SettingsManager.searchQuery === ""
            }
            
            SettingsSection {
                title: "Workspaces"
                description: "Show workspace indicators on the bar."
                
                SettingsToggle {
                    checked: SettingsManager.store.barWorkspacesEnabled
                    onToggled: { SettingsManager.store.barWorkspacesEnabled = !SettingsManager.store.barWorkspacesEnabled }
                }
            }
            
            SettingsSection {
                title: "Clock"
                description: "Show current time and date on the bar."
                
                SettingsToggle {
                    checked: SettingsManager.store.barClockEnabled
                    onToggled: { SettingsManager.store.barClockEnabled = !SettingsManager.store.barClockEnabled }
                }
            }
            
            SettingsSection {
                title: "Battery Indicator"
                description: "Show battery percentage and charging status on the bar."
                
                SettingsToggle {
                    checked: SettingsManager.store.barBatteryEnabled
                    onToggled: { SettingsManager.store.barBatteryEnabled = !SettingsManager.store.barBatteryEnabled }
                }
            }
            
            SettingsSection {
                title: "Bar Position"
                description: "Choose the location of the bar on the screen."
                
                RowLayout {
                    spacing: 12
                    Repeater {
                        model: ["Top", "Bottom"]
                        Rectangle {
                            width: 80; height: 32
                            color: SettingsManager.store.barPosition === modelData ? ThemeManager.accentSoft : ThemeManager.surfaceTop
                            border.color: SettingsManager.store.barPosition === modelData ? ThemeManager.accent : ThemeManager.border
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: SettingsManager.store.barPosition === modelData ? ThemeManager.fgInverted : ThemeManager.fgMid
                                font.pixelSize: 13
                                font.family: "monospace"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: SettingsManager.store.barPosition = modelData
                            }
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true; implicitHeight: 20 }
        }
    }
}
