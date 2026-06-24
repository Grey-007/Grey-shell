import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../colors"
import "Components"
import "Pages"
import "Models"

PanelWindow {
    id: win
    
    property bool panelVisible: false
    
    function toggle() { panelVisible = !panelVisible }
    function open() { panelVisible = true }
    function close() { panelVisible = false }
    
    visible: panelVisible || hideTimer.running
    color: "transparent"
    
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: panelVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    Timer {
        id: hideTimer
        interval: 250
        running: false
    }
    
    onPanelVisibleChanged: {
        if (!panelVisible) hideTimer.restart()
    }
    
    // Dim scrim
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        opacity: panelVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        
        MouseArea {
            anchors.fill: parent
            onClicked: win.close()
        }
    }
    
    // Main Window Container
    Rectangle {
        id: windowCard
        width: 800
        height: 550
        anchors.centerIn: parent
        
        color: ThemeManager.surface
        border.color: ThemeManager.border
        border.width: 1
        
        // Scale/fade animation for opening
        opacity: panelVisible ? 1 : 0
        scale: panelVisible ? 1 : 0.95
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        
        RowLayout {
            anchors.fill: parent
            spacing: 0
            
            Sidebar {
                id: sidebar
                Layout.fillHeight: true
                Layout.preferredWidth: 200
            }
            
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: ThemeManager.border
            }
            
            // Content Area
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                Item {
                    anchors.fill: parent
                    anchors.margins: 32
                    
                    AppearancePage {
                        width: parent.width
                        height: parent.height
                        visible: opacity > 0
                        opacity: sidebar.currentCategory === "Appearance" ? 1 : 0
                        y: sidebar.currentCategory === "Appearance" ? 0 : 20
                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                    
                    WidgetsPage {
                        width: parent.width
                        height: parent.height
                        visible: opacity > 0
                        opacity: sidebar.currentCategory === "Widgets" ? 1 : 0
                        y: sidebar.currentCategory === "Widgets" ? 0 : 20
                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                    
                    AboutPage {
                        width: parent.width
                        height: parent.height
                        visible: opacity > 0
                        opacity: sidebar.currentCategory === "About" ? 1 : 0
                        y: sidebar.currentCategory === "About" ? 0 : 20
                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                    
                    KeybindsPage {
                        width: parent.width
                        height: parent.height
                        visible: opacity > 0
                        opacity: sidebar.currentCategory === "Keybinds" ? 1 : 0
                        y: sidebar.currentCategory === "Keybinds" ? 0 : 20
                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                    
                    BarPage {
                        width: parent.width
                        height: parent.height
                        visible: opacity > 0
                        opacity: sidebar.currentCategory === "Bar" ? 1 : 0
                        y: sidebar.currentCategory === "Bar" ? 0 : 20
                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                    
                    ProfilesPage {
                        width: parent.width
                        height: parent.height
                        visible: opacity > 0
                        opacity: sidebar.currentCategory === "Profiles" ? 1 : 0
                        y: sidebar.currentCategory === "Profiles" ? 0 : 20
                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                    
                    BackupPage {
                        width: parent.width
                        height: parent.height
                        visible: opacity > 0
                        opacity: sidebar.currentCategory === "Backup" ? 1 : 0
                        y: sidebar.currentCategory === "Backup" ? 0 : 20
                        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }
    }
}
