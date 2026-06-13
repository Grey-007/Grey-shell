import QtQuick
import Quickshell
import "wallpaper"

ShellRoot {
    WallpaperConfig {
        id: cfg
    }

    WallpaperModel {
        id: wm
        directory: cfg.wallpaperDirectory
        scanDepth: cfg.scanDepth
    }

    Item {
        width: 1200
        height: 360

        HoneycombGrid {
            wallpaperModel: wm
            config: cfg
        }
    }
}
