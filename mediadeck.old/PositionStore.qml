import QtQuick
import Quickshell
import Quickshell.Io

// PositionStore.qml
//
// Minimal persistence service for the Media Deck's on-screen position.
// It wraps a single JSON file with two integers (x, y) so MediaDeck.qml
// never has to know how or where the value is actually stored.
//
// Public contract (kept deliberately small so this is easy to expand later
// into a shared, multi-key position/settings service):
//   in:  defaultX, defaultY  -- used only before anything has been saved
//   out: x, y                -- current position (read-only)
//        save(x, y)          -- the only way to change/persist the position
QtObject {
    id: root

    // Fallback coordinates used the first time the panel ever runs, before
    // any position has been saved to disk.
    property int defaultX: 40
    property int defaultY: 70

    // Current position. Exposed as read-only aliases straight into the
    // JSON adapter below, so they're always in sync with what's on disk
    // (or about to be). External code changes the position via save(),
    // never by assigning x/y directly -- that keeps the in-memory value
    // and the on-disk value from ever drifting apart.
    readonly property alias x: adapter.x
    readonly property alias y: adapter.y

    function save(newX, newY) {
        adapter.x = Math.round(newX);
        adapter.y = Math.round(newY);
    }

    // The FileView + JsonAdapter pair is Quickshell's own pattern for
    // binding a JSON file to QML properties with automatic read/write.
    property FileView _file: FileView {
        id: fileView

        // A flat filename in the shell's state directory -- deliberately
        // not nested in a sub-folder, since we don't depend on FileView
        // creating intermediate directories on first run.
        path: Quickshell.statePath("mediadeck-position.json")

        printErrors: false

        // Whenever the adapter's data changes (via save(), or because the
        // file changed on disk) write the current state back out.
        onAdapterUpdated: writeAdapter()

        // First run: the file doesn't exist yet. Fall back to the provided
        // defaults and write them out so the file exists for next time.
        onLoadFailed: function (error) {
            adapter.x = root.defaultX;
            adapter.y = root.defaultY;
            writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property int x: root.defaultX
            property int y: root.defaultY
        }
    }
}
