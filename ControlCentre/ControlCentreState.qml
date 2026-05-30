import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
pragma Singleton

Singleton {
    id: root

    property bool open: false
    property bool dnd: false
    property string expandedSection: ""
    property bool wifiEnabled: false
    property bool wifiScanning: false
    property string wifiError: ""
    property var wifiNetworks: []
    property string wifiPasswordSsid: ""
    property string wifiPasswordSecurity: ""
    property string wifiPasswordValue: ""
    property bool bluetoothPowered: false
    property bool bluetoothScanning: false
    property string bluetoothError: ""
    property var bluetoothDevices: []
    property var bluetoothConnectedIds: []
    property var notifications: []
    property var toastNotifications: []
    property int toastSerial: 0
    property int brightnessPercent: 50
    property bool brightnessAdjusting: false

    function toggle() {
        if (open)
            close();
        else
            openPanel();
    }

    function openPanel() {
        open = true;
        refreshWifi();
        refreshBluetooth();
        refreshBrightness();
    }

    function close() {
        open = false;
        expandedSection = "";
        wifiPasswordSsid = "";
        wifiPasswordValue = "";
    }

    function toggleSection(section) {
        expandedSection = expandedSection === section ? "" : section;
        if (expandedSection === "wifi")
            scanWifi();

        if (expandedSection === "bluetooth")
            scanBluetooth();

    }

    function connectedWifiName() {
        for (let i = 0; i < wifiNetworks.length; i++) {
            if (wifiNetworks[i].active)
                return wifiNetworks[i].ssid;

        }
        return wifiEnabled ? "Available" : "Off";
    }

    function toggleWifi() {
        wifiError = "";
        wifiActionProcess.exec(["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"]);
    }

    function refreshWifi() {
        wifiStateProcess.exec(["nmcli", "-t", "-f", "WIFI", "general"]);
        scanWifi();
    }

    function scanWifi() {
        wifiError = "";
        wifiScanning = true;
        wifiListProcess.exec(["nmcli", "-t", "-f", "ACTIVE,SSID,SECURITY,SIGNAL", "device", "wifi", "list", "--rescan", "yes"]);
    }

    function requestWifiConnection(network) {
        if (network.active) {
            wifiActionProcess.exec(["nmcli", "connection", "down", "id", network.ssid]);
            return ;
        }
        if (network.secure) {
            wifiPasswordSsid = network.ssid;
            wifiPasswordSecurity = network.security;
            wifiPasswordValue = "";
        } else {
            connectWifi(network.ssid, "");
        }
    }

    function connectWifi(ssid, password) {
        wifiError = "";
        wifiPasswordSsid = "";
        wifiPasswordValue = "";
        if (password === "")
            wifiActionProcess.exec(["nmcli", "device", "wifi", "connect", ssid]);
        else
            wifiActionProcess.exec(["nmcli", "device", "wifi", "connect", ssid, "password", password]);
    }

    function toggleBluetooth() {
        bluetoothError = "";
        bluetoothActionProcess.exec(["bluetoothctl", "power", bluetoothPowered ? "off" : "on"]);
    }

    function refreshBluetooth() {
        bluetoothShowProcess.exec(["bluetoothctl", "show"]);
        bluetoothDevicesProcess.exec(["bluetoothctl", "devices"]);
        bluetoothConnectedProcess.exec(["bluetoothctl", "devices", "Connected"]);
    }

    function scanBluetooth() {
        bluetoothError = "";
        bluetoothScanning = true;
        bluetoothScanProcess.exec(["bluetoothctl", "--timeout", "4", "scan", "on"]);
    }

    function toggleBluetoothDevice(device) {
        bluetoothError = "";
        bluetoothActionProcess.exec(["bluetoothctl", device.connected ? "disconnect" : "connect", device.address]);
    }

    function refreshBrightness() {
        if (brightnessAdjusting)
            return ;

        brightnessReadProcess.exec(["sh", "-c",
            "for d in /sys/class/backlight/*; do " +
            "[ -r \"$d/brightness\" ] && [ -r \"$d/max_brightness\" ] || continue; " +
            "b=$(cat \"$d/brightness\"); " +
            "m=$(cat \"$d/max_brightness\"); " +
            "[ \"$m\" -gt 0 ] || continue; " +
            "echo $(( (b * 100 + m / 2) / m )); " +
            "exit 0; " +
            "done"
        ]);
    }

    function setBrightness(percent) {
        const clamped = Math.max(0, Math.min(100, Math.round(percent)));
        brightnessPercent = clamped;
        brightnessAdjusting = true;
        brightnessWriteTimer.restart();
    }

    function applyBrightnessWrite() {
        const percent = brightnessPercent;
        brightnessWriteProcess.exec(["sh", "-c",
            "for d in /sys/class/backlight/*; do " +
            "[ -r \"$d/brightness\" ] && [ -r \"$d/max_brightness\" ] || continue; " +
            "m=$(cat \"$d/max_brightness\"); " +
            "v=$(( (m * " + percent + " + 50) / 100 )); " +
            "name=$(basename \"$d\"); " +
            "if command -v brightnessctl >/dev/null 2>&1; then " +
            "  brightnessctl --device=\"$name\" set \"" + percent + "%\" >/dev/null 2>&1 && exit 0; " +
            "fi; " +
            "for session in /org/freedesktop/login1/session/auto /org/freedesktop/login1/session/self; do " +
            "  if busctl call org.freedesktop.login1 \"$session\" org.freedesktop.login1.Session SetBrightness ssu backlight \"$name\" \"$v\" >/dev/null 2>&1; then " +
            "    exit 0; " +
            "  fi; " +
            "done; " +
            "printf '%s' \"$v\" > \"$d/brightness\" 2>/dev/null && exit 0; " +
            "done; " +
            "exit 1"
        ]);
    }

    function finishBrightnessAdjust() {
        brightnessAdjusting = false;
        refreshBrightness();
    }

    function parseWifiState(text) {
        wifiEnabled = text.trim().toLowerCase() === "enabled";
    }

    function parseWifiList(text) {
        const lines = text.trim().split("\n");
        const bySsid = ({
        });
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (line === "")
                continue;

            const parts = line.split(":");
            if (parts.length < 4)
                continue;

            const active = parts[0] === "yes";
            const signal = Number(parts[parts.length - 1]) || 0;
            const security = parts[parts.length - 2];
            const ssid = parts.slice(1, parts.length - 2).join(":").replace(/\\:/g, ":");
            if (ssid === "")
                continue;

            const current = bySsid[ssid];
            if (current == null || active || signal > current.signal)
                bySsid[ssid] = {
                "ssid": ssid,
                "active": active,
                "secure": security !== "" && security !== "--",
                "security": security === "" ? "Open" : security,
                "signal": signal
            };

        }
        const result = [];
        for (const key in bySsid) result.push(bySsid[key])
        result.sort(function(a, b) {
            if (a.active !== b.active)
                return a.active ? -1 : 1;

            return b.signal - a.signal;
        });
        wifiNetworks = result;
        wifiScanning = false;
    }

    function parseBluetoothPower(text) {
        bluetoothPowered = text.indexOf("Powered: yes") !== -1;
    }

    function parseBluetoothDevices(text) {
        const lines = text.trim().split("\n");
        const result = [];
        for (let i = 0; i < lines.length; i++) {
            const match = lines[i].match(/^Device\s+([0-9A-F:]{17})\s+(.+)$/i);
            if (match == null)
                continue;

            result.push({
                "address": match[1],
                "name": match[2],
                "connected": bluetoothConnectedIds.indexOf(match[1]) !== -1
            });
        }
        bluetoothDevices = result;
    }

    function parseConnectedBluetoothDevices(text) {
        const lines = text.trim().split("\n");
        const ids = [];
        for (let i = 0; i < lines.length; i++) {
            const match = lines[i].match(/^Device\s+([0-9A-F:]{17})\s+/i);
            if (match != null)
                ids.push(match[1]);

        }
        bluetoothConnectedIds = ids;
        const updated = [];
        for (let j = 0; j < bluetoothDevices.length; j++) {
            const device = bluetoothDevices[j];
            updated.push({
                "address": device.address,
                "name": device.name,
                "connected": ids.indexOf(device.address) !== -1
            });
        }
        bluetoothDevices = updated;
    }

    function addNotification(notification) {
        notification.tracked = true;
        notifications = [notification].concat(notifications).slice(0, 40);
        if (!dnd) {
            toastSerial += 1;
            toastNotifications = toastNotifications.concat([{
                "id": toastSerial,
                "notification": notification
            }]);
        }
    }

    function removeToast(id) {
        toastNotifications = toastNotifications.filter(function(toast) {
            return toast.id !== id;
        });
    }

    function dismissNotification(notification) {
        if (notification == null)
            return ;

        notification.dismiss();
        notifications = notifications.filter(function(item) {
            return item !== notification;
        });
        toastNotifications = toastNotifications.filter(function(toast) {
            return toast.notification !== notification;
        });
    }

    function clearNotifications() {
        for (let i = 0; i < notifications.length; i++) {
            if (notifications[i] != null)
                notifications[i].dismiss();

        }
        notifications = [];
        toastNotifications = [];
    }

    NotificationServer {
        keepOnReload: false
        actionsSupported: true
        imageSupported: true
        bodySupported: true
        onNotification: function(notification) {
            root.addNotification(notification);
        }
    }

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: root.refreshBrightness()
    }

    Timer {
        id: brightnessWriteTimer

        interval: 80
        repeat: false
        onTriggered: root.applyBrightnessWrite()
    }

    Component.onCompleted: refreshBrightness()

    Process {
        id: brightnessReadProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.brightnessAdjusting)
                    return ;

                const value = parseInt(this.text.trim());
                if (!isNaN(value))
                    root.brightnessPercent = Math.max(0, Math.min(100, value));
            }
        }
    }

    Process {
        id: brightnessWriteProcess

        onExited: finishBrightnessTimer.restart()
    }

    Timer {
        id: finishBrightnessTimer

        interval: 200
        repeat: false
        onTriggered: root.finishBrightnessAdjust()
    }

    Process {
        id: wifiStateProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseWifiState(this.text)
        }

    }

    Process {
        id: wifiListProcess

        onExited: function() {
            root.wifiScanning = false;
        }

        stdout: StdioCollector {
            onStreamFinished: root.parseWifiList(this.text)
        }

        stderr: StdioCollector {
            onStreamFinished: root.wifiError = this.text.trim()
        }

    }

    Process {
        id: wifiActionProcess

        onExited: function() {
            root.refreshWifi();
        }

        stderr: StdioCollector {
            onStreamFinished: root.wifiError = this.text.trim()
        }

    }

    Process {
        id: bluetoothShowProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseBluetoothPower(this.text)
        }

        stderr: StdioCollector {
            onStreamFinished: root.bluetoothError = this.text.trim()
        }

    }

    Process {
        id: bluetoothDevicesProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseBluetoothDevices(this.text)
        }

    }

    Process {
        id: bluetoothConnectedProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseConnectedBluetoothDevices(this.text)
        }

    }

    Process {
        id: bluetoothScanProcess

        onExited: function() {
            root.bluetoothScanning = false;
            root.refreshBluetooth();
        }
    }

    Process {
        id: bluetoothActionProcess

        onExited: function() {
            root.refreshBluetooth();
        }

        stderr: StdioCollector {
            onStreamFinished: root.bluetoothError = this.text.trim()
        }

    }

}
