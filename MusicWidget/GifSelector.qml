import QtQuick
import Quickshell.Io

// Component to scan the assets/gif directory for .gif files
DirectoryModel {
    id: gifSelector
    path: "../assets/gif/"
    nameFilters: ["*.gif"]
    showDirs: false
}