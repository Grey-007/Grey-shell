import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../../colors"

// SystemPopup.qml — slide-down system info popup, feels like an extension of the bar.
// Instantiated inside shell.qml as a separate PanelWindow.
PanelWindow {
    id: win

    property bool popupOpen: false

    function toggle() { popupOpen = !popupOpen }
    function show()   { popupOpen = true  }
    function hide()   { popupOpen = false }

    readonly property int screenWidth:  screen != null ? screen.width  : 1366
    readonly property int popupWidth:   340
    readonly property int popupHeight:  200

    // ── Sepia palette ─────────────────────────────────────────────────
                        
    // System data (polled internally so popup is self-contained)
    property real cpuUsage:  0
    property real ramUsage:  0
    property real cpuLastTotal: 0
    property real cpuLastIdle:  0

    readonly property var  pwSink:   Pipewire.defaultAudioSink
    readonly property var  pwAudio:  pwSink?.audio ?? null
    readonly property int  volume:   Math.round(Math.max(0, Math.min(1, pwAudio?.volume ?? 0)) * 100)
    readonly property bool muted_v:  pwAudio?.muted ?? false

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    function pollCpu() {
        cpuProc.exec(["sh", "-c",
            "awk '/^cpu / {print $2,$3,$4,$5,$6,$7,$8}' /proc/stat"])
    }
    function parseCpu(text) {
        const p = text.trim().split(/\s+/).map(Number)
        if (p.length < 4) return
        const idle  = p[3] + (p[4] || 0)
        const total = p.reduce((s, v) => s + v, 0)
        if (cpuLastTotal > 0) {
            const dt = total - cpuLastTotal, di = idle - cpuLastIdle
            if (dt > 0) cpuUsage = Math.max(0, Math.min(100, Math.round((1 - di / dt) * 100)))
        }
        cpuLastTotal = total; cpuLastIdle = idle
    }
    function pollRam() {
        ramProc.exec(["sh", "-c",
            "awk '/^MemTotal:/{t=$2}/^MemAvailable:/{a=$2}END{if(t>0)printf \"%.0f\",((t-a)*100/t)}' /proc/meminfo"])
    }

    Process { id: cpuProc; stdout: StdioCollector { onStreamFinished: win.parseCpu(this.text) } }
    Process { id: ramProc; stdout: StdioCollector {
        onStreamFinished: {
            const v = Number(this.text.trim())
            if (!isNaN(v)) win.ramUsage = Math.max(0, Math.min(100, v))
        }
    }}
    Timer { interval: 2000; running: win.popupOpen; repeat: true
        onTriggered: { win.pollCpu(); win.pollRam() } }
    Component.onCompleted: { pollCpu(); pollRam() }

    // ── Window config ─────────────────────────────────────────────────
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Only visible while open or animating out
    property bool winVisible: false
    visible: winVisible
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    property bool animatingOut: false
    Timer {
        id: hideTimer
        interval: 330
        onTriggered: win.winVisible = false
    }

    onPopupOpenChanged: {
        if (popupOpen) {
            winVisible = true
        } else {
            hideTimer.restart()
        }
    }

    // ── Popup card — centred, just below bar ──────────────────────────
    Item {
        id: popupCard
        width:  win.popupWidth
        height: win.popupHeight

        // Position: right side of screen, below the bar (bar ~42px + margin)
        x: win.screenWidth - width - 14
        y: 0   // window starts at top; card slides down from y=0

        // Slide in/out: from y=-height to y=44
        readonly property int openY:   44
        readonly property int closedY: -win.popupHeight - 10

        // Animate y
        property real cardY: win.popupOpen ? openY : closedY
        Behavior on cardY {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        transform: Translate { y: popupCard.cardY }

        opacity: win.popupOpen ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        // Background — seamlessly extends bar visual
        Rectangle {
            anchors.fill: parent
            radius: 0
            color:  win.ThemeManager.surfaceHigh
            border.color: win.ThemeManager.accentSoft
            border.width: 1

            // Top connector strip — same colour as bar so popup looks attached
            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 2
                color:  win.ThemeManager.accent
                opacity: 0.3
            }
        }

        // Content
        ColumnLayout {
            anchors {
                fill:    parent
                margins: 16
            }
            spacing: 12

            // Header
            Text {
                text:           "\uf200  System"   // nf-fa-pie_chart
                color:          win.ThemeManager.accent
                font.pixelSize: 12
                font.family:    "monospace"
                font.weight:    Font.DemiBold
                font.letterSpacing: 1
            }

            // CPU row
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text:           "\uf4bc  CPU"   // nf-fa-microchip
                        color:          win.ThemeManager.fg
                        font.pixelSize: 11
                        font.family:    "monospace"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text:           Math.round(win.cpuUsage) + "%"
                        color:          win.ThemeManager.accent
                        font.pixelSize: 11
                        font.family:    "monospace"
                        font.weight:    Font.DemiBold
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 0
                    color:  Qt.rgba(win.ThemeManager.accent.r, win.ThemeManager.accent.g, win.ThemeManager.accent.b, 0.15)
                    Rectangle {
                        width: Math.max(0, Math.min(parent.width, parent.width * win.cpuUsage / 100))
                        height: parent.height
                        radius: 0
                        color:  win.cpuUsage >= 85 ? ThemeManager.warning : win.ThemeManager.accent
                        Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    }
                }
            }

            // RAM row
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text:           "\uf538  RAM"   // nf-fa-memory
                        color:          win.ThemeManager.fg
                        font.pixelSize: 11
                        font.family:    "monospace"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text:           Math.round(win.ramUsage) + "%"
                        color:          win.ThemeManager.accent
                        font.pixelSize: 11
                        font.family:    "monospace"
                        font.weight:    Font.DemiBold
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 0
                    color:  Qt.rgba(win.ThemeManager.accent.r, win.ThemeManager.accent.g, win.ThemeManager.accent.b, 0.15)
                    Rectangle {
                        width: Math.max(0, Math.min(parent.width, parent.width * win.ramUsage / 100))
                        height: parent.height
                        radius: 0
                        color:  win.ramUsage >= 85 ? ThemeManager.warning : win.ThemeManager.accent
                        Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    }
                }
            }

            // Volume row
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: win.muted_v || win.volume === 0 ? "\udb81\udd7e  Vol"
                        : win.volume < 45               ? "\uf027  Vol"
                        :                                  "\uf028  Vol"
                    color:          win.ThemeManager.fg
                    font.pixelSize: 11
                    font.family:    "monospace"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text:           win.muted_v ? "Muted" : win.volume + "%"
                    color:          win.muted_v ? ThemeManager.fgMid : ThemeManager.accent
                    font.pixelSize: 11
                    font.family:    "monospace"
                    font.weight:    Font.DemiBold
                }
            }
        }

        // Click outside popup → close
        MouseArea {
            anchors.fill: parent
            onClicked: {} // absorb — prevent propagation to scrim below
        }
    }

    // Full-screen close area (behind popup)
    MouseArea {
        anchors.fill: parent
        enabled: win.popupOpen
        onClicked: win.hide()
        z: -1
    }
}
