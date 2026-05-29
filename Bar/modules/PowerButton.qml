import QtQuick

Item {
    id: root

    width: powerRing.implicitWidth
    height: 36
    implicitWidth: width
    implicitHeight: height

    signal clicked()

    MetricRing {
        id: powerRing

        iconXOffset: 0
        anchors.centerIn: parent
        icon: "⏻"
        value: 100
        valueVisible: false
        iconSize: 15
        onClicked: root.clicked()
    }
}
