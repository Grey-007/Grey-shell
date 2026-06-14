import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    property bool   openState:  false
    property string filterText: ""

    function toggle(): void { openState ? close() : open() }
    function open():   void { openState = true;  model.refresh() }
    function close():  void { openState = false }

    WallpaperConfig { id: cfg }

    WallpaperModel {
        id: model
        directory: cfg.wallpaperDirectory
        scanDepth: cfg.scanDepth
        autoRefresh: root.openState
        onApplyRequested: function(path) {
            wallpaperSetter.exec(cfg.applyCommand.concat([path]))
        }
    }

    Process { id: wallpaperSetter }

    // ── Filtered model ─────────────────────────────────────────────
    QtObject {
        id: fModel
        property string selectedPath: model.selectedPath
        property bool   loading:      model.loading
        property var    _list:        []
        readonly property int count:  _list.length

        function _rebuild(): void {
            var ft  = root.filterText.toLowerCase()
            var res = []
            for (var i = 0; i < model.wallpapers.count; i++) {
                var e = model.wallpapers.get(i)
                if (ft.length === 0 || e.name.toLowerCase().indexOf(ft) >= 0)
                    res.push({ path: e.path, name: e.name })
            }
            _list = res
        }

        function get(index) {
            return (index >= 0 && index < _list.length) ? _list[index] : null
        }

        Component.onCompleted: _rebuild()
    }

    // Connections OUTSIDE QtObject — fixes "non-existent default property" error
    Connections {
        target: model
        function onCountChanged(): void {
            fModel._rebuild()
            fModel.countChanged()
        }
    }

    onFilterTextChanged: {
        fModel._rebuild()
        fModel.countChanged()
        grid.pageIndex = 0
    }

    // ── Window setup ───────────────────────────────────────────────
    anchors { left: true; right: true; top: true; bottom: true }

    visible: openState || panel.opacity > 0.005
    color:   "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: openState ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace:     "grey-shell-wallpaper"

    // ── Panel — centred, transparent bg ───────────────────────────
    Item {
        id: panel
        anchors.centerIn: parent
        width:  cfg.panelWidth
        height: cfg.panelHeight

        // Fast fade + tiny lift
        opacity: root.openState ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: cfg.openDuration; easing.type: Easing.OutCubic }
        }

        transform: Translate {
            y: root.openState ? 0 : 14
            Behavior on y {
                NumberAnimation { duration: cfg.openDuration; easing.type: Easing.OutCubic }
            }
        }

        ColumnLayout {
            anchors.fill:    parent
            spacing:         10

            // ── Header ────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:    true
                Layout.topMargin:    0
                Layout.leftMargin:   4
                Layout.rightMargin:  4
                spacing: 8

                // Count
                Text {
                    text:  fModel.loading
                        ? "Scanning…"
                        : fModel.count > 0 ? fModel.count + " wallpapers" : "Wallpapers"
                    color: "#99ffffff"
                    font.pixelSize:  12
                    font.weight:     Font.Medium
                }

                // Loading dots
                Row {
                    visible: fModel.loading
                    spacing: 3
                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            required property int index
                            width: 4; height: 4; radius: 2; color: cfg.accent
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite; running: fModel.loading
                                PauseAnimation  { duration: index * 130 }
                                NumberAnimation { to: 1.0;  duration: 220 }
                                NumberAnimation { to: 0.2;  duration: 220 }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Search
                Rectangle {
                    width: 200; height: 26; radius: 6
                    color:        searchFocus.activeFocus ? "#28ffffff" : "#12ffffff"
                    border.color: searchFocus.activeFocus ? cfg.accent  : "#18ffffff"
                    border.width: 1
                    Behavior on color        { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                        spacing: 5
                        Text { text: "⌕"; color: "#55ffffff"; font.pixelSize: 12 }
                        TextInput {
                            id: searchFocus
                            Layout.fillWidth: true
                            color: "#f0f0f0"; font.pixelSize: 11
                            selectionColor: "#447df7c3"; selectedTextColor: "#f0f0f0"
                            clip: true
                            onTextChanged: root.filterText = text
                            Text {
                                anchors.fill: parent
                                text: "Search…"; color: "#33ffffff"; font: parent.font
                                visible: parent.text.length === 0 && !parent.activeFocus
                            }
                        }
                        Text {
                            text: "✕"; color: "#44ffffff"; font.pixelSize: 9
                            visible: searchFocus.text.length > 0
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { searchFocus.text = ""; root.filterText = "" }
                            }
                        }
                    }
                }

                // Close
                Rectangle {
                    width: 26; height: 26; radius: 6
                    color: xhov.containsMouse ? "#22ffffff" : "#10ffffff"
                    border.color: "#14ffffff"; border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text { anchors.centerIn: parent; text: "✕"; color: "#88ffffff"; font.pixelSize: 11 }
                    MouseArea { id: xhov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
                }
            }

            // ── Grid row — arrows + grid ───────────────────────────
            RowLayout {
                Layout.fillWidth:  true
                Layout.preferredHeight: cfg.gridH
                spacing: 8

                // Left arrow
                Rectangle {
                    width: 32; height: cfg.gridH; radius: 7
                    color:   lhov.containsMouse ? "#22ffffff" : "#0dffffff"
                    border.color: "#14ffffff"; border.width: 1
                    opacity: grid.pageIndex > 0 ? 1.0 : 0.25
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    Behavior on color   { ColorAnimation  { duration: 100 } }
                    scale:  lhov.pressed ? 0.94 : 1.0
                    Behavior on scale { NumberAnimation { duration: 80 } }
                    Text { anchors.centerIn: parent; text: "‹"; color: "#ddffffff"; font.pixelSize: 18 }
                    MouseArea { id: lhov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: grid.previousPage() }
                }

                // Grid
                WallpaperGrid {
                    id: grid
                    Layout.preferredWidth:  cfg.gridW
                    Layout.preferredHeight: cfg.gridH
                    wallpaperModel:    fModel
                    config:            cfg
                    onWallpaperChosen: function(path) { model.apply(path); animateTile(path) }
                }

                // Right arrow
                Rectangle {
                    width: 32; height: cfg.gridH; radius: 7
                    color:   rhov.containsMouse ? "#22ffffff" : "#0dffffff"
                    border.color: "#14ffffff"; border.width: 1
                    opacity: grid.pageIndex < grid.maxPage() ? 1.0 : 0.25
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    Behavior on color   { ColorAnimation  { duration: 100 } }
                    scale:  rhov.pressed ? 0.94 : 1.0
                    Behavior on scale { NumberAnimation { duration: 80 } }
                    Text { anchors.centerIn: parent; text: "›"; color: "#ddffffff"; font.pixelSize: 18 }
                    MouseArea { id: rhov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: grid.nextPage() }
                }
            }

            // ── Footer — dots + selected name ─────────────────────
            RowLayout {
                Layout.fillWidth:   true
                Layout.leftMargin:  4
                Layout.rightMargin: 4
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text:  model.selectedPath.length > 0
                        ? ("✓  " + model.selectedPath.split("/").pop()) : ""
                    color: "#55" + cfg.accent.toString().slice(1)
                    font.pixelSize: 10
                    elide: Text.ElideMiddle
                }

                // Page dots
                Row {
                    spacing: 4
                    Repeater {
                        model: Math.min(24, grid.totalPages)
                        delegate: Rectangle {
                            required property int index
                            readonly property bool act: index === grid.pageIndex
                            width:  act ? 16 : 4; height: 4; radius: 2
                            color:  act ? cfg.accent : "#22ffffff"
                            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation  { duration: 130 } }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: grid.goToPage(parent.index)
                            }
                        }
                    }
                }
            }
        }
    }

 // Wheel scroll anywhere + keyboard navigation
    MouseArea {
        id: interactionArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        focus: root.openState

        onWheel: function(w) {
            var d = w.angleDelta.y !== 0 ? w.angleDelta.y : w.angleDelta.x
            if (d < 0) grid.nextPage(); else grid.previousPage()
        }

        Keys.onEscapePressed: root.close()
        Keys.onLeftPressed:   grid.previousPage()
        Keys.onRightPressed:  grid.nextPage()
        Keys.onUpPressed:     grid.previousPage()
        Keys.onDownPressed:   grid.nextPage()
    }
}
