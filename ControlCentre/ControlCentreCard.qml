import "."
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    id: root

    property int panelWidth: 396
    property int panelHeight: 692
    property real openProgress: 0

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink != null ? sink.audio : null
    readonly property int volumePercent: audio != null ? Math.round(Math.max(0, Math.min(1, audio.volume)) * 100) : 0
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

    readonly property color surfaceContainer: "#1A2116"
    readonly property color surfaceContainerHigh: "#222A1C"
    readonly property color surfaceContainerHighest: "#2A3124"
    readonly property color onSurface: "#E8F0DC"
    readonly property color onSurfaceVariant: "#A8B598"
    readonly property color primary: "#C5E87A"

    function deviceName(node) {
        return node == null ? "Output device" : node.description || node.nickname || node.name || "Output device";
    }

    width: panelWidth
    height: panelHeight
    opacity: openProgress
    enabled: ControlCentreState.open || openProgress > 0.01

    Connections {
        target: ControlCentreState
        function onOpenChanged() {
            root.openProgress = ControlCentreState.open ? 1 : 0;
        }
    }

    Component.onCompleted: openProgress = ControlCentreState.open ? 1 : 0

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    PwObjectTracker {
        objects: root.outputDevices
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Item {
            id: controlsCardHost

            Layout.fillWidth: true
            implicitHeight: controlsCard.height
            opacity: openProgress

            transform: Translate {
                x: (1 - root.openProgress) * 28
            }

            DropShadow {
                anchors.fill: controlsCard
                horizontalOffset: 0
                verticalOffset: 8
                radius: 28
                samples: 40
                color: "#00000066"
                source: controlsCard
                transparentBorder: true
            }

            Rectangle {
                id: controlsCard

                width: parent.width
                height: controlsContent.implicitHeight + 28
                radius: 24
                color: root.surfaceContainerHigh
                clip: true

                ColumnLayout {
                    id: controlsContent

                    spacing: 12

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 14
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: "Quick settings"
                            color: root.onSurface
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: Qt.formatTime(new Date(), "hh:mm")
                            color: root.onSurfaceVariant
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 8

                        PillButton {
                            title: "Wi-Fi"
                            subtitle: ControlCentreState.connectedWifiName()
                            glyph: "◉"
                            active: ControlCentreState.wifiEnabled
                            expanded: ControlCentreState.expandedSection === "wifi"
                            onClicked: ControlCentreState.toggleSection("wifi")
                        }

                        PillButton {
                            title: "Bluetooth"
                            subtitle: ControlCentreState.bluetoothPowered ? (ControlCentreState.bluetoothScanning ? "Scanning" : "On") : "Off"
                            glyph: "ᛒ"
                            active: ControlCentreState.bluetoothPowered
                            expanded: ControlCentreState.expandedSection === "bluetooth"
                            onClicked: ControlCentreState.toggleSection("bluetooth")
                        }

                        PillButton {
                            title: "Audio"
                            subtitle: root.volumePercent + "%"
                            glyph: "♪"
                            active: root.audio != null && !root.audio.muted
                            expanded: ControlCentreState.expandedSection === "audio"
                            onClicked: ControlCentreState.toggleSection("audio")
                        }

                        PillButton {
                            title: "DND"
                            subtitle: ControlCentreState.dnd ? "Muted" : "Popups on"
                            glyph: "−"
                            active: ControlCentreState.dnd
                            onClicked: ControlCentreState.dnd = !ControlCentreState.dnd
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: sliderColumn.implicitHeight + 20
                        radius: 18
                        color: root.surfaceContainerHighest

                        ColumnLayout {
                            id: sliderColumn

                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 10
                            }

                            spacing: 4

                            AndroidSlider {
                                Layout.fillWidth: true
                                icon: "☀"
                                externalValue: ControlCentreState.brightnessPercent
                                onMoved: function(value) {
                                    ControlCentreState.setBrightness(value);
                                }
                            }

                            AndroidSlider {
                                Layout.fillWidth: true
                                icon: root.audio == null || root.audio.muted || root.volumePercent === 0 ? "🔇" : "🔊"
                                externalValue: root.volumePercent
                                enabled: root.audio != null
                                onMoved: function(value) {
                                    if (root.audio != null) {
                                        root.audio.volume = value / 100;
                                        if (root.audio.muted && value > 0)
                                            root.audio.muted = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: notificationsCardHost

            Layout.fillWidth: true
            Layout.fillHeight: true
            opacity: openProgress

            transform: Translate {
                x: (1 - root.openProgress) * 36
            }

            DropShadow {
                anchors.fill: notificationsCard
                horizontalOffset: 0
                verticalOffset: 8
                radius: 28
                samples: 40
                color: "#00000066"
                source: notificationsCard
                transparentBorder: true
            }

            Rectangle {
                id: notificationsCard

                anchors.fill: parent
                radius: 24
                color: root.surfaceContainer
                clip: true

                RowLayout {
                    id: notificationHeader

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 14
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: root.onSurface
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    SmallButton {
                        Layout.fillWidth: false
                        text: "Clear"
                        visible: ControlCentreState.notifications.length > 0
                        onClicked: ControlCentreState.clearNotifications()
                    }
                }

                Text {
                    anchors.centerIn: notificationList
                    text: "No notifications"
                    color: root.onSurfaceVariant
                    font.pixelSize: 13
                    visible: ControlCentreState.notifications.length === 0
                    opacity: 0.85
                }

                Flickable {
                    id: notificationList

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: notificationHeader.bottom
                        bottom: parent.bottom
                        topMargin: 8
                        margins: 14
                    }
                    contentHeight: notificationColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: notificationColumn

                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: ControlCentreState.notifications

                            delegate: Item {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                implicitHeight: notificationBody.implicitHeight + 24
                                opacity: 0

                                Component.onCompleted: revealAnim.start()

                                NumberAnimation {
                                    id: revealAnim

                                    target: parent
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 280
                                    easing.type: Easing.OutCubic
                                }

                                transform: Translate {
                                    y: (1 - parent.opacity) * 16
                                }

                                Rectangle {
                                    id: notificationBody

                                    anchors.fill: parent
                                    radius: 16
                                    color: root.surfaceContainerHighest
                                    scale: pressArea.pressed ? 0.985 : 1

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 120
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 3

                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            top: parent.top
                                            margins: 12
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.appName || "Notification"
                                            color: root.primary
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.summary || ""
                                            color: root.onSurface
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                            visible: text !== ""
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.body || ""
                                            color: root.onSurfaceVariant
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

    Loader {
        id: expandedLoader

        anchors {
            left: parent.left
            right: parent.right
        }
        y: controlsCardHost.height + 12
        z: 10
        active: ControlCentreState.expandedSection !== ""
        opacity: active ? 1 : 0
        sourceComponent: ControlCentreState.expandedSection === "wifi" ? wifiPanel : ControlCentreState.expandedSection === "bluetooth" ? bluetoothPanel : audioPanel

        transform: Translate {
            y: expandedLoader.active ? 0 : -10
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
    }

    Component {
        id: wifiPanel

        MenuPanel {
            title: "Wi-Fi networks"
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
                    color: root.onSurface
                    font.pixelSize: 12
                    clip: true
                    onTextChanged: ControlCentreState.wifiPasswordValue = text

                    Rectangle {
                        anchors.fill: parent
                        z: -1
                        radius: 18
                        color: root.surfaceContainerHighest
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 14
                            verticalCenter: parent.verticalCenter
                        }
                        text: "Password for " + ControlCentreState.wifiPasswordSsid
                        color: root.onSurfaceVariant
                        font.pixelSize: 11
                        visible: wifiPassword.text === ""
                    }
                }

                SmallButton {
                    Layout.fillWidth: false
                    text: "Join"
                    active: true
                    onClicked: ControlCentreState.connectWifi(ControlCentreState.wifiPasswordSsid, ControlCentreState.wifiPasswordValue)
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
                    actionText: modelData.active ? "On" : "Join"
                    onClicked: ControlCentreState.requestWifiConnection(modelData)
                }
            }
        }
    }

    Component {
        id: bluetoothPanel

        MenuPanel {
            title: "Bluetooth devices"
            busy: ControlCentreState.bluetoothScanning
            errorText: ControlCentreState.bluetoothError
            onScanClicked: ControlCentreState.scanBluetooth()

            DeviceRow {
                title: ControlCentreState.bluetoothPowered ? "Bluetooth powered" : "Bluetooth off"
                subtitle: "Toggle adapter"
                glyph: "ᛒ"
                active: ControlCentreState.bluetoothPowered
                actionText: ControlCentreState.bluetoothPowered ? "Off" : "On"
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
                    actionText: modelData.connected ? "Drop" : "Link"
                    onClicked: ControlCentreState.toggleBluetoothDevice(modelData)
                }
            }
        }
    }

    Component {
        id: audioPanel

        MenuPanel {
            title: "Output device"
            showScan: false

            Repeater {
                model: root.outputDevices

                delegate: DeviceRow {
                    required property var modelData

                    title: root.deviceName(modelData)
                    subtitle: modelData.name
                    glyph: "♪"
                    active: Pipewire.defaultAudioSink === modelData
                    actionText: active ? "Now" : "Use"
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }
        }
    }

    transform: Translate {
        x: (1 - root.openProgress) * (root.panelWidth + 24)
    }

    Behavior on openProgress {
        NumberAnimation {
            duration: 380
            easing.type: Easing.OutCubic
        }
    }
}
