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
    
    property var binds: []
    
    Process {
        id: bindsProc
        command: ["cat", Quickshell.env("HOME") + "/.config/hypr/modules/binds.lua"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.split('\n')
                var parsedBinds = []
                var currentSection = "General"
                
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    
                    // Parse comments for sections
                    if (line.startsWith("--") && line.indexOf("====") === -1 && line.indexOf("----") === -1) {
                        var sectionName = line.substring(2).trim()
                        if (sectionName !== "Keybinds" && sectionName !== "Set your programs" && sectionName.length > 0) {
                            currentSection = sectionName
                        }
                    }
                    
                    if (line.startsWith("hl.bind(")) {
                        // Very naive parsing
                        var keys = ""
                        var desc = ""
                        
                        // Extract keys (first arg)
                        var keyMatch = line.match(/hl\.bind\(([^,]+),/)
                        if (keyMatch) {
                            keys = keyMatch[1].trim()
                            // replace mainMod with Super
                            keys = keys.replace(/mainMod\s*\.\.\s*"/g, 'Super')
                            keys = keys.replace(/"/g, '')
                        }
                        
                        // Extract description
                        var descMatch = line.match(/description\s*=\s*"([^"]+)"/)
                        if (descMatch) {
                            desc = descMatch[1]
                        } else {
                            // try to guess action
                            if (line.indexOf("exec_cmd") !== -1) desc = "Execute Command"
                            else if (line.indexOf("window.close") !== -1) desc = "Close Window"
                            else desc = "Window Action"
                        }
                        
                        if (keys !== "") {
                            parsedBinds.push({ section: currentSection, keys: keys, description: desc })
                        }
                    }
                }
                root.binds = parsedBinds
            }
        }
    }
    
    Component.onCompleted: bindsProc.running = true
    
    function getSections() {
        var s = []
        for (var i=0; i<binds.length; i++) {
            if (s.indexOf(binds[i].section) === -1) s.push(binds[i].section)
        }
        return s
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
                text: "Hyprland Keybinds"
                color: ThemeManager.fg
                font.pixelSize: 22
                font.family: "monospace"
                font.weight: Font.Bold
                visible: SettingsManager.searchQuery === ""
            }
            
            Repeater {
                model: root.getSections()
                
                SettingsSection {
                    title: modelData
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Repeater {
                            model: root.binds.filter(b => b.section === modelData && (SettingsManager.searchQuery === "" || b.description.toLowerCase().indexOf(SettingsManager.searchQuery.toLowerCase()) !== -1 || b.keys.toLowerCase().indexOf(SettingsManager.searchQuery.toLowerCase()) !== -1))
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 48
                                color: ThemeManager.surfaceTop
                                border.color: ThemeManager.border
                                border.width: 1
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12
                                    
                                    Text {
                                        text: modelData.description
                                        color: ThemeManager.fg
                                        font.pixelSize: 13
                                        font.family: "monospace"
                                        Layout.fillWidth: true
                                    }
                                    
                                    Rectangle {
                                        width: Math.max(100, keyText.implicitWidth + 24)
                                        height: 28
                                        color: ThemeManager.surface
                                        border.color: ThemeManager.border
                                        border.width: 1
                                        
                                        Text {
                                            id: keyText
                                            anchors.centerIn: parent
                                            text: modelData.keys
                                            color: ThemeManager.accent
                                            font.pixelSize: 12
                                            font.family: "monospace"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true; implicitHeight: 20 }
        }
    }
}
