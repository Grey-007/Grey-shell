// AppList.qml

import Quickshell
import QtQuick
import QtQuick.Controls

ListView {
    id: appList

    property var appSearch
    property color border
    property color fg
    property color fgMid
    property color fillColor
    property color fillText

    signal appLaunched()

    clip: true
    currentIndex: 0
    spacing: 0
    model: appSearch ? appSearch.model : null

    function launchCurrent(): void {
        if (launch(currentIndex))
            appLaunched();
    }

    function launch(index: int): bool {
        return appSearch ? appSearch.launch(index) : false;
    }

    Connections {
        target: appList.appSearch
        function onRebuilt(): void {
            appList.currentIndex = 0;
        }
    }

    delegate: Item {
        id: delegateRoot
        width: appList.width
        height: 50

        property bool hovered: rowMa.containsMouse

        Rectangle {
            id: fillRect
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: delegateRoot.hovered ? parent.width : 0
            color: appList.fillColor

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1
            color: appList.border
            opacity: 0.35
        }

        Rectangle {
            visible: appList.currentIndex === index
            width: 3
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            color: delegateRoot.hovered ? appList.fillText : appList.border
        }

        Image {
            id: appIcon
            anchors {
                left: parent.left
                leftMargin: 18
                verticalCenter: parent.verticalCenter
            }
            width: 28
            height: 28
            source: model.icon ? Quickshell.iconPath(model.icon, true) : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true

            Rectangle {
                anchors.fill: parent
                visible: appIcon.status !== Image.Ready || appIcon.source === ""
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: model.name.charAt(0).toUpperCase()
                    color: delegateRoot.hovered ? appList.fillText : appList.fgMid
                    font { pixelSize: 15; family: "monospace"; weight: Font.Bold }
                }
            }
        }

        Text {
            anchors {
                left: appIcon.right
                leftMargin: 14
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            text: model.name
            color: delegateRoot.hovered ? appList.fillText : appList.fg
            font {
                family: "monospace"
                pixelSize: 13
            }
            elide: Text.ElideRight

            Behavior on color {
                ColorAnimation { duration: 80 }
            }
        }

        MouseArea {
            id: rowMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: appList.currentIndex = index
            onClicked: {
                if (appList.launch(index))
                    appList.appLaunched();
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: appList.count === 0
        text: "No applications found"
        color: appList.fgMid
        font {
            family: "monospace"
            pixelSize: 13
        }
    }

    ScrollBar.vertical: ScrollBar {
        id: vScrollBar
        policy: ScrollBar.AsNeeded

        contentItem: Rectangle {
            implicitWidth: 6
            implicitHeight: 50
            color: appList.border
            opacity: vScrollBar.active ? 0.6 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        background: Rectangle {
            color: "transparent"
        }
    }
}
