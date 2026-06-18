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

    function load() {
        let req = new XMLHttpRequest();
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                if (req.status === 200 || req.status === 0) {
                    try {
                        if (req.responseText.length > 0) {
                            let data = JSON.parse(req.responseText);
                            root.wallpaperDirectory = data.wallpaperDirectory || "/home/grey/Pictures/Wallpapers";
                            root.awwwAnimation = data.awwwAnimation || "fade";
                            root.animationDuration = data.animationDuration || 1000;
                            root.appliedWallpaper = data.appliedWallpaper || "";
                        }
                    } catch(e) {
                        console.log("Error parsing wallpaper config:", e);
                    }
                }
                root.isLoaded = true;
            }
        }
        req.open("GET", "file://" + configPath);
        req.send();
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
