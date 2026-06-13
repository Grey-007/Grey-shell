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

    // Staggered entrance animation (set by HoneycombGrid)
    property real entranceY:   0   // offset to slide from
    property real entranceOp:  1   // opacity target

    signal chosen(string path)

    width: 126
    height: 110

    scale: pageScale * (pointer.containsMouse ? hoverScale : 1.0)
    z:     pointer.containsMouse ? 4 : selected ? 3 : 1

    Behavior on scale {
        NumberAnimation { duration: root.hoverDuration; easing.type: Easing.OutCubic }
    }

    // ── Popup / slide-in transform ─────────────────────────────────
    // entranceY is set to a positive value then animated to 0 by HoneycombGrid
    transform: Translate { y: root.entranceY }
    opacity:   root.entranceOp

    readonly property string imageUrl: "file://" + encodeURI(path)

    // ── Drop shadow ────────────────────────────────────────────────
    Canvas {
        id: shadowCanvas
        anchors.fill: imageCanvas
        anchors.topMargin: 7
        opacity: pointer.containsMouse ? 0.52 : 0.28
        Behavior on opacity {
            NumberAnimation { duration: root.hoverDuration; easing.type: Easing.OutCubic }
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = root.shadowColor
            hexPath(ctx, width, height)
            ctx.fill()
        }
        Component.onCompleted: requestPaint()
    }

    // ── Hex-clipped image via layer ────────────────────────────────
    // We render the Image into a layer, then clip via Canvas mask using
    // the layer.effect approach — but the MOST compatible zero-shader
    // approach is: Image inside an Item with layer, clipped by Canvas
    // antialiased mask drawn to a sibling that acts as clip source.
    //
    // Simplest proven approach for Quickshell/Qt6: rectangular Item with
    // layer.enabled, using Canvas clip-path drawn on top of the Image.
    // The Canvas draws the hex clip path and we use clip: true on the item.
    //
    // Actually the cleanest: use a Rectangle with radius=0 and a custom
    // Canvas that draws image via ctx.drawImage but sources the Image element
    // — no, that defeats async loading.
    //
    // BEST APPROACH for Qt6 + performance: Image with layer.enabled + 
    // a Canvas overlay for border only. Clip the Item with a hex-shaped
    // Canvas used as layer.mask (Qt6 supports layer.effect with inline GLSL,
    // but for maximum compat we just let the Image fill and overdraw outside
    // using a Canvas that fills the non-hex area with transparent black).
    //
    // FINAL DECISION: rectangular clip Item containing Image, with a Canvas
    // on top that redraws the hex BORDER only (not clip). The hex shape
    // appearance comes from the Canvas shadow hex underneath + border on top
    // making the rectangular Image corners visually invisible. This avoids
    // ALL the shader/compat issues while keeping async Image perf.
    //
    // For actual hex clip: use Canvas drawImage BUT load image via Image
    // element, then copy pixels. That still blocks. 
    //
    // TRUE SOLUTION: keep Canvas clip approach from original but use
    // Image element's `source` so Qt handles async decode + disk cache.
    // When Image.status === Ready, call imageCanvas.requestPaint() which
    // draws the already-decoded image via drawImage(imageUrl). Qt's image
    // cache means the canvas drawImage is instant — it reads from cache.

    Item {
        id: imageCanvas
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: parent.height
        antialiasing: true

        // Pre-load image asynchronously into Qt's cache at display size.
        // Canvas drawImage then reads from this cache — instant, no block.
        Image {
            id: preloader
            source:      root.path.length > 0 ? root.imageUrl : ""
            // Decode at 2× tile size for crisp rendering — not full wallpaper res
            sourceSize.width:  root.width  * 2
            sourceSize.height: root.height * 2
            asynchronous: true    // background thread decode
            cache:        true    // stays in Qt image cache for canvas.drawImage
            visible:      false   // canvas draws it, not this element directly
            fillMode:     Image.PreserveAspectCrop  // tells Qt what to cache

            onStatusChanged: {
                if (status === Image.Ready)
                    hexCanvas.requestPaint()
            }
        }

        // Hex clip + image draw — canvas.drawImage reads from Qt cache = fast
        Canvas {
            id: hexCanvas
            anchors.fill: parent
            antialiasing: true
            renderStrategy: Canvas.Threaded   // paint off UI thread
            renderTarget:   Canvas.FramebufferObject  // GPU-backed

            onPaint: {
                var ctx = getContext("2d")
                var w = width, h = height
                ctx.clearRect(0, 0, w, h)
                ctx.save()
                hexPath(ctx, w, h)
                ctx.clip()

                if (preloader.status === Image.Ready && isImageLoaded(root.imageUrl)) {
                    // Draw with aspect-crop: compute src crop manually
                    var imgW = preloader.implicitWidth  || w
                    var imgH = preloader.implicitHeight || h
                    var imgAspect  = imgW / imgH
                    var tileAspect = w    / h
                    var srcX, srcY, srcW, srcH
                    if (imgAspect > tileAspect) {
                        // image wider than tile — crop sides
                        srcH = imgH
                        srcW = imgH * tileAspect
                        srcX = (imgW - srcW) / 2
                        srcY = 0
                    } else {
                        // image taller than tile — crop top/bottom
                        srcW = imgW
                        srcH = imgW / tileAspect
                        srcX = 0
                        srcY = (imgH - srcH) / 2
                    }
                    ctx.drawImage(root.imageUrl, srcX, srcY, srcW, srcH, 0, 0, w, h)
                } else {
                    ctx.fillStyle = "#1e2328"
                    ctx.fillRect(0, 0, w, h)
                    // Trigger load into canvas context so onImageLoaded fires
                    loadImage(root.imageUrl)
                }

                ctx.restore()

                // Border
                ctx.lineJoin   = "round"
                ctx.lineWidth  = root.selected ? 4 : pointer.containsMouse ? 3 : 1.5
                ctx.strokeStyle = root.selected
                    ? root.selectedBorderColor
                    : pointer.containsMouse
                        ? root.hoverBorderColor
                        : "#55ffffff"
                hexPath(ctx, w, h)
                ctx.stroke()
            }

            // When canvas finishes its own image load, repaint
            onImageLoaded: requestPaint()
        }
    }

    // ── Filename label (slides up on hover) ───────────────────────
    Item {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 36
        clip: true

        Rectangle {
            anchors {
                left: parent.left; right: parent.right
                leftMargin: 12; rightMargin: 12
            }
            y: pointer.containsMouse ? (parent.height - height - 6) : parent.height
            height: 22
            radius: 5
            color: "#cc000000"

            Behavior on y {
                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
            }

            Text {
                anchors {
                    left: parent.left; right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 6
                }
                text: root.name
                elide: Text.ElideMiddle
                color: root.labelColor
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // ── Selected glow ──────────────────────────────────────────────
    Canvas {
        id: glowCanvas
        anchors.fill: imageCanvas
        visible: root.selected
        opacity: root.selected ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.shadowColor = root.selectedBorderColor
            ctx.shadowBlur  = 12
            ctx.lineWidth   = 3.5
            ctx.strokeStyle = root.selectedBorderColor
            hexPath(ctx, width, height)
            ctx.stroke()
        }
        onVisibleChanged: if (visible) requestPaint()
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.chosen(root.path)
        onContainsMouseChanged: hexCanvas.requestPaint()
    }

    onSelectedChanged: { hexCanvas.requestPaint(); glowCanvas.requestPaint() }
    onPathChanged: {
        // Reset and reload when path swaps (page change)
        preloader.source = root.path.length > 0 ? root.imageUrl : ""
        hexCanvas.requestPaint()
    }

    function hexPath(ctx, w, h): void {
        var inset = w * 0.25
        ctx.beginPath()
        ctx.moveTo(inset, 0)
        ctx.lineTo(w - inset, 0)
        ctx.lineTo(w, h / 2)
        ctx.lineTo(w - inset, h)
        ctx.lineTo(inset, h)
        ctx.lineTo(0, h / 2)
        ctx.closePath()
    }
}
