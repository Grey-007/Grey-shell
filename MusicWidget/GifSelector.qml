import QtQuick
import Quickshell
import Quickshell.Io

// Scans assets/gif/ and exposes a ListModel of { fileName, filePath }.
// Root is Item so Process/StdioCollector can be children via the data property.
Item {
    id: root
    visible: false  // purely logical, not visual

    readonly property string gifDir: Quickshell.shellRoot + "/assets/gif"
    property ListModel model: ListModel {}

    function refresh() {
        lsProc.running = true;
    }

    Process {
        id: lsProc
        command: ["bash", "-c", "ls -1 \"" + root.gifDir + "\" 2>/dev/null | grep -i '\\.gif$'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.model.clear();
                var lines = this.text.trim().split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var name = lines[i].trim();
                    if (name !== "")
                        root.model.append({ fileName: name, filePath: root.gifDir + "/" + name });
                }
            }
        }
    }
}
