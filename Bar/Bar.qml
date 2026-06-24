import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import "modules/workspaces"
import "modules/clock"
import "modules/metrics"
import "modules/tray"
import "../colors"
import "../Settings/Models"

// Bar.qml — floating top panel for Hyprland — sepia theme
PanelWindow {
    id: bar

    signal calendarClicked()

    readonly property int barHeight:      38
    readonly property int topInset:        4
    readonly property int edgeInset:      18
    readonly property int contentInset:    6
    readonly property int modulePadding:   9
    readonly property int sectionGap:     10

    // ── Sepia palette ──────────────────────────────────────────────
                                
    anchors {
        top:   SettingsManager.store.barPosition !== "Bottom"
        bottom: SettingsManager.store.barPosition === "Bottom"
        left:  true
        right: true
    }

    margins {
        top:   SettingsManager.store.barPosition !== "Bottom" ? topInset : 0
        bottom: SettingsManager.store.barPosition === "Bottom" ? topInset : 0
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
        color:        ThemeManager.accentSoft
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
        color:        ThemeManager.fgInverted
        opacity:      0.08
        antialiasing: true
    }

    // ── Main background ────────────────────────────────────────────
    Rectangle {
        id: panelBackground
        anchors.fill: parent
        radius:       12
        color:        ThemeManager.bg
        border.color: ThemeManager.accentSoft
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
            color:   ThemeManager.accent
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
            color:  ThemeManager.surfaceHigh
            border.color: Qt.rgba(
                ThemeManager.accent.r, ThemeManager.accent.g, ThemeManager.accent.b, 0.30)
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
                    color:           ThemeManager.accent
                    font.pixelSize:  16
                    font.weight:     Font.DemiBold
                    verticalAlignment: Text.AlignVCenter
                }

                // Thin sepia separator
                Rectangle {
                    width:  1
                    height: 14
                    color:  Qt.rgba(ThemeManager.accent.r, ThemeManager.accent.g, ThemeManager.accent.b, 0.30)
                }

                Workspaces { visible: SettingsManager.store.barWorkspacesEnabled }
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
            color:  ThemeManager.surface
            border.color: Qt.rgba(
                ThemeManager.accent.r, ThemeManager.accent.g, ThemeManager.accent.b, 0.22)
            border.width: 1
            antialiasing: true
            visible: SettingsManager.store.barClockEnabled

            Clock {
                id: clockWidget
                anchors.centerIn: parent
                color:       ThemeManager.fg
                accentColor: ThemeManager.accent
                mutedColor:  ThemeManager.fgMid
                onClicked:   bar.calendarClicked()
            }
        }

        // ── RIGHT: metrics + tray ─────────────────────────
        Rectangle {
            id: rightGroup
            anchors {
                right:          parent.right
                verticalCenter: parent.verticalCenter
            }
            width:  rightRow.implicitWidth + bar.modulePadding * 2
            height: 28
            radius: 14
            color:  ThemeManager.surfaceHigh
            border.color: Qt.rgba(
                ThemeManager.accent.r, ThemeManager.accent.g, ThemeManager.accent.b, 0.30)
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

                // thin separator between tray and metrics
                Rectangle {
                    width:   1
                    height:  14
                    color:   Qt.rgba(ThemeManager.accent.r, ThemeManager.accent.g, ThemeManager.accent.b, 0.25)
                    visible: SystemTray.items.values.length > 0
                }

                Cpu { onBarClicked: systemPopup.toggle() }
                Ram { onBarClicked: systemPopup.toggle() }
                Volume { onBarClicked: systemPopup.toggle() }
                Battery { visible: SettingsManager.store.barBatteryEnabled }
            }
        }
    }

    SystemPopup {
        id: systemPopup
    }
}
