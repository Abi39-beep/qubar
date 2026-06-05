import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "./meth/"

ShellRoot {
    PanelWindow {
        anchors.top: true
        width: 700
        height: 28
        color: "transparent"
        WlrLayershell.namespace: "simp"
        WlrLayershell.layer: WlrLayer.Top

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colors.bg0, 0.95)
            bottomLeftRadius: 8
            bottomRightRadius: 8

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                Clock {}
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                // 1. Wrap everything in a Rectangle to create the outer background pill
                Rectangle {
                    color: Colors.bg0
                    height: 18
                    radius: height / 2 // Keeps the outer container perfectly pill-shaped

                    // This creates the padding! It adds 6px to all sides of the inner Row.
                    implicitWidth: workspaceRow.implicitWidth + 12
                    implicitHeight: workspaceRow.implicitHeight + 12

                    Row {
                        id: workspaceRow
                        anchors.centerIn: parent // Centers the workspaces inside the padding
                        spacing: 5

                        Repeater {
                            model: [1, 2, 3, 4, 5] // 5 persistent empty workspaces

                            Rectangle {
                                required property int modelData

                                // Get the live workspace object
                                property var ws: Hyprland.workspaces.values.find(w => w.id === modelData)

                                // 1. Is this the one I'm currently on?
                                readonly property bool isFocused: Hyprland.focusedWorkspace?.id === modelData

                                // 2. Does it have windows?
                                readonly property bool isOccupied: ws ? ws.toplevels.values.length > 0 : false

                                // Width expands to 50 if active, otherwise stays 25 (creates a circle/dot)
                                width: isFocused ? 38 : 18
                                height: 10
                                radius: height / 2 // Automatically perfectly rounds the corners

                                // Add a smooth animation when the width expands/shrinks
                                Behavior on width {
                                    NumberAnimation {
                                        duration: 250
                                        easing.type: Easing.OutExpo
                                    }
                                }

                                // Dynamic Styling for the empty pills
                                color: isFocused ? Colors.aqua : (isOccupied ? Colors.bg3 : Colors.bg1)
                                border.width: isFocused ? 0 : 1
                                border.color: isOccupied ? Colors.grey0 : Colors.bg2

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = "${modelData}"})`)
                                }
                            }
                        }
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                WifiWidget {}
                BluetoothWidget {}
                Battery {}
                DashboardWidget {}
            }
        }
        OsdWindow {}
    }
}
