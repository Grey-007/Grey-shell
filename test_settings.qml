import QtQuick
import QtCore

Item {
    Component.onCompleted: {
        Qt.application.name = "Quickshell"
        Qt.application.organization = "Quickshell"
        Qt.application.domain = "quickshell.org"
    }
    
    Settings {
        id: settings
        property string testVal: "hello"
    }
    
    Timer {
        running: true
        interval: 100
        onTriggered: {
            console.log("Settings loaded, testVal: " + settings.testVal)
            settings.testVal = "world"
            Qt.quit()
        }
    }
}
