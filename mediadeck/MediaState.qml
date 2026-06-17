import QtQuick

// MediaState.qml
//
// The centralized state machine for the Media Deck. This non-visual component
// is the single source of truth for the deck's current mode (compact, expanded, etc.).
//
// It uses a formal enumeration for states and provides a clean public API
// for transitions, preventing direct state mutation from other components.
// This design is intentionally scalable for future states.
QtObject {
    id: root

    // -- State Definition --
    // Use readonly properties for states to ensure type safety and clear scoping.
    readonly property int stateCompact: 0
    readonly property int stateExpanded: 1
    readonly property int stateSignal: 2    // For future use
    readonly property int stateDiagnostic: 3  // For future use

    // -- Properties --
    // The active state, defaulting to Compact.
    property int currentState: root.stateCompact

    // A read-only convenience alias for easily checking if the deck is in
    // any expanded state.
    readonly property bool isExpanded: root.currentState === root.stateExpanded

    // -- Public API --
    // These functions are the only valid way to transition between states.

    // Transitions the deck to the Expanded state.
    function expand() {
        if (root.currentState !== root.stateExpanded) {
            root.currentState = root.stateExpanded;
        }
    }

    // Transitions the deck to the Compact state.
    function collapse() {
        if (root.currentState !== root.stateCompact) {
            root.currentState = root.stateCompact;
        }
    }

    // Toggles between the Compact and Expanded states.
    function toggleExpanded() {
        if (root.currentState === root.stateCompact) {
            expand();
        } else {
            collapse();
        }
    }
}
