import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./MusicConfig.qml" as Config
import "./Theme.qml" as MusicTheme
import "./GifSelector.qml" as GifSelectorModule

Popup {
    id: modalRoot
    modal: true
    focus: true
    width: 300
    height: 400
    anchors.centerIn: Overlay.overlay
    background: Rectangle { 
        color: MusicTheme.surfaceColor
        radius: Config.widgetRadius 
        border.color: MusicTheme.accentColorPrimary
        border.width: 1
    }

    signal gifApplied(string source)
    property string selectedGif: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            text: "Select GIF"
            font.pixelSize: 18
            color: MusicTheme.textColor
            Layout.alignment: Qt.AlignHCenter
        }

        ListView {
            id: gifListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: GifSelectorModule {}
            delegate: ItemDelegate {
                text: model.fileName
                width: gifListView.width
                onClicked: {
                    modalRoot.selectedGif = "../assets/gif/" + model.fileName
                    previewImage.source = modalRoot.selectedGif
                }
            }
        }

        Image {
            id: previewImage
            width: 100
            height: 100
            Layout.alignment: Qt.AlignHCenter
            fillMode: Image.PreserveAspectFit
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Button { 
                text: "Cancel"
                onClicked: modalRoot.close() 
            }
            Button { 
                text: "Apply"
                enabled: modalRoot.selectedGif !== ""
                onClicked: {
                    modalRoot.gifApplied(modalRoot.selectedGif)
                    modalRoot.close()
                }
            }
        }
    }
}