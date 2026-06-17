import QtQuick
import Quickshell.Services.Mpris

// MprisService.qml
//
// This service is the single source of truth for all media player information.
// It wraps the low-level Quickshell.Services.Mpris component to provide a clean,
// simplified, and robust API for the UI. It handles fallback behavior and
// formats the data for consumption.
QtObject {
    id: root

    // -- Low-level MPRIS Service --
    // The Mpris component is a singleton provided by the Quickshell module.
    // We access it directly, but create a local alias for stability.
    readonly property var player: Mpris.player

    // -- Internal Resources --
    // A QtObject doesn't have a default property, so non-visual child
    // components must be grouped into a list property.
    property list<QtObject> resources: [
        QtObject { id: dummyTarget }, // Dummy target for Connections when player is null

        // -- Live Position Tracking --
        Timer {
            id: positionTracker
            interval: 1000
            repeat: true
            running: root.hasPlayer && root.playbackStatus === "Playing"
            onTriggered: {
                if (root.position < root.length) {
                    root.position++;
                }
            }
        },

        // -- Synchronization Logic --
        Connections {
            target: root.player ? root.player : dummyTarget
            ignoreUnknownSignals: true

            // Sync when the playback status changes (e.g., user pauses/resumes)
            function onPlaybackStatusChanged() {
                root.position = root.hasPlayer ? Math.round(root.player.position / 1000000) : 0;
            }

            // Sync when the track changes (title is a good proxy for this)
            function onTitleChanged() {
                root.position = root.hasPlayer ? Math.round(root.player.position / 1000000) : 0;
            }

            // Sync when the user seeks in the player
            function onPositionChanged() {
                // This signal can be noisy, so we only use it if the difference
                // is significant, to avoid fighting with our own timer.
                const realPosition = root.hasPlayer ? Math.round(root.player.position / 1000000) : 0;
                if (Math.abs(realPosition - root.position) > 2) {
                    root.position = realPosition;
                }
            }
        }
    ]

    // -- Public API --
    // Expose clean, reactive properties with built-in fallbacks.

    readonly property bool hasPlayer: root.player !== null
    readonly property string playerName: root.player ? root.player.name : "N/A"
    readonly property string playbackStatus: root.player ? formatPlaybackStatus(root.player.playbackStatus) : "Stopped"

    readonly property string title: root.player ? root.player.title : "NO MEDIA"
    readonly property string artist: root.player && root.player.artist ? root.player.artist : ""
    readonly property string album: root.player ? root.player.album : ""

    readonly property int length: root.player ? Math.round(root.player.length / 1000000) : 0
    property int position: 0 // This is managed by the Timer and sync properties

    readonly property string albumArtUrl: root.player ? root.player.albumArtUrl : ""

    // -- Internal Helper Functions --
    function formatPlaybackStatus(status) {
        switch (status) {
            case MprisPlaybackState.Playing:
                return "Playing";
            case MprisPlaybackState.Paused:
                return "Paused";
            case MprisPlaybackState.Stopped:
            default:
                return "Stopped";
        }
    }
}
