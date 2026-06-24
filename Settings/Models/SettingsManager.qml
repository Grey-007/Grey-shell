pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../colors"

Singleton {
    id: root

    property var _initialConfig: {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + Quickshell.env("HOME") + "/.config/quickshell/Settings/Config/settings.json", false)
        try {
            xhr.send()
            if (xhr.status === 200 || xhr.status === 0) {
                return JSON.parse(xhr.responseText.trim())
            }
        } catch(e) {}
        return {}
    }

    property SettingsStore store: SettingsStore {
        themeMode: _initialConfig.themeMode !== undefined ? _initialConfig.themeMode : "Dark"
        transparency: _initialConfig.transparency !== undefined ? _initialConfig.transparency : 100
        animationSpeed: _initialConfig.animationSpeed !== undefined ? _initialConfig.animationSpeed : 250
        blurEnabled: _initialConfig.blurEnabled !== undefined ? _initialConfig.blurEnabled : true
        blurSize: _initialConfig.blurSize !== undefined ? _initialConfig.blurSize : 10
        blurPasses: _initialConfig.blurPasses !== undefined ? _initialConfig.blurPasses : 3
        musicWidgetEnabled: _initialConfig.musicWidgetEnabled !== undefined ? _initialConfig.musicWidgetEnabled : true
        utilityNotchEnabled: _initialConfig.utilityNotchEnabled !== undefined ? _initialConfig.utilityNotchEnabled : false
        clockWidgetEnabled: _initialConfig.clockWidgetEnabled !== undefined ? _initialConfig.clockWidgetEnabled : true
        weatherWidgetEnabled: _initialConfig.weatherWidgetEnabled !== undefined ? _initialConfig.weatherWidgetEnabled : true
        profiles: _initialConfig.profiles !== undefined ? _initialConfig.profiles : []
        activeProfile: _initialConfig.activeProfile !== undefined ? _initialConfig.activeProfile : ""
        barClockEnabled: _initialConfig.barClockEnabled !== undefined ? _initialConfig.barClockEnabled : true
        barWorkspacesEnabled: _initialConfig.barWorkspacesEnabled !== undefined ? _initialConfig.barWorkspacesEnabled : true
        barBatteryEnabled: _initialConfig.barBatteryEnabled !== undefined ? _initialConfig.barBatteryEnabled : true
        barPosition: _initialConfig.barPosition !== undefined ? _initialConfig.barPosition : "Top"
    }
    
    // Ephemeral UI state
    property string searchQuery: ""

    readonly property int animDuration: store.animationSpeed

    readonly property string _statePath: Quickshell.env("HOME") + "/.config/quickshell/Settings/Config/settings.json"

    Timer {
        id: saveTimer
        interval: 300
        repeat: false
        onTriggered: {
            var obj = {
                themeMode: store.themeMode,
                transparency: store.transparency,
                animationSpeed: store.animationSpeed,
                blurEnabled: store.blurEnabled,
                blurSize: store.blurSize,
                blurPasses: store.blurPasses,
                musicWidgetEnabled: store.musicWidgetEnabled,
                utilityNotchEnabled: store.utilityNotchEnabled,
                clockWidgetEnabled: store.clockWidgetEnabled,
                weatherWidgetEnabled: store.weatherWidgetEnabled,
                barPosition: store.barPosition
            }
            saveProc.exec(["sh", "-c",
                "mkdir -p " + Quickshell.env("HOME") + "/.config/quickshell/Settings/Config && printf '%s' " + JSON.stringify(JSON.stringify(obj)) + " > " + JSON.stringify(root._statePath) + " && hyprctl reload && " + Quickshell.env("HOME") + "/.config/quickshell/colors/apply_theme.sh " + store.themeMode
            ])
        }
    }

    function _scheduleSave() {
        saveTimer.restart()
    }

    Process { id: saveProc }

    Component.onCompleted: {
        // Initialization handled inline via _initialConfig
    }

    Connections {
        target: store
        function onThemeModeChanged() { _scheduleSave() }
        function onTransparencyChanged() { _scheduleSave() }
        function onAnimationSpeedChanged() { _scheduleSave() }
        function onBlurEnabledChanged() { _scheduleSave() }
        function onBlurSizeChanged() { _scheduleSave() }
        function onBlurPassesChanged() { _scheduleSave() }
        function onMusicWidgetEnabledChanged() { _scheduleSave() }
        function onUtilityNotchEnabledChanged() { _scheduleSave() }
        function onClockWidgetEnabledChanged() { _scheduleSave() }
        function onWeatherWidgetEnabledChanged() { _scheduleSave() }
        function onProfilesChanged() { _scheduleSave() }
        function onActiveProfileChanged() { _scheduleSave() }
        
        function onBarClockEnabledChanged() { _scheduleSave() }
        function onBarWorkspacesEnabledChanged() { _scheduleSave() }
        function onBarBatteryEnabledChanged() { _scheduleSave() }
        function onBarPositionChanged() { _scheduleSave() }
    }
}
