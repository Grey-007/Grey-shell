import "."
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    id: root

    property int panelWidth: 396
    property int panelHeight: 744
    property real openProgress: ControlCentreState.open ? 1 : 0
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

    function deviceName(node) {
        if (node == null)
            return "Output device";

        return node.description || node.nickname || node.name || "Output device";
    }

    width: panelWidth
    height: panelHeight
    opacity: openProgress
    enabled: ControlCentreState.open || openProgress > 0.01

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    PwObjectTracker {
        objects: root.outputDevices
    }

    DropShadow {
        anchors.fill: body
        horizontalOffset: -5
        verticalOffset: 0
        radius: 28
        samples: 48
        color: "#0000002a"
        source: body
        transparentBorder: true
    }

    Rectangle {
        id: body

        anchors.fill: parent
        radius: 28
        color: "#fffbf7"
        border.color: "#00000012"
        border.width: 1
        antialiasing: true
    }

    Flickable {
        anchors.fill: body
        anchors.margins: 16
        contentHeight: content.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: content

            width: parent.width
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "Control Centre"
                    color: "#272522"
                    font.pixelSize: 20
                    font.weight: 600
                }

                Text {
                    text: Qt.formatTime(new Date(), "hh:mm")
                    color: "#7a736c"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                PillButton {
                    title: "Wi-Fi"
                    subtitle: ControlCentreState.connectedWifiName()
                    glyph: "WF"
                    active: ControlCentreState.wifiEnabled
                    expanded: ControlCentreState.expandedSection === "wifi"
                    onClicked: ControlCentreState.toggleSection("wifi")
                }

                PillButton {
                    title: "Bluetooth"
                    subtitle: ControlCentreState.bluetoothPowered ? (ControlCentreState.bluetoothScanning ? "Scanning" : "On") : "Off"
                    glyph: "BT"
                    active: ControlCentreState.bluetoothPowered
                    expanded: ControlCentreState.expandedSection === "bluetooth"
                    onClicked: ControlCentreState.toggleSection("bluetooth")
                }

                PillButton {
                    title: "Audio"
                    subtitle: root.volumePercent + "%"
                    glyph: "AU"
                    active: root.audio != null && !root.audio.muted
                    expanded: ControlCentreState.expandedSection === "audio"
                    onClicked: ControlCentreState.toggleSection("audio")
                }

                PillButton {
                    title: "DND"
                    subtitle: ControlCentreState.dnd ? "Muted" : "Popups on"
                    glyph: "DN"
                    active: ControlCentreState.dnd
                    expanded: false
                    onClicked: ControlCentreState.dnd = !ControlCentreState.dnd
                }

            }

            Loader {
                Layout.fillWidth: true
                active: ControlCentreState.expandedSection !== ""
                sourceComponent: ControlCentreState.expandedSection === "wifi" ? wifiPanel : ControlCentreState.expandedSection === "bluetooth" ? bluetoothPanel : audioPanel
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 2

                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: "#272522"
                    font.pixelSize: 16
                    font.weight: 600
                }

                Rectangle {
                    width: clearText.implicitWidth + 20
                    height: 30
                    radius: 15
                    color: "#efe9e3"
                    visible: ControlCentreState.notifications.length > 0

                    Text {
                        id: clearText

                        anchors.centerIn: parent
                        text: "Clear"
                        color: "#4b4640"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ControlCentreState.clearNotifications()
                    }

                }

            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 24
                horizontalAlignment: Text.AlignHCenter
                text: "No notifications"
                color: "#8d857d"
                font.pixelSize: 13
                visible: ControlCentreState.notifications.length === 0
            }

            Repeater {
                model: ControlCentreState.notifications

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: notificationContent.implicitHeight + 24
                    radius: 20
                    color: "#f5f1ec"
                    border.color: "#0000000d"
                    border.width: 1
                    antialiasing: true

                    ColumnLayout {
                        id: notificationContent

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
                            color: "#827a73"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary || ""
                            color: "#2c2926"
                            font.pixelSize: 13
                            font.weight: 600
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.body || ""
                            color: "#625b55"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            visible: text !== ""
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ControlCentreState.dismissNotification(modelData)
                    }

                }

            }

        }

    }

    Component {
        id: wifiPanel

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: wifiContent.implicitHeight + 24
            radius: 22
            color: "#f7f2ed"
            border.color: "#00000010"
            border.width: 1

            ColumnLayout {
                id: wifiContent

                spacing: 8

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Wi-Fi networks"
                        color: "#302d29"
                        font.pixelSize: 13
                        font.weight: 600
                    }

                    SmallButton {
                        Layout.fillWidth: false
                        text: ControlCentreState.wifiScanning ? "Scanning" : "Scan"
                        onClicked: ControlCentreState.scanWifi()
                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: ControlCentreState.wifiPasswordSsid !== ""

                    TextInput {
                        id: wifiPassword

                        Layout.fillWidth: true
                        height: 36
                        text: ControlCentreState.wifiPasswordValue
                        echoMode: TextInput.Password
                        color: "#2b2825"
                        font.pixelSize: 12
                        clip: true
                        onTextChanged: ControlCentreState.wifiPasswordValue = text

                        Rectangle {
                            anchors.fill: parent
                            z: -1
                            radius: 16
                            color: "#fffaf5"
                            border.color: "#00000012"
                        }

                        Text {
                            text: "Password for " + ControlCentreState.wifiPasswordSsid
                            color: "#8d857d"
                            font.pixelSize: 11
                            visible: wifiPassword.text === ""

                            anchors {
                                left: parent.left
                                leftMargin: 12
                                verticalCenter: parent.verticalCenter
                            }

                        }

                    }

                    SmallButton {
                        Layout.fillWidth: false
                        text: "Join"
                        active: true
                        onClicked: ControlCentreState.connectWifi(ControlCentreState.wifiPasswordSsid, ControlCentreState.wifiPasswordValue)
                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: ControlCentreState.wifiError
                    color: "#a2443f"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                }

                Repeater {
                    model: ControlCentreState.wifiNetworks

                    delegate: DeviceRow {
                        required property var modelData

                        title: modelData.ssid
                        subtitle: (modelData.active ? "Connected • " : "") + modelData.security + " • " + modelData.signal + "%"
                        glyph: "WF"
                        active: modelData.active
                        actionText: modelData.active ? "On" : "Join"
                        onClicked: ControlCentreState.requestWifiConnection(modelData)
                    }

                }

            }

        }

    }

    Component {
        id: bluetoothPanel

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: bluetoothContent.implicitHeight + 24
            radius: 22
            color: "#f7f2ed"
            border.color: "#00000010"
            border.width: 1

            ColumnLayout {
                id: bluetoothContent

                spacing: 8

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Bluetooth devices"
                        color: "#302d29"
                        font.pixelSize: 13
                        font.weight: 600
                    }

                    SmallButton {
                        Layout.fillWidth: false
                        text: ControlCentreState.bluetoothScanning ? "Scanning" : "Scan"
                        onClicked: ControlCentreState.scanBluetooth()
                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: ControlCentreState.bluetoothError
                    color: "#a2443f"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                }

                DeviceRow {
                    title: ControlCentreState.bluetoothPowered ? "Bluetooth powered" : "Bluetooth off"
                    subtitle: "Toggle adapter"
                    glyph: "BT"
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
                        glyph: "BT"
                        active: modelData.connected
                        actionText: modelData.connected ? "Drop" : "Link"
                        onClicked: ControlCentreState.toggleBluetoothDevice(modelData)
                    }

                }

            }

        }

    }

    Component {
        id: audioPanel

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: audioContent.implicitHeight + 24
            radius: 22
            color: "#f7f2ed"
            border.color: "#00000010"
            border.width: 1

            ColumnLayout {
                id: audioContent

                spacing: 10

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Output volume"
                        color: "#302d29"
                        font.pixelSize: 13
                        font.weight: 600
                    }

                    Text {
                        text: root.volumePercent + "%"
                        color: "#716a63"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                }

                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: root.audio != null ? root.audio.volume : 0
                    enabled: root.audio != null
                    onMoved: {
                        if (root.audio != null) {
                            root.audio.volume = value;
                            if (root.audio.muted && value > 0)
                                root.audio.muted = false;

                        }
                    }

                    background: Rectangle {
                        x: parent.leftPadding
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        width: parent.availableWidth
                        height: 6
                        radius: 3
                        color: "#e6ded7"

                        Rectangle {
                            width: parent.parent.visualPosition * parent.width
                            height: parent.height
                            radius: 3
                            color: "#2f5fae"
                        }

                    }

                    handle: Rectangle {
                        x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        width: 18
                        height: 18
                        radius: 9
                        color: "#2f5fae"
                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: "Output device"
                    color: "#716a63"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                Repeater {
                    model: root.outputDevices

                    delegate: DeviceRow {
                        required property var modelData

                        title: root.deviceName(modelData)
                        subtitle: modelData.name
                        glyph: "AU"
                        active: Pipewire.defaultAudioSink === modelData
                        actionText: active ? "Now" : "Use"
                        onClicked: Pipewire.preferredDefaultAudioSink = modelData
                    }

                }

            }

        }

    }

    transform: Translate {
        x: (1 - root.openProgress) * (root.panelWidth + 24)
    }

    Behavior on openProgress {
        NumberAnimation {
            duration: 420
            easing.type: Easing.OutQuint
        }

    }

}
