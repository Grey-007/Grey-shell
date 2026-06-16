import "."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Pipewire

// Material You – main control centre card
Item {
    id: root

    property int panelWidth: 400
    property int panelHeight: 700
    // ── Audio via Pipewire ────────────────────────────────────────────────
    readonly property var sink:    Pipewire.defaultAudioSink
    readonly property var audio:   sink != null ? sink.audio : null

    // FIX: volume is 0-1 float from Pipewire; round it to 0-100 int
    readonly property int volumePercent: {
        if (audio == null) return 0;
        return Math.round(Math.max(0.0, Math.min(1.0, audio.volume)) * 100);
    }

    readonly property var outputDevices: {
        const result = [];
        const values = Pipewire.nodes.values;
        for (let i = 0; i < values.length; i++) {
            const node = values[i];
            if (node != null && node.audio != null && node.isSink && !node.isStream)
                result.push(node);
        }
        return result;
    }

    // ── Material You dark colour tokens ──────────────────────────────────
    readonly property color md_surface:             "#2C241D"  // Background
    readonly property color md_surfaceContainer:    "#3B3027"  // Surface
    readonly property color md_surfaceContainerHigh:"#4A3C31"  // Raised Surface
    readonly property color md_surfaceContainerHighest: "#59493E" // Slightly lighter than Raised Surface for distinction
    readonly property color md_primary:             "#A67C52"  // Primary Accent
    readonly property color md_onPrimary:           "#2C241D"  // Background for contrast on primary elements
    readonly property color md_onSurface:           "#F5E6D3"  // Text
    readonly property color md_onSurfaceVariant:    "#D2B89C"  // Muted Text
    readonly property color md_outline:             "#B59A7E"  // Darker Muted Text for outlines
    readonly property color md_scrim:               "#2C241D"  // Background, even if scrim is removed

    function deviceName(node) {
        return node == null ? "Output device"
             : node.description || node.nickname || node.name || "Output device";
    }

    width:   panelWidth
    height:  panelHeight
    enabled: ControlCentreState.open

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    PwObjectTracker { objects: root.outputDevices }

    // ── Main column ───────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // ── QUICK CONTROLS CARD ──────────────────────────────────────────
        Item {
            id: controlsCardHost
            Layout.fillWidth: true
            implicitHeight: controlsCard.height

            opacity: ControlCentreState.open ? 1 : 0

            transform: Translate {
                x: ControlCentreState.open ? 0 : 22
            }

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic } // Adjusted duration
            }

            Behavior on x { // Added behavior for x transform
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            DropShadow {
                anchors.fill: controlsCard
                source: controlsCard
                horizontalOffset: 0
                verticalOffset: 10
                radius: 24
                samples: 36
                color: "#70000000"
                transparentBorder: true
            }

            Rectangle {
                id: controlsCard
                width: parent.width
                height: controlsContent.implicitHeight + 32
                radius: 28
                color: root.md_surfaceContainerHigh
                clip: true

                ColumnLayout {
                    id: controlsContent
                    spacing: 14
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 16
                    }

                    // ── Header row: label + clock ────────────────────────
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: "Control Centre"
                            color: root.md_onSurface
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            opacity: 0.85
                        }

                        Text {
                            text: Qt.formatTime(new Date(), "hh:mm")
                            color: root.md_onSurfaceVariant
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }
                    }

                    // ── 2×2 Quick-setting tiles ──────────────────────────
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 8

                        PillButton {
                            title: "Wi-Fi"
                            subtitle: ControlCentreState.connectedWifiName()
                            glyph: "⌨"
                            active: ControlCentreState.wifiEnabled
                            expanded: ControlCentreState.expandedSection === "wifi"
                            onClicked: ControlCentreState.toggleSection("wifi")
                        }

                        PillButton {
                            title: "Bluetooth"
                            subtitle: ControlCentreState.bluetoothPowered
                                    ? (ControlCentreState.bluetoothScanning ? "Scanning…" : "On")
                                    : "Off"
                            glyph: "ᛒ"
                            active: ControlCentreState.bluetoothPowered
                            expanded: ControlCentreState.expandedSection === "bluetooth"
                            onClicked: ControlCentreState.toggleSection("bluetooth")
                        }

                        PillButton {
                            title: "Volume"
                            subtitle: root.volumePercent + "%"
                            glyph: root.audio == null || root.audio.muted ? "🔇" : "🔊"
                            active: root.audio != null && !root.audio.muted
                            expanded: ControlCentreState.expandedSection === "audio"
                            onClicked: ControlCentreState.toggleSection("audio")
                        }

                        PillButton {
                            title: "Do Not Disturb"
                            subtitle: ControlCentreState.dnd ? "Silenced" : "Allowed"
                            glyph: "🔕"
                            active: ControlCentreState.dnd
                            onClicked: ControlCentreState.dnd = !ControlCentreState.dnd
                        }
                    }

                    // ── Sliders card ─────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: slidersCol.implicitHeight + 20
                        radius: 20
                        color: root.md_surfaceContainerHighest
                        clip: true

                        ColumnLayout {
                            id: slidersCol
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 12
                            }
                            spacing: 2

                            // Brightness slider
                            // externalValue fed from ControlCentreState.brightnessPercent (0-100 int)
                            AndroidSlider {
                                id: brightnessSlider
                                Layout.fillWidth: true
                                icon: "☀"
                                from: 0
                                to: 100
                                // FIX: two-way bind: set on open and track state changes,
                                //      but don't overwrite while the user is dragging.
                                externalValue: ControlCentreState.brightnessPercent

                                onMoved: function(val) {
                                    ControlCentreState.setBrightness(val);
                                }
                            }

                            // Volume slider
                            // FIX: externalValue must be the *percentage* (0-100),
                            //      not the raw 0-1 float from Pipewire.
                            AndroidSlider {
                                id: volumeSlider
                                Layout.fillWidth: true
                                icon: root.audio == null || root.audio.muted || root.volumePercent === 0
                                      ? "🔇" : "🔊"
                                from: 0
                                to: 100
                                // FIX: explicitly use the already-computed integer percentage
                                externalValue: root.volumePercent
                                enabled: root.audio != null

                                onMoved: function(val) {
                                    if (root.audio == null) return;
                                    // Convert percentage back to 0-1 float for Pipewire
                                    root.audio.volume = val / 100.0;
                                    if (root.audio.muted && val > 0)
                                        root.audio.muted = false;
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── NOTIFICATIONS CARD ───────────────────────────────────────────
        Item {
            id: notificationsCardHost
            Layout.fillWidth: true
            Layout.fillHeight: true

            opacity: ControlCentreState.open ? 1 : 0

            transform: Translate {
                x: ControlCentreState.open ? 0 : 32
            }

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic } // Adjusted duration
            }

            Behavior on x { // Added behavior for x transform
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            DropShadow {
                anchors.fill: notificationsCard
                source: notificationsCard
                horizontalOffset: 0
                verticalOffset: 8
                radius: 22
                samples: 32
                color: "#60000000"
                transparentBorder: true
            }

            Rectangle {
                id: notificationsCard
                anchors.fill: parent
                radius: 28
                color: root.md_surfaceContainer
                clip: true

                // Header
                RowLayout {
                    id: notifHeader
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 16
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: root.md_onSurface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        opacity: 0.85
                    }

                    SmallButton {
                        text: "Clear all"
                        visible: ControlCentreState.notifications.length > 0
                        onClicked: ControlCentreState.clearNotifications()
                    }
                }

                // Empty state
                Item {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: notifHeader.bottom
                        bottom: parent.bottom
                    }
                    visible: ControlCentreState.notifications.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: "No notifications"
                        color: root.md_onSurfaceVariant
                        font.pixelSize: 13
                        opacity: 0.6
                    }
                }

                // Scrollable notification list
                Flickable {
                    id: notifList
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: notifHeader.bottom
                        bottom: parent.bottom
                        topMargin: 8
                        leftMargin: 12
                        rightMargin: 12
                        bottomMargin: 12
                    }
                    contentHeight: notifColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    visible: ControlCentreState.notifications.length > 0

                    ColumnLayout {
                        id: notifColumn
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: ControlCentreState.notifications

                            delegate: Item {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                implicitHeight: notifBody.implicitHeight + 24
                                opacity: 1 // Notifications should be visible by default

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 250 // Consistent animation duration
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                transform: Translate {
                                    y: (1 - opacity) * 18 // Still apply a slight translate if opacity changes (e.g. fading out)
                                }

                                Rectangle {
                                    id: notifBody
                                    anchors.fill: parent
                                    radius: 18
                                    color: root.md_surfaceContainerHighest
                                    scale: pressArea.containsPress ? 0.985 : 1.0

                                    Behavior on scale {
                                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                                    }

                                    // Coloured left accent line
                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                            leftMargin: 0
                                            topMargin: 6
                                            bottomMargin: 6
                                        }
                                        width: 3
                                        radius: 2
                                        color: root.md_primary
                                        opacity: 0.7
                                    }

                                    ColumnLayout {
                                        spacing: 3
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                            margins: 12
                                            leftMargin: 18
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.appName || "Notification"
                                            color: root.md_primary
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.summary || ""
                                            color: root.md_onSurface
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                            visible: text !== ""
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.body || ""
                                            color: root.md_onSurfaceVariant
                                            font.pixelSize: 12
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 3
                                            elide: Text.ElideRight
                                            textFormat: Text.PlainText
                                            visible: text !== ""
                                        }
                                    }

                                    MouseArea {
                                        id: pressArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: ControlCentreState.dismissNotification(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Expanded sub-panels (wifi / bt / audio) ───────────────────────────
    Loader {
        id: expandedLoader
        anchors {
            left: parent.left
            right: parent.right
        }
        y: controlsCardHost.height + 18
        z: 10
        active: ControlCentreState.expandedSection !== ""
        opacity: active ? 1 : 0

        sourceComponent: ControlCentreState.expandedSection === "wifi"
                       ? wifiPanel
                       : ControlCentreState.expandedSection === "bluetooth"
                         ? bluetoothPanel
                         : audioPanel

        transform: Translate {
            y: expandedLoader.active ? 0 : -12
        }

        Behavior on opacity {
            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
        }
    }

    // ── Wi-Fi panel ───────────────────────────────────────────────────────
    Component {
        id: wifiPanel
        MenuPanel {
            title: "Wi-Fi Networks"
            busy: ControlCentreState.wifiScanning
            errorText: ControlCentreState.wifiError
            onScanClicked: ControlCentreState.scanWifi()

            RowLayout {
                Layout.fillWidth: true
                visible: ControlCentreState.wifiPasswordSsid !== ""

                TextInput {
                    id: wifiPassword
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    leftPadding: 14
                    rightPadding: 14
                    text: ControlCentreState.wifiPasswordValue
                    echoMode: TextInput.Password
                    color: root.md_onSurface
                    font.pixelSize: 12
                    clip: true
                    onTextChanged: ControlCentreState.wifiPasswordValue = text

                    Rectangle {
                        anchors.fill: parent
                        z: -1
                        radius: 18
                        color: root.md_surfaceContainerHighest
                    }

                    Text {
                        anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                        text: "Password for " + ControlCentreState.wifiPasswordSsid
                        color: root.md_onSurfaceVariant
                        font.pixelSize: 11
                        visible: wifiPassword.text === ""
                    }
                }

                SmallButton {
                    text: "Join"
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
                    title: modelData.ssid
                    subtitle: (modelData.active ? "Connected · " : "") + modelData.security + " · " + modelData.signal + "%"
                    glyph: "◉"
                    active: modelData.active
                    actionText: modelData.active ? "Active" : "Join"
                    onClicked: ControlCentreState.requestWifiConnection(modelData)
                }
            }
        }
    }

    // ── Bluetooth panel ───────────────────────────────────────────────────
    Component {
        id: bluetoothPanel
        MenuPanel {
            title: "Bluetooth Devices"
            busy: ControlCentreState.bluetoothScanning
            errorText: ControlCentreState.bluetoothError
            onScanClicked: ControlCentreState.scanBluetooth()

            DeviceRow {
                title: ControlCentreState.bluetoothPowered ? "Bluetooth is on" : "Bluetooth is off"
                subtitle: "Toggle adapter"
                glyph: "ᛒ"
                active: ControlCentreState.bluetoothPowered
                actionText: ControlCentreState.bluetoothPowered ? "Turn off" : "Turn on"
                onClicked: ControlCentreState.toggleBluetooth()
            }

            Repeater {
                model: ControlCentreState.bluetoothDevices
                delegate: DeviceRow {
                    required property var modelData
                    title: modelData.name
                    subtitle: modelData.address
                    glyph: "ᛒ"
                    active: modelData.connected
                    actionText: modelData.connected ? "Disconnect" : "Connect"
                    onClicked: ControlCentreState.toggleBluetoothDevice(modelData)
                }
            }
        }
    }

    // ── Audio output panel ────────────────────────────────────────────────
    Component {
        id: audioPanel
        MenuPanel {
            title: "Audio Output"
            showScan: false

            Repeater {
                model: root.outputDevices
                delegate: DeviceRow {
                    required property var modelData
                    title: root.deviceName(modelData)
                    subtitle: modelData.name
                    glyph: "♪"
                    active: Pipewire.defaultAudioSink === modelData
                    actionText: active ? "Active" : "Use"
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }
        }
    }
}
