// ConfigPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property var config: null

    color: "#241D18"
    border.color: "#5A4736"
    border.width: 2

    // Avoid bindings loops, update UI from config when config changes
    Connections {
        target: root.config
        function onIsLoadedChanged() {
            if (root.config && root.config.isLoaded) {
                dirInput.text = root.config.wallpaperDirectory
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 24

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            // Directory config
            RowLayout {
                spacing: 16
                Text {
                    text: "Directory:"
                    color: "#F2E0C8"
                    font.family: "monospace"
                    font.pixelSize: 14
                    Layout.preferredWidth: 80
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    color: "transparent"
                    border.color: dirInput.activeFocus ? "#A67C52" : "#5A4736"
                    border.width: 2

                    TextInput {
                        id: dirInput
                        anchors.fill: parent
                        anchors.margins: 8
                        color: "#F2E0C8"
                        font.family: "monospace"
                        font.pixelSize: 14
                        clip: true
                        onEditingFinished: {
                            if (root.config) {
                                root.config.wallpaperDirectory = text
                                root.config.save()
                            }
                        }
                    }
                }
            }

            // Animation Type
            RowLayout {
                spacing: 16
                Text {
                    text: "Animation:"
                    color: "#F2E0C8"
                    font.family: "monospace"
                    font.pixelSize: 14
                    Layout.preferredWidth: 80
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: ["fade", "grow", "left", "right", "top", "bottom", "center", "random"]
                        Rectangle {
                            width: Math.max(60, typeText.implicitWidth + 16)
                            height: 32
                            color: (root.config && root.config.awwwAnimation === modelData) ? "#A67C52" : "transparent"
                            border.color: "#5A4736"
                            border.width: 2

                            Text {
                                id: typeText
                                anchors.centerIn: parent
                                text: modelData
                                color: (root.config && root.config.awwwAnimation === modelData) ? "#241D18" : "#F2E0C8"
                                font.family: "monospace"
                                font.pixelSize: 12
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.config) {
                                        root.config.awwwAnimation = modelData
                                        root.config.save()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Animation Duration
            RowLayout {
                spacing: 16
                Text {
                    text: "Duration:"
                    color: "#F2E0C8"
                    font.family: "monospace"
                    font.pixelSize: 14
                    Layout.preferredWidth: 80
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: [500, 1000, 1500, 2000, 3000]
                        Rectangle {
                            width: 70
                            height: 32
                            color: (root.config && root.config.animationDuration === modelData) ? "#A67C52" : "transparent"
                            border.color: "#5A4736"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: modelData + "ms"
                                color: (root.config && root.config.animationDuration === modelData) ? "#241D18" : "#F2E0C8"
                                font.family: "monospace"
                                font.pixelSize: 12
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.config) {
                                        root.config.animationDuration = modelData
                                        root.config.save()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
