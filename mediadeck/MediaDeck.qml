import QtQuick
import Quickshell

// MediaDeck.qml -- Phase 1: Media Deck Foundation
//
// A floating, draggable, cyberdeck-styled overlay panel. This phase is
// intentionally just a movable foundation: no media playback, no MPRIS,
// no controls, no animations. It exists to prove out the window behavior,
// positioning, persistence, and public API that later phases will build
// directly on top of, without rewrites.
PanelWindow {
    id: root

    // ---- Public configuration -------------------------------------------
    // Collapsed panel dimensions. Phase 1 does not resize or expand.
    property int panelWidth: 320
    property int panelHeight: 90

    // Default offset from the bottom-right corner of the target screen.
    // Only used the first time the panel runs, before any saved position
    // exists.
    property int edgeMarginRight: 40
    property int edgeMarginBottom: 80

    // Which monitor the deck appears on. Defaults to the first enumerated
    // screen; later phases (or shell.qml) can override this externally,
    // e.g. to target whichever monitor Hyprland reports as focused/primary.
    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    // Default top-left-anchored position, derived from the screen size.
    // Exposed as plain properties so other code can read or override them.
    property int defaultX: (screen ? screen.width : panelWidth) - panelWidth - edgeMarginRight
    property int defaultY: (screen ? screen.height : panelHeight) - panelHeight - edgeMarginBottom

    // ---- Persistence -------------------------------------------------------
    PositionStore {
        id: positionStore
        defaultX: root.defaultX
        defaultY: root.defaultY
    }

    // ---- Overlay behavior ------------------------------------------------
    // Anchoring only the top-left corner (not an opposite pair) keeps width
    // and height under our own control, and makes the margins behave like a
    // plain (x, y) position rather than a strut offset.
    anchors {
        top: true
        left: true
    }
    margins {
        left: positionStore.x
        top: positionStore.y
    }

    implicitWidth: panelWidth
    implicitHeight: panelHeight

    // Never reserves space, never pushes tiled windows, never changes
    // workspace layout -- it's purely a shell overlay.
    exclusionMode: ExclusionMode.Ignore

    // Renders above normal desktop windows, but never grabs keyboard focus.
    aboveWindows: true
    focusable: false

    color: "#241D18"

    visible: true

    // ---- Visual structure --------------------------------------------------
    // Flat, hard-edged "hardware module" look: no radius, no shadow, no
    // blur, no gradient, no transparency beyond the border itself.
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 0
        border.width: 1
        border.color: "#5A4736"

        Column {
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "MEDIA DECK"
                color: "#F2E0C8"
                font.family: "monospace"
                font.pixelSize: 16
                font.letterSpacing: 2
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "PHASE 1 FOUNDATION"
                color: "#A67C52"
                font.family: "monospace"
                font.pixelSize: 11
                font.letterSpacing: 1
            }
        }
    }

    // ---- Dragging ------------------------------------------------------
    // Plain, immediate drag: no inertia, no animation, no snapping. Only
    // the left mouse button does anything; right/middle clicks and hover
    // are intentionally left at their inert defaults.
    MouseArea {
        id: dragArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        
        property point lastMousePos: "0,0"

        onPressed: (mouse) => {
            lastMousePos = dragArea.mapToGlobal(mouse.x, mouse.y)
        }

        onPositionChanged: (mouse) => {
            if(!dragArea.pressed) return
            const pos = dragArea.mapToGlobal(mouse.x, mouse.y)
            const delta = Qt.point(pos.x - lastMousePos.x, pos.y - lastMousePos.y)
            root.margins.left += delta.x
            root.margins.top += delta.y
            lastMousePos = pos
        }

        onReleased: (mouse) => {
            positionStore.save(root.margins.left, root.margins.top);
        }
    }

    // ---- Future keybind integration --------------------------------------
    // Wired up correctly now; actual global keybind registration is
    // deferred to a later phase.
    function show() {
        root.visible = true;
    }

    function hide() {
        root.visible = false;
    }

    function toggle() {
        root.visible = !root.visible;
    }
}
