import QtQuick

Item {
    Component.onCompleted: {
        var xhr = new XMLHttpRequest()
        try {
            xhr.open("GET", "file:///etc/hostname", false)
            xhr.send()
            console.log("XHR read: " + xhr.responseText)
        } catch(e) {
            console.log("XHR error: " + e)
        }
        Qt.quit()
    }
}
