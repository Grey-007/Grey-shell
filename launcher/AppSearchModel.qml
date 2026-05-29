// AppSearchModel.qml

import Quickshell
import QtQuick

QtObject {
    id: root

    property string query: ""
    readonly property int count: model.count

    signal rebuilt()

    property ListModel model: ListModel {}

    function rebuild(): void {
        model.clear();

        var normalizedQuery = query.toLowerCase().trim();
        var entries = DesktopEntries.applications.values || [];
        var sorted = [];

        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (!entry || entry.noDisplay)
                continue;

            var name = entry.name || "";
            var genericName = entry.genericName || "";
            var comment = entry.comment || "";
            var haystack = (name + " " + genericName + " " + comment).toLowerCase();

            if (normalizedQuery === "" || haystack.indexOf(normalizedQuery) !== -1) {
                sorted.push({
                    name: name,
                    icon: entry.icon || "",
                    entryId: entry.id
                });
            }
        }

        sorted.sort(function(a, b) {
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
}
