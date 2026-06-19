pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string fontFamily: "monospace"
    property int fontSize: 64
    property int xPos: 100
    property int yPos: 100

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/utils/widgets/clockwidget/config.json"

    function save() {
        var data = {
            fontFamily: root.fontFamily,
            fontSize: root.fontSize,
            xPos: root.xPos,
            yPos: root.yPos
        }
        saveProc.exec(["sh", "-c", "printf '%s' " + JSON.stringify(JSON.stringify(data)) + " > " + JSON.stringify(configPath)])
    }

    property Process saveProc: Process {}

    property Process loadProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var obj = JSON.parse(this.text.trim())
                    if (obj) {
                        if (obj.fontFamily) root.fontFamily = obj.fontFamily
                        if (obj.fontSize) root.fontSize = obj.fontSize
                        if (obj.xPos !== undefined) root.xPos = obj.xPos
                        if (obj.yPos !== undefined) root.yPos = obj.yPos
                    }
                } catch(e) {}
            }
        }
    }

    Component.onCompleted: {
        loadProc.exec(["sh", "-c", "cat " + JSON.stringify(configPath) + " 2>/dev/null || echo '{}'"])
    }
}
