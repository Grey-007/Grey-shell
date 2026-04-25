import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import QtQuick.Controls

// AppLauncher.qml
// ─────────────────────────────────────────────────────────────────────────────
// PanelWindow anchored to the bottom center of the screen.
// Slides up from the bottom on open, slides back down on close.
// The panel window itself is transparent & non-exclusive — the visible
// card is an inner Item whose `y` is animated (QsWindow has no y/opacity).
//
// To open/close from shell.qml:
//   AppLauncher { id: launcher }
//   // then call:  launcher.toggle()
// ─────────────────────────────────────────────────────────────────────────────

PanelWindow {
    id: root

    // ── Public API ────────────────────────────────────────────────
    property bool open: false

    function toggle() {
        open = !open
        if (open) {
            searchField.text = ""
            searchField.forceActiveFocus()
        }
    }

    function close() {
        open = false
    }

    // ── Window setup ──────────────────────────────────────────────
    // Anchor to bottom, horizontally centered via left+right then clip
    anchors {
        bottom: true
        left: true
        right: true
    }

    // Don't push other windows up — we float above them
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // Window is full-width but transparent — card inside is 480px centered
    height: cardHeight + 20   // 20px bottom clearance for the curve overhang
    color: "transparent"

    // ── Sizing constants ──────────────────────────────────────────
    readonly property int cardWidth:  480
    readonly property int cardHeight: 520
    readonly property int listHeight: 380

    // ── Filtered app list ─────────────────────────────────────────
    readonly property string query: searchField.text.toLowerCase().trim()

    readonly property var allApps: {
        const result = []
        for (const entry of DesktopEntries.applications.values) {
            if (!entry.noDisplay) result.push(entry)
        }
        // Sort alphabetically
        result.sort((a, b) => a.name.localeCompare(b.name))
        return result
    }

    readonly property var filteredApps: {
        if (query === "") return allApps
        return allApps.filter(e =>
            e.name.toLowerCase().includes(query) ||
            (e.description ?? "").toLowerCase().includes(query)
        )
    }

    // ── Animation state ───────────────────────────────────────────
    // We animate the card's y: 0 = fully visible, cardHeight+20 = hidden below
    property real cardY: cardHeight + 20

    onOpenChanged: {
        if (open) {
            cardY = 0
        } else {
            cardY = cardHeight + 20
        }
    }

    // ── Card ──────────────────────────────────────────────────────
    Item {
        id: card

        // Center horizontally
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.cardWidth
        height: root.cardHeight + 20
        // Start hidden below
        y: root.cardY

        Behavior on y {
            NumberAnimation {
                duration: 340
                easing.type: Easing.OutCubic
            }
        }

        // ── Outer curve shape ─────────────────────────────────────
        // The card has top rounded corners; bottom edge merges into screen
        // bottom. A larger radius on top gives the "attached" curve look.
        Rectangle {
            id: cardBg
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: root.cardHeight
            radius: 20
            color: "#f5f4ef"   // warm off-white, monochrome

            // Subtle shadow suggestion via a slightly darker border
            border.color: "#00000014"
            border.width: 1

            // Fill in the bottom corners so it looks flush with screen edge
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 20
                color: parent.color
            }

            // ── App list ──────────────────────────────────────────
            ListView {
                id: appList

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: searchRow.top
                    topMargin: 8
                    bottomMargin: 4
                }

                clip: true
                model: root.filteredApps
                spacing: 0
                keyNavigationEnabled: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 4
                }

                delegate: Item {
                    id: appRow

                    required property var modelData
                    required property int index

                    width: appList.width
                    height: 56

                    // Hover highlight
                    Rectangle {
                        anchors {
                            fill: parent
                            leftMargin: 8
                            rightMargin: 8
                        }
                        radius: 10
                        color: rowArea.containsMouse ? "#00000009" : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 18
                            rightMargin: 18
                        }
                        spacing: 12

                        // App icon
                        Image {
                            id: appIcon
                            Layout.alignment: Qt.AlignVCenter
                            width: 32
                            height: 32
                            source: appRow.modelData.icon !== ""
                                    ? Quickshell.iconPath(appRow.modelData.icon)
                                    : ""
                            sourceSize.width: 32
                            sourceSize.height: 32
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            asynchronous: true

                            // Fallback circle when no icon
                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: "#00000012"
                                visible: appIcon.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: appRow.modelData.name.charAt(0).toUpperCase()
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: "#000000aa"
                                }
                            }
                        }

                        // Name + description
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: appRow.modelData.name
                                color: "#000000"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: appRow.modelData.description ?? ""
                                color: "#00000066"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }
                    }

                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            appRow.modelData.execute()
                            root.close()
                        }
                    }
                }
            }

            // ── Divider ───────────────────────────────────────────
            Rectangle {
                id: divider
                anchors {
                    left: searchRow.left
                    right: searchRow.right
                    bottom: searchRow.top
                }
                height: 1
                color: "#0000001a"
            }

            // ── Search row ────────────────────────────────────────
            Item {
                id: searchRow

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 12
                    bottomMargin: 14
                }
                height: 40

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "#00000008"
                    border.color: "#0000001a"
                    border.width: 1
                }

                // Search icon
                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    text: "⌕"
                    font.pixelSize: 16
                    color: "#00000055"
                }

                TextInput {
                    id: searchField

                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 34
                        rightMargin: 12
                    }

                    color: "#000000"
                    font.pixelSize: 13
                    selectionColor: "#00000025"
                    clip: true

                    // Placeholder text
                    Text {
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        text: 'Type "/" for commands'
                        color: "#00000040"
                        font.pixelSize: 13
                        visible: searchField.text === "" && !searchField.activeFocus
                    }

                    onAccepted: {
                        if (root.filteredApps.length > 0) {
                            root.filteredApps[0].execute()
                            root.close()
                        }
                    }

                    Keys.onEscapePressed: root.close()
                }
            }
        }

        // ── Click-outside-to-close overlay ────────────────────────
        // Invisible full-screen catch area BEHIND the card
        MouseArea {
            anchors.fill: parent
            // only active in the area outside the card bg
            z: -1
            onClicked: root.close()
        }
    }
}
