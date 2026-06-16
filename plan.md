# Music Widget Implementation Plan

## PHASE 1 - Project Analysis (Completed)

*   **Findings:**
    *   The `MusicWidget/` and `assets/gif/` directories **do not exist** and will need to be created.
    *   `shell.qml` loads modules directly (e.g., `Bar`, `ControlCentre`) and uses `Loader` components (e.g., for `wallpaperSelectorLoader`). `IpcHandler` is used for external control of components.
    *   MPRIS integration already exists via `Quickshell.Services.Mpris`, as evidenced in `lockscreen/MediaCard.qml`. This will be leveraged for media controls.
    *   No explicit "Animation" folder or global animation system currently exists, though `PropertyAnimation` is likely used in various components.

## PHASE 2 - Required Folder Structure (Action: Create missing folders and initial files)

*   **Create:**
    *   `/home/grey/.config/quickshell/Animation/`
    *   `/home/grey/.config/quickshell/MusicWidget/`
    *   `/home/grey/.config/quickshell/assets/gif/`
*   **Initial Files (to be created and then populated in subsequent phases):**
    *   `Animation/AnimationManager.qml`
    *   `Animation/AnimationConfig.qml`
    *   `MusicWidget/MusicWidget.qml`
    *   `MusicWidget/MusicControls.qml`
    *   `MusicWidget/MusicVisualizer.qml`
    *   `MusicWidget/GifSelector.qml` (will handle GIF scanning and selection UI)
    *   `MusicWidget/MusicConfig.qml`
    *   `MusicWidget/Theme.qml`
    *   `MusicWidget/WidgetState.qml` (for pinning state)
    *   `MusicWidget/ArtworkDisplay.qml` (for album art/GIF switching)
    *   `MusicWidget/MusicProgressBar.qml`
    *   `MusicWidget/GifPickerModal.qml`

## PHASE 3 - Global Animation System (Design & Implementation)

*   **Location:** `Animation/AnimationConfig.qml` and `Animation/AnimationManager.qml`.
*   **`AnimationConfig.qml` Responsibilities:**
    *   Define consistent animation durations (e.g., `durationShort: 150`, `durationNormal: 250`, `durationLong: 300`).
    *   Define standard easing curves (e.g., `easingDefault: Easing.OutCubic`, `easingSmooth: Easing.InOutQuad`).
*   **`AnimationManager.qml` Responsibilities:**
    *   Provide reusable `Transition` components (e.g., for opacity, scale, position).
    *   Offer wrapper components for common animation patterns (e.g., `SmoothOpacityAnimator`, `SlideAnimator`).
    *   All animations within the Music Widget (and eventually other parts of the shell) will `import ".." as Animation` and utilize these definitions to ensure consistency.
*   **Implementation Principle:** Utilize `PropertyAnimation` and `NumberAnimation` within `Transition` blocks or `Animator` components, referencing values from `AnimationConfig.qml`.

## PHASE 4 - Theme System (Design & Implementation)

*   **Location:** `MusicWidget/Theme.qml`.
*   **Responsibilities:** Centralize all color definitions specific to the Music Widget.
*   **Color Palette (based on SepiaShell Design Guide, adapted for Music Widget):**
    *   `backgroundColor: "#000000"` (Pure black, as requested)
    *   `accentColorPrimary: "#A67C52"` (Primary Accent from `GEMINI.md`)
    *   `accentColorSecondary: "#C8A77A"` (Secondary Accent from `GEMINI.md`)
    *   `textColor: "#F5E6D3"` (Text from `GEMINI.md`, high contrast for black background)
    *   `mutedTextColor: "#D2B89C"` (Muted Text from `GEMINI.md`)
    *   Other colors as needed, derived from the core palette.
*   **Usage:** All QML files within `MusicWidget/` will `import "Theme.qml" as MusicTheme` and use `MusicTheme.backgroundColor`, `MusicTheme.textColor`, etc.

## PHASE 5 - Music Widget Design (Initial Structure and Positioning)

*   **Main Component:** `MusicWidget/MusicWidget.qml`.
*   **Dimensions:**
    *   `width: 340`
    *   `height: 420`
