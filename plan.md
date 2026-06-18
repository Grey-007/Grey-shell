# Phase 7 Plan — Real Audio Visualization

This plan details the architecture for replacing the `FakeAudioSource` with a real-time audio data source using the native capabilities of the Quickshell environment.

## 1. Backend Comparison & Recommendation

To capture system-wide audio for visualization, two primary backends were evaluated:

1.  **CAVA (Console-based Audio Visualizer for ALSA)**:
    *   **Pros**: A dedicated and lightweight visualizer.
    *   **Cons**: Requires running a separate process, parsing its `stdout`, and managing it as an external dependency. This is less robust and less integrated than a native solution.

2.  **PipeWire**:
    *   **Pros**: The modern standard for audio on Linux, especially in Wayland environments. It allows for direct, low-level access to audio streams. Crucially, the Quickshell documentation includes a **`Quickshell.Services.Pipewire`** module, indicating this is the officially supported and intended method for audio integration.
    *   **Cons**: None, given the native module support.

**Recommendation**: The clear choice is to use the **`Quickshell.Services.Pipewire`** module. It promises the best performance, stability, and integration, and avoids adding external application dependencies.

## 2. Architecture Diagram

The new data flow will be as follows:

```
[System Audio (PipeWire Server)]
        ↓
[Quickshell.Services.Pipewire Module (e.g., Stream object)]
        ↓
[RealAudioSource.qml (Processes raw data)]
        ↓ (Exposes leftChannelData & rightChannelData)
[WaveformLayer.qml (Binds to RealAudioSource)]
        ↓
[Canvas (Draws the waveform)]
```

This architecture replaces `FakeAudioSource.qml` with `RealAudioSource.qml` without requiring any changes to the UI components (`WaveformLayer`, `ExpandedView`, `SignalView`).

## 3. File Structure & Implementation Details

-   **`mediadeck/services/FakeAudioSource.qml` (REMOVED)**
-   **`mediadeck/services/RealAudioSource.qml` (NEW)**:
    -   This service will be the new heart of the visualization.
    -   It will import `Quickshell.Services.Pipewire`.
    -   It will instantiate a PipeWire stream/monitor component to capture the default audio output.
    -   It will contain the logic to process the raw data from PipeWire (e.g., a `Float32Array`) and downsample or average it into the `leftChannelData` and `rightChannelData` arrays that `WaveformLayer` expects.
    -   It will expose `readonly property bool hasSignal` which will be `true` if PipeWire is connected and providing data, and `false` otherwise.

-   **`mediadeck/MediaDeck.qml` (MODIFIED)**:
    -   The `FakeAudioSource` instance will be replaced with a `RealAudioSource` instance.
    -   The `fakeAudioSource` property passed to the views will now point to the new `RealAudioSource` instance.

-   **`WaveformLayer.qml` (MODIFIED)**:
    -   The `active` property will be updated to bind to `audioSource.hasSignal` in addition to the player's playback status, ensuring it only runs when there is a real signal. `active: mprisService.playbackStatus === "Playing" && audioSource && audioSource.hasSignal`

## 4. Update Flow & Performance

-   **Event-Driven**: The system will be event-driven. The `Pipewire` module will likely emit a signal whenever a new audio buffer is ready.
-   **No QML Timers**: `RealAudioSource.qml` will connect to this signal to process data. This is far more efficient than using a QML `Timer` to poll for data, as it ensures the UI updates are perfectly in sync with the audio buffer rate and do not run unnecessarily.
-   **Minimal JS Processing**: The JavaScript in `RealAudioSource.qml` will only be responsible for light data transformation (e.g., averaging a large buffer into 256 points), keeping its performance footprint low. The heavy lifting of audio capture is handled by the native C++ backend of the PipeWire module.

## 5. Error Handling & Fallback Behavior

-   **Backend Unavailable**: `RealAudioSource.qml` will listen for connection error signals from the `Pipewire` module. If the backend is not available (PipeWire not running), it will set `hasSignal = false`.
-   **Graceful Degradation**: When `hasSignal` is `false`, the `WaveformLayer`'s `active` property will become `false`. This will cause the waveform to disappear cleanly from both `ExpandedView` and `SignalView`, fulfilling the "no frozen frames" requirement. The rest of the Media Deck will continue to function normally.
-   **Audio Source Changes**: PipeWire handles audio source switching at the system level. `RealAudioSource` will monitor the default sink, so it should automatically reflect whatever application is currently playing audio without any special handling.

This plan provides a robust, performant, and natively integrated solution for real-time audio visualization, adhering to the project's architecture and future compatibility goals.
