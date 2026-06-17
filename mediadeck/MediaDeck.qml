import QtQuick
import Quickshell
import "./views"
import "./services"

// MediaDeck.qml -- Phase 3: MPRIS Integration
//
// This phase integrates the MprisService to make the deck media-aware.
PanelWindow {
    id: root

    // ---- State Management -----------------------------------------------
    MediaState {
        id: mediaState
    }

    // ---- Services -------------------------------------------------------
    MprisService {
        id: mprisService
    }

    // ---- Public configuration -------------------------------------------
    // Panel dimensions are now bound to the state machine.
    readonly property int panelWidth: mediaState.isExpanded ? 520 : 320
    readonly property int panelHeight: mediaState.isExpanded ? 260 : 90

    property int edgeMarginRight: 40
    property int edgeMarginBottom: 80

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    property int defaultX: (screen ? screen.width : panelWidth) - panelWidth - edgeMarginRight
    property int defaultY: (screen ? screen.height : panelHeight) - panelHeight - edgeMarginBottom

    // ---- Persistence -------------------------------------------------------
    PositionStore {
        id: positionStore
        defaultX: root.defaultX
        defaultY: root.defaultY
    }

    // ---- Overlay behavior ------------------------------------------------
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

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: false
    color: "#241D18"
    visible: true

    // ---- Collapse Delay ----------------------------------------------------
    Timer {
        id: collapseTimer
        interval: 500
        repeat: false
        onTriggered: mediaState.collapse()
    }

    // ---- Visual structure --------------------------------------------------
    // The main visual is a border, with the actual content provided by a Loader.
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 0
        border.width: 1
        border.color: "#5A4736"

        Loader {
            id: viewLoader
            anchors.fill: parent
            source: mediaState.isExpanded ? "views/ExpandedView.qml" : "views/CompactView.qml"

            onLoaded: {
                // Pass the service instances to the newly created view.
                item.mprisService = mprisService
            }
        }

        // ---- Dragging & Hover Logic ------------------------------------------
        // The main MouseArea now handles both dragging and hover state changes.
        MouseArea {
            id: dragArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true

            property point lastMousePos: "0,0"

            onPressed: (mouse) => {
                collapseTimer.stop(); // Stop collapse when drag starts
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

            onEntered: {
                mediaState.expand();
                collapseTimer.stop();
            }

            onExited: {
                collapseTimer.start();
            }
        }
    }

    // ---- Future keybind integration --------------------------------------
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
