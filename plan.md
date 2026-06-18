# Phase 6 Plan — Signal View and Background Waveform Architecture

This plan outlines the implementation of a background waveform rendering system and a new "Signal View" for the SepiaShell Media Deck. The core philosophy is to treat the waveform as an integral part of the deck's hardware display, not a separate widget.

## 1. File Structure

The following files will be created or modified to implement the new architecture:

```text
quickshell/
└── mediadeck/
    ├── MediaDeck.qml           (MODIFIED)
    ├── MediaState.qml          (MODIFIED)
    │
    ├── services/
    │   ├── MprisService.qml    (MODIFIED)
    │   └── FakeAudioSource.qml (NEW)
    │
    ├── components/
    │   └── WaveformLayer.qml   (NEW)
    │
    └── views/
        ├── ExpandedView.qml    (MODIFIED)
        └── SignalView.qml      (NEW)
```

## 2. Rendering Layer Hierarchy

The waveform will be rendered as a background layer. The stacking order within views will be managed using `z-ordering`:

-   **`z: 4`**: Text (Track, Artist, etc.)
-   **`z: 3`**: Controls & Progress Bar
-   **`z: 2`**: GIF Panel
-   **`z: 1`**: `WaveformLayer.qml`
-   **`z: 0`**: Main Deck Background

This ensures the waveform is always visible behind all other content, creating a sense of depth.

## 3. WaveformLayer.qml Architecture

This new component is responsible for rendering the waveform.

-   **`Canvas` Rendering**: It will use a `Canvas` element to draw the waveform paths. The `onPaint` handler will be optimized to only redraw when necessary.
-   **Dual Channel**: It will accept two data arrays, `leftChannelData` and `rightChannelData`, and render them as two distinct waveform traces (top and bottom).
-   **Properties**:
    -   `property var audioSource`: The data source to use (e.g., `FakeAudioSource`).
    -   `property real opacity`: Controls the visibility of the waveform.
    -   `property bool active`: Determines if the waveform should be animating.
-   **Animation**: A `Timer` will trigger the `Canvas` to redraw and create an animated, scrolling effect when `active` is `true`.

## 4. Fake Audio Data (`FakeAudioSource.qml`)

To ensure future compatibility, the data source will be a pluggable component.

-   **Generation**: This service will use a `Timer` to generate arrays of numbers (representing layered sine waves) at a regular interval (e.g., 60 times per second).
-   **API**: It will expose `readonly property var leftChannelData` and `readonly property var rightChannelData` that `WaveformLayer` can bind to.
-   **Pluggability**: In the future, this component can be replaced by a real audio service (CAVA, PipeWire, etc.) that exposes data in the same format, requiring no changes to the UI.

## 5. View Switching & Signal View Architecture

-   **`MediaState.qml`**: A new state, `stateSignal`, will be added. A `toggleSignalView()` function will be implemented to switch between `stateExpanded` and `stateSignal`.
-   **`MediaDeck.qml`**: The `Loader` will be updated to load `views/SignalView.qml` when `mediaState` is `stateSignal`.
-   **`SignalView.qml`**: This new view will:
    -   Contain a `WaveformLayer` with high opacity (e.g., `0.8`).
    -   Display essential metadata (Track, Artist) and new placeholder metadata (Codec, Bitrate, Latency) overlaid on top of the waveform.
    -   It will *not* contain the `GifPanel`, `MediaControls`, or `ProgressBar`.
-   **`MprisService.qml`**: Placeholder properties will be added for the new metadata fields (`codec: "FLAC"`, `bitrate: "1024kbps"`, `latency: "5ms"`).

## 6. Expanded View Integration

`ExpandedView.qml` will be modified to include the waveform as a subtle background element.

-   A `WaveformLayer` instance will be added with `z: -1` (or the lowest z-order).
-   Its `opacity` will be bound to a low value (e.g., `0.25`).
-   Its `active` property will be bound to `mprisService.playbackStatus === "Playing"`, making it animate only during playback and disappear completely when paused or stopped.

## 7. Performance & Future Integration

-   **`Canvas` Efficiency**: Using `Canvas` is highly efficient for this type of custom drawing.
-   **Decoupled Logic**: The data source (`FakeAudioSource`) is completely decoupled from the rendering (`WaveformLayer`), which is in turn decoupled from the views (`ExpandedView`, `SignalView`). This modularity is key for future maintenance and for integrating a real audio source in Phase 7.
-   **Throttled Updates**: The timers in `FakeAudioSource` and `WaveformLayer` will be configured for smooth animation without excessive CPU usage.

This architecture provides a robust, visually appealing, and future-proof foundation for the new Signal View and background waveform effects.
