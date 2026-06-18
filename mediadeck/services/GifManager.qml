import QtQuick
import Quickshell
import Quickshell.Io

// GifManager.qml
//
// Manages the selection of random GIFs from the local assets folder.
// Reacts to track changes from MprisService.
QtObject {
    id: root

    // -- Properties --
    property var mprisService
    property string currentGif: ""
    readonly property bool hasGifs: gifList.length > 0
    property var gifList: []
    
    // The reactive path that components should bind to
    readonly property string currentGifPath: {
        if (currentGif === "" || _gifsPath === "") return "";
        return "file://" + _gifsPath + "/" + currentGif;
    }

    // -- Internal State --
    property string _gifsPath: ""

    // -- Initialization --
    Component.onCompleted: {
        _gifsPath = Quickshell.configDir + "/mediadeck/assets/gifs";
        console.log("GifManager: Scanning path: " + _gifsPath);
        refresh();
    }

    // -- Directory Scanning --
    property list<QtObject> resources: [
        Process {
            id: lsProcess
            command: ["ls", "-1", root._gifsPath]
            stdout: StdioCollector {
                onStreamFinished: {
                    const files = text.split("\n")
                        .map(f => f.trim())
                        .filter(f => f.length > 0);
                    
                    // Filter for supported extensions and remove potential quotes from ls output
                    root.gifList = files.map(f => f.replace(/^"|"$/g, '')).filter(f => {
                        const ext = f.split('.').pop().toLowerCase();
                        return ["gif", "webp"].includes(ext);
                    });
                    
                    console.log("GifManager: Found " + root.gifList.length + " GIFs");
                    
                    if (root.hasGifs && root.currentGif === "") {
                        selectRandomGif();
                    }
                }
            }
        },

        Connections {
            target: root.mprisService
            ignoreUnknownSignals: true

            // When track title or artist changes, pick a new GIF
            function onTitleChanged() {
                console.log("GifManager: MprisService.titleChanged detected. Selecting new GIF.");
                selectRandomGif();
            }
            function onArtistChanged() {
                console.log("GifManager: MprisService.artistChanged detected. Selecting new GIF.");
                selectRandomGif();
            }
        }
    ]

    function refresh() {
        lsProcess.running = true;
        console.log("GifManager: Refreshing GIF list.");
    }

    // -- Selection Logic --
    function selectRandomGif() {
        if (!root.hasGifs) {
            console.log("GifManager: No GIFs available to select.");
            root.currentGif = "";
            return;
        }

        let newList = root.gifList;
        let selectedGif = "";

        if (newList.length > 1) {
            // Filter out current GIF to avoid immediate repeats
            newList = newList.filter(f => f !== root.currentGif);
        }

        const randomIndex = Math.floor(Math.random() * newList.length);
        selectedGif = newList[randomIndex];
        
        if (root.currentGif !== selectedGif) {
            root.currentGif = selectedGif;
            console.log("GifManager: New GIF selected: " + selectedGif + " (Path: " + root.currentGifPath + ")");
        } else {
            console.log("GifManager: Selected same GIF again or only one GIF available: " + selectedGif);
        }
    }

    // Returns the full path for the current GIF
    function getGifPath() {
        if (root.currentGif === "") return "";
        return "file://" + root._gifsPath + "/" + root.currentGif;
    }
}