*   **Positioning in `shell.qml`:**
    *   Instantiate `MusicWidget.qml` in `shell.qml` (likely within a `Loader` for dynamic control).
    *   `anchors.right: parent.right`
    *   `anchors.rightMargin: MusicConfig.marginRight`
    *   `anchors.verticalCenter: parent.verticalCenter`
*   **Layout:** Use a `Column` or `ColumnLayout` within `MusicWidget.qml` to arrange internal components vertically.

## PHASE 6 - Pinning System (Logic and State Management)

*   **State Management:**
    *   Introduce `property bool pinned: false` in `MusicWidget/WidgetState.qml` or directly in `MusicWidget.qml`.
    *   `MusicWidget/WidgetState.qml` will be an `QtObject` that encapsulates the `pinned` state and potentially other widget-level states.
*   **Interaction:**
    *   A `Button` inside `MusicWidget.qml` (or `MusicControls.qml`) will toggle the `pinned` property.
    *   When `pinned` is `false`, a transparent `MouseArea` in `shell.qml` (covering the non-widget area) will detect clicks outside the widget and trigger its `hide()` method.
*   **Persistence:** The `pinned` state will be transient and *not persisted* across reboots, as per requirements.

## PHASE 7 - Open/Close Animation (Integration with Global Animation System)

*   **Implementation:** `PropertyAnimation` on the `x` property of `MusicWidget.qml` (or its containing `Item`).
*   **Show Animation (Slide in from right):**
    *   Initial `x` (when hidden): `ShellRoot.width`
    *   Final `x` (when visible): `ShellRoot.width - MusicWidget.width - MusicConfig.marginRight`
    *   Use easing and duration from `Animation/AnimationConfig.qml`.
*   **Hide Animation (Slide out to right):**
    *   Initial `x` (when visible): Current `x`
    *   Final `x` (when hidden): `ShellRoot.width`
    *   Use easing and duration from `Animation/AnimationConfig.qml`.

## PHASE 8 - Album Art + GIF Mode (UI & Transition)

*   **Location:** `MusicWidget/ArtworkDisplay.qml`.
*   **Mechanism:** Use `SwipeView` or a `States` and `Transitions` approach on an `Item` containing both an `Image` (for album art) and an `AnimatedImage` (for GIF).
*   **Gesture:** A `MouseArea` over the artwork region will handle horizontal drag/flick gestures to switch between states/views.
*   **Transitions:** `PropertyAnimation` for `opacity` and `x` properties during view changes, leveraging `Animation/AnimationManager.qml` for smooth, non-flashing transitions. No geometry changes during the switch.

## PHASE 9 - GIF System (Logic & UI)

*   **Scan GIFs:**
    *   `MusicWidget/GifSelector.qml` will use `Quickshell.Io.DirectoryModel` to list `.gif` files in `assets/gif/`.
    *   This component will expose a list of available GIF paths.
*   **"Switch GIF" Button:** A button in `MusicWidget.qml` (or `MusicControls.qml`) will trigger the opening of `GifPickerModal.qml`.
*   **`MusicWidget/GifPickerModal.qml`:**
    *   Loaded via a `Loader` in `MusicWidget.qml` (or directly as a `Popup`).
    *   **Content:**
        *   `Image` for live preview of selected GIF.
        *   `ComboBox` or `ListView` to display GIF filenames from `GifSelector.qml`.
        *   "Apply" and "Cancel" `Button`s.
    *   **Functionality:** On "Apply," update a property in `MusicWidget.qml` (e.g., `currentGifSource`) with the selected GIF path. The change should be smooth, without widget reload.

## PHASE 10 - Music Visualizer (Research & Implementation)

*   **Location:** `MusicWidget/MusicVisualizer.qml`.
*   **Research Current Shell Capabilities:**
    1.  **Check `Quickshell.Services`:** Look for any existing audio analysis services within `Quickshell`.
    2.  **CAVA Integration:** Search for any QML examples or `Quickshell` modules related to `CAVA` (Console Audio Visualizer for ALSA) integration.
