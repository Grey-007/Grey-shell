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

    property bool isNewTile: false

    signal chosen(string path)

    // Pointy-top hex: H = W * 2/sqrt(3) ≈ W * 1.1547
    width:  128
    height: 148

    property real _visualScale: pointer.containsMouse ? hoverScale : 1.0
    z: pointer.containsMouse ? 10 : selected ? 5 : 1

    // Entrance / exit animation state — driven by HoneycombGrid
    property real _entX:  0.0
    property real _entOp: 1.0
    property real _entSc: 1.0

    readonly property string imageUrl: path.length > 0 ? ("file://" + encodeURI(path)) : ""

    // ── Shadow ─────────────────────────────────────────────────────
    Canvas {
        id: shadowC
        anchors.fill:      hexBody
        anchors.topMargin: 8
        opacity: pointer.containsMouse ? 0.55 : 0.28
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

    // ── Hex body ───────────────────────────────────────────────────
    Item {
        id: hexBody
        width:  root.width
        height: root.height
        anchors.centerIn: parent
        scale: root._visualScale * root._entSc

        Behavior on scale {
            NumberAnimation { duration: root.hoverDuration; easing.type: Easing.OutCubic }
        }

        // Hidden Image — Qt decodes asynchronously at exact tile size
        // with PreserveAspectCrop so the cached pixels are already
        // centred-cropped. Canvas drawImage reads from this cache instantly.
        Image {
            id: img
            anchors.fill: parent
            source:       root.imageUrl
            // Exact tile size — Qt crops and centres for us, no manual math
            sourceSize:   Qt.size(root.width, root.height)
            asynchronous: true
            cache:        true
            visible:      false
            fillMode:     Image.PreserveAspectCrop
            smooth:       true

            onStatusChanged: {
                if (status === Image.Ready) hexC.requestPaint()
            }
        }

        // Hex-clipped canvas — just draws the pre-cropped cached image
        Canvas {
            id: hexC
            anchors.fill:   parent
            antialiasing:   true
            renderStrategy: Canvas.Threaded
            renderTarget:   Canvas.FramebufferObject

            onPaint: {
                var ctx = getContext("2d")
                var w = width, h = height
                ctx.clearRect(0, 0, w, h)
                ctx.save()

                // Clip to hex shape
                pointyHex(ctx, w, h)
                ctx.clip()

                if (img.status === Image.Ready && isImageLoaded(root.imageUrl)) {
                    // Qt already decoded at tile size with centred crop — draw directly
                    ctx.drawImage(root.imageUrl, 0, 0, w, h)
                } else {
                    // Dark placeholder while loading
                    ctx.fillStyle = "#1a1e24"
                    ctx.fill()
                    // Kick canvas-internal load so onImageLoaded fires
                    loadImage(root.imageUrl)
                }

                ctx.restore()

                // Hex border on top
                ctx.lineJoin    = "round"
                ctx.lineWidth   = root.selected ? 3.5
                               : pointer.containsMouse ? 2.5 : 1.2
                ctx.strokeStyle = root.selected
                    ? root.selectedBorderColor
                    : pointer.containsMouse ? root.hoverBorderColor : "#40ffffff"
                pointyHex(ctx, w, h)
                ctx.stroke()
            }

            onImageLoaded: requestPaint()
        }

        // Selected glow
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

    // ── Label — slides up on hover ─────────────────────────────────
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
        // Pre-load into canvas image cache too — if Qt cache already has it,
        // this is instant and onImageLoaded fires before next paint frame
        if (root.imageUrl.length > 0)
            hexC.loadImage(root.imageUrl)
        hexC.requestPaint()
    }

    // ── awww apply animation — grow + spring bounce ────────────────
    function playApplyAnim() {
        applyAnim.restart()
    }

    SequentialAnimation {
        id: applyAnim
        running: false
        NumberAnimation {
            target: root; property: "_entSc"
            from: 1.0; to: 1.24
            duration: 160; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root; property: "_entSc"; to: 0.94
            duration: 130; easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: root; property: "_entSc"; to: 1.06
            duration: 110; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root; property: "_entSc"; to: 1.0
            duration: 90;  easing.type: Easing.OutCubic
        }
    }

    // ── Correct pointy-top hex corners ────────────────────────────
    // For a pointy-top hex fitting exactly in W×H bounding box:
    //   Top:       (W/2,   0   )
    //   Top-right: (W,     H/4 )
    //   Bot-right: (W,     3H/4)
    //   Bottom:    (W/2,   H   )
    //   Bot-left:  (0,     3H/4)
    //   Top-left:  (0,     H/4 )
    // This fills the bounding box edge-to-edge (no wasted pixels).
    function pointyHex(ctx, w, h): void {
        var h4 = h / 4
        ctx.beginPath()
        ctx.moveTo(w / 2, 0)
        ctx.lineTo(w,     h4)
        ctx.lineTo(w,     h - h4)
        ctx.lineTo(w / 2, h)
        ctx.lineTo(0,     h - h4)
        ctx.lineTo(0,     h4)
        ctx.closePath()
    }
}
