import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../colors"

PanelWindow {
    id: root

    color: "transparent"
    
    WlrLayershell.layer: WlrLayer.Bottom
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: clockContainer }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Item {
        id: clockContainer
        width: display.implicitWidth
        height: display.implicitHeight

        x: ClockConfig.xPos
        y: ClockConfig.yPos

        Behavior on x { enabled: false }
        Behavior on y { enabled: false }

        ClockDisplay {
            id: display
            anchors.fill: parent
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: clockContainer
            drag.axis: Drag.XAndYAxis
            
            onReleased: {
                ClockConfig.xPos = clockContainer.x
                ClockConfig.yPos = clockContainer.y
                ClockConfig.save()
            }
        }
    }
}