*   **Implementation Strategy (Prioritized):**
    1.  **If `Quickshell.Services` offers audio spectrum data:** Utilize that directly to drive a `Path` or `Repeater` of `Rectangle` elements.
    2.  **If CAVA integration is found:** Adapt existing code or integrate with the CAVA output.
    3.  **Fallback (if no direct audio data):** Implement a subtle, abstract visualizer based on pseudo-random data or driven by the track's progress. This could involve animating a `ShaderEffect` or a `Path` with smooth, low-frequency curves.
*   **Visual Style:** Thin, elegant line graph, subtle animation, blended into the black background. Prioritize smoothness and non-distraction.

## PHASE 11 - Music Controls (UI & MPRIS Integration)

*   **Location:** `MusicWidget/MusicControls.qml`.
*   **UI Components:**
    *   `Image` for album art (if not handled by `ArtworkDisplay`).
    *   `Text` elements for `songTitle`, `artist`, `album`.
    *   `Button`s for `play`, `pause`, `previous`, `next`.
*   **MPRIS Integration:**
    *   `import Quickshell.Services.Mpris` into `MusicControls.qml`.
    *   Access `Mpris.players.values[0]` (assuming one primary player) or iterate through `Mpris.players` if multiple.
    *   **Binding:**
        *   `songTitle.text: player ? player.title : "No Track Playing"`
        *   `artist.text: player ? player.artist : ""`
        *   `album.text: player ? player.album : ""`
        *   `playButton.enabled: player && player.canPlay`
        *   `pauseButton.enabled: player && player.canPause`
        *   `previousButton.enabled: player && player.canGoPrevious`
        *   `nextButton.enabled: player && player.canGoNext`
    *   **Actions:**
        *   `onPlayClicked: player.play()`
        *   `onPauseClicked: player.pause()`
        *   `onPreviousClicked: player.previous()`
        *   `onNextClicked: player.next()`
    *   **Updates:** The `Mpris` service handles automatic updates, ensuring real-time reflection of track changes.

## PHASE 12 - Progress Bar (Custom Component)

*   **Location:** `MusicWidget/MusicProgressBar.qml`.
*   **UI/Logic:**
    *   Use a `Canvas` element or a combination of `Rectangle` and `Path` items.
    *   The "played" section will be a dynamically generated wave pattern.
    *   The "unplayed" section will be a straight line.
*   **Data:**
    *   `player.position` and `player.length` from MPRIS.
*   **Animation:**
    *   A `Timer` or `Connections` to `player.positionChanged` will trigger updates to the wave pattern's extent.
    *   The wave itself can be generated using a mathematical function (e.g., sine wave with variable amplitude) or pre-defined SVG-like path data manipulated by `PropertyAnimation`.
    *   Ensure smooth animation of the wave expanding/shrinking.

## PHASE 13 - Configuration System (Data Storage)

*   **Location:** `MusicWidget/MusicConfig.qml`.
*   **Purpose:** Centralize all configurable parameters for the Music Widget.
*   **Properties:**
    *   `property int widgetWidth: 340`
    *   `property int widgetHeight: 420`
    *   `property int marginRight: 10`
    *   `property string defaultGif: "" ` (or empty)
    *   `property bool visualizerEnabled: true`
    *   `property real defaultOpacity: 1.0`
    *   `property var animationDurations: AnimationConfig.durations` (reference from `AnimationConfig`)
    *   `property var themeColors: MusicTheme.colors` (reference from `MusicWidget/Theme.qml`)
*   **Usage:** Other QML files within `MusicWidget/` will `import "MusicConfig.qml" as Config` to access these values.

## PHASE 14 - Performance Requirements (Guidelines during Implementation)

*   **QML Best Practices:**
    *   Use `Loader` for deferred loading of complex sub-components.
    *   Avoid deep `Item` hierarchies.
    *   Minimize `Binding` loops.
    *   Optimize `Repeater` and `ListView` models.
    *   Prefer `anchors` for layout over explicit `x, y, width, height` for better performance.
    *   Use `opacity` animations for fading over dynamically changing `visible`.
