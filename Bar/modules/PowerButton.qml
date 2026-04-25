import QtQuick

Item {
    id: root

    width: 36
    height: 36
    implicitWidth: width
    implicitHeight: height

    signal clicked()

    MetricRing {
        iconXOffset: 0
        anchors.centerIn: parent
        icon: "⏻"
        value: 100
        valueVisible: false
        iconSize: 15
        onClicked: root.clicked()
    }
}
