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
    // The Mpris singleton only exposes the list of *all* connected players --
    // there's no singular "current player" at this layer. We pick the first
    // one as "the" active player for this service. This stays reactive to
    // players connecting/disconnecting because the binding reads
    // Mpris.players.values, which changes whenever the player list does.
    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

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
            function onPlaybackStateChanged() {
                root.position = root.hasPlayer ? Math.round(root.player.position) : 0;
            }

            // Sync when the track changes (title is a good proxy for this)
            function onTrackTitleChanged() {
                root.position = root.hasPlayer ? Math.round(root.player.position) : 0;
            }

            // Sync when the user seeks in the player
            function onPositionChanged() {
                // This signal can be noisy, so we only use it if the difference
                // is significant, to avoid fighting with our own timer.
                const realPosition = root.hasPlayer ? Math.round(root.player.position) : 0;
                if (Math.abs(realPosition - root.position) > 2) {
                    root.position = realPosition;
                }
            }
        }
    ]

    // -- Public API --
    // Expose clean, reactive properties with built-in fallbacks.

    readonly property bool hasPlayer: root.player !== null
    readonly property string playerName: root.player ? root.player.identity : "N/A"
    readonly property string playbackStatus: root.player ? formatPlaybackStatus(root.player.playbackState) : "Stopped"

    readonly property bool canGoPrevious: root.player ? root.player.canGoPrevious : false
    readonly property bool canGoNext: root.player ? root.player.canGoNext : false
    readonly property bool canTogglePlaying: root.player ? root.player.canTogglePlaying : false

    readonly property string title: root.player ? root.player.trackTitle : "NO MEDIA"
    readonly property string artist: root.player && root.player.trackArtist ? root.player.trackArtist : ""
    readonly property string album: root.player ? root.player.trackAlbum : ""

    readonly property int length: root.player ? Math.round(root.player.length) : 0
    property int position: 0 // This is managed by the Timer and sync properties

    readonly property string albumArtUrl: root.player ? root.player.trackArtUrl : ""

    // -- Control API --
    function next() {
        if (root.player && root.canGoNext) {
            root.player.next();
        }
    }

    function previous() {
        if (root.player && root.canGoPrevious) {
            root.player.previous();
        }
    }

    function togglePlaying() {
        if (root.player && root.canTogglePlaying) {
            root.player.togglePlaying();
        }
    }

    // -- Internal Helper Functions --
    function formatPlaybackStatus(state) {
        switch (state) {
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
