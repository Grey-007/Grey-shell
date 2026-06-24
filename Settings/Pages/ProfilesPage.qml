import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"
import "../Components"
import "../Models"

Item {
    id: root
    
    ProfileEditor {
        id: profileEditor
        property string actionType: "create"
        
        onProfileSaved: (newName) => {
            var arr = SettingsManager.store.profiles ? SettingsManager.store.profiles.slice() : []
            if (actionType === "create") {
                arr.push({ name: newName, settings: JSON.parse(JSON.stringify(SettingsManager.store)) })
            } else if (actionType === "rename") {
                for (var i=0; i<arr.length; i++) {
                    if (arr[i].name === profileEditor.initialName) {
                        arr[i].name = newName
                    }
                }
                if (SettingsManager.store.activeProfile === profileEditor.initialName) {
                    SettingsManager.store.activeProfile = newName
                }
            }
            SettingsManager.store.profiles = arr
        }
    }
    
    ConfirmationDialog {
        id: deleteConfirm
        message: "Are you sure you want to delete this profile?"
        isDestructive: true
        property string targetProfile: ""
        onConfirmed: {
            var arr = SettingsManager.store.profiles ? SettingsManager.store.profiles.slice() : []
            var newArr = arr.filter(p => p.name !== targetProfile)
            SettingsManager.store.profiles = newArr
            if (SettingsManager.store.activeProfile === targetProfile) {
                SettingsManager.store.activeProfile = "Default"
            }
        }
    }
    
    function loadProfile(name) {
        if (name === "Default") {
            SettingsManager.store.activeProfile = "Default"
            return
        }
        var arr = SettingsManager.store.profiles || []
        for (var i=0; i<arr.length; i++) {
            if (arr[i].name === name) {
                var pStore = arr[i].settings
                SettingsManager.store.activeProfile = name
                if (pStore.themeMode !== undefined) SettingsManager.store.themeMode = pStore.themeMode
                if (pStore.transparency !== undefined) SettingsManager.store.transparency = pStore.transparency
                if (pStore.animationSpeed !== undefined) SettingsManager.store.animationSpeed = pStore.animationSpeed
                if (pStore.blurEnabled !== undefined) SettingsManager.store.blurEnabled = pStore.blurEnabled
                if (pStore.blurSize !== undefined) SettingsManager.store.blurSize = pStore.blurSize
                if (pStore.blurPasses !== undefined) SettingsManager.store.blurPasses = pStore.blurPasses
                if (pStore.themeOverrides !== undefined) SettingsManager.store.themeOverrides = pStore.themeOverrides
            }
        }
    }
    
    property var allProfiles: {
        var res = ["Default"]
        var arr = SettingsManager.store.profiles || []
        for (var i=0; i<arr.length; i++) {
            res.push(arr[i].name)
        }
        return res
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
            
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Profiles"
                    color: ThemeManager.fg
                    font.pixelSize: 22
                    font.family: "monospace"
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    visible: SettingsManager.searchQuery === ""
                }
                
                Rectangle {
                    width: 120; height: 32
                    color: ThemeManager.accentSoft
                    border.color: ThemeManager.accent
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "+ New Profile"
                        color: ThemeManager.fgInverted
                        font.family: "monospace"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            profileEditor.actionType = "create"
                            profileEditor.initialName = ""
                            profileEditor.open()
                        }
                    }
                }
            }
            
            SettingsSection {
                title: "Available Profiles"
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Repeater {
                        model: root.allProfiles
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 60
                            color: SettingsManager.store.activeProfile === modelData ? ThemeManager.accentSoft : ThemeManager.surfaceTop
                            border.color: SettingsManager.store.activeProfile === modelData ? ThemeManager.accent : ThemeManager.border
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12
                                
                                Text {
                                    text: modelData
                                    color: SettingsManager.store.activeProfile === modelData ? ThemeManager.fgInverted : ThemeManager.fg
                                    font.pixelSize: 15
                                    font.family: "monospace"
                                    font.weight: SettingsManager.store.activeProfile === modelData ? Font.Bold : Font.Normal
                                    Layout.fillWidth: true
                                }
                                
                                Rectangle {
                                    width: 80; height: 32
                                    color: "transparent"
                                    border.color: SettingsManager.store.activeProfile === modelData ? ThemeManager.bg : ThemeManager.border
                                    border.width: 1
                                    visible: SettingsManager.store.activeProfile !== modelData
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Activate"
                                        color: SettingsManager.store.activeProfile === modelData ? ThemeManager.fgInverted : ThemeManager.fgMid
                                        font.family: "monospace"
                                        font.pixelSize: 12
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.loadProfile(modelData)
                                    }
                                }
                                
                                Rectangle {
                                    width: 32; height: 32
                                    color: "transparent"
                                    visible: modelData !== "Default"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "🗑"
                                        color: "#e06c75"
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            deleteConfirm.targetProfile = modelData
                                            deleteConfirm.open()
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
