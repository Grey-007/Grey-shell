// WallpaperConfig.qml
import QtQuick
import Quickshell.Io

Item {
    id: root

    property string configPath: "/home/grey/.config/quickshell/wallpaper/config/wallpaper.json"

    // Persisted settings
    property string wallpaperDirectory: "/home/grey/Pictures/Wallpapers"
    property string awwwAnimation: "fade"
    property int animationDuration: 1000
    property string appliedWallpaper: ""

    property bool isLoaded: false

    Process {
        id: writeProcess
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
                        root.wallpaperDirectory = data.wallpaperDirectory || "/home/grey/Pictures/Wallpapers";
                        root.awwwAnimation = data.awwwAnimation || "fade";
                        root.animationDuration = data.animationDuration || 1000;
                        root.appliedWallpaper = data.appliedWallpaper || "";
                    }
                } catch(e) {
                    console.log("Error parsing wallpaper config:", e);
                }
                root.isLoaded = true;
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.isLoaded = true;
            }
        }
    }

    function load() {
        readProcess.running = true;
    }

    function save() {
        let data = {
            wallpaperDirectory: root.wallpaperDirectory,
            awwwAnimation: root.awwwAnimation,
            animationDuration: root.animationDuration,
            appliedWallpaper: root.appliedWallpaper
        };
        let jsonStr = JSON.stringify(data);
        let safeStr = jsonStr.replace(/'/g, "'\\''");
        writeProcess.command = ["bash", "-c", "echo '" + safeStr + "' > " + root.configPath];
        writeProcess.running = true;
    }

    Component.onCompleted: {
        load();
    }
}
