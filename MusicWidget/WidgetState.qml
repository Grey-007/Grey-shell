pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Controls whether the music widget remains visible or hides when not active
    property bool pinned: false
}
