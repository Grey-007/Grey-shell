import QtQuick
import Quickshell.Io

Item {
    id: root

    property string configPath: "/home/grey/.config/quickshell/launcher/state.json"
    property var usageMap: ({})
    property var favoritesList: []

    Process {
        id: writeProcess
    }

    function saveState() {
        let data = {
            usage: root.usageMap,
            favorites: root.favoritesList
        };
        let jsonStr = JSON.stringify(data);
        let safeStr = jsonStr.replace(/'/g, "'\\''");
        writeProcess.command = ["bash", "-c", "mkdir -p $(dirname " + root.configPath + ") && echo '" + safeStr + "' > " + root.configPath];
        writeProcess.running = true;
    }

    Process {
        id: readProcess
        command: ["bash", "-c", "cat " + root.configPath + " 2>/dev/null || echo '{}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let text = this.text.trim();
                    if (text && text.length > 0 && text !== "{}") {
                        let data = JSON.parse(text);
                        root.usageMap = data.usage || {};
                        root.favoritesList = data.favorites || [];
                    }
                } catch(e) {
                    console.log("Error parsing launcher settings", e)
                }
            }
        }
    }

    Component.onCompleted: {
        readProcess.running = true;
    }

    function incrementUsage(appId) {
        let usage = usageMap;
        usage[appId] = (usage[appId] || 0) + 1;
        usageMap = usage;
        saveState();
    }

    function toggleFavorite(appId) {
        let favs = favoritesList;
        let index = favs.indexOf(appId);
        if (index !== -1) favs.splice(index, 1);
        else favs.push(appId);
        favoritesList = favs;
        favoritesChanged();
        saveState();
    }

    function isFavorite(appId) {
        return favoritesList.indexOf(appId) !== -1;
    }

    function getUsage(appId) {
        return usageMap[appId] || 0;
    }

    signal favoritesChanged()
}
