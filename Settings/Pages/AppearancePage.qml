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
                text: "Appearance"
                color: ThemeManager.fg
                font.pixelSize: 22
                font.family: "monospace"
                font.weight: Font.Bold
                visible: SettingsManager.searchQuery === ""
            }
            
            SettingsSection {
                title: "Theme Mode"
                description: "Toggle between Dark and Light mode globally."
                
                RowLayout {
                    spacing: 12
                    
                    Repeater {
                        model: ["Dark", "Light"]
                        Rectangle {
                            width: 80; height: 32
                            color: SettingsManager.store.themeMode === modelData ? ThemeManager.accentSoft : ThemeManager.surfaceTop
                            border.color: SettingsManager.store.themeMode === modelData ? ThemeManager.accent : ThemeManager.border
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: SettingsManager.store.themeMode === modelData ? ThemeManager.fgInverted : ThemeManager.fgMid
                                font.pixelSize: 13
                                font.family: "monospace"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: SettingsManager.store.themeMode = modelData
                            }
                        }
                    }
                }
            }
            
            SettingsSection {
                title: "Transparency"
                description: "Adjust the opacity of panels and menus."
                
                RowLayout {
                    spacing: 12
                    SettingsSlider {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: SettingsManager.store.transparency
                        onMoved: (val) => { SettingsManager.store.transparency = val }
                    }
                    Text {
                        text: Math.round(SettingsManager.store.transparency) + "%"
                        color: ThemeManager.fgMid
                        font.pixelSize: 13
                        font.family: "monospace"
                        Layout.preferredWidth: 40
                    }
                }
            }
            
            SettingsSection {
                title: "Animations"
                description: "Control the global speed of UI transitions."
                
                RowLayout {
                    spacing: 12
                    SettingsSlider {
                        Layout.fillWidth: true
                        from: 50
                        to: 1000
                        value: SettingsManager.store.animationSpeed
                        onMoved: (val) => { SettingsManager.store.animationSpeed = Math.round(val) }
                    }
                    Text {
                        text: Math.round(SettingsManager.store.animationSpeed) + "ms"
                        color: ThemeManager.fgMid
                        font.pixelSize: 13
                        font.family: "monospace"
                        Layout.preferredWidth: 40
                    }
                }
            }
            
            SettingsSection {
                title: "Hyprland Blur"
                description: "Configure background blur (requires hyprland.lua integration)."
                
                RowLayout {
                    spacing: 12
                    
                    Text {
                        text: "Enable Blur"
                        color: ThemeManager.fg
                        font.family: "monospace"
                        font.pixelSize: 13
                    }
                    
                    SettingsToggle {
                        checked: SettingsManager.store.blurEnabled
                        onCheckedChanged: SettingsManager.store.blurEnabled = checked
                    }
                }
                
                Text {
                    text: "Blur Size"
                    color: ThemeManager.fgMid
                    font.pixelSize: 12
                    font.family: "monospace"
                }
                RowLayout {
                    spacing: 12
                    SettingsSlider {
                        Layout.fillWidth: true
                        from: 1; to: 10
                        value: SettingsManager.store.blurSize
                        onMoved: (val) => { SettingsManager.store.blurSize = Math.round(val) }
                    }
                    Text {
                        text: SettingsManager.store.blurSize
                        color: ThemeManager.fgMid
                        font.pixelSize: 13
                        font.family: "monospace"
                        Layout.preferredWidth: 40
                    }
                }
                
                Text {
                    text: "Blur Passes"
                    color: ThemeManager.fgMid
                    font.pixelSize: 12
                    font.family: "monospace"
                }
                RowLayout {
                    spacing: 12
                    SettingsSlider {
                        Layout.fillWidth: true
                        from: 1; to: 5
                        value: SettingsManager.store.blurPasses
                        onMoved: (val) => { SettingsManager.store.blurPasses = Math.round(val) }
                    }
                    Text {
                        text: SettingsManager.store.blurPasses
                        color: ThemeManager.fgMid
                        font.pixelSize: 13
                        font.family: "monospace"
                        Layout.preferredWidth: 40
                    }
                }
            }
            
            Item { Layout.fillHeight: true; implicitHeight: 20 }
        }
    }
}
