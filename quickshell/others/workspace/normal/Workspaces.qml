import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 8
    
    Repeater {
        model:[1, 2, 3, 4, 5] // Your 5 persistent workspaces
        
        Rectangle {
            required property int modelData
            width: 30; height: 30; radius: 15
            
            // Get the live workspace object
            property var ws: Hyprland.workspaces.values.find(w => w.id === modelData)
            
            // 1. Is this the one I'm currently on?
            readonly property bool isFocused: Hyprland.focusedWorkspace?.id === modelData
            
            // 2. Does it have windows?
            // "toplevels" actively tracks the windows (toplevels). We check if the array length > 0.
            readonly property bool isOccupied: ws ? ws.toplevels.values.length > 0 : false

            // Dynamic Styling
            color: isFocused ? Colors.green : (isOccupied ? Colors.bg3 : Colors.bg1)
            border.width: isFocused ? 0 : 1
            border.color: isOccupied ? Colors.grey0 : Colors.bg2

            Text {
                anchors.centerIn: parent
                text: modelData
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                font.bold: parent.isFocused
                color: parent.isFocused ? Colors.bg0 : (parent.isOccupied ? Colors.fg : Colors.grey1)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch(`workspace ${modelData}`)
            }
        }
    }
}
