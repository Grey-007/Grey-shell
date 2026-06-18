// FilmFrame.qml
import QtQuick

Item {
    id: root

    property string imageSource: ""
    property bool isSelected: false
    
    signal clicked()
    signal doubleClicked()

    width: 200
    height: 120

    Rectangle {
        anchors.fill: parent
        color: "#241D18"
        border.color: root.isSelected ? "#A67C52" : (ma.containsMouse ? "#A67C52" : "#5A4736")
        border.width: root.isSelected ? 4 : 2

        Image {
            anchors.fill: parent
            anchors.margins: root.isSelected ? 4 : 2
            source: root.imageSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            sourceSize.height: 120 // Force small memory footprint
            sourceSize.width: 200
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
            onDoubleClicked: root.doubleClicked()
        }
    }
}
