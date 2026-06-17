# SepiaShell Media Deck — Phase 2 Plan

This document outlines the architecture and implementation plan for Phase 2 of the Media Deck. The focus is on creating a foundational state and view management system that is robust, extensible, and directly builds upon the work completed in Phase 1.

---

## 1. File Structure

The project directory will be updated to include the new state management and view files.

```
quickshell/
├── shell.qml
│
└── mediaDeck/
    ├── MediaDeck.qml         # (Modified) Core container and logic hub
    ├── MediaState.qml        # (New) Centralized state machine
    ├── PositionStore.qml     # (Unchanged) Handles position persistence
    │
    └── views/                # (New Directory)
        ├── CompactView.qml   # (New) UI for the compact state
        └── ExpandedView.qml  # (New) UI for the expanded state
```

---

## 2. Component Responsibilities

Each file has a distinct role, ensuring a clean separation of concerns.

*   **`MediaDeck.qml` (Container & Logic Controller)**
    *   Acts as the root component for the entire Media Deck.
    *   Owns and instantiates `MediaState`, `PositionStore`, and the view `Loader`.
    *   Binds its own size (`panelWidth`, `panelHeight`) to properties derived from `MediaState`.
    *   Contains the primary `MouseArea` that manages both dragging (from Phase 1) and the new hover logic for expansion/collapse.
    *   Hosts the `Timer` responsible for the collapse delay.

*   **`MediaState.qml` (State Machine)**
    *   A non-visual `QtObject` that serves as the single source of truth for the deck's current state.
    *   Defines the possible states using an enumeration (`DeckState`).
    *   Exposes the current state (`currentState`) and convenience booleans (`isExpanded`).
    *   Provides public API methods (`expand()`, `collapse()`) for state transitions. This prevents direct state manipulation from other components.

*   **`CompactView.qml` (View)**
    *   A purely visual component displaying the UI for the compact state.
    *   Contains no business logic, state management, or timers.
    *   Receives data via properties if needed in the future, but for Phase 2, it will only contain the required placeholder text.

*   **`ExpandedView.qml` (View)**
    *   A purely visual component displaying the UI for the expanded state.
    *   Like the compact view, it contains no internal logic.
    *   For Phase 2, it will display the placeholder layout (HEADER, CONTENT, FOOTER).

---

## 3. State Management & Flow

We will use a formal state machine pattern within `MediaState.qml` to ensure predictable transitions and prepare for future complexity.

### State Definition (`MediaState.qml`)

An enumeration will define all possible modes for the deck.

```qml
// In MediaState.qml
property int deckState: DeckState.Compact

enum DeckState {
    Compact,
    Expanded,
    Signal,      // For future use
    Diagnostic   // For future use
}
```

### State Flow Diagram

The flow is simple for Phase 2 but establishes the pattern. State transitions are only triggered by calling the public API methods.

```
                  expand()
                 /--------
                /          
[Compact] -----/------------> [Expanded]
        <-----\------------/
         \     collapse()   /
          \                /
           \--------------/
```

### View Loading (`MediaDeck.qml`)

`MediaDeck.qml` will use a `Loader` to dynamically load the correct view based on the state from `MediaState.qml`. This is highly efficient and scalable.

```qml
// In MediaDeck.qml
Loader {
    id: viewLoader
    anchors.fill: parent
    source: {
        switch(MediaState.currentState) {
            case MediaState.DeckState.Expanded:
                return "views/ExpandedView.qml";
            case MediaState.DeckState.Compact:
            default:
                return "views/CompactView.qml";
        }
    }
}
```

The panel's size will be similarly bound:

```qml
// In MediaDeck.qml
property int panelWidth: MediaState.isExpanded ? 520 : 320
property int panelHeight: MediaState.isExpanded ? 260 : 90
```

---

## 4. Hover & Collapse Logic

This logic will be handled entirely within the main `MouseArea` in `MediaDeck.qml` to ensure it can correctly monitor the cursor entering/leaving the entire component.

### Combining Drag & Hover

The existing `MouseArea` for dragging will be modified to also handle hover events.

```qml
// In MediaDeck.qml
MouseArea {
    id: dragArea
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    hoverEnabled: true // <--- NEW

    // ... drag properties (lastMousePos) ...

    onPressed: (mouse) => {
        collapseTimer.stop(); // <--- CRITICAL: Stop collapse on drag start
        // ... existing drag logic ...
    }

    onEntered: {
        MediaState.expand();
        collapseTimer.stop();
    }

    onExited: {
        collapseTimer.start();
    }

    // ... other drag handlers (onPositionChanged, onReleased) ...
}

Timer {
    id: collapseTimer
    interval: 500
    repeat: false
    onTriggered: MediaState.collapse()
}
```

### Hover Flow Diagram

```
[Cursor Enters Deck]
        |
        V
[ Call MediaState.expand() ]
        |
        V
[ Stop Collapse Timer (if running) ]
```

### Collapse Flow Diagram

This flow correctly handles the delay and cancellation.

```
[Cursor Exits Deck]
        |
        V
[ Start 500ms Collapse Timer ]
        |
        +----------------------------------+
        |                                  |
        V                                  V
[ IF Cursor Re-enters Deck ]       [ IF Timer Finishes ]
        |                                  |
        V                                  V
[ Stop Collapse Timer ]            [ Call MediaState.collapse() ]
        |
        V
[ Deck Remains Expanded ]
```

This design ensures that moving the mouse between child elements within a view (e.g., from the header to the content area in `ExpandedView`) will not trigger `onExited` on the main `dragArea`, preventing accidental collapses.

---

## 5. Future Expansion Strategy

The proposed architecture is designed for easy extension without requiring rewrites.

1.  **Add a State:** To add a "Signal" view, we first update the `DeckState` enum in `MediaState.qml`:
    ```qml
    enum DeckState { Compact, Expanded, Signal, Diagnostic }
    ```

2.  **Add a View File:** Create the new `views/SignalView.qml` file containing the UI for that state.

3.  **Update the Loader:** Add a `case` to the `Loader` in `MediaDeck.qml`:
    ```qml
    // In MediaDeck.qml's Loader
    case MediaState.DeckState.Signal:
        return "views/SignalView.qml";
    ```

4.  **Update Sizing:** Update the size bindings in `MediaDeck.qml` to account for the new state's dimensions.

5.  **Add Transition Logic:** Add a new public function to `MediaState.qml` (e.g., `showSignalView()`) to handle the transition into the new state. The trigger for this (e.g., a keybind, a button click) would be implemented in a later phase, but the state management foundation is already in place.

This approach isolates each view's UI and keeps the core `MediaDeck` component clean, acting as a simple controller.
