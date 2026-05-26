import QtQuick
import Quickshell.Hyprland
import ".."

// 1. Wrap everything in a Rectangle to create the outer background pill
Rectangle {
    // You can change Colors.bg0 to whichever color matches the dark background in your image
    color: Colors.bg0
    height: 28
    radius: height / 2 // Keeps the outer container perfectly pill-shaped

    // This creates the padding! It adds 6px to all sides of the inner Row.
    implicitWidth: workspaceRow.implicitWidth + 12
    implicitHeight: workspaceRow.implicitHeight + 12

    Row {
        id: workspaceRow
        anchors.centerIn: parent // Centers the workspaces inside the padding
        spacing: 5

        Repeater {
            model: [1, 2, 3, 4, 5] // Your 5 persistent workspaces

            Rectangle {
                required property int modelData

                // Get the live workspace object
                property var ws: Hyprland.workspaces.values.find(w => w.id === modelData)

                // 1. Is this the one I'm currently on?
                readonly property bool isFocused: Hyprland.focusedWorkspace?.id === modelData

                // 2. Does it have windows?
                readonly property bool isOccupied: ws ? ws.toplevels.values.length > 0 : false

                // STYLING CHANGE: Make width expand to 60 if active, otherwise 30
                width: isFocused ? 50 : 19
                height: 19
                radius: 15

                // STYLING CHANGE: Add a smooth animation when the width expands/shrinks
                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutExpo
                    }
                }

                // Dynamic Styling (Kept your original logic)
                color: isFocused ? Colors.green : (isOccupied ? Colors.bg3 : Colors.bg1)
                border.width: isFocused ? 0 : 1
                border.color: isOccupied ? Colors.grey0 : Colors.bg2

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                    font.bold: parent.isFocused
                    color: parent.isFocused ? Colors.bg0 : (parent.isOccupied ? Colors.fg : Colors.grey1)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = "${modelData}"})`)
                }
            }
        }
    }
}
