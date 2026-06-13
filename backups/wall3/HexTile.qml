import QtQuick

Item {
    id: root

    required property string path
    required property string name
    property bool   selected:            false
    property color  selectedBorderColor: "#7df7c3"
    property color  hoverBorderColor:    "#ffffff"
    property color  shadowColor:         "#44000000"
    property color  labelColor:          "#f6f7f2"
    property int    hoverDuration:       140
    property real   hoverScale:          1.09

    // Entrance animation — driven by HoneycombGrid
    // isNewTile: true = this tile is newly revealed (animate in)
    //            false = it was already visible (stays put, no animation)
    property bool isNewTile: false

    signal chosen(string path)

    // ── Geometry ───────────────────────────────────────────────────
    // Pointy-top hexagon: width = sqrt(3)*R, height = 2*R
    // We set width; height is derived so proportions are always correct.
    width:  128
    height: 148   // ≈ width * 2/sqrt(3)

    // Hover scale — only on the visual content, not the hit area
    property real _visualScale: pointer.containsMouse ? hoverScale : 1.0
    z: pointer.containsMouse ? 10 : selected ? 5 : 1

    // ── Entrance animation state ───────────────────────────────────
    property real _entX:  0.0    // X offset (slides in from right/left)
    property real _entOp: 1.0    // opacity
    property real _entSc: 1.0    // scale multiplier

    readonly property string imageUrl: path.length > 0 ? "file://" + encodeURI(path) : ""

    // ── Shadow ─────────────────────────────────────────────────────
    Canvas {
        id: shadowC
        anchors.fill:      hexBody
        anchors.topMargin: 8
        opacity: pointer.containsMouse ? 0.55 : 0.30
        Behavior on opacity { NumberAnimation { duration: root.hoverDuration } }
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = root.shadowColor
            pointyHex(ctx, width, height)
            ctx.fill()
        }
        Component.onCompleted: requestPaint()
    }

    // ── Hex body (clip container + image + border) ─────────────────
    Item {
        id: hexBody
        width:  root.width
        height: root.height
        anchors.centerIn: parent

        // Scale + entrance transforms applied here so shadow tracks correctly
        scale: root._visualScale * root._entSc

        Behavior on scale {
            NumberAnimation { duration: root.hoverDuration; easing.type: Easing.OutCubic }
        }

        // Async image — decoded at 2× tile size, cached by Qt
        Image {
            id: img
            anchors.fill: parent
            source:      root.imageUrl
            sourceSize:  Qt.size(root.width , root.height )
            asynchronous: true
            cache:        true
            visible:      false     // canvas draws it, image just populates cache
            fillMode:     Image.PreserveAspectCrop

            onStatusChanged: {
                if (status === Image.Ready) hexC.requestPaint()
            }
        }

        // Hex clip canvas — draws image from Qt cache (instant after async load)
        Canvas {
            id: hexC
            anchors.fill:    parent
            antialiasing:    true
            renderStrategy:  Canvas.Threaded
            renderTarget:    Canvas.FramebufferObject

            onPaint: {
                var ctx = getContext("2d")
                var w = width, h = height
                ctx.clearRect(0, 0, w, h)
                ctx.save()
                pointyHex(ctx, w, h)
                ctx.clip()

                    if (img.status === Image.Ready && isImageLoaded(root.imageUrl)) {
                       // Qt already decoded at tile size with centred crop — just draw it
                        ctx.drawImage(root.imageUrl, 0, 0, w, h)
                    }
                } 


            onImageLoaded: requestPaint()
        }

        // Selected glow ring (separate canvas so it doesn't re-clip)
        Canvas {
            id: glowC
            anchors.fill: parent
            antialiasing: true
            visible:      root.selected
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.shadowColor = root.selectedBorderColor
                ctx.shadowBlur  = 16
                ctx.lineWidth   = 4
                ctx.strokeStyle = root.selectedBorderColor
                pointyHex(ctx, width, height)
                ctx.stroke()
            }
            onVisibleChanged: if (visible) requestPaint()
        }
    }

    // ── Filename label — slides up on hover ────────────────────────
    Item {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 32
        clip:   true

        Rectangle {
            anchors { left: parent.left; right: parent.right; leftMargin: 14; rightMargin: 14 }
            y:      pointer.containsMouse ? (parent.height - height - 4) : parent.height
            height: 20
            radius: 4
            color:  "#cc000000"
            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            Text {
                anchors { fill: parent; margins: 4 }
                text:  root.name
                elide: Text.ElideMiddle
                color: root.labelColor
                font.pixelSize:      9
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
            }
        }
    }

    // ── Hit area ───────────────────────────────────────────────────
    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.chosen(root.path)
        onContainsMouseChanged: hexC.requestPaint()
    }

    onSelectedChanged: { hexC.requestPaint(); glowC.requestPaint() }
    onPathChanged: {
        img.source = root.imageUrl
        hexC.requestPaint()
    }

    // ── awww apply animation — grow ripple ─────────────────────────
    function playApplyAnim() {
        applyAnim.restart()
    }

    SequentialAnimation {
        id: applyAnim
        running: false
        // Quick grow
        NumberAnimation {
            target: root; property: "_entSc"
            from: 1.0; to: 1.22
            duration: 180; easing.type: Easing.OutCubic
        }
        // Spring back with overshoot
        NumberAnimation {
            target: root; property: "_entSc"
            to: 0.96
            duration: 140; easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: root; property: "_entSc"
            to: 1.04
            duration: 120; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root; property: "_entSc"
            to: 1.0
            duration: 100; easing.type: Easing.OutCubic
        }
    }

    // ── Pointy-top hex path ────────────────────────────────────────
    // Corners: top, top-right, bot-right, bot, bot-left, top-left
    function pointyHex(ctx, w, h): void {
        var cx = w / 2, cy = h / 2
        var rx = w / 2, ry = h / 2
        ctx.beginPath()
        // 6 corners at angles: 90, 30, -30, -90, -150, 150  (pointy top)
        var angles = [-90, -30, 30, 90, 150, 210]  // degrees
        for (var i = 0; i < 6; i++) {
            var rad = angles[i] * Math.PI / 180
            var px  = cx + rx * Math.cos(rad)
            var py  = cy + ry * Math.sin(rad)
            if (i === 0) ctx.moveTo(px, py)
            else         ctx.lineTo(px, py)
        }
        ctx.closePath()
    }
}
