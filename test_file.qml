import QtQuick
import Quickshell
import Quickshell.Io

Item {
    Component.onCompleted: {
        var file = Quickshell.Io.File // Is this a type?
        console.log("File is: " + file)
        Qt.quit()
    }
}
