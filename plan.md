# SepiaShell Media Deck — Phase 3 Plan

This document outlines the architecture and implementation plan for Phase 3 of the Media Deck. The focus is on connecting the deck to MPRIS to display real-time media player metadata. This builds upon the state and view management system from Phase 2.

---

## 1. File Structure

A new `services` directory will be created to house background services. For this phase, it will contain the new `MprisService`.

```
quickshell/
├── shell.qml
│
└── mediaDeck/
    ├── MediaDeck.qml         # (Modified) Passes service to views
    ├── MediaState.qml        # (Unchanged)
    ├── PositionStore.qml     # (Unchanged)
    │
    ├── services/             # (New Directory)
    │   └── MprisService.qml  # (New) Handles all MPRIS logic
    │
    └── views/
        ├── CompactView.qml   # (Modified) Displays basic metadata
        └── ExpandedView.qml  # (Modified) Displays detailed metadata
```

---

## 2. Service Architecture (`MprisService.qml`)

`MprisService.qml` will be the central hub for all media-related data. It will be a non-visual `QtObject` that encapsulates all interaction with the low-level MPRIS D-Bus interface, providing a clean and simplified API to the rest of the application.

*   **Technology:** It will use the `Quickshell.Services.Mpris` component, which is the standard, reactive API provided by Quickshell 0.3.0 for this purpose.
*   **Instantiation:** A single instance of `MprisService` will be created in `MediaDeck.qml`. This instance will be passed as a property to the views, allowing them to bind directly to its data.
*   **Exposed Properties:** The service will expose the following reactive properties, with built-in fallbacks for when no player is active:
    *   `hasPlayer` (bool): True if a player is available.
    *   `playerName` (string)
    *   `playbackStatus` (string): e.g., "Playing", "Paused", "Stopped"
    *   `title` (string)
    *   `artist` (string)
    *   `album` (string)
    *   `length` (int): Track length in seconds.
    *   `position` (int): Track position in seconds (live updating).
    *   `albumArtUrl` (string): For future use in Phase X.

---

## 3. Data Flow and Update Strategy

The architecture is designed to be fully reactive, ensuring the UI updates automatically without manual polling.

### Data Flow Diagram

```
 D-Bus (MPRIS)
      |
      V
[ Quickshell.Services.Mpris ]  (Low-level reactive API in Quickshell)
      |
      |  (Binds to Mpris.player)
      V
[ MprisService.qml ]           (Cleans up data, provides fallbacks)
      |
      |  (Service instance passed as property)
      V
[ MediaDeck.qml ]              (Controller)
      |
      +----------------------------+
      | (Passes service to view)   | (Passes service to view)
      V                            V
[ CompactView.qml ]          [ ExpandedView.qml ]
 (Binds to service props)     (Binds to service props)
```

### Update Flow

1.  A property in an MPRIS-compatible player (e.g., Spotify) changes on D-Bus.
2.  The `Quickshell.Services.Mpris` component automatically detects this change.
3.  Properties in `MprisService.qml` are bound directly to the `Mpris.player` object (e.g., `readonly property string title: Mpris.player ? Mpris.player.title : ...`), so they update automatically.
4.  The `Text` elements in `CompactView.qml` and `ExpandedView.qml` are bound to the properties of the `MprisService` instance, so they re-render instantly with the new data.

---

## 4. Player Selection & Multiple Player Handling

*   **Strategy:** We will adopt the default strategy provided by `Quickshell.Services.Mpris`. The `Mpris.player` property automatically points to the most relevant media player. This is typically the one that is currently playing, or the one that most recently had user interaction.
*   **Implementation:** `MprisService.qml` will bind all its properties to this single `Mpris.player` object. When the user switches players (e.g., pauses Spotify and plays a YouTube video in Firefox), `Mpris.player` will change, and the entire UI will reactively update to show the new player's information. This is efficient and requires no manual player management logic.

---

## 5. Position Tracking

Live position tracking will be handled efficiently to minimize CPU usage.

*   **Strategy:** A `Timer` will be placed inside `MprisService.qml`.
*   **Condition:** The `Timer` will only run when `Mpris.player.playbackStatus` is `MprisPlaybackState.Playing`. It will be stopped for any other state (`Paused`, `Stopped`, `null`).
*   **Update:** Every second, the timer's `onTriggered` signal will simply increment a local `position` property within the service. This avoids costly D-Bus calls every second.
*   **Synchronization:** The local `position` will be reset and synchronized with the true `Mpris.player.position` whenever:
    1.  The track changes (`Mpris.player.title` changes).
    2.  The playback state changes (e.g., from `Paused` to `Playing`).
    This hybrid approach gives the illusion of a smooth, real-time counter while being very performant.

---

## 6. Fallback Behavior

The UI must remain clean and stable when no media is playing.

*   **Detection:** The service will determine if a player is active by checking `if (Mpris.player)`.
*   **Implementation:** All exposed properties in `MprisService.qml` will use ternary operators to provide sensible default strings.

    ```qml
    // Example in MprisService.qml
    readonly property bool hasPlayer: Mpris.player !== null
    readonly property string title: hasPlayer ? Mpris.player.title : "NO MEDIA"
    readonly property string artist: hasPlayer ? Mpris.player.artist : ""
    ```
*   **UI Logic:** The views will then use this data. For example, `CompactView` can check `if (service.hasPlayer)` to decide whether to show the "NO MEDIA" text or the track/artist information. This prevents `null` values and ensures the UI never appears broken.

---

## 7. Future Compatibility

This architecture is explicitly designed for future expansion.

*   **Playback Controls:** A future `ControlsView.qml` could be given the same `MprisService` instance. The service could expose control functions (`function play() { Mpris.player.play() }`) that directly call the underlying MPRIS methods.
*   **Album Art:** The `albumArtUrl` property is already included in the service's API. A future `Artwork.qml` component would simply bind its `source` to `service.albumArtUrl`.
*   **Multiple Views:** The `Signal` and `Diagnostic` views can be added to the `MediaDeck` `Loader` and can also be passed the `MprisService` instance if they need access to media data, without any changes to the service itself.

By centralizing all MPRIS logic in `MprisService`, we create a single, reliable source of truth that any other component can consume, making future feature development clean and modular.
