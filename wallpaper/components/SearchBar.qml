// SearchBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property alias text: searchInput.text
    // True when the inner TextInput has keyboard focus
    readonly property bool inputActive: searchInput.activeFocus

    signal searchChanged(string query)

    height: 40
    color: "#241D18"
    border.color: searchInput.activeFocus ? "#A67C52" : "#5A4736"
    border.width: 2

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        Text {
            text: "⌕"
            color: "#5A4736"
            font.pixelSize: 18
            Layout.alignment: Qt.AlignVCenter
        }

        TextInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: TextInput.AlignVCenter
            color: "#F2E0C8"
            font.family: "monospace"
            font.pixelSize: 14
            clip: true
            selectByMouse: true

            // Placeholder text logic
            Text {
                text: "Search wallpapers..."
                color: "#5A4736"
                font.family: "monospace"
                font.pixelSize: 14
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: searchInput.text === "" && !searchInput.activeFocus
            }

            onTextChanged: {
                root.searchChanged(text)
            }

            // Esc: clear text and drop focus back to keyboard scope
            Keys.onEscapePressed: function(event) {
                searchInput.text = ""
                searchInput.focus = false
                event.accepted = true
            }
        }
    }
}
