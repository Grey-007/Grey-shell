import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool visible: false

    // Raw list: [{path, name, url}]
    property var wallpapers: []

    // Search filter only (no tags)
    property string searchText: ""

    readonly property var filteredWallpapers: {
        const q = searchText.trim().toLowerCase();
        if (q === "") return wallpapers;
        return wallpapers.filter(w => w.name.toLowerCase().indexOf(q) !== -1);
    }

    property string currentWallpaper: ""
    property bool   scanning:  false
    property string errorText: ""

    function open()   { visible = true;  if (wallpapers.length === 0) scan(); }
    function close()  { visible = false; searchText = ""; errorText = ""; }
    function toggle() { if (visible) close(); else open(); }

    function scan() {
        if (scanning) return;
        scanning  = true;
        errorText = "";
        const dir = Quickshell.env("HOME") + "/Pictures/Wallpapers";
        _scanProc.command = [
            "bash", "-c",
            "find " + JSON.stringify(dir) +
            " -maxdepth 3 -type f" +
            " \\( -iname '*.jpg' -o -iname '*.jpeg'" +
            "  -o -iname '*.png' -o -iname '*.webp'" +
            "  -o -iname '*.gif' -o -iname '*.bmp' \\)" +
            " | sort"
        ];
        _scanProc.running = true;
    }

    function applyWallpaper(path) {
        currentWallpaper = path;
        const effects = ["wipe", "wave", "grow", "outer", "center", "fade"];
        const t = effects[Math.floor(Math.random() * effects.length)];
        _applyProc.command = [
            "awww", "img", path,
            "--transition-type", t,
            "--transition-fps",  "60",
            "--transition-step", "2"
        ];
        _applyProc.running = true;
    }

    Process {
        id: _scanProc
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l !== "");
                // Parse in chunks to avoid blocking the UI thread
                const result = [];
                for (let i = 0; i < lines.length; i++) {
                    const p    = lines[i];
                    const name = p.split("/").pop().replace(/\.[^.]+$/, "");
                    result.push({ path: p, name: name, url: "file://" + p });
                }
                root.wallpapers = result;
                root.scanning   = false;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim();
                if (t !== "") root.errorText = t;
                root.scanning = false;
            }
        }
    }

    Process {
        id: _applyProc
        stderr: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim();
                if (t !== "") root.errorText = "awww: " + t;
            }
        }
    }
}
