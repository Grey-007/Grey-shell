import QtQuick

QtObject {
    property string themeMode: "Dark"
    property real transparency: 70
    property int animationSpeed: 250
    property bool blurEnabled: true
    property int blurSize: 3
    property int blurPasses: 1
    
    property bool musicWidgetEnabled: true
    property bool utilityNotchEnabled: true
    property bool clockWidgetEnabled: true
    property bool weatherWidgetEnabled: true
    
    // Phase 4: Power User Features
    property var profiles: []
    property string activeProfile: "Default"
    
    // Bar Settings
    property bool barClockEnabled: true
    property bool barWorkspacesEnabled: true
    property bool barBatteryEnabled: true
    property string barPosition: "Top"
}
