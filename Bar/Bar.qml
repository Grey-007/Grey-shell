import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "modules"
import "."

// Bar.qml — floating top panel for Hyprland — sepia theme
PanelWindow {
    id: bar

    signal mediaClicked()
    signal powerClicked()
    signal calendarClicked()

    readonly property int barHeight:      38
    readonly property int topInset:        4
    readonly property int edgeInset:      18
    readonly property int contentInset:    6
    readonly property int modulePadding:   9
    readonly property int sectionGap:     10

    // ── Sepia palette ──────────────────────────────────────────────
    readonly property color bg:         "#1c1510"
    readonly property color bgRaised:   "#2e2118"
    readonly property color bgInset:    "#241c14"
    readonly property color accent:     "#d4a45a"
    readonly property color accentSoft: "#a0784a"
    readonly property color fg:         "#f0e0c0"
    readonly property color muted:      "#8a7055"
    readonly property color border:     "#a0784a"

    anchors {
        top:   true
        left:  true
        right: true
    }

    margins {
        top:   topInset
        left:  edgeInset
        right: edgeInset
    }

    exclusionMode:  ExclusionMode.Normal
    exclusiveZone:  topInset + barHeight - 8

    implicitHeight: barHeight
    color: "transparent"

    // ── Outer glow shadow ──────────────────────────────────────────
    Rectangle {
        anchors {
            fill:         panelBackground
            topMargin:    5
            leftMargin:   2
            rightMargin:  2
            bottomMargin: -3
        }
        radius:       panelBackground.radius
        color:        bar.accentSoft
        opacity:      0.10
        antialiasing: true
    }

    // ── Highlight rim ──────────────────────────────────────────────
    Rectangle {
        anchors {
            fill:         panelBackground
            topMargin:    1
            leftMargin:   1
            rightMargin:  1
            bottomMargin: -1
        }
        radius:       panelBackground.radius
        color:        "#ffffff"
        opacity:      0.08
        antialiasing: true
    }

    // ── Main background ────────────────────────────────────────────
    Rectangle {
        id: panelBackground
        anchors.fill: parent
        radius:       12
        color:        bar.bg
        border.color: bar.border
        border.width: 1
        antialiasing: true

        // top inner gleam
        Rectangle {
            anchors {
                left:   parent.left
                right:  parent.right
                top:    parent.top
                margins: 2
            }
            height:  1
            radius:  1
            color:   bar.accent
            opacity: 0.22
        }
    }

    // ── Layout container ──────────────────────────────────────────
    Item {
        id: barLayout
        anchors {
            fill:        parent
            leftMargin:  bar.contentInset
            rightMargin: bar.contentInset
        }

        // ── LEFT: logo + workspaces ────────────────────────────────
        Rectangle {
            id: leftGroup
            anchors {
                left:           parent.left
                verticalCenter: parent.verticalCenter
            }
            width:  leftRow.implicitWidth + bar.modulePadding * 2
            height: 28
            radius: 14
            color:  bar.bgRaised
            border.color: Qt.rgba(
                bar.accent.r, bar.accent.g, bar.accent.b, 0.30)
            border.width: 1
            antialiasing: true

            Behavior on width {
                NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
            }

            RowLayout {
                id: leftRow
                anchors {
                    left:           parent.left
                    right:          parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin:     bar.modulePadding
                    rightMargin:    bar.modulePadding
                }
                spacing: 10

                // Nix logo
                Text {
                    text:            "󰣇"
                    color:           bar.accent
                    font.pixelSize:  16
                    font.weight:     Font.DemiBold
                    verticalAlignment: Text.AlignVCenter
                }

                // Thin sepia separator
                Rectangle {
                    width:  1
                    height: 14
                    color:  Qt.rgba(bar.accent.r, bar.accent.g, bar.accent.b, 0.30)
                }

                Workspaces {}
            }
        }

        // ── CENTRE: clock (constrained to not overlap edges) ───────
        Rectangle {
            id: clockGroup

            readonly property real idealX: (barLayout.width - width) / 2
            readonly property real minX:   leftGroup.x + leftGroup.width + sectionGap
            readonly property real maxX:   rightGroup.x - sectionGap - width

            x:      Math.max(minX, Math.min(idealX, maxX))
            anchors.verticalCenter: parent.verticalCenter
            width:  clockWidget.implicitWidth + 24
            height: 28
            radius: 14
            color:  bar.bgInset
            border.color: Qt.rgba(
                bar.accent.r, bar.accent.g, bar.accent.b, 0.22)
            border.width: 1
            antialiasing: true

            // No Behavior on x so it never drifts on its own

            Clock {
                id: clockWidget
                anchors.centerIn: parent
                color:       bar.fg
                accentColor: bar.accent
                mutedColor:  bar.muted
                onClicked:   bar.calendarClicked()
            }
        }

        // ── RIGHT: metrics + tray + power ─────────────────────────
        Rectangle {
            id: rightGroup
            // Anchor to right edge — no manual x — fixes drift
            anchors {
                right:          parent.right
                verticalCenter: parent.verticalCenter
            }
            width:  rightRow.implicitWidth + bar.modulePadding * 2
            height: 28
            radius: 14
            color:  bar.bgRaised
            border.color: Qt.rgba(
                bar.accent.r, bar.accent.g, bar.accent.b, 0.30)
            border.width: 1
            antialiasing: true

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            RowLayout {
                id: rightRow
                anchors {
                    left:           parent.left
                    right:          parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin:     bar.modulePadding
                    rightMargin:    bar.modulePadding
                }
                spacing: 2

                Tray {}

                // thin separator between tray and metrics (only when tray visible)
                Rectangle {
                    width:   1
                    height:  14
                    color:   Qt.rgba(bar.accent.r, bar.accent.g, bar.accent.b, 0.25)
                    visible: SystemTray !== undefined
                }

                Cpu {}
                Ram {}
                Volume {}
                Battery {}

                // thin separator before power
                Rectangle {
                    width:  1
                    height: 14
                    color:  Qt.rgba(bar.accent.r, bar.accent.g, bar.accent.b, 0.25)
                }

                PowerButton {
                    onClicked: bar.powerClicked()
                }
            }
        }
    }
}
