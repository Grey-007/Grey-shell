import QtQuick

Item {
    id: root

    required property string path
    required property string name
    property bool selected: false
    property color selectedBorderColor: "#7df7c3"
    property color hoverBorderColor: "#ffffff"
    property color shadowColor: "#66000000"
    property color labelColor: "#f6f7f2"
    property int hoverDuration: 130
    property real hoverScale: 1.08
    property real pageScale: 1.0

    signal chosen(string path)

    width: 126
    height: 110
    scale: pageScale * (pointer.containsMouse ? hoverScale : 1.0)
    z: pointer.containsMouse ? 4 : selected ? 3 : 1

    Behavior on scale {
        NumberAnimation {
            duration: root.hoverDuration
            easing.type: Easing.OutCubic
        }
    }

    readonly property string imageUrl: "file://" + encodeURI(path)

    Canvas {
        id: shadowCanvas
        anchors.fill: imageCanvas
        anchors.topMargin: 5
        opacity: pointer.containsMouse ? 0.42 : 0.26

        onPaint: {
            var ctx = getContext("2d");
            var w = width;
            var h = height;
            ctx.clearRect(0, 0, w, h);
            ctx.fillStyle = root.shadowColor;
            hexPath(ctx, w, h);
            ctx.fill();
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.hoverDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Canvas {
        id: imageCanvas
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: parent.height
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            var w = width;
            var h = height;
            ctx.clearRect(0, 0, w, h);

            ctx.save();
            hexPath(ctx, w, h);
            ctx.clip();

            if (isImageLoaded(root.imageUrl)) {
                ctx.drawImage(root.imageUrl, 0, 0, w, h);
            } else {
                ctx.fillStyle = "#20252a";
                ctx.fillRect(0, 0, w, h);
                loadImage(root.imageUrl);
            }

            ctx.restore();

            ctx.lineJoin = "round";
            ctx.lineWidth = root.selected ? 4 : pointer.containsMouse ? 3 : 1.5;
            ctx.strokeStyle = root.selected
                ? root.selectedBorderColor
                : pointer.containsMouse ? root.hoverBorderColor : "#55ffffff";
            hexPath(ctx, w, h);
            ctx.stroke();
        }

        onImageLoaded: requestPaint()
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 14
            rightMargin: 14
            bottomMargin: 10
        }
        height: 22
        radius: 4
        color: "#99000000"
        opacity: pointer.containsMouse ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: root.hoverDuration
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 8
            }
            text: root.name
            elide: Text.ElideMiddle
            color: root.labelColor
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.chosen(root.path)
        onContainsMouseChanged: imageCanvas.requestPaint()
    }

    onSelectedChanged: imageCanvas.requestPaint()
    onPathChanged: imageCanvas.requestPaint()

    function hexPath(ctx, w, h): void {
        var inset = w * 0.25;
        ctx.beginPath();
        ctx.moveTo(inset, 0);
        ctx.lineTo(w - inset, 0);
        ctx.lineTo(w, h / 2);
        ctx.lineTo(w - inset, h);
        ctx.lineTo(inset, h);
        ctx.lineTo(0, h / 2);
        ctx.closePath();
    }
}
