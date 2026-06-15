import QtQuick

Item {
    id: root

    required property string path
    required property string name
    property bool   selected: false
    property color  accent:   "#7df7c3"
    property int    hoverMs:  120

    signal chosen(string path)

    readonly property string imgUrl: path.length > 0 ? ("file://" + encodeURI(path)) : ""
    readonly property bool   hov:    ma.containsMouse

    // ── Rounded clip ───────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius:       7
        clip:         true
        color:        "#111318"   // dark fallback

        // Image — async, cached, centred crop at 2× size
        Image {
            id: img
            anchors.fill:    parent
            source:          root.imgUrl
            sourceSize:      Qt.size(root.width * 2, root.height * 2)
            asynchronous:    true
            cache:           true
            fillMode:        Image.PreserveAspectCrop
            smooth:          true
            mipmap:          true
            transformOrigin: Item.Center

            // Hover zoom inside clip — image grows, tile shape stays
            scale: root.hov ? root.hoverScale : 1.0
            property real hoverScale: root.selected ? 1.02 : 1.06
            Behavior on scale {
                NumberAnimation { duration: root.hoverMs; easing.type: Easing.OutCubic }
            }

            opacity: status === Image.Ready ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }

        // Shimmer skeleton while loading
        Rectangle {
            anchors.fill: parent
            visible:      img.status !== Image.Ready
            color:        "#181e28"

            Rectangle {
                id: sh
                width:   parent.width * 0.6
                height:  parent.height
                x:       -width
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#0fffffff"   }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                NumberAnimation on x {
                    from: -sh.width; to: root.width + sh.width
                    duration: 1400; loops: Animation.Infinite
                    easing.type: Easing.InOutSine
                    running: img.status !== Image.Ready
                }
            }
        }

        // Bottom gradient + label
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height:  50
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#c0000000"   }
            }
            opacity: root.hov ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: root.hoverMs } }
        }

        Text {
            anchors {
                left: parent.left; right: parent.right; bottom: parent.bottom
                margins: 8; bottomMargin: root.hov ? 8 : 2
            }
            text:            root.name
            color:           "#eeeeee"
            font.pixelSize:  10
            font.weight:     Font.Medium
            elide:           Text.ElideMiddle
            opacity:         root.hov ? 1.0 : 0.0
            Behavior on opacity       { NumberAnimation { duration: root.hoverMs } }
            Behavior on anchors.bottomMargin {
                NumberAnimation { duration: root.hoverMs; easing.type: Easing.OutCubic }
            }
        }

        // Selected checkmark
        Rectangle {
            anchors { top: parent.top; right: parent.right; margins: 7 }
            width: 20; height: 20; radius: 10
            color:   root.accent
            opacity: root.selected ? 1.0 : 0.0
            scale:   root.selected ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 160 } }
            Behavior on scale   {
                NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
            }
            Text {
                anchors.centerIn: parent
                text: "✓"; color: "#000"; font.pixelSize: 10; font.weight: Font.Bold
            }
        }
    }

    // Border ring — outside clip so always sharp
    Rectangle {
        anchors.fill: parent
        radius:       7
        color:        "transparent"
        border.width: root.selected ? 2.5 : root.hov ? 1.5 : 0
        border.color: root.selected ? root.accent : "#88ffffff"
        Behavior on border.width { NumberAnimation { duration: root.hoverMs } }
        Behavior on border.color { ColorAnimation  { duration: root.hoverMs } }

        // Soft pulse on selected
        SequentialAnimation on opacity {
            running: root.selected; loops: Animation.Infinite
            NumberAnimation { to: 0.5; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.chosen(root.path)
    }

    // Apply bounce
    function playApplyAnim() { bounce.restart() }
    SequentialAnimation {
        id: bounce; running: false
        NumberAnimation { target: root; property: "scale"; from: 1.0; to: 1.16; duration: 130; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "scale"; to: 0.95; duration: 90;  easing.type: Easing.InCubic  }
        NumberAnimation { target: root; property: "scale"; to: 1.03; duration: 80;  easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "scale"; to: 1.0;  duration: 70;  easing.type: Easing.OutCubic }
    }
}
