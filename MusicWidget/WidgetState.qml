pragma Singleton
import QtQuick

QtObject {
    id: widgetState

    // Controls whether the music widget remains visible or hides when not active
    property bool pinned: false

    // Other widget-specific states can be added here
}