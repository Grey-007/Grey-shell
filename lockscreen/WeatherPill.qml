import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · WeatherPill
//
// Minimal weather readout via wttr.in's compact text format (no API key,
// no JSON parsing). Refreshes on start and every Config.weatherIntervalMin
// minutes. If curl/network is unavailable, the pill simply stays hidden —
// it never blocks or slows down the lock screen.
// ─────────────────────────────────────────────────────────────────────────
Card {
    id: root

    implicitHeight: Config.pillHeight
    property string condition: ""
    property string temperature: ""
    readonly property bool hasData: temperature !== ""
    readonly property bool shown: hasData

    visible: shown || opacity > 0.01
    enabled: shown
    visibilityFactor: shown ? 1 : 0
    scaleFactor: shown ? 1 : 0.965
    height: shown ? implicitHeight : 0
    Layout.preferredWidth: shown ? implicitWidth : 0

    RowLayout {
        anchors.fill: parent
        anchors.margins: Config.spacingMedium
        spacing: Config.spacingMedium
        Text {
            text: root.condition
            font.pixelSize: 24
        }

        ColumnLayout {
            spacing: 0
            Text {
                text: root.temperature
                color: Colours.surfaceForeground
                font.family: Config.fontFamily
                font.pixelSize: 15
                font.weight: Font.Medium
            }
            Text {
                text: "Weather"
                color: Colours.surfaceVariantForeground
                font.family: Config.fontFamily
                font.pixelSize: 11
            }
        }

        Item { Layout.fillWidth: true }
    }

    Behavior on height {
        NumberAnimation {
            duration: Config.durationMedium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeEmphasizedDecel
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Config.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeEmphasizedDecel
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Config.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.easeExpressive
        }
    }

    // ── Fetch logic ──────────────────────────────────────────────────
    readonly property string _url: "wttr.in/" + Config.weatherLocation + "?format=%c|%t"

    Process {
        id: proc
        command: ["curl", "-s", "-m", "5", root._url]
        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                const parts = collector.text.trim().split("|");
                if (parts.length === 2 && parts[0] !== "") {
                    root.condition = parts[0];
                    root.temperature = parts[1];
                }
            }
        }
    }

    function refresh() {
        proc.running = false;
        proc.running = true;
    }

    Component.onCompleted: refresh()

    Timer {
        interval: Config.weatherIntervalMin * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
