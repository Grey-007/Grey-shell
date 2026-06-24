import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../colors"
import "../Components"
import "../Models"

Item {
    id: root
    
    ConfirmationDialog {
        id: resetConfirm
        message: "Are you sure you want to completely reset all settings to defaults? This action cannot be undone."
        isDestructive: true
        confirmText: "Reset All"
        onConfirmed: {
            SettingsManager.store.themeMode = "Dark"
            SettingsManager.store.transparency = 70
            SettingsManager.store.animationSpeed = 250
            SettingsManager.store.blurEnabled = true
            SettingsManager.store.blurSize = 3
            SettingsManager.store.blurPasses = 1
            SettingsManager.store.musicWidgetEnabled = true
            SettingsManager.store.utilityNotchEnabled = true
            SettingsManager.store.clockWidgetEnabled = true
            SettingsManager.store.weatherWidgetEnabled = true
            SettingsManager.store.shortcuts = []
            SettingsManager.store.profiles = []
            SettingsManager.store.activeProfile = "Default"
            SettingsManager.store.themeOverrides = {}
        }
    }
    
    Process {
        id: exportProc
        command: ["sh", "-c", "cp ~/.config/quickshell/Settings/Config/settings.json ~/quickshell_backup.json"]
    }
    
    Process {
        id: importProc
        command: ["sh", "-c", "cp ~/quickshell_backup.json ~/.config/quickshell/Settings/Config/settings.json"]
        onExited: {
            // Need to tell SettingsManager to reload
            // Quick and dirty: wait for reload
            SettingsManager.loadProc.running = true
        }
    }
    
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
                text: "Backup & Restore"
                color: ThemeManager.fg
                font.pixelSize: 22
                font.family: "monospace"
                font.weight: Font.Bold
                visible: SettingsManager.searchQuery === ""
            }
            
            SettingsSection {
                title: "Data Management"
                description: "Export or Import your configuration to ~/quickshell_backup.json"
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: ThemeManager.surfaceTop
                        border.color: ThemeManager.border
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Export Configuration"
                            color: ThemeManager.fg
                            font.family: "monospace"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: exportProc.running = true
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: ThemeManager.surfaceTop
                        border.color: ThemeManager.border
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Import Configuration"
                            color: ThemeManager.fg
                            font.family: "monospace"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: importProc.running = true
                        }
                    }
                }
            }
            
            SettingsSection {
                title: "Factory Reset"
                description: "Wipe all current settings, profiles, and overrides."
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: "transparent"
                    border.color: "#e06c75"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Reset Everything"
                        color: "#e06c75"
                        font.family: "monospace"
                        font.weight: Font.Bold
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: resetConfirm.open()
                    }
                }
            }
            
            Item { Layout.fillHeight: true; implicitHeight: 20 }
        }
    }
}
