import "."
import QtQuick

// Search pill only – no tag strip
Item {
    id: root

    implicitHeight: 38
    implicitWidth:  500

    Rectangle {
        anchors.fill: parent
        radius: 19
        color:  "#CC0D110A"

        Row {
            anchors {
                left: parent.left; right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 14; rightMargin: 14
            }
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "⌕"
                font.pixelSize: 16
                color: "#9DB88A"
            }

            TextInput {
                id: _input
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 70
                color: "#DDE8CC"
                font.pixelSize: 13
                clip: true
                text: WallpaperState.searchText

                onTextChanged: WallpaperState.searchText = text

                Connections {
                    target: WallpaperState
                    function onVisibleChanged() {
                        if (WallpaperState.visible) {
                            _input.forceActiveFocus();
                            _input.text = "";
                        }
                    }
                }

                Keys.onEscapePressed: {
                    if (_input.text !== "") _input.text = "";
                    else WallpaperState.close();
                }

                Text {
                    anchors.fill: parent
                    text: "Search wallpapers…"
                    color: "#3A4830"
                    font.pixelSize: 13
                    visible: _input.text === "" && !_input.activeFocus
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: WallpaperState.filteredWallpapers.length
                color: "#6A8860"
                font.pixelSize: 11
                font.weight: Font.Medium
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "✕"
                font.pixelSize: 11
                color: "#9DB88A"
                visible: _input.text !== ""
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: _input.text = ""
                }
            }
        }
    }
}
