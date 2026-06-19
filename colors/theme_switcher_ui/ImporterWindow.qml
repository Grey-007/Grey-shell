import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../"

Rectangle {
    id: root

    signal imported(string themeName)
    signal canceled()

    color: ThemeManager.bg
    border.color: ThemeManager.accentSoft
    border.width: 2
    radius: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Import Custom Theme"
            color: ThemeManager.fg
            font.family: "monospace"
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        Text {
            text: "Enter absolute path to your theme color file:"
            color: ThemeManager.fgMid
            font.family: "monospace"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: "transparent"
            border.color: fileInput.activeFocus ? ThemeManager.accent : ThemeManager.border
            border.width: 2

            TextInput {
                id: fileInput
                anchors.fill: parent
                anchors.margins: 8
                color: ThemeManager.fg
                font.family: "monospace"
                font.pixelSize: 12
                clip: true
            }
        }
        
        Text {
            id: errorText
            color: ThemeManager.errorText
            font.family: "monospace"
            font.pixelSize: 11
            visible: text !== ""
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 32
                color: cancelMa.containsMouse ? ThemeManager.surfaceTop : ThemeManager.surfaceHigh
                border.color: ThemeManager.border
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: ThemeManager.fg
                    font.family: "monospace"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: cancelMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.canceled()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                color: importMa.containsMouse ? ThemeManager.accent : ThemeManager.surfaceHigh
                border.color: ThemeManager.accent
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Import"
                    color: importMa.containsMouse ? ThemeManager.fgInverted : ThemeManager.accent
                    font.family: "monospace"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: importMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        errorText.text = ""
                        var path = fileInput.text.trim()
                        if (path === "") {
                            errorText.text = "Path cannot be empty"
                            return
                        }
                        
                        importProc.exec(["python3", Quickshell.env("HOME") + "/.config/quickshell/colors/import_theme.py", path])
                    }
                }
            }
        }
    }

    Process {
        id: importProc
        stdout: StdioCollector {
            onStreamFinished: {
                var outStr = this.text.trim()
                if (outStr.startsWith("SUCCESS: ")) {
                    var themeName = outStr.substring(9)
                    root.imported(themeName)
                    fileInput.text = ""
                } else if (outStr !== "") {
                    errorText.text = outStr
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                var errStr = this.text.trim()
                if (errStr !== "") {
                    errorText.text = errStr
                }
            }
        }
    }
}
