import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
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

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {} // consume click events
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + Quickshell.env("HOME") + "/.config/quickshell/colors/raw_themes"
        showDirs: false
    }

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
            text: "Select a theme from raw_themes:"
            color: ThemeManager.fgMid
            font.family: "monospace"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ComboBox {
            id: themeCombo
            Layout.fillWidth: true
            model: folderModel
            textRole: "fileName"
            
            background: Rectangle {
                implicitHeight: 32
                color: themeCombo.hovered ? ThemeManager.surfaceHigh : "transparent"
                border.color: ThemeManager.border
                border.width: 1
            }

            contentItem: Text {
                leftPadding: 8
                rightPadding: 24
                text: themeCombo.displayText
                color: ThemeManager.fg
                font.family: "monospace"
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }
            
            delegate: ItemDelegate {
                width: themeCombo.width
                height: 32
                highlighted: themeCombo.highlightedIndex === index
                
                contentItem: Text {
                    text: fileName
                    color: highlighted ? ThemeManager.fgInverted : ThemeManager.fg
                    font.family: "monospace"
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    color: highlighted ? ThemeManager.accent : "transparent"
                }
            }

            popup: Popup {
                y: themeCombo.height - 1
                width: themeCombo.width
                implicitHeight: contentItem.implicitHeight > 200 ? 200 : contentItem.implicitHeight
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: themeCombo.popup.visible ? themeCombo.delegateModel : null
                    currentIndex: themeCombo.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    border.color: ThemeManager.border
                    color: ThemeManager.bg
                }
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
                        if (themeCombo.currentIndex < 0) {
                            errorText.text = "Please select a theme"
                            return
                        }
                        
                        var path = folderModel.get(themeCombo.currentIndex, "filePath")
                        if (!path) {
                            errorText.text = "Invalid file path"
                            return
                        }
                        
                        if (path.startsWith("file://")) {
                            path = path.substring(7)
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
