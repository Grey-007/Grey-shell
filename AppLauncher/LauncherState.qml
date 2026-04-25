import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property bool open: false
    property string query: ""
    property int selectedIndex: 0
    readonly property var allApps: {
        const result = [];
        const vals = DesktopEntries.applications.values;
        for (let i = 0; i < vals.length; i++) {
            const e = vals[i];
            if (e != null)
                result.push(e);

        }
        result.sort(function(a, b) {
            return (a.name || "").localeCompare(b.name || "");
        });
        return result;
    }
    readonly property var filteredApps: {
        const q = query.toLowerCase().trim();
        if (q === "")
            return allApps;

        return allApps.filter(function(e) {
            const name = (e.name || "").toLowerCase();
            const generic = (e.genericName || "").toLowerCase();
            const comment = (e.comment || "").toLowerCase();
            const keys = keywordText(e).toLowerCase();
            return name.includes(q) || generic.includes(q) || comment.includes(q) || keys.includes(q);
        });
    }

    function toggle() {
        if (open)
            close();
        else
            openLauncher();
    }

    function openLauncher() {
        query = "";
        selectedIndex = 0;
        open = true;
    }

    function close() {
        open = false;
        query = "";
        selectedIndex = 0;
    }

    function description(entry) {
        if (entry == null)
            return "";

        return entry.comment || entry.genericName || "";
    }

    function keywordText(entry) {
        if (entry == null || entry.keywords == null)
            return "";

        let text = "";
        for (let i = 0; i < entry.keywords.length; i++) text += " " + entry.keywords[i]
        return text;
    }

    function launch(entry) {
        if (entry == null)
            return ;

        entry.execute();
        close();
    }

}
