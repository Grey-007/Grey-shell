import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    layer.enabled: true
    layer.smooth: true

    property int cardWidth: 450
    property int cardHeight: 434
    property int flareWidth: 54
    property int flareHeight: 70
    property real openProgress: LauncherState.open ? 1 : 0
    readonly property color panelColor: "#fdf7f4"
    readonly property color panelLipColor: "#fcf1ed"
    readonly property color borderColor: "#aaa491"
    readonly property color searchColor: "#f2dcda"

    function paintFlare(ctx, mirror, w, h) {
        ctx.clearRect(0, 0, w, h);
        ctx.save();
        if (mirror) {
            ctx.translate(w, 0);
            ctx.scale(-1, 1);
        }
        ctx.shadowColor = "#554f431d";
        ctx.shadowBlur = 12;
        ctx.shadowOffsetY = -1;
        ctx.fillStyle = panelLipColor;
        ctx.beginPath();
        ctx.moveTo(w, 0);
        ctx.bezierCurveTo(w * 0.95, h * 0.28, w * 0.76, h * 0.64, w * 0.34, h * 0.82);
        ctx.bezierCurveTo(w * 0.15, h * 0.9, w * 0.04, h * 0.98, 0, h);
        ctx.lineTo(w, h);
        ctx.lineTo(w, 0);
        ctx.closePath();
        ctx.fill();
        ctx.shadowColor = "transparent";
        ctx.strokeStyle = borderColor;
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.moveTo(w - 0.5, 0.5);
        ctx.bezierCurveTo(w * 0.95, h * 0.28, w * 0.76, h * 0.64, w * 0.34, h * 0.82);
        ctx.bezierCurveTo(w * 0.15, h * 0.9, w * 0.04, h * 0.98, 0.5, h - 0.5);
        ctx.stroke();
        ctx.restore();
    }

    width: cardWidth + flareWidth * 2
    height: cardHeight
    enabled: LauncherState.open || openProgress > 0.01
    opacity: openProgress
    transform: [
        Translate {
            y: (1 - root.openProgress) * 68
        },
        Scale {
            origin.x: root.width / 2
            origin.y: root.height
            xScale: 0.97 + root.openProgress * 0.03
            yScale: 0.965 + root.openProgress * 0.035
        }
    ]

    DropShadow {
        anchors.fill: body
        horizontalOffset: 0
        verticalOffset: -1
        radius: 18
        samples: 36
        color: "#554f4326"
        source: body
        transparentBorder: true
    }

    Canvas {
        id: leftFlare

        x: 0
        y: root.cardHeight - root.flareHeight
        width: root.flareWidth
        height: root.flareHeight
        opacity: root.openProgress
        onPaint: root.paintFlare(getContext("2d"), false, width, height)
    }

    Canvas {
        id: rightFlare

        x: root.flareWidth + root.cardWidth
        y: root.cardHeight - root.flareHeight
        width: root.flareWidth
        height: root.flareHeight
        opacity: root.openProgress
        onPaint: root.paintFlare(getContext("2d"), true, width, height)
    }

    Rectangle {
        id: body

        x: root.flareWidth
        y: 0
        width: root.cardWidth
        height: root.cardHeight
        radius: 18
        color: root.panelColor
        border.color: root.borderColor
        border.width: 1
        antialiasing: true

        Rectangle {
            height: parent.radius + 1
            color: root.panelLipColor

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

        }

        Rectangle {
            height: 1
            color: root.panelLipColor

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

        }

    }

    MouseArea {
        anchors.fill: body
        z: 1
        enabled: LauncherState.open
        onClicked: function(mouse) {
            mouse.accepted = true;
        }
    }

    ListView {
        id: appList

        z: 2
        clip: true
        model: LauncherState.filteredApps
        currentIndex: LauncherState.selectedIndex
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
        keyNavigationEnabled: true
        highlightMoveDuration: 120
        highlightResizeDuration: 120
        onCurrentIndexChanged: {
            if (currentIndex >= 0)
                LauncherState.selectedIndex = currentIndex;

        }

        anchors {
            left: body.left
            right: body.right
            top: body.top
            bottom: searchBar.top
            leftMargin: 14
            rightMargin: 14
            topMargin: 10
            bottomMargin: 8
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 3

            contentItem: Rectangle {
                radius: 2
                color: "#9c938633"
            }

        }

        delegate: AppRow {
            required property var modelData
            required property int index

            width: appList.width
            entry: modelData
            selected: ListView.isCurrentItem
            rowIndex: index
            onHovered: {
                appList.currentIndex = index;
                appList.positionViewAtIndex(index, ListView.Contain);
            }
            onLaunched: LauncherState.launch(modelData)
        }

    }

    Item {
        id: searchBar

        z: 3
        height: 31

        anchors {
            left: body.left
            right: body.right
            bottom: body.bottom
            leftMargin: 14
            rightMargin: 14
            bottomMargin: 22
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: root.searchColor
            border.color: "#ead4d1"
            border.width: 1
            antialiasing: true
        }

        Text {
            text: "⌕"
            font.pixelSize: 15
            color: "#5c5552"

            anchors {
                left: parent.left
                leftMargin: 13
                verticalCenter: parent.verticalCenter
            }

        }

        TextInput {
            id: searchField

            text: LauncherState.query
            color: "#4c4643"
            selectionColor: "#d7bbb8"
            selectedTextColor: "#2f2a28"
            font.pixelSize: 12
            clip: true
            onTextChanged: {
                if (LauncherState.query !== text) {
                    LauncherState.query = text;
                    LauncherState.selectedIndex = 0;
                    Qt.callLater(function() {
                        appList.positionViewAtBeginning();
                    });
                }
            }
            onAccepted: {
                const apps = LauncherState.filteredApps;
                if (apps.length > 0) {
                    const index = Math.max(0, Math.min(appList.currentIndex, apps.length - 1));
                    LauncherState.launch(apps[index]);
                }
            }
            Keys.onEscapePressed: LauncherState.close()
            Keys.onDownPressed: {
                if (appList.count > 0) {
                    appList.currentIndex = Math.min(appList.count - 1, appList.currentIndex + 1);
                    appList.positionViewAtIndex(appList.currentIndex, ListView.Contain);
                }
            }
            Keys.onUpPressed: {
                if (appList.count > 0) {
                    appList.currentIndex = Math.max(0, appList.currentIndex - 1);
                    appList.positionViewAtIndex(appList.currentIndex, ListView.Contain);
                }
            }

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 36
                rightMargin: 12
            }

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: "Type \">\" for commands"
                color: "#867d78"
                font.pixelSize: 12
                visible: searchField.text === ""
            }

        }

    }

    Connections {
        function onOpenChanged() {
            if (LauncherState.open) {
                LauncherState.selectedIndex = 0;
                Qt.callLater(function() {
                    searchField.forceActiveFocus();
                    appList.currentIndex = appList.count > 0 ? 0 : -1;
                    appList.positionViewAtBeginning();
                });
            }
        }

        function onQueryChanged() {
            Qt.callLater(function() {
                appList.currentIndex = appList.count > 0 ? 0 : -1;
                appList.positionViewAtBeginning();
            });
        }

        target: LauncherState
    }

    Behavior on openProgress {
        NumberAnimation {
            duration: 420
            easing.type: Easing.OutQuint
        }

    }

}
