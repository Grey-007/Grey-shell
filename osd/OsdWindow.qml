import QtQuick
import Quickshell
import Quickshell.Wayland
import "../colors"

PanelWindow {
    id: root

    property string currentType: ""
    property real currentValue: 0
    property string currentText: ""

    WlrLayershell.namespace: "osd"
    WlrLayershell.layer: WlrLayer.Overlay
    
    anchors {
        bottom: true
    }

    margins {
        bottom: 100
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    implicitWidth: 300
    implicitHeight: 60

    visible: false

    function showOsd(type, value, text) {
        currentType = type;
        if (value !== undefined) currentValue = value;
        if (text !== undefined) currentText = text;
        
        visible = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 2000
        repeat: false
        onTriggered: root.visible = false
    }

    Rectangle {
        anchors.fill: parent
        color: ThemeManager.surfaceHigh || "#2a2a2a"
        radius: 12
        border.color: ThemeManager.accent || "#888888"
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 16

            Text {
                text: {
                    if (currentType === "volume") return " ";
                    if (currentType === "brightness") return " ";
                    if (currentType === "capslock") return "󰪛 ";
                    if (currentType === "numlock") return "󰎦 ";
                    if (currentType === "scrolllock") return "󰜯 ";
                    return "";
                }
                color: ThemeManager.fg || "#ffffff"
                font.pixelSize: 24
                font.family: "Material Design Icons"
            }

            Rectangle {
                width: 200
                height: 12
                anchors.verticalCenter: parent.verticalCenter
                radius: 6
                color: ThemeManager.bg || "#111111"
                visible: currentType === "volume" || currentType === "brightness"

                Rectangle {
                    width: Math.max(0, Math.min(100, currentValue)) / 100 * parent.width
                    height: parent.height
                    radius: 6
                    color: ThemeManager.accent || "#ffffff"
                }
            }

            Text {
                text: currentText
                color: ThemeManager.fg || "#ffffff"
                font.pixelSize: 18
                visible: currentType !== "volume" && currentType !== "brightness"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