*   **Profiling:** Utilize QML profiling tools to identify and address performance bottlenecks if they arise.
*   **Low Resource Usage:** Aim for efficient updates, especially for the visualizer and progress bar, to maintain low CPU/GPU usage.

## PHASE 15 - Deliverable (Current Output)

## Potential Issues and Solutions

1.  **MPRIS Player Selection:** If multiple MPRIS players are active, which one should the widget control/display?
    *   **Solution:** Initially, focus on `Mpris.players.values[0]` for simplicity. Later, a selection mechanism (e.g., a dropdown) could be added to `MusicConfig.qml` or `MusicControls.qml` to allow the user to choose an active player.
2.  **Visualizer Data Source:** Real-time audio spectrum data is hard to get in QML without specific native integrations.
    *   **Solution:** Start with a simple, subtle, and abstract visualizer (e.g., sine wave) driven by music progress or a generic animation. If needed, investigate platform-specific integrations (Hyprland, Arch Linux, QML plugins) for audio analysis. A "now playing" state could also trigger a subtle pulsating effect on the widget.
3.  **GIF Scanning Performance:** Scanning `assets/gif/` with many large GIFs could cause UI freezes.
    *   **Solution:** Implement GIF scanning in a `WorkerScript` to offload it from the main UI thread. Implement lazy loading or virtual delegates in the `GifPickerModal`'s `ListView` to only load visible GIFs.
4.  **`MusicWidget` in `shell.qml` Placement:** How to ensure it doesn't conflict with other elements (Control Center, Bar)?
    *   **Solution:** Place `MusicWidget` within `shell.qml` with explicit `z` ordering if necessary. Ensure its `anchors` are relative to `ShellRoot` and don't overlap with critical `Bar` or `ControlCentre` areas. The Control Center is on the left, so placing the music widget on the right should naturally avoid conflicts.
5.  **Lack of `assets/gif/` content:** The widget will initially have no GIFs.
    *   **Solution:** Provide a default GIF placeholder within the widget itself, or clearly indicate when no GIFs are found. Instruct the user on where to place their GIFs.

## Final Implementation Roadmap

1.  **Setup:**
    *   Create directories: `Animation`, `MusicWidget`, `assets/gif`.
    *   Create `GEMINI.md` within the new directories if they contain specific guidelines.
2.  **Core Framework:**
    *   Implement `Animation/AnimationConfig.qml` and `Animation/AnimationManager.qml`.
    *   Implement `MusicWidget/Theme.qml`.
    *   Implement `MusicWidget/MusicConfig.qml`.
    *   Create `MusicWidget/WidgetState.qml`.
3.  **Base Widget Structure:**
    *   Create basic `MusicWidget/MusicWidget.qml` with initial size, layout, and placement logic.
    *   Integrate `MusicWidget.qml` into `shell.qml` using a `Loader` and appropriate anchoring.
    *   Implement pinning logic and open/close animations using the `Animation` system.
4.  **Music Controls & MPRIS:**
    *   Create `MusicWidget/MusicControls.qml`.
    *   Implement MPRIS integration (metadata, play/pause/next/prev buttons).
5.  **Progress Bar:**
    *   Create `MusicWidget/MusicProgressBar.qml`.
    *   Implement the custom wave progress bar logic using MPRIS position and length.
6.  **Artwork Display & GIF System:**
    *   Create `MusicWidget/ArtworkDisplay.qml` to handle album art and GIF switching.
    *   Create `MusicWidget/GifSelector.qml` for scanning `assets/gif/`.
    *   Create `MusicWidget/GifPickerModal.qml` for GIF selection UI.
    *   Integrate these components.
7.  **Visualizer:**
    *   Create `MusicWidget/MusicVisualizer.qml`.
    *   Implement a simple, subtle visualizer (fallback first, then explore advanced).
8.  **Refinement & Testing:**
    *   Integrate all sub-components into `MusicWidget.qml`.
    *   Thoroughly test all features: pinning, animations, MPRIS controls, GIF selection, visualizer.
    *   Review for performance and adherence to design principles.
    *   Make a git commit after editing each file as requested.