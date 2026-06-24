import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../colors"
import "../Models"

ColumnLayout {
    id: root
    
    property string title: ""
    property string description: ""
    default property alias content: contentArea.data

    property bool matchesSearch: {
        var q = SettingsManager.searchQuery.toLowerCase();
        if (q === "") return true;
        return title.toLowerCase().indexOf(q) !== -1 || description.toLowerCase().indexOf(q) !== -1;
    }

    visible: matchesSearch
    spacing: 8
    Layout.fillWidth: true

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        
        Text {
            text: root.title
            color: ThemeManager.fg
            font.pixelSize: 14
            font.family: "monospace"
            font.weight: Font.DemiBold
        }
        
        Text {
            text: root.description
            color: ThemeManager.fgMid
            font.pixelSize: 12
            font.family: "monospace"
            visible: text !== ""
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: contentArea.implicitHeight + 24
        color: ThemeManager.surfaceHigh
        border.color: ThemeManager.border
        border.width: 1
        
        ColumnLayout {
            id: contentArea
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
        }
    }
}
