// WallpaperStore.qml
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Io

Item {
    id: root

    // Output properties
    property string selectedWallpaper: ""
    property int selectedIndex: 0
    property alias model: filteredModel

    // Search input
    property string searchQuery: ""

    // Reference to configuration
    property var config: null

    Process {
        id: awwwProcess
        onExited: function(code) {
            if (code !== 0) {
                console.log("AWWW failed to apply wallpaper");
            } else {
                if (root.config) {
                    root.config.appliedWallpaper = root.selectedWallpaper;
                    root.config.save();
                }
            }
        }
    }

    // Hidden source of truth
    FolderListModel {
        id: folderModel
        folder: (root.config && root.config.isLoaded) ? "file://" + root.config.wallpaperDirectory : "file:///home/grey/Pictures/Wallpapers"
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        showDotAndDotDot: false

        onCountChanged: {
            // Re-populate the filter model when the base directory scan finishes
            updateFilteredModel()
        }
    }

    // Exposed model handling search filtering
    ListModel {
        id: filteredModel
    }

    onSearchQueryChanged: {
        updateFilteredModel()
    }

    function updateFilteredModel() {
        filteredModel.clear();
        let query = root.searchQuery.toLowerCase();
        
        let previouslySelected = root.selectedWallpaper;
        let newSelectedIndex = -1;

        for (let i = 0; i < folderModel.count; i++) {
            let fileUrl = folderModel.get(i, "fileUrl");
            let fileName = folderModel.get(i, "fileName").toLowerCase();

            if (query === "" || fileName.includes(query)) {
                filteredModel.append({ "fileUrl": fileUrl, "fileName": fileName });
                
                // Track if our currently selected wallpaper is still visible
                if (fileUrl === previouslySelected) {
                    newSelectedIndex = filteredModel.count - 1;
                }
            }
        }

        // Handle selection state post-filter
        if (filteredModel.count === 0) {
            root.selectedIndex = -1;
            root.selectedWallpaper = "";
        } else if (newSelectedIndex !== -1) {
            // Maintain current selection
            root.selectedIndex = newSelectedIndex;
        } else {
            // Selection was filtered out, default to first item
            root.selectedIndex = 0;
            root.selectedWallpaper = filteredModel.get(0).fileUrl;
        }
    }

    onSelectedIndexChanged: {
        if (selectedIndex >= 0 && selectedIndex < filteredModel.count) {
            selectedWallpaper = filteredModel.get(selectedIndex).fileUrl
        }
    }

    function applyWallpaper() {
        if (!root.config || root.selectedWallpaper === "") return;
        
        let localPath = root.selectedWallpaper.replace("file://", "");
        let anim = root.config.awwwAnimation;
        let durationSeconds = (root.config.animationDuration / 1000.0).toString();

        awwwProcess.command = ["awww", "img", "--transition-type", anim, "--transition-duration", durationSeconds, localPath];
        awwwProcess.running = true;
    }
}
