import QtQuick
import QtCore

Item {
    id: root

    property var usageMap: ({})
    property var favoritesList: []

    Settings {
        id: settings
        category: "QuickshellLauncher"
        property string usageJson: "{}"
        property string favoritesJson: "[]"
        
        Component.onCompleted: {
            try {
                root.usageMap = JSON.parse(settings.usageJson)
                root.favoritesList = JSON.parse(settings.favoritesJson)
            } catch(e) {
                console.log("Error parsing launcher settings", e)
            }
        }
    }

    function incrementUsage(appId) {
        let usage = usageMap;
        usage[appId] = (usage[appId] || 0) + 1;
        usageMap = usage;
        settings.usageJson = JSON.stringify(usage);
    }

    function toggleFavorite(appId) {
        let favs = favoritesList;
        let index = favs.indexOf(appId);
        if (index !== -1) favs.splice(index, 1);
        else favs.push(appId);
        favoritesList = favs;
        settings.favoritesJson = JSON.stringify(favs);
        favoritesChanged();
    }

    function isFavorite(appId) {
        return favoritesList.indexOf(appId) !== -1;
    }

    function getUsage(appId) {
        return usageMap[appId] || 0;
    }

    signal favoritesChanged()
}
