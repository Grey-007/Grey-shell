import QtQuick

Item {
    id: root

    width:          powerRing.implicitWidth
    height:         36
    implicitWidth:  width
    implicitHeight: height

    signal clicked()

    MetricRing {
        id: powerRing
        anchors.centerIn: parent
        icon:         "⏻"
        iconSize:     15
        value:        100
        valueVisible: false
        // Slightly warmer red-ish tint on hover via ink override
        ink:   hoverArea2.containsMouse ? "#e8856a" : "#d4a45a"
        paper: "#2e2118"
        onClicked: root.clicked()
    }

    // Extra hover detection to tint the power icon
    MouseArea {
        id: hoverArea2
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
