import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.MusicWidget

Popup {
    id: root

    modal:  true
    focus:  true
    width:  320
    height: 440
    // Center relative to parent window, not Overlay (which needs an ApplicationWindow)
    x: parent ? Math.round((parent.width  - width)  / 2) : 0
    y: parent ? Math.round((parent.height - height) / 2) : 0

    background: Rectangle {
        color:        Theme.surfaceColor
        radius:       MusicConfig.widgetRadius
        border.color: Theme.accentColorPrimary
        border.width: 1
    }

    signal gifApplied(string source)
    property string selectedGif: ""

    // GIF scanner — declared as a property so it lives in data, not the visual tree
    property var gifScanner: GifSelector { id: _gifScanner }

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: 12
        spacing: 8

        Text {
            text:  "Select GIF"
            font.pixelSize: 17
            font.bold: true
            color: Theme.textColor
            Layout.alignment: Qt.AlignHCenter
        }

        ListView {
            id: gifList
            Layout.fillWidth:  true
            Layout.fillHeight: true
            clip: true
            model: _gifScanner.model

            ScrollBar.vertical: ScrollBar {}

            delegate: Rectangle {
                width:  gifList.width
                height: 36
                color:  root.selectedGif === model.filePath
                        ? Theme.accentColorPrimary
                        : (delegateArea.containsMouse ? Theme.raisedSurfaceColor : "transparent")
                radius: 6
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:          parent.left
                    anchors.leftMargin:    10
                    text:  model.fileName
                    color: root.selectedGif === model.filePath
                           ? Theme.backgroundColor
                           : Theme.textColor
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: delegateArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.selectedGif    = model.filePath;
                        previewImage.source = model.filePath;
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: gifList.count === 0
                text:    "No GIFs found in\nassets/gif/"
                color:   Theme.mutedTextColor
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
            }
        }

        AnimatedImage {
            id: previewImage
            width:  100
            height: 100
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignHCenter
            playing: root.visible && source !== ""
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Rectangle {
                width: 90; height: 36; radius: 8
                color: cancelArea.containsMouse ? Theme.raisedSurfaceColor : Theme.surfaceColor
                border.color: Theme.mutedTextColor; border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "Cancel"; color: Theme.textColor; font.pixelSize: 13 }
                MouseArea { id: cancelArea; anchors.fill: parent; hoverEnabled: true; onClicked: root.close() }
            }

            Rectangle {
                width: 90; height: 36; radius: 8
                color: root.selectedGif !== ""
                       ? (applyArea.containsMouse ? Theme.accentColorSecondary : Theme.accentColorPrimary)
                       : Theme.raisedSurfaceColor
                opacity: root.selectedGif !== "" ? 1.0 : 0.4
                Behavior on color { ColorAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "Apply"; color: Theme.backgroundColor; font.pixelSize: 13; font.bold: true }
                MouseArea {
                    id: applyArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.selectedGif !== ""
                    onClicked: { root.gifApplied(root.selectedGif); root.close() }
                }
            }
        }
    }
}
