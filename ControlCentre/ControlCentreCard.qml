import "."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../colors"

// SepiaShell – main control centre card content
Item {
    id: root

    property int panelWidth:  400
    property int panelHeight: 700

    // ── Audio via Pipewire ────────────────────────────────────────────────
    readonly property var sink:  Pipewire.defaultAudioSink
    readonly property var audio: sink != null ? sink.audio : null

    readonly property int volumePercent: {
        if (audio == null) return 0
        return Math.round(Math.max(0.0, Math.min(1.0, audio.volume)) * 100)
    }

    readonly property var outputDevices: {
        const result = []
        const values = Pipewire.nodes.values
        for (let i = 0; i < values.length; i++) {
            const node = values[i]
            if (node != null && node.audio != null && node.isSink && !node.isStream)
                result.push(node)
        }
        return result
    }

    // ── SepiaShell colour tokens ──────────────────────────────────────────
                                        
    function deviceName(node) {
        return node == null ? "Output device"
             : node.description || node.nickname || node.name || "Output device"
    }

    width:   panelWidth
    height:  panelHeight
    enabled: ControlCentreState.open

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    PwObjectTracker { objects: root.outputDevices }

    // ── Scrollable content ────────────────────────────────────────────────
    Flickable {
        id: scrollArea
        anchors.fill: parent
        contentHeight: mainCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 10

            // ── QUICK CONTROLS CARD ──────────────────────────────────────
            Rectangle {
                id: controlsCard
                Layout.fillWidth: true
                implicitHeight: controlsContent.implicitHeight + 32
                radius: 0
                color: root.ThemeManager.surfaceHigh
                border.color: root.ThemeManager.border
                border.width: 1

                ColumnLayout {
                    id: controlsContent
                    spacing: 12
                    anchors {
                        left:   parent.left
                        right:  parent.right
                        top:    parent.top
                        margins: 14
                    }

                    // Header: title + clock
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text:           "Control Centre"
                            color:          root.ThemeManager.accent
                            font.pixelSize: 13
                            font.family:    "monospace"
                            font.weight:    Font.DemiBold
                            font.letterSpacing: 1
                        }

                        Text {
                            text:           Qt.formatTime(new Date(), "hh:mm")
                            color:          root.ThemeManager.fgMid
                            font.pixelSize: 12
                            font.family:    "monospace"
                        }
                    }

                    // Separator
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.ThemeManager.border
                        opacity: 0.5
                    }

                    // 2×2 Quick-setting pill buttons
                    GridLayout {
                        Layout.fillWidth: true
                        columns:       2
                        columnSpacing: 8
                        rowSpacing:    8

                        PillButton {
                            title:    "Wi-Fi"
                            subtitle: ControlCentreState.connectedWifiName()
                            glyph:    "⌨"
                            active:   ControlCentreState.wifiEnabled
                            expanded: ControlCentreState.expandedSection === "wifi"
                            onClicked: ControlCentreState.toggleSection("wifi")
                        }

                        PillButton {
                            title:    "Bluetooth"
                            subtitle: ControlCentreState.bluetoothPowered
                                    ? (ControlCentreState.bluetoothScanning ? "Scanning…" : "On")
                                    : "Off"
                            glyph:    "ᛒ"
                            active:   ControlCentreState.bluetoothPowered
                            expanded: ControlCentreState.expandedSection === "bluetooth"
                            onClicked: ControlCentreState.toggleSection("bluetooth")
                        }

                        PillButton {
                            title:    "Volume"
                            subtitle: root.volumePercent + "%"
                            glyph:    root.audio == null || root.audio.muted ? "🔇" : "🔊"
                            active:   root.audio != null && !root.audio.muted
                            expanded: ControlCentreState.expandedSection === "audio"
                            onClicked: ControlCentreState.toggleSection("audio")
                        }

                        PillButton {
                            title:    "Do Not Disturb"
                            subtitle: ControlCentreState.dnd ? "Silenced" : "Allowed"
                            glyph:    "🔕"
                            active:   ControlCentreState.dnd
                            onClicked: ControlCentreState.dnd = !ControlCentreState.dnd
                        }
                    }

                    // Sliders section
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: slidersCol.implicitHeight + 16
                        radius: 0
                        color: root.ThemeManager.surfaceTop
                        border.color: root.ThemeManager.border
                        border.width: 1

                        ColumnLayout {
                            id: slidersCol
                            anchors {
                                left:    parent.left
                                right:   parent.right
                                top:     parent.top
                                margins: 10
                            }
                            spacing: 0

                            // Brightness
                            AndroidSlider {
                                Layout.fillWidth: true
                                icon:          "☀"
                                from:          0
                                to:            100
                                externalValue: ControlCentreState.brightnessPercent
                                onMoved: function(val) {
                                    ControlCentreState.setBrightness(val)
                                }
                            }

                            // Divider
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: root.ThemeManager.border
                                opacity: 0.4
                            }

                            // Volume
                            AndroidSlider {
                                Layout.fillWidth: true
                                icon: root.audio == null || root.audio.muted || root.volumePercent === 0
                                      ? "🔇" : "🔊"
                                from:          0
                                to:            100
                                externalValue: root.volumePercent
                                enabled:       root.audio != null
                                onMoved: function(val) {
                                    if (root.audio == null) return
                                    root.audio.volume = val / 100.0
                                    if (root.audio.muted && val > 0)
                                        root.audio.muted = false
                                }
                            }
                        }
                    }

                    // Expanded sub-panel (wifi / bt / audio) inline
                    Loader {
                        id: expandedLoader
                        Layout.fillWidth: true
                        active: ControlCentreState.expandedSection !== ""

                        opacity: active ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }

                        sourceComponent: ControlCentreState.expandedSection === "wifi"
                                       ? wifiPanel
                                       : ControlCentreState.expandedSection === "bluetooth"
                                         ? bluetoothPanel
                                         : audioPanel
                    }
                }
            }



            // Bottom spacer so last card has breathing room
            Item { implicitHeight: 8 }
        }
    }

    // ── Wi-Fi panel ───────────────────────────────────────────────────────
    Component {
        id: wifiPanel
        MenuPanel {
            title:     "Wi-Fi Networks"
            busy:      ControlCentreState.wifiScanning
            errorText: ControlCentreState.wifiError
            onScanClicked: ControlCentreState.scanWifi()

            RowLayout {
                Layout.fillWidth: true
                visible: ControlCentreState.wifiPasswordSsid !== ""

                TextInput {
                    id: wifiPassword
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    leftPadding:  12
                    rightPadding: 12
                    text:       ControlCentreState.wifiPasswordValue
                    echoMode:   TextInput.Password
                    color:      root.ThemeManager.fg
                    font.pixelSize: 12
                    font.family:    "monospace"
                    clip: true
                    onTextChanged: ControlCentreState.wifiPasswordValue = text

                    Rectangle {
                        anchors.fill: parent
                        z: -1
                        radius: 0
                        color:  root.ThemeManager.surfaceTop
                        border.color: root.ThemeManager.border
                        border.width: 1
                    }

                    Text {
                        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                        text:           "Password for " + ControlCentreState.wifiPasswordSsid
                        color:          root.ThemeManager.fgMid
                        font.pixelSize: 11
                        font.family:    "monospace"
                        visible: wifiPassword.text === ""
                    }
                }

                SmallButton {
                    text:   "Join"
                    active: true
                    onClicked: ControlCentreState.connectWifi(
                        ControlCentreState.wifiPasswordSsid,
                        ControlCentreState.wifiPasswordValue)
                }
            }

            Repeater {
                model: ControlCentreState.wifiNetworks
                delegate: DeviceRow {
                    required property var modelData
                    title:      modelData.ssid
                    subtitle:   (modelData.active ? "Connected · " : "") + modelData.security + " · " + modelData.signal + "%"
                    glyph:      "◉"
                    active:     modelData.active
                    actionText: modelData.active ? "Active" : "Join"
                    onClicked:  ControlCentreState.requestWifiConnection(modelData)
                }
            }
        }
    }

    // ── Bluetooth panel ───────────────────────────────────────────────────
    Component {
        id: bluetoothPanel
        MenuPanel {
            title:     "Bluetooth Devices"
            busy:      ControlCentreState.bluetoothScanning
            errorText: ControlCentreState.bluetoothError
            onScanClicked: ControlCentreState.scanBluetooth()

            DeviceRow {
                title:      ControlCentreState.bluetoothPowered ? "Bluetooth is on" : "Bluetooth is off"
                subtitle:   "Toggle adapter"
                glyph:      "ᛒ"
                active:     ControlCentreState.bluetoothPowered
                actionText: ControlCentreState.bluetoothPowered ? "Turn off" : "Turn on"
                onClicked:  ControlCentreState.toggleBluetooth()
            }

            Repeater {
                model: ControlCentreState.bluetoothDevices
                delegate: DeviceRow {
                    required property var modelData
                    title:      modelData.name
                    subtitle:   modelData.address
                    glyph:      "ᛒ"
                    active:     modelData.connected
                    actionText: modelData.connected ? "Disconnect" : "Connect"
                    onClicked:  ControlCentreState.toggleBluetoothDevice(modelData)
                }
            }
        }
    }

    // ── Audio output panel ────────────────────────────────────────────────
    Component {
        id: audioPanel
        MenuPanel {
            title:    "Audio Output"
            showScan: false

            Repeater {
                model: root.outputDevices
                delegate: DeviceRow {
                    required property var modelData
                    title:      root.deviceName(modelData)
                    subtitle:   modelData.name
                    glyph:      "♪"
                    active:     Pipewire.defaultAudioSink === modelData
                    actionText: active ? "Active" : "Use"
                    onClicked:  Pipewire.preferredDefaultAudioSink = modelData
                }
            }
        }
    }
}
