import Quickshell.Io
import QtQuick

QtObject {
    id: root

    property string directory: ""
    property int scanDepth: 2
    property bool autoRefresh: false
    property string selectedPath: ""
    property bool loading: false
    readonly property int count: wallpapers.count
    property ListModel wallpapers: ListModel {}

    signal scanned()
    signal applyRequested(string path)

    function refresh(): void {
        if (directory.length === 0)
            return;

        loading = true;
        scanner.exec([
            "find", directory,
            "-maxdepth", Math.max(1, scanDepth).toString(),
            "-type", "f",
            "-regextype", "posix-extended",
            "-iregex", ".*\\.(jpg|jpeg|png|webp|bmp|gif|avif|heic|jxl)$",
            "-printf", "%T@\t%p\n"
        ]);
    }

    function load(text: string): void {
        var rows = text.split("\n");
        var files = [];

        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            if (row.length === 0)
                continue;

            var tab = row.indexOf("\t");
            if (tab < 0)
                continue;

            var path = row.slice(tab + 1);
            files.push({
                modified: Number(row.slice(0, tab)),
                path: path,
                name: path.split("/").pop()
            });
        }

        files.sort(function(a, b) {
            return b.modified - a.modified;
        });

        wallpapers.clear();
        for (var j = 0; j < files.length; j++)
            wallpapers.append(files[j]);

        loading = false;
        scanned();
    }

    function get(index: int) {
        if (index < 0 || index >= wallpapers.count)
            return null;

        return wallpapers.get(index);
    }

    function apply(path: string): void {
        if (path.length === 0)
            return;

        selectedPath = path;
        applyRequested(path);
    }

    property Process scanner: Process {
        id: scanner
        stdout: StdioCollector {
            onStreamFinished: root.load(text)
        }
        onRunningChanged: {
            if (!running && root.loading)
                root.loading = false;
        }
    }

    onDirectoryChanged: {
        if (autoRefresh)
            refresh();
    }

    onScanDepthChanged: {
        if (autoRefresh)
            refresh();
    }

    Component.onCompleted: {
        if (autoRefresh)
            refresh();
    }
}
