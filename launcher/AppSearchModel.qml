// AppSearchModel.qml

import Quickshell
import QtQuick

QtObject {
    id: root

    property string query: ""
    property var state: null
    readonly property int count: model.count

    signal rebuilt()

    property ListModel model: ListModel {}

    function rebuild(): void {
        model.clear();

        var normalizedQuery = query.toLowerCase().trim();
        var chars = normalizedQuery.split("");
        var entries = DesktopEntries.applications.values || [];
        var sorted = [];

        function isFuzzyMatch(text) {
            if (chars.length === 0) return true;
            var t = text.toLowerCase();
            var i = 0;
            for (var c = 0; c < t.length; c++) {
                if (t[c] === chars[i]) i++;
                if (i === chars.length) return true;
            }
            return false;
        }

        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (!entry || entry.noDisplay)
                continue;

            var name = entry.name || "";
            var genericName = entry.genericName || "";
            var comment = entry.comment || "";
            var haystack = name + " " + genericName + " " + comment;

            if (isFuzzyMatch(haystack)) {
                sorted.push({
                    name: name,
                    icon: entry.icon || "",
                    entryId: entry.id
                });
            }
        }

        sorted.sort(function(a, b) {
            if (root.state) {
                var aFav = root.state.isFavorite(a.entryId) ? 1 : 0;
                var bFav = root.state.isFavorite(b.entryId) ? 1 : 0;
                if (aFav !== bFav) return bFav - aFav;
                
                var aUse = root.state.getUsage(a.entryId);
                var bUse = root.state.getUsage(b.entryId);
                if (aUse !== bUse) return bUse - aUse;
            }
            return a.name.localeCompare(b.name);
        });

        for (var j = 0; j < sorted.length; j++) {
            model.append(sorted[j]);
        }

        rebuilt();
    }

    function launch(index: int): bool {
        if (index < 0 || index >= model.count)
            return false;

        var entryInfo = model.get(index);
        var entry = DesktopEntries.byId(entryInfo.entryId);
        if (!entry)
            return false;

        if (root.state) root.state.incrementUsage(entry.id);
        entry.execute();
        return true;
    }

    onQueryChanged: rebuild()
    Component.onCompleted: rebuild()

    property Connections desktopEntryConnections: Connections {
        target: DesktopEntries
        function onApplicationsChanged(): void {
            root.rebuild();
        }
    }

    property Connections stateConnections: Connections {
        target: root.state
        function onFavoritesChanged(): void {
            root.rebuild();
        }
    }
}
